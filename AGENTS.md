# AGENTS.md

Personal dotfiles for **macOS**, managed with **GNU Stow**. This is not a software project — there is no build, test, lint, typecheck, or codegen. "Deploy" = symlinking config files into `$HOME`.

## Primary commands

- `make install` — stow every top-level package into `$HOME`. The main setup step.
- `make clean` — unstow (remove symlinks).
- `make list` — show packages that will be stowed.
- `./install` — thin wrapper that just runs `make install`.

Requires **GNU Stow** (`brew install stow`); `make check-stow` verifies it.

## Package layout

Each top-level directory is a Stow package; its contents symlink into `$HOME` preserving the relative path:

- Home-rooted: `zsh/.zshrc`, `git/.gitconfig`, `bash/.bashrc` → `~/`.
- XDG: `aerospace/.config/aerospace/...`, `tmux/.config/tmux/...`, `nvim/.config/nvim`, `opencode/.config/opencode/...` → `~/.config/...`.

To add a tool, create a new top-level dir mirroring the target path, then `make install`.

## Submodules (init after clone)

Run `git clone --recurse-submodules` or `git submodule update --init`:

- `nvim/.config/nvim` → `git@github.com:baohuamap/nvim-config.git` (SSH, a **separate repo**). Edit Neovim config **there**, not here.
- `fzf-git.sh/.config/fzf-git.sh` → junegunn/fzf-git.sh.

## Commit constraints

- The stowed `git/.gitconfig` is the **global** `~/.gitconfig`. It sets `commit.gpgsign = true` and `tag.gpgSign = true` — `git commit`/`tag` **require working GPG signing** or they fail.
- This repo's primary branch is **`main`** (the global `init.defaultBranch = master` only affects brand-new repos).
- No PR/CI flow here — direct commits to `main`, GPG-signed.

## Local-only (untracked) env files

`zsh/.zshenv` and `bash/.bashenv` are **gitignored** and never committed (they're stowed to `~/.zshenv`/`~/.bashenv`, but only exist locally). Do **not** put config meant to be shared into `.zshenv`/`.bashenv` — edits there are local-only and won't be version-controlled. Shared shell config goes in `.zshrc` / `.bashrc`.

## Configs are machine-specific (not portable)

Several files hardcode absolute paths and won't transfer clean to another machine/user. Don't "fix" them to be portable unless asked:

- `zsh/.zshrc` sources theme/plugins from `/opt/homebrew/share/...`, a manual `~/plugins/git/git.plugin.zsh`, a catppuccin syntax file at `~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh`, and prepends `/Users/baohua/.opencode/bin` to `PATH`.
- `zsh/.zprofile` loads Homebrew + OrbStack; `zsh/.zshenv` (local) loads nvm/cargo/pyenv/postgres.

## opencode config

`opencode/.config/opencode/` holds `opencode.jsonc`, `tui.json` (theme `catppuccin-macchiato`), `themes/`, and `commands/` (the Matt Pocock skills slash-commands). `node_modules/` under it is **generated and gitignored** — don't commit it.

## macOS window-manager stack

- `aerospace/` — tiling WM (`aerospace.toml`).
- `borders/` — window borders; **active** (launched by aerospace's `after-startup-command`).
- `sketchybar/` — Lua status bar. Its launch is **intentionally commented out** in `aerospace.toml` (disabled while using aerospace). The bar has **C helpers compiled via `make`** in `helpers/` and `helpers/event_providers/{cpu_load,network_load}/`.

## README install steps are stale

`README.md` describes an older bare-repo workflow (`git clone --bare ... $HOME/.dotfiles`). The actual mechanism is a **normal repo + Stow via the Makefile** (`make install`). Trust the Makefile, not the README's install section.

## Secrets

`.gitignore` drops `*secret*`, `*credential*`, `*.env`, `*secret*`. Never add secrets, credentials, or local env files to the repo.

## Agent skills

### Issue tracker
Issues are tracked as GitHub issues in this repo (via the `gh` CLI). See `docs/agents/issue-tracker.md`.

### Triage labels
Five canonical labels kept as-is: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs
Single-context — one `CONTEXT.md` at the repo root and `docs/adr/`. See `docs/agents/domain.md`. (Neither exists yet; they're created lazily by the modeling skills.)