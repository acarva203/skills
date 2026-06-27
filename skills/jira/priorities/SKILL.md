---
name: priorities
description: This skill helps you identify which tickets are your highest and lowest priority. It uses a scoring system to rank tickets based on various factors such as urgency, impact, and complexity. Triggers on phrases like "what are my highest priority tickets" or "show me the lowest priority tickets".
---

## priorities

This is a skill that helps you identify which tickets are your highest and lowest priority. It uses a scoring system to rank tickets based on various factors such as urgency, impact, and complexity.

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


### Step 3: Fetch Issues by Scope
Use the scope determined in Step 2 to build the JQL query. In all cases fetch these fields: `["key", "summary", "status", "assignee", "issuelinks", "subtasks", "created", "updated", "priority", "fixVersions"]` with `maxResults: 50`.

**my-tasks (default)**
```
searchJiraIssuesUsingJql:
  cloudId: {cloudId}
  jql: "assignee = currentUser() AND status != 'Closed' ORDER BY priority DESC"
  fields: [...]
  maxResults: 50
```

**team** — run one query per confirmed team member, substituting their accountId:
```
searchJiraIssuesUsingJql:
  cloudId: {cloudId}
  jql: "assignee = '{accountId}' AND status != 'Closed' ORDER BY priority DESC"
  fields: [...]
  maxResults: 50
```

**project** — use the confirmed project key:
```
searchJiraIssuesUsingJql:
  cloudId: {cloudId}
  jql: "project = '{projectKey}' AND status != 'Closed' ORDER BY priority DESC"
  fields: [...]
  maxResults: 50
```

Merge results from all queries (for team scope) and deduplicate by issue key.

### Step 4: Score Issues by Priority Field

Map each issue's `priority.name` to a numeric score:

| Priority name (Jira) | Score |
|---|---|
| P1 | 3 |
| P2 | 2 |
| P3 | 1 |
| Unknown / missing | 2 |

Matching is case-insensitive. Sort all issues by score descending.

### Step 5: Identify Top and Bottom Tickets

From the sorted list:
- **Highest priority**: all P1 issues (score 3) — show up to 5 total
- **Lowest priority**: all P3 issues (score 1) — show up to 5 total

If fewer than 5 issues exist in either direction, show all of them.

### Step 6: Present Results

Output two sections. Omit any section that has no tickets.

```
## Your Priority Breakdown

### 🔴 Highest Priority (P1)
- [KEY-123] Summary text | Priority: P1 | Status: In Progress
- [KEY-456] Summary text | Priority: P1 | Status: To Do

### 🟢 Lowest Priority (P3)
- [KEY-789] Summary text | Priority: P3 | Status: To Do
- [KEY-012] Summary text | Priority: P3 | Status: To Do
```

After the table, add one sentence recommending the single most actionable next ticket: the highest-scored issue still in `To Do` or `In Progress`.

If no issues were returned at all, tell the user:
> "No open tickets found for the selected scope."