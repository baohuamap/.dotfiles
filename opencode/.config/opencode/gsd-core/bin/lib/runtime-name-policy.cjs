"use strict";
/**
 * Runtime name policy — alias resolution and canonicalization for GSD runtime
 * identifiers (ADR-457 build-at-publish: the hand-written
 * bin/lib/runtime-name-policy.cjs collapsed to a TypeScript source of truth).
 * Behaviour is preserved byte-for-behaviour from the prior hand-written .cjs;
 * only types are added.
 *
 * Group C cross-import candidate: no bin/lib sibling dependencies; only
 * node:fs and node:path. Once this module is migrated, runtime-slash.cjs
 * (which imports runtime-name-policy.cjs) becomes the first true cross-import
 * proof candidate.
 */
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.canonicalizeRuntimeName = canonicalizeRuntimeName;
exports.resolveRuntimeNameFromCandidates = resolveRuntimeNameFromCandidates;
const node_fs_1 = __importDefault(require("node:fs"));
const node_path_1 = __importDefault(require("node:path"));
const FALLBACK_ALIASES = {
    claude: ['claude', 'claude-code', 'claude-cli'],
    opencode: ['opencode', 'open-code', 'opencode-cli'],
    kilo: ['kilo', 'kilo-cli'],
    gemini: ['gemini', 'gemini-cli', 'gemini-code'],
    codex: ['codex', 'codex-app', 'codex-cli', 'codex_desktop', 'codex-desktop'],
    copilot: ['copilot', 'copilot-cli', 'github-copilot'],
    antigravity: ['antigravity', 'antigravity-cli', 'antigravity-agent'],
    cursor: ['cursor', 'cursor-cli', 'cursor-nightly'],
    windsurf: ['windsurf', 'windsurf-cli', 'windsurf-next', 'devin-desktop'],
    augment: ['augment', 'augment-code', 'augment-cli'],
    trae: ['trae', 'trae-cli'],
    qwen: ['qwen', 'qwen-code', 'qwen-cli'],
    hermes: ['hermes', 'hermes-agent', 'hermes-cli'],
    kimi: ['kimi'],
    codebuddy: ['codebuddy', 'codebuddy-cli'],
    cline: ['cline', 'cline-cli'],
};
function normalizeRuntimeToken(value) {
    return String(value).trim().toLowerCase().replace(/[_\s]+/g, '-');
}
function loadAliasManifest() {
    const manifestCandidates = [
        node_path_1.default.resolve(__dirname, '..', 'shared', 'runtime-aliases.manifest.json'),
        node_path_1.default.resolve(__dirname, '../../../sdk/shared/runtime-aliases.manifest.json'),
    ];
    for (const manifestPath of manifestCandidates) {
        try {
            const parsed = JSON.parse(node_fs_1.default.readFileSync(manifestPath, 'utf8'));
            if (parsed && typeof parsed === 'object')
                return parsed;
        }
        catch {
            // Try next candidate.
        }
    }
    return { ...FALLBACK_ALIASES };
}
const aliasManifest = loadAliasManifest();
const aliasToCanonical = new Map();
for (const [canonical, aliases] of Object.entries(aliasManifest)) {
    if (typeof canonical !== 'string' || !Array.isArray(aliases))
        continue;
    aliasToCanonical.set(normalizeRuntimeToken(canonical), normalizeRuntimeToken(canonical));
    for (const alias of aliases) {
        if (typeof alias !== 'string')
            continue;
        aliasToCanonical.set(normalizeRuntimeToken(alias), normalizeRuntimeToken(canonical));
    }
}
function canonicalizeRuntimeName(value) {
    if (typeof value !== 'string')
        return null;
    return aliasToCanonical.get(normalizeRuntimeToken(value)) || null;
}
/**
 * Resolve runtime from a precedence list of candidate values.
 *
 * - First non-empty string candidate wins.
 * - Known aliases are canonicalized (codex-cli -> codex).
 * - Unknown values are normalized and returned (future-runtime tolerance).
 *
 * @param candidates - string candidates in precedence order
 * @returns the resolved runtime name, or null if no valid candidate
 */
function resolveRuntimeNameFromCandidates(...candidates) {
    for (const candidate of candidates) {
        if (typeof candidate !== 'string')
            continue;
        const normalized = normalizeRuntimeToken(candidate);
        if (!normalized)
            continue;
        return canonicalizeRuntimeName(normalized) || normalized;
    }
    return null;
}
