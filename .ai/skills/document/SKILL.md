---
name: document
description: Write or update documentation for a completed task. Saves AI-optimized docs to the docs/ directory and updates the Docs section in CLAUDE.md. Use after implementing a feature, adding a subsystem, or changing behavior that agents need to understand.
---

You are writing documentation for AI agents, not humans. Optimize for precision, completeness, and navigability — not readability or prose style.

## What to document

Document the task described in $ARGUMENTS, or if no arguments are given, infer from recent changes what needs documenting.

## Process

1. **Understand the subject**: Read the relevant source files. Understand the public interface, data flow, edge cases, and any non-obvious constraints.

2. **Choose a filename**: Use `.ai/docs/<topic>.md` where topic is a short kebab-case noun phrase (e.g. `.ai/docs/search-engine.md`, `.ai/docs/visual-mode.md`).

3. **Write AI-optimized documentation**:
   - One-line summary of what the component does
   - **Feature description first**: describe what the feature does from a user/caller perspective before any implementation details
   - **Key implementation elements**: highlight the non-obvious parts — data structures, algorithms, state machines, dispatch paths, or invariants that an agent would need to understand to modify the code correctly
   - For everything else, reference the relevant source file and line range instead of re-explaining it
   - No prose padding

4. **Update CLAUDE.md**: Add or update a line in the `## Docs` section pointing to the new file:
   ```
   - `.ai/docs/<filename>.md` — one-line description of what it covers
   ```
   If the `## Docs` section does not exist in CLAUDE.md, add it after the `## Build` section.

## Output

- One new or updated file in `.ai/docs/`
- One updated line in `CLAUDE.md` under `## Docs`
- No other files modified
