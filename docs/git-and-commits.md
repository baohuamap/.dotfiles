# Git, commits & secrets

## Signing

The stowed `git/.gitconfig` is the **global** `~/.gitconfig`. It sets `commit.gpgsign = true` and `tag.gpgSign = true`, so `git commit` / `git tag` **require working GPG signing** or they fail. Fix GPG before committing; don't work around it (`--no-gpg-sign`, etc.).

## Branch & flow

- This repo's primary branch is **`main`**. (The global `init.defaultBranch = master` only affects brand-new repos.)
- No PR/CI flow — direct, GPG-signed commits to `main`.

## Never commit

`.gitignore` drops `*.env`, `*.env*`, `*secret*`, `*credential*`, `.zshenv`, `.bashenv`. In particular:

- **Secrets, credentials, local env files** — never add them.
- **`zsh/.zshenv` and `bash/.bashenv`** are gitignored and exist only locally. Put shared shell config in `.zshrc` / `.bashrc` — never in `.zshenv` / `.bashenv`.