---
name: gtd
description: "Get Things Done — break large tasks into verified subtasks with automated testing and code review. Use when starting a complex multi-step project."
disable-model-invocation: true
argument-hint: "[plan <description> | run | status | skip | reset]"
---

# GTD — Get Things Done

You are executing the GTD workflow. This workflow breaks large tasks into small, verified subtasks that are executed one per conversation to manage context efficiently.

For task sizing guidelines and test command patterns, see [planning-guide.md](planning-guide.md).

## Sub-commands

| Command | Action |
|---|---|
| `/gtd plan <description>` | Create a new plan for a task |
| `/gtd run` | Execute the next subtask |
| `/gtd status` | Show progress dashboard |
| `/gtd skip` | Skip the current in-progress task |
| `/gtd reset` | Delete the plan and start fresh |

## Step 1: Determine Mode

Parse `$ARGUMENTS` (the first word is the sub-command):

- First word is `plan` → **Planning Mode** (remaining words = task description)
- First word is `run` → **Execution Mode**
- First word is `status` → **Status Mode**
- First word is `skip` → **Skip Mode**
- First word is `reset` → **Reset Mode**
- `$ARGUMENTS` is empty → show usage help (see bottom of this file)

---

## Planning Mode

Triggered by: `/gtd plan <description>`

**If `.gtd/index.md` already exists**, tell the user: "A plan already exists. Run `/gtd status` to view it, or `/gtd reset` first to start fresh." Do NOT overwrite.

You are creating a plan for a large task. Be thorough in understanding what the user wants.

### Step P1: Auto-detect test framework

Scan the project for test configuration:
- `package.json` → look for test scripts (jest, vitest, mocha, etc.)
- `pytest.ini` / `pyproject.toml` / `setup.cfg` → pytest
- `Cargo.toml` → cargo test
- `go.mod` → go test
- `Makefile` → look for test targets
- `.github/workflows/` → look for CI test commands

Note the test command found (or "none detected").

### Step P2: Gather requirements

Use AskUserQuestion to understand the task. Ask as many rounds as needed — thorough planning saves tokens during execution. Combine related questions (up to 4 per AskUserQuestion call) for efficiency.

Key things to understand:
- What is the desired end result?
- What are the constraints or requirements?
- Are there specific files or areas of the codebase involved?
- What testing strategy should be used? (unit tests, integration tests, manual verification)
- Are there any dependencies or ordering constraints between parts of the work?

### Step P3: Explore the codebase

Use Grep and Glob to understand:
- Project structure and file organization
- Existing patterns and conventions
- Files that will need to be modified
- Existing tests and test patterns

### Step P4: Break into subtasks

Create subtasks following these rules:
- Each task touches **1-3 files maximum**
- Each task is **describable in under 200 words**
- Each task is **independently testable**
- Tasks are ordered by dependency (independent tasks first)
- Each task description must be **self-contained** — a fresh conversation with no prior context must be able to execute it

### Step P5: Write the plan files

1. Create `.gtd/` directory
2. Write `.gtd/index.md` with this format:

```markdown
# GTD: [Title]
Created: [today's date]
Goal: [one-line goal]
Test Framework: [detected framework or "manual"]
Test Command: [base test command or "none"]

## Tasks
1. [Task name] — Status: pending — File: task-01.md
2. [Task name] — Status: pending — File: task-02.md
...
```

3. Write individual `.gtd/task-XX.md` files with this format:

```markdown
# Task X: [Name]
Status: pending
Files: [comma-separated list of files to modify]
Test: `[specific test command for this task]`
Verify: [manual verification step, or "none"]
Depends: [task numbers this depends on, or "none"]

## Description
[Detailed instructions for what to do. Must be self-contained — assume the reader
has no context from this conversation. Include specific function names, file paths,
and expected behavior. Under 200 words.]

## Failure Notes
[Empty — populated during execution if task fails after retries]
```

4. Add `.gtd/` to `.gitignore` if not already present

5. Tell the user:
```
Plan created with N tasks. To begin:
  /gtd run   — start first task (in a new chat)
  /gtd status — view all tasks
```

---

## Execution Mode

Triggered by: `/gtd run`

You are executing the next task from an existing plan.

If `.gtd/index.md` does not exist, tell the user: "No plan found. Run `/gtd plan <description>` to create one."

### Step E1: Show progress dashboard

Read `.gtd/index.md` and display:
```
GTD: [Title]
Progress: X/N tasks done
Last completed: Task Y — [name]
Next up: Task Z — [name]
```

Count tasks by status to compute progress. Do NOT read completed task files.

### Step E2: Find the current task

1. First, look for any task with `Status: in-progress` (resuming a previous session)
2. If none, find the first task with `Status: pending` that is not blocked
3. A task is blocked if it has `Depends: Task X` where Task X is not `done` and not `skipped`
4. **If no pending or in-progress tasks remain**, tell the user: "All tasks complete! Run `/gtd reset` to clean up." and stop.

