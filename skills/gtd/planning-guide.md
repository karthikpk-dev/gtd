# Planning Guide

Reference for the GTD planning phase. Use these guidelines when breaking down large tasks into subtasks.

## Task Sizing

Each subtask should:
- Touch **1-3 files** maximum
- Be describable in **under 200 words**
- Be **independently testable** (has its own test command)
- Be **self-contained** — executable by a fresh conversation with zero prior context

### Signs a task is too large
- Requires modifying more than 3 files
- Description exceeds 200 words
- Has multiple distinct pieces of functionality
- Would take more than one implementation-test-review cycle
- Involves files over 500 lines — split into focused sections per task

### Signs a task is too small
- Just renaming a variable or fixing a typo
- Only adds an import statement
- Can be naturally combined with another related task

## Task Ordering

1. **Foundation first**: Setup, configuration, types/interfaces
2. **Core logic next**: Business logic, data models, algorithms
3. **Integration**: Connecting components, API endpoints, routes
4. **Polish last**: Error handling, edge cases, UI refinements
5. **Tests**: If tests aren't part of each task, add a final testing task

### Dependencies
- Mark dependencies explicitly: `Depends: Task 1, Task 3`
- Minimize dependencies — prefer independent tasks that can be done in any order
- If Task B depends on Task A, Task A must produce a testable, working state

## Test Command Patterns

### JavaScript/TypeScript
- Jest: `npx jest --silent --testPathPattern="feature"`
- Vitest: `npx vitest run --reporter=dot src/feature`
- Mocha: `npx mocha --grep "feature" --reporter dot`
- General: `npm test -- --silent`

### Python
- Pytest: `python -m pytest tests/test_feature.py -q --tb=short`
- Unittest: `python -m unittest tests.test_feature -v 2>&1 | tail -5`

### Go
- `go test ./pkg/feature/... -count=1`

### Rust
- `cargo test feature_name -- --quiet`

### General
- If no test framework: specify a manual verification step instead
- Prefer targeted test commands over running the full test suite
- Use quiet/minimal output flags to save context

## Writing Good Task Descriptions

A good description answers:
1. **What** to implement (specific functions, components, endpoints)
2. **Where** to implement it (exact file paths)
3. **How** it should behave (expected inputs/outputs, edge cases)
4. **How** to verify it works (test command + manual check)

### Example of a good task description:
```
Create the User model in src/models/user.ts with fields: id (uuid), email (string, unique),
name (string), createdAt (Date). Export a TypeScript interface and a Zod validation schema.
Add a factory function createUser(email, name) that generates a new User with auto-generated
id and createdAt. Write tests in src/models/__tests__/user.test.ts covering: valid creation,
duplicate email rejection, and missing field validation.
```

### Example of a bad task description:
```
Set up the user system with authentication and profiles.
```
(Too vague, touches too many concerns, not independently testable)
