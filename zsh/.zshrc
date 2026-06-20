export LANG=en_US.UTF-8
export XDG_CONFIG_HOME=$HOME/.config

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git )

[[ -f ~/plugins/git/git.plugin.zsh ]] && source ~/plugins/git/git.plugin.zsh

[[ -f ~/.zsh_alias ]] && source ~/.zsh_alias
[[ -f ~/.zprofile ]] && source ~/.zprofile
[[ -f ~/.env ]] && source ~/.env
[[ -f ~/.zshenv ]] && source ~/.zshenv

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=100000
HISTSIZE=1999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
setopt hist_ignore_space
setopt hist_find_no_dups

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---- wezterm -----

export WEZTERM_CONFIG_DIR="$XDG_CONFIG_HOME/wezterm"

# ---- eza -----

export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza/"

# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

source ~/.config/fzf-git.sh/fzf-git.sh

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}


# thefuck alias
eval $(thefuck --alias)
eval $(thefuck --alias fk)


# zoxide

eval "$(zoxide init zsh)"

# dxpy
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

unset ZSH_AUTOSUGGEST_USE_ASYNC

# Usage: vault_file my_data.tar.gz
vault_file() {
    local input_file=$1
    local pub_key="$HOME/.ssh/bhua.pub" # Path to your RSA public key

[[ ! -f "$input_file" ]] && { echo "Error: File not found."; return 1; }

    local tmp_key=$(openssl rand -base64 32)

    # Use PBKDF2 and 100k iterations
    openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -in "$input_file" -out "${input_file}.enc" -pass pass:"$tmp_key"

    echo -n "$tmp_key" | openssl pkeyutl -encrypt -pubin -inkey "$pub_key" -out "${input_file}.key.enc"

    sudo chown root:wheel "${input_file}.enc" "${input_file}.key.enc"
    sudo chmod 600 "${input_file}.enc" "${input_file}.key.enc"
    echo "Vaulted with PBKDF2 protection."
    rm $input_file
}

# Usage: unvault_file secret.zip.enc secret.key.enc
unvault_file() {
    local encrypted_file=$1
    local encrypted_key=$2
    local private_key="$HOME/.ssh/bhua.pem"
    local decrypted_key=$(sudo openssl pkeyutl -decrypt -inkey "$private_key" -in "$encrypted_key")

    # Match the PBKDF2 and iteration count exactly
    sudo openssl enc -d -aes-256-cbc -salt -pbkdf2 -iter 100000 -in "$encrypted_file" -out "${encrypted_file%.enc}.dec" -pass pass:"$decrypted_key"
}

# opencode
export PATH=/Users/baohua/.opencode/bin:$PATH
