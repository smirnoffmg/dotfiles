# Login shells only. Session-scoped setup and anything too slow for .zshenv.

# /etc/zprofile ran path_helper after .zshenv and pushed our toolchains below
# the system paths — re-apply to restore precedence.
if [[ -r "$ZDOTDIR/path.zsh" ]]; then
  _ZSH_PATH_REBUILD=1 source "$ZDOTDIR/path.zsh"
  unset _ZSH_PATH_REBUILD
fi

# java_home costs ~100ms, so it stays out of .zshenv and is skipped when a
# parent shell already paid for it
if [[ -z $JAVA_HOME ]]; then
  export JAVA_HOME="$(/usr/libexec/java_home -v 11 2>/dev/null)"
  [[ -z $JAVA_HOME && -d $HOMEBREW_PREFIX/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home ]] &&
    export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home"
  [[ -n $JAVA_HOME ]] && path=($JAVA_HOME/bin $path)
fi

if [[ -n "$ALACRITTY_SOCKET" ]] && [[ -z "$TMUX" ]]; then
  tmux attach 2>/dev/null || exec tmux new-session
fi
