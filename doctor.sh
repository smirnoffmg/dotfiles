#!/usr/bin/env zsh
# Health check for this dotfiles repo. Read-only — starts no tmux server, edits
# nothing.
#
# Config correctness is measured in a freshly built shell, so the result does
# not depend on how the shell you launch this from was started. A separate
# section reports whether *this* shell is stale.
#
#   ./doctor.sh

emulate -L zsh
setopt extended_glob

REPO=${0:A:h}
typeset -i passed=0 failed=0 warned=0 skipped=0

if [[ -t 1 ]]; then
  C_OK=$'\e[32m'
  C_BAD=$'\e[31m'
  C_WARN=$'\e[33m'
  C_DIM=$'\e[2m'
  C_OFF=$'\e[0m'
else
  C_OK= C_BAD= C_WARN= C_DIM= C_OFF=
fi

# Every reporter returns 0 on purpose: `cmd && ok ... || bad ...` would other-
# wise run both branches, because (( n++ )) is false while n is still 0.
# $'\n' is not interpreted inside the replacement half of ${x//a/b}, so the
# newline and padding have to arrive as variables.
note() {
  [[ -z $1 ]] && return 0
  local nl=$'\n' pad='      '
  print -r -- "${pad}${C_DIM}${1//$nl/$nl$pad}${C_OFF}"
  return 0
}
ok() {
  print -r -- "  ${C_OK}✓${C_OFF} $1"
  ((passed++))
  return 0
}
bad() {
  print -r -- "  ${C_BAD}✗${C_OFF} $1"
  note "$2"
  ((failed++))
  return 0
}
warn() {
  print -r -- "  ${C_WARN}!${C_OFF} $1"
  note "$2"
  ((warned++))
  return 0
}
skip() {
  print -r -- "  ${C_DIM}–${C_OFF} $1"
  ((skipped++))
  return 0
}
section() { print -r -- $'\n'"${C_DIM}── $1${C_OFF}"; }

# Resolve a command in a shell built from scratch: no inherited environment, so
# what it finds reflects the config rather than the current session's history.
fresh() { env -i HOME=$HOME zsh -c "command -v $1" 2>/dev/null; }

# Index of an element in $path, or 0 when absent.
path_index() {
  local needle=$1
  local -i i=1
  for p in $path; do
    [[ $p == $needle ]] && {
      print -r -- $i
      return
    }
    ((i++))
  done
  print -r -- 0
}

section "Activation"

link=$HOME/.zshenv target=$REPO/zsh/.zshenv
if [[ -L $link && ${link:A} == ${target:A} ]]; then
  ok "~/.zshenv symlinks into the repo"
else
  bad "~/.zshenv does not point at $target" "fix: ln -sf $target $link"
fi

[[ ${ZDOTDIR:-} == $REPO/zsh ]] &&
  ok "ZDOTDIR is $ZDOTDIR" ||
  bad "ZDOTDIR is '${ZDOTDIR:-unset}', expected $REPO/zsh"

section "Config correctness (fresh shell)"

# macOS ships no /etc/zshenv, so without path.zsh a plain `zsh -c` gets neither
# /sbin nor any toolchain. This is the main thing the chain exists to fix.
for tool in python node brew ifconfig; do
  [[ -n $(fresh $tool) ]] &&
    ok "a bare 'zsh -c' finds $tool" ||
    bad "a bare 'zsh -c' cannot find $tool" \
      "cron, launchd and Makefile recipes would fail"
done

check_tool() {
  local tool=$1 want=$2 got=$(fresh $1)
  [[ -z $got ]] && {
    bad "$tool not found in a fresh shell"
    return
  }
  [[ $got == $~want ]] &&
    ok "$tool → $got" ||
    bad "$tool → $got" "expected to match: $want"
}

check_tool python "$HOME/.pyenv/shims/*"
check_tool ruby "$HOME/.rbenv/shims/*"
check_tool cargo "$HOME/.cargo/bin/*"
check_tool brew "*/bin/brew"
# The secret-scanning hooks depend on this one resolving through pyenv.
check_tool pre-commit "$HOME/.pyenv/shims/*"

out=$(zsh -c 'true' 2>/dev/null)
err=$(zsh -c 'true' 2>&1 >/dev/null)
[[ -z $out ]] && ok "startup prints nothing on stdout" ||
  bad "startup writes to stdout: $out" "this breaks scp, sftp and rsync"
[[ -z $err ]] && ok "startup prints nothing on stderr" ||
  bad "startup writes to stderr: $err"

# Regression guard: a child shell must not rebuild PATH over what its parent
# deliberately put in front — an activated virtualenv, direnv, a CI runner.
probe=$(PATH="/usr/local:$PATH" zsh -c 'print -r -- $path[1]')
[[ $probe == /usr/local ]] &&
  ok "a child shell preserves the parent's leading PATH entry" ||
  bad "a child shell replaced the parent's leading entry with '$probe'" \
    "an activated virtualenv would be stomped in every subshell"

section "PATH ordering (fresh shell)"

fresh_path=(${(f)"$(env -i HOME=$HOME zsh -c 'print -l $path')"})
fp_index() {
  local needle=$1
  local -i i=1
  for p in $fresh_path; do
    [[ $p == $needle ]] && {
      print -r -- $i
      return
    }
    ((i++))
  done
  print -r -- 0
}

