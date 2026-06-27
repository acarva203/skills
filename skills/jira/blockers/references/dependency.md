# Dependency Detection Rules

## Jira Link Types to Analyze

### Direct Dependencies
Detected via `issuelinks` on each issue (Step 3 of workflow):
- `"Blocks"` — this issue is blocking another
- `"Is blocked by"` — this issue is blocked by another
- `"Depends on"` — this issue cannot proceed until another is resolved

### Indirect Dependencies
Detected via JQL when scope is team or project:

**Same Epic** — tasks in the same epic may have implicit ordering:
```
JQL: project = {project} AND "Epic Link" = {epic_key} AND status != Done
```

**Subtask relationships** — parent task cannot close until all subtasks are done:
```
JQL: issueType = Sub-task AND parent = {parent_key} AND status != Done
```

**Component overlap** — tasks affecting the same component may conflict:
```
JQL: project = {project} AND component = {component_name} AND status in ("In Progress", "In Review")
```

## Blocker Severity Classification

### 🔴 Critical
- Blocking more than 2 people (`people_waiting` > 2)
- Blocked for more than 5 days (`days_blocked` > 5)
- Linked to a release fix version or milestone epic
- Issue has a customer-facing label or component

### 🟡 Medium
- Blocking 1–2 people (`people_waiting` is 1–2)
- Blocked for 2–5 days (`days_blocked` is 2–5)
- Internal dependency with no stated workaround

### 🟢 Low
- Blocked on own subtask or self-assigned prerequisite
- Blocked for less than 2 days (`days_blocked` < 2)
- Blocker issue is already in progress or in review (clear resolution path)

## Action Priority Framework

### Priority 1 — Today
- Resolve blockers affecting more than 2 people
- Clear blockers older than 1 week
- Complete overdue reviews or approvals the user owes others

### Priority 2 — This Week
- Follow up on external or third-party dependencies
- Clarify missing requirements causing information blockers
- Unblock team members waiting 2+ days

### Priority 3 — Ongoing
- Add dependency tracking to sprint planning
- Establish review SLAs with recurring bottleneck teams
- Document handoff requirements to prevent repeat blocks
