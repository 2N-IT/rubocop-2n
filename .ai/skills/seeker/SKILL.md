---
name: seeker
description: Explore the codebase to build context before implementing a task. Use when starting a new task, investigating an issue, or onboarding to unfamiliar code. Gathers requirements, reviews related files, and summarizes what's relevant.
allowed-tools: Read, Grep, Glob, Bash(git log *), Bash(git show *), Bash(find *), Bash(head *), Bash(tail *)
---

Explore the codebase to build context for the following task or question:

$ARGUMENTS

Steps:
1. Read CLAUDE.md and any docs/ files to understand project conventions
2. Use Glob and Grep to find files related to the task
3. Read the most relevant files
4. Check recent git log for context on the area being changed (`git log --oneline -20 -- <relevant paths>`)
5. Summarize:
   - What you found and where (file:line references)
   - Which files are most relevant to the task
   - Any constraints, patterns, or conventions to respect
   - What you'd need to know before implementing

Be specific. Include file paths and line numbers.
