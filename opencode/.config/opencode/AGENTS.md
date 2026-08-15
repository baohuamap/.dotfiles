# AGENTS.md

Preferences for every project on this machine.

## Style

- Be extremely concise. Sacrifice grammar for the sake of concision.
- Be direct, no preamble or postamble. Answer the question; don't restate it.
- No emojis. No code comments unless asked.
- Reference code as `file_path:line_number`.
- Edit existing files; don't create new ones unless needed.
- Act on clear tasks. Ask only before destructive or ambiguous changes.

## Environment

- macOS on Apple Silicon. Homebrew at `/opt/homebrew`.
- Shell is zsh (`/bin/zsh`). Quote paths with spaces.

## Git

- Primary branch is `main`. Commits are GPG-signed by default.
- Flow: feature branch -> change -> add -> commit -> push -> PR -> ask for review.

## MCP

- **Context7** — fetch current library/framework/SDK docs before answering about API syntax, config, version migration, setup, or CLI usage. Start with `resolve-library-id`, then `query-docs` scoped to one concept per call. Skip for refactoring, business logic, or general concepts.
- **Grep.app** — search code across all public GitHub repos for usage patterns or examples outside the current repo.
