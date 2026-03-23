---
description: Workflow for creating comprehensive Product Requirements Documents (PRDs) for AI-assisted development. Use when the user wants to plan a new feature or write a PRD.
applyTo: "**/*.md"
---

# Product Requirements Document (PRD) Creation Workflow

## Overview

This workflow guides you through creating comprehensive Product Requirements Documents (PRDs) that serve as the foundation for AI-assisted development tasks. The PRD should be detailed enough for a junior developer to understand and implement.

## Process

### Step 1: Initial Assessment

When a user provides a feature request or project idea, first ask clarifying questions to understand:

- **Problem/Goal**: What specific problem are we solving?
- **Target User**: Who will use this feature?
- **Core Functionality**: What are the main capabilities needed?
- **User Stories**: How will users interact with this feature?
- **Acceptance Criteria**: What defines "done"?
- **Scope/Boundaries**: What's included and excluded?
- **Data Requirements**: What data needs to be stored/processed?
- **Design/UI**: Any specific design requirements?
- **Edge Cases**: What unusual scenarios should we handle?

### Step 2: PRD Structure

Create a comprehensive PRD with these sections:

1. **Introduction/Overview** — Brief description of the feature
2. **Goals** — Primary objectives
3. **User Stories** — As a [user type], I want [functionality] so that [benefit]
4. **Functional Requirements** — Detailed feature specifications
5. **Non-Goals** — Explicitly state what's out of scope
6. **Design Considerations** — UI/UX requirements
7. **Technical Considerations** — Performance, security, scalability
8. **Success Metrics** — How will we measure success?
9. **Open Questions** — Unresolved issues

### Step 3: File Management

- Save the PRD as `prd-[feature-name].md` in a `/tasks` directory
- Use clear, descriptive filename
- Ensure proper markdown formatting

## Writing Guidelines

- Write for a junior developer audience
- Be explicit and unambiguous
- Avoid jargon and technical assumptions
- Use concrete examples where possible
- Include error handling scenarios
- Consider edge cases and boundary conditions
