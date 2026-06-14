# opencode

Public part of the OpenCode configuration. Cloned into `~/.config/opencode/`
together with the rest of the dotfiles.

## Contents

```
opencode/
├── AGENTS.md                      # global instructions (style, Python, Go, security)
├── command/
│   ├── test.md                    # /test — ruff + pytest, triage failures
│   └── mr-review.md               # /mr-review — review changes / MR
└── instructions/
    ├── python-conventions.md      # loaded via the instructions field in opencode.json
    └── security-rules.md          # loaded via the instructions field in opencode.json
```

## Intentionally not here

- `opencode.json` — the main config with provider, MCP servers, permissions.
  It contains internal hostnames and is tied to the work environment. Kept
  separately, out of the public repository.
- The `/triage` command — tied to internal Mattermost channels, Jira projects,
  and the work summary format. Lives in the private `.opencode/` of the work repo.

## Loading instruction files

In the private work `opencode.json`, add:

```json
"instructions": [
  "~/.config/opencode/instructions/python-conventions.md",
  "~/.config/opencode/instructions/security-rules.md"
]
```

## How it applies

When the dotfiles are cloned into `~/.config`, the files land in place
automatically. `AGENTS.md` and `command/` are picked up by OpenCode from
`~/.config/opencode/` with no extra setup. Instruction files are loaded
explicitly via the field above.
