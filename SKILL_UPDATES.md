# Sequential Workflow Skills - Decoupled Structure

This document outlines the separation of sequential-workflow into two distinct skills:
1. **sequential-planning** - Creates prompts and handoff files
2. **sequential-execution** - Executes existing prompts

---

## 1. Sequential Planning Skill

**File:** `~/.claude/skills/sequential-planning/README.md`

### Purpose
Plan multi-step implementations as numbered prompts with Archon integration. Creates self-contained prompt files but does NOT execute them.

### When to Use

#### For PLANNING (creating prompts)
- "Create a plan" / "plan the implementation"
- "Break this into steps" / "break into prompts"
- "Sequential prompts" / "numbered prompts"
- "Generate implementation prompts"
- Complex features requiring 3+ steps

### What It Does

1. Gathers requirements (project name, directory, goal)
2. Searches Archon knowledge base for relevant patterns
3. Analyzes and breaks down task into atomic steps
4. Shows preview for user approval
5. Creates Archon project and tasks
6. Generates numbered prompt files (01-xxx.md, 02-xxx.md, etc.)
7. Generates HANDOFF file with execution trigger
8. Displays summary

### What It Does NOT Do

- Does NOT execute prompts
- Does NOT launch sub-agents
- Does NOT modify code/files (except creating prompt files)

### Key Change: HANDOFF Template

The HANDOFF file must end with an explicit invocation of the execution skill:

```markdown
---

## ACTION REQUIRED

To execute this plan, use the sequential-execution skill:

**Invoke the sequential-execution skill** to run the prompts in `/full/path/to/prompts/`.
```

### Output Files

- `prompts/HANDOFF-[project-slug].md` - Entry point
- `prompts/01-[name].md` - First step
- `prompts/02-[name].md` - Second step
- ... (one file per step)

---

## 2. Sequential Execution Skill

**File:** `~/.claude/skills/sequential-execution/README.md`

### Purpose
Execute numbered prompt files sequentially using Opus 4.5 sub-agents. Stops on failure, archives on success.

### When to Use

#### For EXECUTION (running prompts)
- "Execute prompts" / "run prompts" / "run the plan"
- References to prompts directory (e.g., "prompts/01-xxx.md")
- "Execute sequential plan" / "run sequential"
- "Start from prompt [X]"
- Any numbered .md files (01-xxx.md, 02-xxx.md)
- When HANDOFF prompt invokes this skill

### Workflow

#### Step 1: Gather Input

Ask the user:
```
To execute your sequential prompts, I need:

1. **Prompts Directory**: Full path to the prompts folder?
2. **Starting Prompt** (optional): Start from beginning or specific prompt?

Note: All prompts will be executed using Opus 4.5 sub-agents.
```

#### Step 2: Discover and Validate Prompts

```bash
ls -1 [PROMPTS_DIR]/*.md | sort
```

Validate:
- Directory exists with .md files
- Files follow numbered naming
- Starting prompt exists (if specified)

#### Step 3: Show Execution Preview

```
Sequential Execution Plan
=========================

Directory: [path]
Prompts Found: [N]
Starting From: [prompt name]

Execution Order:
  1. 01-setup.md
  2. 02-implementation.md
  3. 03-testing.md

Model: Opus 4.5 (all sub-agents)

If any step fails, execution stops for your review.

Proceed? (yes/no)
```

**Wait for approval.**

#### Step 4: Execute Prompts Sequentially

For each prompt in order:

**4a. Read the Prompt**
```bash
cat [PROMPTS_DIR]/[prompt_file]
```

**4b. Launch Sub-Agent**

Use Task tool with `subagent_type: "general-purpose"` and `model: "opus"`.

