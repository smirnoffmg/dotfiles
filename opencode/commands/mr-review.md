---
description: Review MR changes with a focus on correctness and security
subtask: true
---

Review the changes. By default review uncommitted changes (`git diff`).
If an MR number is passed in arguments, fetch it via `glab mr diff $ARGUMENTS`.

Check:

1. Correctness: logic errors, edge cases, error handling.
2. Security: leaked secrets, injection, unsafe input handling, careless handling
   of permissions and data (context is risk/compliance).
3. Conformance to repo conventions (`AGENTS.md`) and language idioms.
4. Tests: are the changes covered, are there tests bent to fit a bug.

Output: group findings by severity (blocker / major / minor). For each, give
file, line, the issue, and a suggested fix. Do not edit code yourself, analysis
only. If the changes are clean, say so plainly; do not invent findings.

MR or review scope: $ARGUMENTS
