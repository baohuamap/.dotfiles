"use strict";
/**
 * Planning Workspace — .planning path resolution + active workstream routing.
 *
 * This module owns the planning workspace seam:
 * - planningDir/planningRoot/planningPaths
 * - planning lock semantics
 *
 * Active workstream pointer policy/session identity lives in
 * active-workstream-store.cjs and is consumed here via thin adapters.
 *
 * ADR-457 build-at-publish: the hand-written bin/lib/planning-workspace.cjs collapsed
 * to a TypeScript source of truth. Behaviour is preserved byte-for-behaviour from
 * the prior hand-written .cjs; only types are added.
 */
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
const node_fs_1 = __importDefault(require("node:fs"));
const node_path_1 = __importDefault(require("node:path"));
const shell_command_projection_cjs_1 = require("./shell-command-projection.cjs");
const clock_cjs_1 = require("./clock.cjs");
// eslint-disable-next-line @typescript-eslint/no-require-imports
const activeWorkstreamStore = require("./active-workstream-store.cjs");
const { createSharedPointerAdapter, createSessionScopedPointerAdapter, createMemoryPointerAdapter, getActiveWorkstream: getStoredActiveWorkstream, setActiveWorkstream: setStoredActiveWorkstream, clearActiveWorkstream: clearStoredActiveWorkstream, } = activeWorkstreamStore;
// Track .planning/.lock files held by this process so they can be removed on exit.
const _heldPlanningLocks = new Set();
process.on('exit', () => {
    for (const lockPath of _heldPlanningLocks) {
        try {
            node_fs_1.default.unlinkSync(lockPath);
        }
        catch { /* already gone */ }
    }
});
// Transient errno codes that indicate a temporary filesystem condition under
// concurrent O_EXCL races — Docker overlay-fs (ENOENT/EINVAL/EIO), NFS
// (ESTALE), and OS-level interrupt/retry signals (EAGAIN/EINTR).  These are
// recoverable; withPlanningLock retries instead of propagating them.
// Truly fatal codes (EMFILE, ENOSPC, EROFS, EACCES) are NOT in this set and
// will still throw immediately.
const PLANNING_LOCK_RETRY_ERRNOS = new Set([
    'EPERM', // Windows / macOS AV scanner holds the file open during delete
    'EBUSY', // Windows: file in use by another process
    'EAGAIN', // POSIX: resource temporarily unavailable
    'EINTR', // POSIX: syscall interrupted by signal
    'EINVAL', // Docker overlay-fs: transient during concurrent O_EXCL creation
    'EIO', // Docker overlay-fs / NFS: transient I/O error
    'ENOENT', // Docker overlay-fs: parent dir transiently missing during race
    'ESTALE', // NFS: stale file handle (self-resolves on retry)
]);
function planningDir(cwd, ws, project) {
    if (project === undefined)
        project = process.env['GSD_PROJECT'] ?? null;
    if (ws === undefined)
        ws = process.env['GSD_WORKSTREAM'] ?? null;
    // Reject path separators and traversal components in project/workstream names
    const BAD_SEGMENT = /[/\\]|\.\./;
    if (project && BAD_SEGMENT.test(project)) {
        throw new Error(`GSD_PROJECT contains invalid path characters: ${project}`);
    }
    if (ws && BAD_SEGMENT.test(ws)) {
        throw new Error(`GSD_WORKSTREAM contains invalid path characters: ${ws}`);
    }
    let base = node_path_1.default.join(cwd, '.planning');
    if (project)
        base = node_path_1.default.join(base, project);
    if (ws)
        base = node_path_1.default.join(base, 'workstreams', ws);
    return base;
}
function planningRoot(cwd) {
    return node_path_1.default.join(cwd, '.planning');
}
function planningPaths(cwd, ws) {
    const base = planningDir(cwd, ws);
    return {
        planning: base,
        state: node_path_1.default.join(base, 'STATE.md'),
        roadmap: node_path_1.default.join(base, 'ROADMAP.md'),
        project: node_path_1.default.join(base, 'PROJECT.md'),
        config: node_path_1.default.join(base, 'config.json'),
        phases: node_path_1.default.join(base, 'phases'),
        requirements: node_path_1.default.join(base, 'REQUIREMENTS.md'),
    };
}
/**
 * @param cwd
 * @param fn - callback to run while holding the lock
 * @param clock
 *   Optional clock seam for testing. Defaults to realClock (Date.now + Atomics.wait).
 *   Pass a fake clock from tests/helpers/clock.cjs to drive timeout/stale logic
 *   without real wall-clock waits.
 */
