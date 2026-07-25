# Runs for EVERY zsh: interactive, scripts, cron, launchd.
# Keep to what a non-interactive shell genuinely needs.

# Bootstrap: tell zsh where to find all config files
export ZDOTDIR="$HOME/.config/zsh"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Guarded: an unguarded source here would print an error from every zsh on the
# system, including the non-interactive ones whose output other tools parse.
[ -r "$ZDOTDIR/path.zsh" ] && . "$ZDOTDIR/path.zsh"

# Machine-local secrets — gitignored, absent on a fresh clone
[ -f "$ZDOTDIR/.zshenv.local" ] && . "$ZDOTDIR/.zshenv.local"

return 0
