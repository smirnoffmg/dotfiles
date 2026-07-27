# Dotfiles

Personal configuration, versioned **directly at `~/.config`** — there is no symlink or stow
layer, so every edit takes effect in the live environment immediately.

| Tool          | Path         | Notes                                                   |
| ------------- | ------------ | ------------------------------------------------------- |
| **zsh**       | `zsh/`       | ZDOTDIR layout, Powerlevel10k, Oh My Zsh                |
| **Neovim**    | `nvim/`      | From-scratch config on lazy.nvim — see `nvim/README.md` |
| **tmux**      | `tmux/`      | Plugins pinned as git submodules                        |
| **Alacritty** | `alacritty/` | `alacritty.toml`                                        |
| **opencode**  | `opencode/`  | Agent instructions and commands                         |

Theme across every tool is Catppuccin Macchiato.

## Setup on a new machine

```bash
git clone <repository-url> ~/.config
~/.config/bootstrap.sh
```

`bootstrap.sh` is idempotent — every step checks state before acting, so re-running after a
failure is safe. It installs Homebrew and the brew packages (neovim, tmux, fzf, eza, alacritty,
the fonts), the toolchains through their version managers (pyenv python, rbenv ruby, nvm node,
rustup — `path.zsh` puts the managers above brew, so a brew python or rust would be dead
weight), `pre-commit` + `detect-secrets` into the pyenv python, clones oh-my-zsh /
zsh-autosuggestions / powerlevel10k where `.zshrc` expects them, links `~/.zshenv` into the
repo, initializes the tmux plugin submodules, installs the commit hooks, restores nvim plugins
from `lazy-lock.json`, and finishes by running `./doctor.sh` as verification.

One `defaults` call it also carries: `defaults write org.alacritty AppleFontSmoothing -int 0`.
Alacritty dropped `font.use_thin_strokes` in 0.11 and now follows the macOS `AppleFontSmoothing`
default instead; left unset, macOS thickens light-on-dark text. `0` disables smoothing, `1`–`2`
are lighter variants, and `defaults delete org.alacritty AppleFontSmoothing` restores system
behaviour. It is read at process start, so Alacritty must be restarted — `live_config_reload`
does not apply.

`pre-commit` and `detect-secrets` resolve through pyenv shims. If `pre-commit` suddenly
"disappears", check the active pyenv version before reinstalling anything.

## Machine-local overrides

Anything machine-specific — API keys, work proxies, corporate tooling — goes in a `*.local`
file next to the config it extends. All of them are gitignored, all are optional, and each is
sourced through an existence guard, so a machine without them behaves normally.

| File                 | Loaded by  | Use for                                                                    |
| -------------------- | ---------- | -------------------------------------------------------------------------- |
| `zsh/.zshenv.local`  | `.zshenv`  | secrets and environment, visible to every shell including scripts and cron |
| `zsh/path.zsh.local` | `path.zsh` | extra PATH entries; manipulate `$path` directly                            |
| `zsh/.zshrc.local`   | `.zshrc`   | aliases, functions, interactive-only settings                              |

Secrets belong in `zsh/.zshenv.local` and nowhere else. Never put them in a tracked file:
`gitleaks` runs with `--staged`, so edits sitting in the working tree are invisible to it, and
`detect-secrets` ships no detector for Anthropic keys.

## How the zsh startup chain fits together

zsh reads its startup files in this order, and each file here holds only what its stage needs:

```
.zshenv  →  /etc/zprofile  →  .zprofile  →  .zshrc
 every       path_helper      login only    interactive only
 shell       (macOS)
```

- **`zsh/path.zsh`** is the single source of truth for `PATH`. It is sourced twice on purpose:
  from `.zshenv`, so scripts, cron and launchd get a usable `PATH`; and again from `.zprofile`,
  because macOS runs `path_helper` in between and demotes everything below the system paths.
  It builds at most once per process tree, so a child shell never stomps on a `PATH` its parent
  set deliberately — an activated virtualenv, direnv, a CI runner.
- **`zsh/.zshenv`** — `ZDOTDIR`, locale, `path.zsh`, machine-local secrets.
- **`zsh/.zprofile`** — login-only work: `JAVA_HOME` (the `java_home` call is slow) and the
  tmux auto-attach for Alacritty.
- **`zsh/.zshrc`** — Oh My Zsh, version-manager shell functions, fzf, nvm, aliases, prompt.

Ordering rule inside `path.zsh`: version managers (pyenv, rbenv, rustup, nvm) outrank Homebrew,
because brew also ships `python3`, `pip3`, `pre-commit`, `ruby`, `gem` and `cargo` — letting
those win would make `pyenv global` or `rustup default` silently do nothing. Homebrew is the
primary source of everything else and outranks the plain user directories below it.

## Adding a new tool config

`.gitignore` is an **allowlist**: everything is ignored unless named. This repo shares a
directory with applications that create state on their own schedule, and a denylist leaves each
new one untracked-but-committable until someone remembers to exclude it.

To track a new tool, add both lines — git will not descend into an excluded directory, so the
`**` pattern alone is inert:

```gitignore
!newtool/
!newtool/**
```

## Commands

```bash
./doctor.sh                         # health check: PATH, tool resolution, secrets, nvim
pre-commit run --all-files          # lint + secret scan; the repo's only test suite
./tmux/update-plugins.sh            # update plugin submodules (--dry-run, --plugin <name>)
stylua nvim/                        # format nvim Lua (config in nvim/stylua.toml)
```

Updating tmux plugins moves submodule pointers, which have to be committed.
