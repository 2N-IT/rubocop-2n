---
name: retrospect
description: Summarize what happened in a recent implementation session — what worked, what didn't, and what to do differently next time. Use after completing a task or after getting stuck.
disable-model-invocation: true
---

Review the work just completed and extract lessons.

$ARGUMENTS

1. Identify what went wrong, required correction, or took longer than expected — and why.
2. For each insight, write a standalone lesson file in `.ai/lessons/` with a short kebab-case name (e.g. `.ai/lessons/avoid-premature-abstraction.md`). Each file: one heading, 2–4 sentences stating the rule and when to apply it.
3. Output to the user: one sentence summarizing what was covered, then a bullet list of the lesson filenames created.
