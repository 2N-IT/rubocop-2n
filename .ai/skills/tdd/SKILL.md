---
name: tdd
description: Implement a task using test-driven development. Writes failing tests first, then implements the code to make them pass. Use when building new functionality or fixing bugs where correctness can be verified.
disable-model-invocation: true
---

Implement the following task using TDD:

$ARGUMENTS

Process:
1. **Write failing tests first** — based on the requirements, write tests that clearly express the expected behavior. Do not write implementation yet.
2. **Confirm tests fail** — run the tests to verify they fail for the right reason.
3. **Implement** — write the minimal code to make the tests pass.
4. **Run tests** — verify all tests pass.
5. **Run linter** — run `just lint` (or `go vet ./...`) and fix any issues.
6. **Refactor if needed** — clean up the implementation without breaking tests.

Rules:
- Tests must be written before the code they test
- Only write enough code to pass the current tests
- If the task involves a bug fix, add a regression test reproducing the bug before fixing it
