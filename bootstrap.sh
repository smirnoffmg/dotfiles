#!/usr/bin/env zsh
# First-time setup for a fresh macOS machine. Idempotent — every step checks
# state before acting, so re-running after a failure is safe.
#
#   git clone <repo> ~/.config && ~/.config/bootstrap.sh
#
# What it installs, and why it looks the way it does:
#   - version managers via brew, toolchains via the managers themselves
#     (pyenv python, rbenv ruby, nvm node, rustup) — path.zsh puts the
#     managers above brew, so a brew python/ruby/rust would be dead weight
#   - pre-commit + detect-secrets into the pyenv python: the commit hooks
#     resolve pre-commit through the pyenv shim
#   - oh-my-zsh / zsh-autosuggestions / powerlevel10k at the exact paths
#     .zshrc sources them from
#   - ~/.zshenv symlink — the single activation point for the whole zsh chain

emulate -L zsh
set -e -o pipefail

REPO=${0:A:h}
NODE_VERSION=22
PYTHON_SERIES=3.12
NVM_VERSION=v0.40.3
# The zsh framework layer has no lockfile of its own, so pin it here — this is
# the only record of which versions the live machine actually runs. After a
# deliberate `omz update` (auto-update is disabled in .zshrc), refresh with:
#   git -C ~/.oh-my-zsh rev-parse HEAD
OMZ_REF=b37dd49ca5bfe0d99b35607637152cb8cc8b29d7
AUTOSUGGESTIONS_REF=c3d4e576c9c86eac62884bd47c01f6faed043fc5
P10K_REF=62341054d8aa40ade03fc55bdbc95b9ff2d8d2b6

step() { print -r -- $'\n'"==> $1" }
have() { command -v $1 >/dev/null 2>&1 }

# Shallow-fetch an exact commit — GitHub allows fetching arbitrary shas, and
# `clone --depth=1` can only pin branches/tags.
clone_pinned() {  # <url> <dest> <sha>
  [[ -d $2 ]] && return 0
  git init -q "$2"
  git -C "$2" fetch -q --depth=1 "$1" "$3"
  git -C "$2" checkout -q --detach FETCH_HEAD
}

if [[ $OSTYPE != darwin* ]]; then
  print -ru2 -- "bootstrap.sh targets macOS; on Linux install the equivalents by hand"
  exit 1
fi

# path.zsh, ZDOTDIR and every config path assume this exact location.
if [[ ${REPO:A} != ${HOME:A}/.config ]]; then
  print -ru2 -- "repo must live at ~/.config, found: $REPO"
  exit 1
fi

step "Homebrew"
if ! have brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
for _p in /opt/homebrew /usr/local; do
  [[ -x $_p/bin/brew ]] && { eval "$($_p/bin/brew shellenv)"; break }
done
have brew || { print -ru2 -- "brew still not on PATH after install"; exit 1 }

step "Brew packages"
# Per package, so one renamed/discontinued formula doesn't abort the whole run —
# this script's next execution may be on a machine that needs everything else.
_failed=()
for _pkg in neovim tmux fzf eza gh go pyenv pyenv-virtualenv rbenv tree-sitter-cli stylua; do
  brew install "$_pkg" || _failed+=("$_pkg")
done
for _pkg in alacritty font-fira-code-nerd-font font-jetbrains-mono; do
  brew install --cask "$_pkg" || _failed+=("$_pkg")
done
if (( $#_failed )); then
  print -ru2 -- "brew could not install: $_failed — continuing, doctor.sh will show the damage"
fi

step "Alacritty font smoothing (read at process start, not from config)"
defaults write org.alacritty AppleFontSmoothing -int 0

step "Rust (rustup, not brew rust — brew's would shadow rustup default)"
if [[ ! -x $HOME/.cargo/bin/cargo ]]; then
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs \
    | sh -s -- -y --no-modify-path
fi

step "Python $PYTHON_SERIES via pyenv"
export PYENV_ROOT="$HOME/.pyenv"
pyenv install --skip-existing "$PYTHON_SERIES"
pyenv global "$(pyenv latest "$PYTHON_SERIES")"

step "pre-commit + detect-secrets into the pyenv python"
"$PYENV_ROOT/shims/pip" install --quiet --upgrade pre-commit detect-secrets
pyenv rehash

step "Ruby via rbenv (compiles from source — the slow step)"
if [[ -z $(rbenv versions --bare 2>/dev/null) ]]; then
  _ruby=$(rbenv install -l 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)
  rbenv install "$_ruby"
  rbenv global "$_ruby"
fi

step "Node $NODE_VERSION via nvm"
export NVM_DIR="$HOME/.nvm"
if [[ ! -s $NVM_DIR/nvm.sh ]]; then
  # PROFILE=/dev/null keeps the installer from appending to rc files —
  # .zshrc already sources nvm.sh itself.
  PROFILE=/dev/null bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh)"
fi
source "$NVM_DIR/nvm.sh" --no-use
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"

step "oh-my-zsh, zsh-autosuggestions, powerlevel10k (pinned)"
clone_pinned https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" "$OMZ_REF"
clone_pinned https://github.com/zsh-users/zsh-autosuggestions \
  "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" "$AUTOSUGGESTIONS_REF"
clone_pinned https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k" "$P10K_REF"

step "Activate zsh config: ~/.zshenv → repo"
_link=$HOME/.zshenv _target=$REPO/zsh/.zshenv
if [[ ! -L $_link || ${_link:A} != ${_target:A} ]]; then
  [[ -e $_link && ! -L $_link ]] && mv "$_link" "$_link.pre-bootstrap"
  ln -sfn "$_target" "$_link"
fi

step "tmux plugins (git submodules)"
git -C "$REPO" submodule update --init --recursive

step "Commit hooks"
(cd "$REPO" && "$PYENV_ROOT/shims/pre-commit" install)

step "Neovim plugins from lazy-lock.json"
nvim --headless "+Lazy! restore" +qa

step "Verify"
zsh "$REPO/doctor.sh"

print -r -- $'\n'"Done. Open a new terminal (or tmux pane) to pick up the fresh environment."
