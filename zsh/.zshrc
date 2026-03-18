# Powerlevel10k instant prompt — must stay at the top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # disabled — p10k loaded below
zstyle ':omz:update' mode auto
plugins=(git zsh-autosuggestions)
source "$ZSH/oh-my-zsh.sh"

# --- Pyenv ---
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - --no-rehash)"
eval "$(pyenv virtualenv-init - --no-rehash)"

# --- FZF ---
source <(fzf --zsh)

# --- NVM (lazy-loaded) ---
export NVM_DIR="$HOME/.nvm"
nvm()  { unset -f nvm node npm npx; [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"; nvm "$@"; }
node() { nvm use default >/dev/null 2>&1; unset -f node; node "$@"; }
npm()  { nvm use default >/dev/null 2>&1; unset -f npm;  npm "$@"; }
npx()  { nvm use default >/dev/null 2>&1; unset -f npx;  npx "$@"; }

# --- Go ---
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# --- Aliases ---
alias n="nvim"
alias dc="docker compose"
alias pa="poetry add"
alias ll="eza --all --header --long $eza_params --icons"

# --- Powerlevel10k ---
source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"
[[ -f "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"

# --- Misc ---
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
