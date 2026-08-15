# Stow packages & layout

Each top-level directory is a Stow package; `make install` symlinks its contents into `$HOME` preserving the relative path.

## Layout by target

- Home-rooted → `~/`:
  - `zsh/.zshrc`
  - `git/.gitconfig`
  - `bash/.bashrc`
- XDG → `~/.config/...`:
  - `aerospace/.config/aerospace/...`
  - `tmux/.config/tmux/...`
  - `nvim/.config/nvim` (submodule — see below)
  - `opencode/.config/opencode/...`

## Add a tool

1. Create a new top-level dir mirroring the target path (e.g. `foo/.config/foo/config.toml`).
2. `make install` to stow it into `$HOME`.
3. `make list` to verify it's included.

`README.md`'s install section describes an older bare-repo workflow and is stale; the Makefile is the source of truth.

## Submodules

Init after clone with `git clone --recurse-submodules` or `git submodule update --init`:

- `nvim/.config/nvim` → `git@github.com:baohuamap/nvim-config.git` (SSH, a **separate repo**). Edit Neovim config **there**, not here.
- `fzf-git.sh/.config/fzf-git.sh` → junegunn/fzf-git.sh.