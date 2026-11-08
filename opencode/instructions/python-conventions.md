# Python conventions

Detailed Python conventions. Loaded via the `instructions` field in
`opencode.json`; extends `AGENTS.md`.

## Tooling

- `uv` is the only dependency and environment manager.
  - Install: `uv add <pkg>` (only with confirmation).
  - Run: `uv run <cmd>`. Tests: `uv run pytest`.
  - Sync: `uv sync`. Lock: `uv lock`.
- `ruff` is the linter and formatter. `ruff check` for lint, `ruff format` for format.
- The Python version comes from `pyproject.toml` / `.python-version`, pinned by `uv`.

## Code style

- Fully type-annotate functions and methods. Return types are required.
- Prefer explicit over implicit. No magic that hides the flow of data.
- Structure errors: specific exceptions instead of a bare `except Exception`.
- Docstrings where behavior is not obvious from the signature, not for formality.
- Do not write comments that restate the code. A comment explains "why", not "what".

## Tests

- `pytest`. Tests are deterministic, free of network and time dependencies where possible.
- Do not bend a test to fit a bug. If a test fails because of the code, fix the code.
- New code ships with tests for key branches and edge cases.

## Structure

- Follow the repository's existing module structure.
- Do not introduce new abstraction layers without clear need.
