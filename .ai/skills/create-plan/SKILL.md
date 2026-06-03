---
name: create-plan
description: Produce a concrete implementation plan for a task before writing code. Use after exploration to create a human-reviewable checkpoint. Narrows context to only relevant files and outlines specific steps.
disable-model-invocation: true
---

Produce an implementation plan for the following task:

$ARGUMENTS

The plan must include:
1. Goal - one sentence on what will be achieved
2. Files to change - list each file with a brief note on what changes
3. Files to read - files needed for reference but not modified
4. Steps - ordered, concrete implementation steps (not vague; each step should be actionable)
5. Tests - what tests need to be written or updated
6. Risks - anything that could go wrong or needs clarification

Do not write any code yet. This plan is for review before implementation begins.

Save it to `.ai/plans` and display path for the user
