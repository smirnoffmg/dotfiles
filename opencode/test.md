---
description: Run ruff lint + pytest, triage failures
---

Run Python project checks in this order:

1. `ruff check .` — show and fix lint violations.
2. `ruff format .` — apply formatting.
3. `uv run pytest` — run the tests.

If there are failures: focus on the failing tests, state each cause briefly
(expected vs actual), and suggest concrete fixes. Do not change tests just to
make them pass when the bug is in the code. Do not touch dependencies.

Additional focus (optional): $ARGUMENTS