Sub-agent prompt:
```
# Sequential Prompt Execution

You are executing step [N] of [TOTAL].

## Your Task

Execute the following prompt completely:

---
[FULL PROMPT CONTENT]
---

## Requirements

1. Implement everything specified
2. Update Archon status (in_progress → done/blocked)
3. Run success criteria to verify
4. Do NOT proceed to other prompts

## Required Report Back

### EXECUTION REPORT

**Status**: [SUCCESS | FAILURE | BLOCKED]
**Archon Task Status**: [in_progress/done/blocked]
**What Was Accomplished**: [bullets]
**Files Created/Modified**: [list]
**Verification Results**: [results]
**Issues/Blockers**: [any problems]
**Ready for Next Step**: [YES | NO]
```

**4c. Process Report**

- **If SUCCESS and Ready = YES**: Proceed to next prompt
- **If FAILURE/BLOCKED or Ready = NO**: Stop and report to user

#### Step 5: Handle Failures

```
EXECUTION STOPPED
=================

Failed at: [prompt filename]
Step: [N] of [TOTAL]

Issues/Blockers: [from report]

Remaining Prompts Not Executed:
- [list]

Options:
1. Fix issues manually and re-run from this prompt
2. Modify the prompt and retry
3. Skip (not recommended if dependencies exist)
```

**Wait for user direction.**

#### Step 6: Completion Summary

```
SEQUENTIAL EXECUTION COMPLETE
=============================

Prompts Executed: [N] of [N]
All Steps: SUCCESS

Execution Summary:
- 01-setup.md: SUCCESS [brief summary]
- 02-implementation.md: SUCCESS [brief summary]

All Archon tasks marked as 'done'.
```

#### Step 7: Archive Completed Prompts

After ALL prompts execute successfully, move them to an archive folder:

**7a. Create Archive Directory**
```bash
mkdir -p [PROMPTS_DIR]/IGNORE_OLDPROMPTS
```

**7b. Move Executed Prompts**
```bash
# Move numbered prompts
mv [PROMPTS_DIR]/[0-9][0-9]-*.md [PROMPTS_DIR]/IGNORE_OLDPROMPTS/

# Move HANDOFF file
mv [PROMPTS_DIR]/HANDOFF-*.md [PROMPTS_DIR]/IGNORE_OLDPROMPTS/ 2>/dev/null || true
```

**7c. Create Completion Marker**
```bash
cat > [PROMPTS_DIR]/IGNORE_OLDPROMPTS/EXECUTION_COMPLETE.md << 'EOF'
# Execution Complete

**Date:** [TIMESTAMP]
**Project:** [PROJECT_NAME]
**Archon Project ID:** [PROJECT_ID]

## Prompts Executed
- [list of prompts with status]

## All Archon Tasks: DONE
EOF
```

**IMPORTANT**: Only archive prompts after ALL steps complete successfully.

### What It Does NOT Do

- Does NOT create prompts
- Does NOT plan implementations
- Does NOT modify prompts (only executes them)

---

## 3. Updated HANDOFF Template

**File:** `~/.claude/skills/sequential-planning/references/handoff-template.md`

```markdown
# HANDOFF: [Project Name]

You are receiving a handoff for implementing [brief description].

---

## Project Overview

**Project Name:** [project-name]
**Archon Project ID:** [project_id]
**Working Directory:** `/full/path/to/project`
**Archon Host:** http://localhost:8181

### Objective

[Detailed objective description]

### Environment

[Environment details]

---

## Implementation Plan

This project is broken into [N] sequential steps:

### Step 1: [Title]
**File:** `01-[slug].md`
**Task ID:** [task_id]
**What:** [description]
**Depends On:** None

### Step 2: [Title]
**File:** `02-[slug].md`
**Task ID:** [task_id]
**What:** [description]
**Depends On:** Step 1

[... more steps ...]

---

## Deliverables

[List of files/artifacts that will be created]

---

## Success Criteria

The setup is complete when:

1. ✅ [Criterion 1]
2. ✅ [Criterion 2]
3. ✅ [Criterion 3]

---

## Important Notes

[Key technical requirements, design principles, constraints]

---

## Archon Integration

All steps are tracked in Archon:
- **Project:** [name] (ID: [project_id])
- **Tasks:** [N] tasks created (one per step)
- **API:** http://localhost:8181/api/

---

## Execution Instructions

The prompts are designed to be executed sequentially by Opus 4.5 sub-agents. Each prompt:
- Is self-contained with full context
- Has pre-populated Archon task ID
- Includes success criteria and verification commands
- Has explicit Archon status update commands

Execute in order:
1. 01-[name].md
2. 02-[name].md
[... list all prompts ...]

If any step fails, stop and resolve before continuing.

---

## ACTION REQUIRED

To execute this plan, use the **sequential-execution** skill.

The prompts are located in: `/full/path/to/prompts/`

Invoke the sequential-execution skill to run the plan.
```

