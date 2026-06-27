---
name: blockers
description: Use when the user wants to see what is blocking their Jira tasks or what they are blocking for others. Trigger on phrases like "what's blocking me", "show my Jira blockers", "what am I blocking", or "I'm stuck on a Jira issue."
---

## blockers

Analyzes Jira issues to show the user what is blocking their progress and what they are blocking for others. Produces a structured report with severity classification, critical path analysis, and a prioritized action plan.

## Workflow

### Step 0: Verify Connection and Resolve Identity
Call `atlassianUserInfo` (no parameters) to confirm the MCP is authenticated and retrieve the current user's account details.

```
atlassianUserInfo()
```

If this fails, stop and tell the user:
> "Jira is not connected. Please run /mcp and authenticate Atlassian Rovo, then try again."

### Step 1: Get Cloud ID
Call `getAccessibleAtlassianResources` (no parameters) to retrieve the `cloudId` required for all subsequent Jira calls. Store this value — it is used in every call below.

```
getAccessibleAtlassianResources()
```

Use the `id` field from the first result as `cloudId`. If multiple sites are returned, ask the user which Jira site to use.

### Step 2: Determine Scope
Default to **my-tasks** unless the user specifies otherwise:
- **my-tasks**: issues assigned to the current user (default)
- **team**: issues assigned to any member of the user's team — ask the user to confirm team member names before proceeding
- **project**: all issues in a project — ask the user to confirm the project key before proceeding

### Step 3: Fetch Assigned Issues
Call `searchJiraIssuesUsingJql` using `currentUser()` in JQL:

```
searchJiraIssuesUsingJql:
  cloudId: {cloudId}
  jql: "assignee = currentUser() AND statusCategory != Done ORDER BY priority DESC"
  fields: ["key", "summary", "status", "assignee", "issuelinks", "subtasks", "created", "updated", "priority", "fixVersions"]
  maxResults: 50
```

If the result is empty, skip to Step 9 (Edge Cases).

### Step 4: Fetch Full Issue Detail per Assigned Issue
For each issue returned in Step 3, call `getJiraIssue` to get the full issuelinks graph:

```
getJiraIssue:
  cloudId: {cloudId}
  issueIdOrKey: {issue.key}
  fields: ["summary", "status", "assignee", "issuelinks", "priority", "created", "updated", "fixVersions", "labels", "components"]
```

From each response, extract two link directions:
- **Inward links** (`fields.issuelinks[].inwardIssue`): issues that are blocking this task
- **Outward links** (`fields.issuelinks[].outwardIssue`): issues that this task is blocking

Only process links where `issuelinks[].type.name` is one of: `"Blocks"`, `"Is blocked by"`, `"Depends on"`.
Skip any linked issue whose status is `"Done"` or `"Closed"`.

### Step 5: Fetch Details of Each Blocking Issue
For every inward link found in Step 4, call `getJiraIssue` to get blocker details:

```
getJiraIssue:
  cloudId: {cloudId}
  issueIdOrKey: {inwardIssue.key}
  fields: ["summary", "status", "assignee", "created", "updated", "priority"]
```

Calculate `days_blocked`: today's date minus `fields.created` of the blocking issue (use as a conservative estimate if the link creation date is unavailable).

### Step 6: Fetch Details of Each Blocked Issue (Reverse Lookup)
For every outward link found in Step 4, call `getJiraIssue` to get details of the issue the user is blocking:

```
getJiraIssue:
  cloudId: {cloudId}
  issueIdOrKey: {outwardIssue.key}
  fields: ["summary", "status", "assignee", "priority"]
```

Collect all unique `fields.assignee` values across these issues — this is `people_waiting`. Count them to determine how many people the user is blocking.

### Step 7: Classify Severity
Apply the rules from `references/dependency.md` to each blocker identified in Steps 5 and 6.

**Critical (🔴)** if ANY of:
- `people_waiting` > 2
- `days_blocked` > 5
- Issue has a non-empty `fields.fixVersions` (linked to a release)
- Issue has a customer-facing label or component

**Medium (🟡)** if ANY of:
- `people_waiting` is 1–2
- `days_blocked` is 2–5
- Internal dependency with no stated workaround

**Low (🟢)** if ALL of:
- Blocked on own subtask or self-assigned prerequisite
- `days_blocked` < 2
- Blocker issue status is `"In Progress"` or `"In Review"` (clear resolution path)

### Step 8: Derive Critical Path and Quick Wins

**Critical Path**: Starting from the user's highest-priority blocked task, follow outward links up to 3 levels deep to find the longest downstream chain. Format as:
```
PROJ-100 → PROJ-123 → PROJ-124 → PROJ-135
```
State the total risk: if the first task delays by N days, estimate the downstream cascade.

**Quick Wins**: Identify outward-link tasks the user can unblock today without external dependencies — specifically tasks where the user owes a code review or approval (`status = "In Review"` and the review is pending the user's action).

### Step 9: Edge Cases

**No blockers found**: Produce a brief positive summary:
> "No active blockers found across your [N] assigned tasks. You are not blocked on anything, and you are not blocking anyone else."

**No assigned issues**:
> "No active issues found assigned to you in the statuses: To Do, In Progress, In Review, Blocked. If you expected results, check your Jira project filters."

**Jira not authenticated**:
> "Jira is not connected. Please run /mcp and authenticate Atlassian Rovo, then try again."

### Step 10: Generate the Report
Produce the report following the structure in `example/template_output.md`, in this order:

1. Executive Summary — counts and the single most important action
2. What's Blocking You — Critical first, then Medium, then Low; omit any severity tier with no entries
3. What You're Blocking Others — sorted by `days_waiting` descending
4. Critical Path Analysis — longest chain and bottleneck owners
5. Action Plan — Today / This Week / Process Improvements
6. Blocker Metrics table
7. Insights & Recommendations
8. Follow-up Schedule
9. Success Criteria

Use `example/sample_output.md` as a reference for tone, depth, and formatting.
