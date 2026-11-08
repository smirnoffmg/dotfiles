# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles versioned **directly at `~/.config`** — there is no symlink/stow layer. Every edit takes effect immediately in the live environment. Tracked tools: alacritty, nvim, opencode, tmux, zsh.

Theme across all tools is Catppuccin Macchiato.

## Commands

```bash
# Health check: PATH ordering, tool resolution, secrets, repo hygiene, nvim.
# Measures a freshly built shell, so its verdict does not depend on how the
# calling shell was started; it flags a stale caller separately.
./doctor.sh

# Lint + secret-scan everything (the other "test suite" here). NB: the gitleaks
# hook scans the staged diff, which is empty here — for a real secret audit run:
pre-commit run --all-files
pre-commit run --hook-stage manual gitleaks-history

# After cloning, or if tmux plugins are missing
git submodule update --init --recursive

# Update tmux plugin submodules (supports --dry-run, --plugin <name>)
./tmux/update-plugins.sh

# Format nvim Lua config (config in nvim/stylua.toml)
stylua nvim/

# New machine: toolchain, ~/.zshenv symlink, submodules, hooks, nvim plugins.
# Idempotent; ends by running doctor.sh
./bootstrap.sh
```

`pre-commit` and `detect-secrets` resolve through pyenv shims — if pre-commit suddenly "disappears", check the active pyenv Python rather than reinstalling.

**Never run tmux commands** (`tmux source-file`, `kill-server`, `update-plugins.sh`, any `tmux` subcommand). The user works inside tmux and a stray command kills their session. Read `tmux/tmux.conf` as a file and reason about it; if a live reload is genuinely needed, ask the user to run it.

## Architecture notes