---

## 4. Skill Invocation Flow

### Current Behavior (Coupled)
```
User: "Create a plan and execute it"
  ↓
sequential-workflow skill
  ↓
Creates prompts + Executes prompts
```

### New Behavior (Decoupled)

#### Scenario 1: Plan Only
```
User: "Create a plan for [task]"
  ↓
sequential-planning skill
  ↓
Creates prompts + HANDOFF file
  ↓
User decides when to execute
```

#### Scenario 2: Plan + Execute
```
User: "Create a plan and execute it"
  ↓
sequential-planning skill
  ↓
Creates prompts with HANDOFF that invokes execution skill
  ↓
User pastes HANDOFF or directly invokes sequential-execution skill
  ↓
sequential-execution skill
  ↓
Executes all prompts sequentially
```

#### Scenario 3: Execute Existing Prompts
```
User: "Execute the prompts in ./prompts/"
  ↓
sequential-execution skill
  ↓
Executes existing prompts (no planning phase)
```

---

## 5. Benefits of Decoupling

### Flexibility
- Create prompts for later execution
- Execute prompts created in previous sessions
- Share prompt sets between projects

### Clarity
- Clear separation of planning vs. execution
- Each skill has single responsibility
- Easier to understand and maintain

### Reusability
- Execution skill works with any numbered prompts
- Planning skill can create prompts for different execution contexts
- HANDOFF files can be shared/version controlled

### Debugging
- Can modify prompts after creation, before execution
- Can re-execute failed prompts without re-planning
- Can execute prompts manually if needed

---

## 6. Migration Guide

### For Users

1. **Update sequential-workflow skill:**
   - Rename to `sequential-planning`
   - Remove execution workflow (Part 2)
   - Update HANDOFF template to invoke sequential-execution skill

2. **Create sequential-execution skill:**
   - New skill with only execution workflow
   - Auto-detects prompts directory
   - Handles archiving on success

3. **Update skill descriptions:**
   - `sequential-planning`: "Plan multi-step implementations as numbered prompts. Does NOT execute."
   - `sequential-execution`: "Execute numbered prompts sequentially using Opus 4.5 sub-agents."

### For Existing Prompts

Existing HANDOFF files need one change:

**Old ACTION section:**
```markdown
## ACTION REQUIRED

Execute the prompts in `/path/to/prompts/` sequentially.

Run the plan now.
```

**New ACTION section:**
```markdown
## ACTION REQUIRED

To execute this plan, use the **sequential-execution** skill.

The prompts are located in: `/path/to/prompts/`

Invoke the sequential-execution skill to run the plan.
```

---

## 7. Implementation Checklist

- [ ] Rename sequential-workflow to sequential-planning
- [ ] Remove execution code from sequential-planning
- [ ] Update sequential-planning HANDOFF template
- [ ] Create sequential-execution skill
- [ ] Add execution workflow to sequential-execution
- [ ] Update skill descriptions
- [ ] Update trigger phrases in both skills
- [ ] Test planning without execution
- [ ] Test execution without planning
- [ ] Test full workflow (plan → execute)

---

## Files to Modify

1. `~/.claude/skills/sequential-planning/README.md`
2. `~/.claude/skills/sequential-planning/references/handoff-template.md`
3. `~/.claude/skills/sequential-execution/README.md` (new)

---

Would you like me to generate the complete skill files for both sequential-planning and sequential-execution?
