# Interactive shells only. PATH lives in path.zsh, environment in .zshenv.

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

# Everything below relies on the compinit that oh-my-zsh runs above.

# --- Version managers ---
# Shims are already on PATH from path.zsh; these add only the shell functions
# and completions, which a non-interactive shell has no use for.
# rbenv first, so pyenv's shims end up ahead of it.
eval "$(rbenv init - --no-rehash zsh)"
eval "$(pyenv init - --no-rehash)"
eval "$(pyenv virtualenv-init - --no-rehash)"

# --- FZF ---
source <(fzf --zsh)

# --- NVM ---
# Eager on purpose: lazy wrappers never fire in Claude Code subagent shells,
# which are then left without node. NVM_DIR comes from path.zsh, which already
# put the default version's bin on PATH for non-interactive shells.
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# --- Yandex Cloud CLI ---
[[ -f "$HOME/yandex-cloud/completion.zsh.inc" ]] && source "$HOME/yandex-cloud/completion.zsh.inc"

# --- Aliases ---
alias n="nvim"
alias dc="docker compose"
alias pa="poetry add"
alias ll="eza --all --header --long --icons"

# --- Powerlevel10k ---
source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"
[[ -f "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"

# --- Machine-local overrides (gitignored) ---
# Aliases, functions, work-specific completions. Last, so it can override
# anything above it.
[[ -f "$ZDOTDIR/.zshrc.local" ]] && source "$ZDOTDIR/.zshrc.local"