- **`.gitignore` is an allowlist**, not a denylist: `*` ignores everything, and each tracked config is named with `!`. This is deliberate — the repo shares a directory with applications that create state on their own schedule, and a denylist left every new one untracked-but-committable (a directory holding a live IAM token nearly got committed that way). To track a new tool, add **both** `!newtool/` and `!newtool/**`: git does not descend into an excluded directory, so the `**` pattern alone is inert.
- **Secret scanning is load-bearing.** Commits run detect-secrets (against `.secrets.baseline`), gitleaks (`.gitleaks.toml`), and `detect-private-key`. A new legitimate "secret-looking" string requires updating the baseline: `detect-secrets scan --baseline .secrets.baseline`. Never weaken these configs to get a commit through.
- **Security hook coverage (verified 2026-07-27):** the commit path is solid — the gitleaks hook scans the staged diff (exactly what gets committed) and its default rules include `anthropic-api-key`, which fires on `sk-ant-api03-` keys even at low entropy. The gaps are elsewhere: in a `pre-commit run --all-files` audit the staged diff is empty, so gitleaks scans nothing (use `pre-commit run --hook-stage manual gitleaks-history` for a full-history scan; CI runs the same on every push), and `detect-secrets` has no Anthropic detector at all. Machine-local secrets belong in `zsh/.zshenv.local`, never in a tracked file.
- **zsh uses ZDOTDIR.** `~/.zshenv` is a symlink to `zsh/.zshenv`, which sets `ZDOTDIR="$HOME/.config/zsh"`, so all zsh startup files live in `zsh/`, not `~`. That symlink is the single activation point. Runtime artifacts (`.zcompdump*`, history, sessions) are gitignored.
- **`zsh/path.zsh` is the single source of truth for PATH.** It is sourced twice on purpose: from `.zshenv`, so non-login shells (scripts, cron, launchd) get a usable PATH — macOS ships no `/etc/zshenv`, so without it they lack even `/usr/sbin`; and again from `.zprofile`, because `/etc/zprofile` runs `path_helper` in between and demotes everything below the system paths. It builds **at most once per process tree** (`_ZSH_PATH_SET` guard): a child shell inherits a correct PATH, and rebuilding there would stomp on what the parent deliberately set — an activated virtualenv, direnv, a CI runner. `.zprofile` bypasses the guard with `_ZSH_PATH_REBUILD`.
- **PATH ordering rule:** version managers (pyenv, rbenv, rustup, nvm) outrank Homebrew, because brew also ships `python3`, `pip3`, `pre-commit`, `ruby`, `gem` and `cargo` — letting those win would make `pyenv global` or `rustup default` silently do nothing, and would move `pre-commit` off the pyenv shim this repo depends on. Homebrew is the primary source of everything else and outranks the plain user directories (`~/.local/bin`, `~/yandex-cloud/bin`) below it.
- **Two zsh gotchas that cost real debugging**, both load-bearing in `path.zsh`: `typeset -U` must name `PATH`/`FPATH` alongside `path`/`fpath`, or writes through the scalar (as `rbenv init` does) bypass deduplication; and `$^array(N-/)` needs the `^`, or the glob qualifier applies to the last element only and missing directories survive in PATH.
- **Machine-local overrides** are `zsh/*.local`, all gitignored and all optional, each sourced behind an existence guard: `.zshenv.local` (secrets and env, visible to every shell), `path.zsh.local` (extra PATH, manipulates `$path` directly), `.zshrc.local` (aliases and functions, loaded last so it can override anything).
- **NVM is eagerly loaded** in `zsh/.zshrc` (not lazy-wrapped). This is intentional — lazy wrappers (`nvm(){ unset -f ... }`) break Claude Code subagent shells where the stub is never triggered. Do not convert back to lazy loading. `path.zsh` separately resolves the default version's bin directory by glob, so non-interactive shells get node without paying for `nvm.sh`.
- **tmux plugins are git submodules** under `tmux/plugins/` (tpm, tmux-sensible, catppuccin) — they are pinned by commit in this repo, not installed ad hoc via tpm. Updating them changes submodule pointers that must be committed.
- **nvim is a from-scratch config**, not a LazyVim distribution (`nvim/README.md` is authoritative). Layout: `nvim/init.lua` → `lua/config/` (options/keymaps/autocmds + `lazy.lua` bootstrap), plugin specs in `lua/plugins/init.lua`, per-plugin configs in `lua/config/plugins/`. `lazy-lock.json` pins plugin versions and is committed. LSP uses the Neovim 0.11+ `vim.lsp.config`/`vim.lsp.enable` API with mason for server installs.
- **nvim-treesitter tracks the `main` branch**, which only ships parsers and queries — highlighting, folding and indent are enabled by the config itself (`vim.treesitter.start()` in a `FileType` autocmd, `vim.treesitter.foldexpr()`, `require('nvim-treesitter').indentexpr()`). The frozen `master` branch is incompatible with Nvim 0.12: its query directives read `match[id]` as a single node, but 0.11+ passes a node list, which crashes markdown/HTML injections. `main` requires the `tree-sitter` CLI (`brew install tree-sitter-cli`) to build parsers, and installs them into `~/.local/share/nvim/site/parser`, not into the plugin directory.
- **Commit style** follows conventional commits scoped by tool, e.g. `feat(zsh): …`, `fix(alacritty): …`.

## Known open items

- `.secrets.baseline` has `results: []` — an empty baseline, currently a formality.
- tmux itself floats with brew while its plugins are pinned to 2022–2023 commits; when a tmux major lands, check compatibility with `./tmux/update-plugins.sh --dry-run` (user runs it, not Claude).
- treesitter parsers in `~/.local/share/nvim/site/parser` are machine state, rebuilt by whatever `tree-sitter` CLI is installed — an nvim upgrade can invalidate their ABI with no change in this repo.
- The zsh framework layer (oh-my-zsh, p10k, zsh-autosuggestions) is pinned via refs in `bootstrap.sh` and omz auto-update is disabled; after a deliberate `omz update`, refresh `OMZ_REF` there.
