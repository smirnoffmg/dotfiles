# Single source of truth for PATH. Sourced twice on purpose:
#   .zshenv   — so non-login shells (scripts, cron, launchd) get a usable PATH
#   .zprofile — because /etc/zprofile runs path_helper *after* .zshenv and demotes
#               everything here below the system paths
# Builds at most once per process tree. A child shell already inherits a correct
# PATH, and rebuilding there would stomp on whatever the parent deliberately put
# in front — an activated virtualenv, direnv, a CI runner. .zprofile is the one
# exception: it sets _ZSH_PATH_REBUILD because /etc/zprofile runs path_helper
# after .zshenv. To force a rebuild by hand:
#   _ZSH_PATH_REBUILD=1 source ~/.config/zsh/path.zsh
if [[ -n $_ZSH_PATH_SET && -z $_ZSH_PATH_REBUILD ]]; then
  return 0
fi

# `typeset -U` makes re-sourcing idempotent: prepending an existing entry moves
# it back to the front instead of duplicating it. PATH/FPATH must be named
# alongside path/fpath, or writes through the scalar (as `rbenv init` does)
# bypass the uniqueness check.

typeset -U path PATH fpath FPATH

# System base: /etc/paths + /etc/paths.d. Not run for non-login shells otherwise,
# since macOS ships no /etc/zshenv — without this, scripts lack /usr/sbin and /sbin.
[[ -x /usr/libexec/path_helper ]] && eval "$(/usr/libexec/path_helper -s)"

# Homebrew. First match wins: Apple Silicon, Intel, Linuxbrew.
for _brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
  if [[ -x $_brew_prefix/bin/brew ]]; then
    export HOMEBREW_PREFIX=$_brew_prefix
    export HOMEBREW_CELLAR=$_brew_prefix/Cellar
    # Intel macOS and Linuxbrew keep the repo in a subdirectory; Apple Silicon
    # does not. Probing beats hardcoding which prefix implies which layout.
    if [[ -d $_brew_prefix/Homebrew ]]; then
      export HOMEBREW_REPOSITORY=$_brew_prefix/Homebrew
    else
      export HOMEBREW_REPOSITORY=$_brew_prefix
    fi
    fpath=($_brew_prefix/share/zsh/site-functions $fpath)
    break
  fi
done
unset _brew_prefix

export GOPATH="$HOME/go"
export PYENV_ROOT="$HOME/.pyenv"
export RBENV_ROOT="$HOME/.rbenv"
export NVM_DIR="$HOME/.nvm"

# nvm.sh is far too slow to source here, so resolve the default version's bin
# directory by hand — otherwise scripts and cron jobs get no node at all.
# `alias/default` holds whatever `nvm alias default` was given ("22", "v22.17.1",
# "lts/jod"), so match it as a prefix and take the highest version installed.
# Interactive shells still source nvm.sh in .zshrc, which wins by re-prepending.
_nvm_bin=()
if [[ -r $NVM_DIR/alias/default ]]; then
  _nvm_default=$(<$NVM_DIR/alias/default)
  _nvm_bin=($NVM_DIR/versions/node/v${_nvm_default#v}*/bin(Nn[-1]))
  unset _nvm_default
fi

# Ordered highest priority first.
#
# Version managers outrank Homebrew: brew also ships python3/pip3/pre-commit,
# ruby/gem/bundle and cargo/rustc (28, 14 and 11 colliding names). Letting those
# win would mean `pyenv global` or `rustup default` silently does nothing.
#
# Homebrew is the primary source of everything else, so it outranks the plain
# user directories below it. `:+` keeps these out when no brew was found —
# otherwise an empty prefix would expand to a bare /bin near the top of PATH.
#
# yc ships its own path.bash.inc, deliberately not sourced: it prepends to the
# front, which would put yc above Homebrew and the version managers.
_path_pre=(
  $_nvm_bin
  $PYENV_ROOT/bin
  $PYENV_ROOT/shims
  $RBENV_ROOT/bin
  $RBENV_ROOT/shims
  $HOME/.cargo/bin
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin}
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin}
  $HOME/.local/bin
  $HOME/yandex-cloud/bin
)
_path_post=(
  $GOPATH/bin
)

# (N-/) drops entries missing on this machine. Applied only to our own additions —
# system paths from path_helper stay untouched, since Apple creates some of them
# (the cryptex bootstrap dirs) lazily.
# `$^array` is required: without it the glob qualifier applies to the last
# element only, and missing directories survive in PATH.
path=($^_path_pre(N-/) $path $^_path_post(N-/))
unset _path_pre _path_post _nvm_bin

# Machine-local PATH additions (gitignored) — corporate tooling and the like.
# Sourced after the order above is settled, so it can place entries wherever it
# needs by manipulating $path directly, e.g.
#   path=($HOME/corp/bin $path)
[[ -r "$ZDOTDIR/path.zsh.local" ]] && source "$ZDOTDIR/path.zsh.local"

export _ZSH_PATH_SET=1