dupes=(${(f)"$(print -l $fresh_path | sort | uniq -d)"})
((${#dupes} == 0)) &&
  ok "no duplicate entries (${#fresh_path} total)" ||
  bad "duplicate entries: ${dupes}"

brew_i=$(fp_index ${HOMEBREW_PREFIX:-/nonexistent}/bin)
usr_i=$(fp_index /usr/bin)
if ((brew_i == 0)); then
  skip "Homebrew not on PATH — ordering checks skipped"
else
  ((brew_i < usr_i)) &&
    ok "Homebrew ($brew_i) outranks /usr/bin ($usr_i)" ||
    bad "Homebrew ($brew_i) sits below /usr/bin ($usr_i)"

  for vm in ${PYENV_ROOT:-$HOME/.pyenv}/shims ${RBENV_ROOT:-$HOME/.rbenv}/shims $HOME/.cargo/bin; do
    vm_i=$(fp_index $vm)
    ((vm_i == 0)) && {
      skip "${vm:h:t}: not on PATH"
      continue
    }
    ((vm_i < brew_i)) &&
      ok "${vm:h:t} ($vm_i) outranks Homebrew ($brew_i)" ||
      bad "${vm:h:t} ($vm_i) sits below Homebrew ($brew_i)" \
        "brew ships python3/pip3/pre-commit, ruby/gem and cargo/rustc — those would shadow the selected version"
  done
fi

section "This shell"

if [[ -z ${_ZSH_PATH_SET:-} ]]; then
  warn "path.zsh never ran here — this shell predates the current config"
else
  drift=()
  for t in python ruby cargo brew node; do
    [[ $(command -v $t 2>/dev/null) != $(fresh $t) ]] && drift+=$t
  done
  ((${#drift} == 0)) &&
    ok "resolves the same tools as a fresh shell" ||
    warn "differs from a fresh shell for: ${drift}" \
      "this session started before the current config; open a new tmux pane"
fi

stray=()
for p in $path; do
  [[ -d $p ]] && continue
  # Apple creates the cryptex bootstrap dirs lazily; absence there is normal.
  [[ $p == /var/run/com.apple.security.cryptexd/* || $p == /Library/Apple/* ]] && continue
  stray+=$p
done
((${#stray} == 0)) &&
  ok "no PATH entry points at a missing directory" ||
  warn "PATH entries pointing nowhere: ${#stray}" \
    "${(F)stray}"$'\n'"harmless, but they are inherited — path.zsh prunes its own"

section "Secrets"

if [[ -f $REPO/zsh/.zshenv.local ]]; then
  git -C $REPO check-ignore -q zsh/.zshenv.local &&
    ok "zsh/.zshenv.local exists and is ignored" ||
    bad "zsh/.zshenv.local is NOT ignored — it would be committed"
else
  skip "no zsh/.zshenv.local on this machine"
fi

# A literal secret-looking assignment in a tracked file. gitleaks only sees the
# staged diff, so working-tree edits like this slip past the commit hooks.
leaks=$(git -C $REPO grep -nIE '^[[:space:]]*export [A-Z_]*(KEY|TOKEN|SECRET|PASSWORD)=[^"$'\''[:space:]]' \
  -- . ':!doctor.sh' 2>/dev/null)
[[ -z $leaks ]] &&
  ok "no literal secret assignments in tracked files" ||
  bad "possible secret in a tracked file:" "$leaks"

section "Repo hygiene"

tracked_but_ignored=$(git -C $REPO ls-files -i -c --exclude-standard)
[[ -z $tracked_but_ignored ]] &&
  ok "no tracked file matches an ignore rule" ||
  bad "tracked yet ignored:" "$tracked_but_ignored"

# The allowlist exists so new application state is ignored by default.
holes=()
for p in yandex-cloud raycast node_modules .DS_Store zsh/.zshrc.local; do
  git -C $REPO check-ignore -q $p || holes+=$p
done
((${#holes} == 0)) &&
  ok "allowlist ignores application state by default" ||
  bad "not ignored: ${holes}" "the allowlist has a hole"

section "Neovim"

if (($+commands[nvim])); then
  nvim_err=$(nvim --headless -c 'lua vim.defer_fn(function() vim.cmd("qa!") end, 3000)' 2>&1)
  [[ -z $nvim_err ]] && ok "starts clean" || bad "startup output:" "$nvim_err"

  nvim --headless -c 'lua assert(require("ibl"))' -c 'qa!' >/dev/null 2>&1 &&
    ok "indent-blankline (ibl) loads" ||
    bad "indent-blankline does not load" \
      "v3 removed the v2 API — call require('ibl').setup()"
else
  skip "nvim not installed"
fi

section "Not covered here"

print -r -- "  ${C_DIM}Needs a real terminal — check by eye in a fresh tmux pane:${C_OFF}"
print -r -- "  ${C_DIM}prompt renders without a gitstatus error · Tab completion ·${C_OFF}"
print -r -- "  ${C_DIM}Ctrl+R history search · indent guides visible in nvim${C_OFF}"

print -r -- $'\n'"${C_OK}${passed} passed${C_OFF}  ${C_BAD}${failed} failed${C_OFF}  ${C_WARN}${warned} warnings${C_OFF}  ${C_DIM}${skipped} skipped${C_OFF}"
((failed == 0))