Read ONLY that task's `.gtd/task-XX.md` file.

### Step E3: Mark as in-progress

Update the status to `in-progress` in both:
- `.gtd/index.md` (the task list line)
- `.gtd/task-XX.md` (the Status field)

### Step E4: Confirm with user

Show the task summary and ask:
```
Ready to start Task X: [name]
Files: [list]
Test: [command]

Proceed?
```

Wait for user confirmation before implementing.

### Step E5: Implement

Execute the task as described in the task file. Be concise — no unnecessary commentary.

Track which files you modify (you'll need this for the code review).

### Step E6: Run tests

**If the task's Test field is "none"**, skip this step entirely and go to Step E7.

Run the test command specified in the task file. Use quiet/minimal output flags where possible:
- Jest/Vitest: `--silent` or `--reporter=dot`
- Pytest: `-q` or `--tb=short`
- Go: `-count=1` (no verbose)
- General: pipe through `tail -20` if output is expected to be long

**If tests pass** → go to Step E7
**If tests fail** → fix the issue and re-run. Maximum **2 retry attempts**.
**If still failing after 2 retries**:
  1. Save failure details to the `## Failure Notes` section of the task file
  2. Tell the user what's failing and ask for help
  3. Do NOT mark the task as done

### Step E7: Code review

Spawn a code review subagent to review your changes:

Use the Agent tool with these parameters:
- subagent_type: "general-purpose"
- prompt: Include the following in the prompt:
  - "Review the code changes for bugs, security issues, code quality, and simplification opportunities."
  - "Run `git diff HEAD -- [list of modified files]` to see the changes. For newly created files, read them directly instead."
  - "Be concise. Report: (1) any bugs or security issues, (2) any code quality concerns, (3) any simplification opportunities. If everything looks good, just say 'LGTM'."
  - "Do NOT make any edits. Only report findings."

If the subagent reports issues:
1. Fix the issues
2. Re-run tests to make sure fixes don't break anything
3. If tests pass, proceed

### Step E8: Manual verification

If the task specifies a `Verify:` step (not "none"):
1. Tell the user what to verify
2. Wait for their confirmation

### Step E9: Mark as done

Update the status to `done` in both:
- `.gtd/index.md` (the task list line)
- `.gtd/task-XX.md` (the Status field)

### Step E10: Git checkpoint

First check if the project is a git repository by running `git rev-parse --git-dir`. If not a git repo, skip this step entirely.

If it is a git repo, ask the user:
```
Task X/N complete. Create a git checkpoint commit?
```

If approved, stage the modified files and commit with message: `gtd: Task X/N — [task name]`

If declined, skip the commit.

### Step E11: Next steps

Tell the user:
```
Task X done (Y/N complete).
Next: Task Z — [name]

Start a new chat and run /gtd run to continue.
```

If all tasks are done:
```
All N tasks complete! The GTD plan is finished.
Run /gtd reset to clean up the plan files.
```

---

## Status Mode

Triggered by: `/gtd status`

Read `.gtd/index.md` and display all tasks with their statuses:

```
GTD: [Title]
Goal: [goal]
Progress: X/N tasks done

Tasks:
  1. [done]        Task name
  2. [done]        Task name
  3. [in-progress] Task name  ← current
  4. [pending]     Task name
  5. [blocked]     Task name (depends on Task 4)
```

Do NOT read individual task files. Only read `index.md`.

---

## Skip Mode

Triggered by: `/gtd skip`

1. Read `.gtd/index.md`
2. Find the task with `Status: in-progress`
3. If found, update its status to `skipped` in both `index.md` and the task file
4. Tell the user which task was skipped and what the next pending task is

If no task is in-progress, tell the user: "No task is currently in-progress. Run `/gtd run` to start the next task."

---

## Reset Mode

Triggered by: `/gtd reset`

1. Ask the user for confirmation: "This will delete the entire GTD plan and all task files. Are you sure?"
2. If confirmed, delete the `.gtd/` directory
3. Tell the user: "GTD plan deleted. Run `/gtd plan <description>` to start a new one."

---

## Usage Help

Shown when `/gtd` is run with no arguments:

```
GTD — Get Things Done

Commands:
  /gtd plan <description>  — Plan a new task (creates subtasks)
  /gtd run                 — Execute the next subtask
  /gtd status              — Show progress
  /gtd skip                — Skip the current task
  /gtd reset               — Delete plan and start fresh
```

---

## Important Rules

- **Be concise**. No fluff, no unnecessary summaries, no trailing recaps.
- **One task per conversation**. After completing a task, tell the user to start a new chat.
- **Never read completed task files**. Only read `index.md` + the current task file.
- **Track modified files** during implementation for the code review subagent.
- **Always update both** `index.md` and the task file when changing status.
- **Tests must pass** before marking a task done. No exceptions.
