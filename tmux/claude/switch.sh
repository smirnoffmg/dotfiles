#!/usr/bin/env bash
list=$(tmux list-panes -a -f '#{@claude_state}' -F '#{?#{==:#{@claude_state},waiting},0,#{?#{==:#{@claude_state},done},1,#{?#{==:#{@claude_state},working},2,3}}}	#{pane_id}	#{@claude_state}	#{session_name}:#{window_index}	#{pane_title}	#{b:pane_current_path}' | sort -s -t $'\t' -k1,1n)
if [ -z "$list" ]; then
  echo "No Claude Code sessions"
  read -rsn1
  exit 0
fi
pane=$(fzf --delimiter $'\t' --with-nth 3.. <<<"$list" | cut -f2)
[ -n "$pane" ] && tmux switch-client -t "$pane" \; select-window -t "$pane" \; select-pane -t "$pane"
exit 0
