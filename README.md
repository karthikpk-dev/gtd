# GTD — Get Things Done for Claude Code

A slash command that breaks large tasks into small, verified subtasks. Each subtask is executed in a fresh conversation with automated testing and code review.

Designed for developers on Claude's $20/month plan who need to manage context window efficiently.

## Install

```bash
git clone https://github.com/karthikpk-dev/gtd.git
cd gtd
chmod +x install.sh && ./install.sh
```

## Uninstall

```bash
./uninstall.sh
```

## Usage

### Start a new task
```
/gtd plan build a REST API with user authentication
```
Claude will ask questions to understand your requirements, explore the codebase, and create a plan with subtasks.

### Execute subtasks
```
/gtd run
```
Each run picks up the next subtask, implements it, runs tests, performs a code review, and marks it done. Start a new conversation for each subtask.

### Check progress
```
/gtd status
```

### Skip current task
```
/gtd skip
```

### Start over
```
/gtd reset
```

## How It Works

```
/gtd plan <description>     /gtd run                /gtd run
      |                       |                       |
  Ask questions          Pick next task           Pick next task
  Explore codebase       Implement                Implement
  Break into subtasks    Run tests (2 retries)    Run tests
  Write plan files       Code review subagent     Code review
      |                  Manual verification       Mark done
  .gtd/index.md         Mark done                     |
  .gtd/task-01.md       Git commit (optional)    All done!
  .gtd/task-02.md            |                   /gtd reset
  ...                   "Start new chat,
                         run /gtd run"
```

### Per-task workflow
1. Read task from plan
2. Implement the changes
3. Run tests — auto-fix up to 2 retries
4. Code review via subagent (bugs, security, quality, simplification)
5. Manual verification (if specified)
6. Git checkpoint commit (with your approval)

### Plan file structure
Plans are stored in `.gtd/` in your project root (gitignored):
- `index.md` — task list with statuses
- `task-01.md`, `task-02.md`, ... — individual task details

Each task file is self-contained, so a fresh conversation only needs to read one file.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- Claude Pro or higher plan

## Token Efficiency

This workflow is designed to minimize token usage:
- One subtask per conversation — fresh context each time
- Separate task files — only the current task is read
- Tests run with quiet output flags
- Code review subagent scoped to changed files only
- No re-reading completed tasks
