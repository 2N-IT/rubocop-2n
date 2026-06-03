---
name: refine
description: Review and update project docs, skills, and instructions to stay accurate and consistent. Use periodically to fight entropy in the knowledge base. Identifies stale, missing, or conflicting documentation.
disable-model-invocation: true
---

Review and refine the project knowledge base.

$ARGUMENTS

Steps:
1. Read CLAUDE.md and all files in `.ai/docs/`.
2. Read recent git log (`git log --oneline -20`) and scan relevant source files to understand current reality.
3. Read all files in `.ai/lessons/` (if any exist).

Check for:

**Sync issues** — where docs say X but code does Y. For each conflict, show both versions and ask the user: "Which is correct — the doc or the code?"

**Duplication** — the same fact stated in multiple places. Flag it and propose which copy to keep and which to remove.

**Lesson integration** — for each lesson in `.ai/lessons/`, identify where in CLAUDE.md or `.ai/docs/` it could be incorporated. Show the proposed addition in context (quote the insertion point) and ask the user whether to apply it.

**Stale or missing content** — outdated descriptions, missing architecture entries, skills that no longer apply.

Ask before making any changes. Present all findings first, then proceed section by section based on user confirmation.
