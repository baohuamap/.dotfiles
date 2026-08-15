# Package-specific internals

## opencode config (`opencode/.config/opencode/`)

Holds `opencode.jsonc`, `tui.json` (theme `catppuccin-macchiato`), `themes/`, and `commands/` (the Matt Pocock skills slash-commands). `node_modules/` under it is **generated and gitignored** — don't commit it.

## zsh non-portable paths

Several zsh files hardcode absolute paths and won't transfer to another machine/user. Don't "fix" them to be portable unless asked:

- `zsh/.zshrc` sources theme/plugins from `/opt/homebrew/share/...`, a manual `~/plugins/git/git.plugin.zsh`, a catppuccin syntax file at `~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh`, and prepends `/Users/baohua/.opencode/bin` to `PATH`.
- `zsh/.zprofile` loads Homebrew + OrbStack.