function withPlanningLock(cwd, fn, clock) {
    if (clock === undefined)
        clock = clock_cjs_1.realClock;
    const lockPath = node_path_1.default.join(planningDir(cwd), '.lock');
    const lockTimeout = 10000; // 10 seconds
    const start = clock.now();
    // Ensure .planning/ exists
    try {
        (0, shell_command_projection_cjs_1.platformEnsureDir)(planningDir(cwd));
    }
    catch { /* ok */ }
    function acquireLock() {
        // Atomic create — fails if file exists
        node_fs_1.default.writeFileSync(lockPath, JSON.stringify({
            pid: process.pid,
            cwd,
            acquired: new Date().toISOString(),
        }), { flag: 'wx' });
        _heldPlanningLocks.add(lockPath);
    }
    function runWithHeldLock() {
        try {
            return fn();
        }
        finally {
            _heldPlanningLocks.delete(lockPath);
            try {
                node_fs_1.default.unlinkSync(lockPath);
            }
            catch { /* already released */ }
        }
    }
    while (clock.now() - start < lockTimeout) {
        let lockWasAcquired = false;
        try {
            acquireLock();
            lockWasAcquired = true;
            return runWithHeldLock();
        }
        catch (err) {
            // Transient filesystem errors (Docker overlay-fs, NFS, OS signals, AV scanners)
            // are recoverable — wait and retry rather than propagating.
            // See PLANNING_LOCK_RETRY_ERRNOS for the full list and rationale.
            if (lockWasAcquired)
                throw err;
            const nodeErr = err;
            if (PLANNING_LOCK_RETRY_ERRNOS.has(nodeErr.code ?? '')) {
                clock.sleep(100);
                continue;
            }
            if (nodeErr.code === 'EEXIST') {
                // Lock exists — check if stale (>30s old)
                try {
                    const stat = node_fs_1.default.statSync(lockPath);
                    if (clock.now() - stat.mtimeMs > 30000) {
                        node_fs_1.default.unlinkSync(lockPath);
                        continue; // retry
                    }
                }
                catch {
                    continue;
                }
                // Wait and retry (cross-platform, no shell dependency)
                clock.sleep(100);
                continue;
            }
            throw err;
        }
    }
    // Timeout — stale-lock recovery, then re-acquire atomically before entering critical section.
    try {
        node_fs_1.default.unlinkSync(lockPath);
    }
    catch { /* ok */ }
    acquireLock();
    return runWithHeldLock();
}
function createPlanningWorkspace(cwd, opts = {}) {
    return {
        paths: {
            dir(ws, project) {
                return planningDir(cwd, ws, project);
            },
            root() {
                return planningRoot(cwd);
            },
            all(ws) {
                return planningPaths(cwd, ws);
            },
        },
        activeWorkstream: {
            get() {
                return getStoredActiveWorkstream(cwd, opts);
            },
            set(name) {
                setStoredActiveWorkstream(cwd, name, opts);
            },
            clear() {
                clearStoredActiveWorkstream(cwd, opts);
            },
        },
    };
}
function getActiveWorkstream(cwd) {
    return getStoredActiveWorkstream(cwd);
}
function setActiveWorkstream(cwd, name) {
    setStoredActiveWorkstream(cwd, name);
}
/**
 * Locate the CONTEXT.md file in a phase directory, handling both the bare
 * form (`CONTEXT.md`) and the padded-prefix convention (`NN-CONTEXT.md`,
 * `NN.N-CONTEXT.md`, etc.) used by gsd-discuss-phase output.
 *
 * Returns the filename (not the full path) of the first match, or null if
 * no CONTEXT.md exists in the directory.
 *
 * Canonical dual-form predicate extracted here to eliminate the 5-site
 * duplication that previously existed across init.cjs, roadmap.cjs,
 * core.cjs, gap-checker.cjs (#3739).
 *
 * @param absDirOrFiles - Absolute path to the phase directory,
 *   OR an already-read files array (avoids a redundant readdirSync at call sites
 *   that already hold a directory listing).
 */
function findContextMdIn(absDirOrFiles) {
    try {
        const files = Array.isArray(absDirOrFiles)
            ? absDirOrFiles
            : node_fs_1.default.readdirSync(absDirOrFiles);
        if (files.includes('CONTEXT.md'))
            return 'CONTEXT.md';
        return files.find((f) => f.endsWith('-CONTEXT.md')) ?? null;
    }
    catch {
        return null;
    }
}
module.exports = {
    createPlanningWorkspace,
    createSharedPointerAdapter,
    createSessionScopedPointerAdapter,
    createMemoryPointerAdapter,
    planningDir,
    planningRoot,
    planningPaths,
    withPlanningLock,
    getActiveWorkstream,
    setActiveWorkstream,
    findContextMdIn,
};
