# AGENTS.md

Personal dotfiles for **macOS**, deployed with **GNU Stow**: each top-level directory stows (symlinks) its contents into `$HOME`. "Deploy" = running the Makefile, not building software.

## Deploy

Requires **GNU Stow** (`brew install stow`).

- `make install` — stow every top-level package into `$HOME`.
- `make clean` — unstow.
- `make list` — show packages that will be stowed.

`README.md`'s install section is stale (older bare-repo workflow) — trust the Makefile.

## Stow packages

Each top-level directory is a Stow package stowing its contents into `$HOME` preserving the relative path — home-rooted files land in `~/`, `.config/...` paths land in `~/.config/...`. Add a tool by mirroring the target path in a new top-level dir, then `make install`. Layout examples, submodules (incl. the separate neovim repo), and add-a-tool steps: [docs/stow-and-packages.md](docs/stow-and-packages.md).

## Verification

No repo-wide build, test, lint, or typecheck exists. The one build is the **sketchybar C helpers** — see [docs/window-manager.md](docs/window-manager.md). Re-run `make install` after editing a Stow package to redeploy.

## Commits

- Commits/tags require **working GPG signing** — the stowed `git/.gitconfig` sets `commit.gpgsign`/`tag.gpgSign`; the primary branch is **`main`**, no PR/CI flow (direct signed commits). Details: [docs/git-and-commits.md](docs/git-and-commits.md).
- Never commit secrets, credentials, or local env files. `zsh/.zshenv` and `bash/.bashenv` are gitignored — shared shell config lives in `.zshrc`/`.bashrc`, never `.zshenv`/`.bashenv`.

## Machine-specific (don't port unless asked)

Several configs hardcode absolute paths (`/opt/homebrew/...`, `/Users/baohua/...`, `~/.opencode/bin`). Don't "fix" portability unless asked. Per-package details: [docs/package-specific.md](docs/package-specific.md).

## Tool-specific internals

- Window-manager stack (aerospace/borders/sketchybar) and its C build: [docs/window-manager.md](docs/window-manager.md).
- opencode config layout (`opencode/.config/opencode/`): [docs/package-specific.md](docs/package-specific.md).
- neovim config is a **separate submodule repo** — edit it there, not here: [docs/stow-and-packages.md](docs/stow-and-packages.md).

## Agent skills integration

Issues, triage labels, and domain docs live under `docs/agents/`:

- Issues — GitHub issues via `gh`: [docs/agents/issue-tracker.md](docs/agents/issue-tracker.md).
- Triage labels — five canonical labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`): [docs/agents/triage-labels.md](docs/agents/triage-labels.md).
- Domain docs — one `CONTEXT.md` at the repo root and `docs/adr/` (lazy-created by the modeling skills): [docs/agents/domain.md](docs/agents/domain.md).