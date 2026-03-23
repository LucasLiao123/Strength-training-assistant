---
description: Convert Product Requirements Documents (PRDs) into actionable development tasks with clear dependencies. Use when breaking down a PRD or feature into tasks.
applyTo: "**/*.md"
---

# Task Generation from PRD Workflow

## Overview

This workflow converts Product Requirements Documents (PRDs) into actionable, granular development tasks that can be systematically implemented.

## Process

### Step 1: PRD Analysis

1. Read and analyze the complete PRD
2. Identify all functional requirements
3. Map out dependencies between features
4. Consider technical implementation needs

### Step 2: Task Decomposition

Break down the PRD into logical groups:

- **Setup & Infrastructure**: Project setup, dependencies, configuration
- **Data Layer**: Database schema, models, data access
- **Business Logic**: Core functionality, algorithms, processing
- **API/Services**: External integrations, service layers
- **User Interface**: Frontend components, user interactions
- **Testing**: Unit tests, integration tests, validation
- **Documentation**: Code docs, user guides, deployment notes

Each task should be completable in 1-4 hours with clear, measurable outcomes.

### Step 3: Task List Format

```markdown
# Task List: [Feature Name]

**Generated from:** `prd-[feature-name].md`

## Setup & Infrastructure
- [ ] **T001: Project Setup**
  - [ ] Initialize project structure
  - [ ] Configure development environment

## Data Layer
- [ ] **T002: Database Schema**
  - [ ] Design database tables
  - [ ] Create migration scripts

## Task Dependencies
- T002 depends on T001
```

### Step 4: User Confirmation

After generating the task list, present the complete task breakdown and ask user to confirm before proceeding.

## Task Writing Guidelines

- Use action verbs: "Create", "Implement", "Configure", "Test"
- Include specific deliverables
- Define success criteria
- Specify file locations
