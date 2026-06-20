"use strict";
/**
 * Project-Root Resolution Module — resolves a project root from a starting
 * directory by walking the ancestor chain and applying four heuristics:
 *   (0) own .planning/ guard (#1362)
 *   (1) parent .planning/config.json sub_repos
 *   (2) legacy multiRepo: true + ancestor .git
 *   (3) .git heuristic with parent .planning/
 * Bounded by FIND_PROJECT_ROOT_MAX_DEPTH ancestors. Sync I/O.
 *
 * ADR-457 build-at-publish: the hand-written bin/lib/project-root.cjs
 * collapsed to a TypeScript source of truth. Behaviour is preserved
 * byte-for-behaviour from the prior hand-written .cjs; only types are added.
 */
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.findProjectRoot = findProjectRoot;
const node_fs_1 = __importDefault(require("node:fs"));
const node_path_1 = __importDefault(require("node:path"));
const node_os_1 = __importDefault(require("node:os"));
const FIND_PROJECT_ROOT_MAX_DEPTH = 10;
function findProjectRoot(startDir) {
    let resolvedStart;
    try {
        resolvedStart = node_path_1.default.resolve(startDir);
    }
    catch {
        return startDir;
    }
    const fsRoot = node_path_1.default.parse(resolvedStart).root;
    const home = node_os_1.default.homedir();
    // If startDir already contains .planning/, it IS the project root.
    try {
        const ownPlanningDir = resolvedStart + node_path_1.default.sep + '.planning';
        if (node_fs_1.default.existsSync(ownPlanningDir) && node_fs_1.default.statSync(ownPlanningDir).isDirectory()) {
            return startDir;
        }
    }
    catch {
        // fall through
    }
    // Walk upward, mirroring isInsideGitRepo from the CJS reference.
    function isInsideGitRepo(candidateParent) {
        let d = resolvedStart;
        while (d !== fsRoot) {
            try {
                if (node_fs_1.default.existsSync(d + node_path_1.default.sep + '.git'))
                    return true;
            }
            catch {
                // ignore
            }
            if (d === candidateParent)
                break;
            const next = node_path_1.default.dirname(d);
            if (next === d)
                break;
            d = next;
        }
        return false;
    }
    let dir = resolvedStart;
    let depth = 0;
    while (dir !== fsRoot && depth < FIND_PROJECT_ROOT_MAX_DEPTH) {
        const parent = node_path_1.default.dirname(dir);
        if (parent === dir)
            break;
        if (parent === home)
            break;
        const parentPlanning = parent + node_path_1.default.sep + '.planning';
        let parentPlanningIsDir = false;
        try {
            parentPlanningIsDir = node_fs_1.default.existsSync(parentPlanning) && node_fs_1.default.statSync(parentPlanning).isDirectory();
        }
        catch {
            parentPlanningIsDir = false;
        }
        if (parentPlanningIsDir) {
            const configPath = parentPlanning + node_path_1.default.sep + 'config.json';
            let matched = false;
            try {
                const raw = node_fs_1.default.readFileSync(configPath, 'utf-8');
                const config = JSON.parse(raw);
                if (config && typeof config === 'object') {
                    const cfg = config;
                    const subReposValue = cfg['sub_repos'] ??
                        (cfg['planning'] && typeof cfg['planning'] === 'object'
                            ? cfg['planning']['sub_repos']
                            : undefined);
                    const subRepos = Array.isArray(subReposValue) ? subReposValue : [];
                    if (subRepos.length > 0) {
                        const relPath = node_path_1.default.relative(parent, resolvedStart);
                        const topSegment = relPath.split(node_path_1.default.sep)[0];
                        if (subRepos.includes(topSegment)) {
                            return parent;
                        }
                    }
                    if (cfg['multiRepo'] === true && isInsideGitRepo(parent)) {
                        matched = true;
                    }
                }
            }
            catch {
                // config.json missing or unparseable — fall through to .git heuristic.
            }
            if (matched)
                return parent;
            // Heuristic: parent has .planning/ and we're inside a git repo.
            if (isInsideGitRepo(parent)) {
                return parent;
            }
        }
        dir = parent;
        depth += 1;
    }
    return startDir;
}
