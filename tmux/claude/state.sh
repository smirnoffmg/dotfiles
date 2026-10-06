#!/usr/bin/env bash
[ -t 0 ] || cat >/dev/null
pane=$TMUX_PANE
[ -n "$pane" ] || exit 0

t() { tmux "$@" 2>/dev/null; }
put() { t set -p -t "$pane" @claude_state "$1" \; set -w -t "$pane" @claude_win_state "$1"; }
seen_now() { [ "$(t display -p -t "$pane" '#{&&:#{window_active},#{session_attached}}')" = 1 ]; }

cur=$(t show -pqv -t "$pane" @claude_state)
case $1 in
idle | working) put "$1" ;;
tool) case $cur in waiting | idle) put working ;; esac ;;
waiting) [ "$cur" = working ] && { if seen_now; then put idle; else put waiting; fi; } ;;
done) if seen_now; then put idle; else put "done"; fi ;;
end) t set -pu -t "$pane" @claude_state \; set -wu -t "$pane" @claude_win_state ;;
seen)
  w=$(t show -wqv -t "$pane" @claude_win_state)
  while read -r p s; do
    case $s in done | waiting) t set -p -t "$p" @claude_state idle ;; working) w=working ;; esac
  done < <(t list-panes -t "$pane" -F '#{pane_id} #{@claude_state}')
  case $w in done | waiting) w=idle ;; esac
  [ -n "$w" ] && t set -w -t "$pane" @claude_win_state "$w"
  ;;
esac
exit 0
