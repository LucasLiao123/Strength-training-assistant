---
description: Systematic task execution workflow with proper testing and git practices for AI-assisted development. Use when implementing tasks from a task list.
applyTo: "**/*.{js,ts,py,dart,java}"
---

# Task Execution and Management Workflow

## Core Principles

### One Task at a Time

- **Execute one sub-task at a time** — Do not start the next sub-task until the current one is complete
- **Seek approval** — Ask for user permission before starting each new sub-task
- **Wait for confirmation** — User must respond "yes" or equivalent before proceeding

### Progress Tracking

- **Update immediately** — Mark tasks as completed `[x]` as soon as they're finished
- **Maintain accuracy** — Keep the task list current and accurate
- **Document changes** — Update the "Relevant Files" section with every modification

## Task Execution Protocol

### Step 1: Task Selection

1. Identify the next available task (not blocked by dependencies)
2. Review task requirements and acceptance criteria
3. Confirm prerequisites are met
4. Ask user for permission to proceed

### Step 2: Implementation

1. **Plan the approach** — Outline implementation strategy
2. **Implement the feature** — Write code
3. **Test locally** — Verify functionality works as expected
4. **Mark sub-task complete** — Update task list with `[x]`

### Step 3: Completion Protocol

When all sub-tasks under a parent task are marked `[x]`:

1. Run full test suite
2. Only if all tests pass — Proceed to next steps
3. Stage changes — `git add .`
4. Clean up — Remove temporary files and code
5. Commit with structured message

### Step 4: Git Commit Guidelines

Use conventional commit format:

```bash
git commit -m "feat: add payment validation logic" \
           -m "- Validates card type and expiry" \
           -m "- Adds unit tests for edge cases"
```

## Quality Assurance

### Before Marking Tasks Complete

- [ ] Functionality works as specified
- [ ] All edge cases are handled
- [ ] Error handling is implemented
- [ ] Code follows project conventions
- [ ] Tests are written and passing
- [ ] Documentation is updated
