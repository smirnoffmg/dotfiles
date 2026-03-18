# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# rbenv
eval "$(rbenv init - --no-rehash zsh)"

# Java (cached — doesn't change between shells)
export JAVA_HOME=$(/usr/libexec/java_home -v 11 2>/dev/null || echo "/opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk")
export PATH="$JAVA_HOME/bin:$PATH"

if [[ -n "$ALACRITTY_SOCKET" ]] && [[ -z "$TMUX" ]]; then
  tmux attach 2>/dev/null || exec tmux new-session
fi
