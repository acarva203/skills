---
name: deadlines
description: >
  List upcoming Jira deadlines for the current user, a team, or a project.
  Trigger phrases: "What are my upcoming deadlines?", "List my tasks due soon", "What's due this sprint?",
  "Show deadlines for project X", "What are my overdue tickets?",
  "Show me tasks due in the next 2 weeks", "What does my team have due?".
---

## Introduction

This skill fetches upcoming (and overdue) Jira issues assigned to the current user (or a specified team/project), sorted by due date, and renders them as a color-coded Markdown table. It requires the Atlassian Rovo MCP to be authenticated.

## Workflow

### Step 0: Determine Scope and Time Window (before any API calls)

Infer both scope and time window from the user's message before making any API calls.

**Scope:**
- **my-tasks** (default): user mentions "my", "I", or no specific scope
- **team**: user mentions "team", "us", or names specific people
- **project**: user mentions a project name or project key (e.g. "project ENG", "ENG board")

For **team** scope: extract the names or handles the user mentioned. If none were given, ask:
> "Who should I include? Please list the team members' names."

For **project** scope: extract the project key if present. If ambiguous, ask:
> "Which project? Please provide the project key (e.g. ENG, PLATFORM)."

**Time window:**

Parse the user's message for a look-ahead window. Use these mappings:

| User says | `duedate` upper bound |
|---|---|
| "this week" | end of current week (next Sunday) |
| "this sprint" / "this iteration" | no upper bound (sprint filter handles it) |
| "next N days" / "in the next N days" | `+Nd` from today |
| "next week" | `+14d` |
| "next N weeks" | `+N*7d` |
| "next month" / "this month" | `+30d` |
| nothing specified | `+30d` (default) |

The lower bound always includes overdue issues: use `duedate >= -365d` to capture issues up to a year past due without an open-ended scan.

Do not proceed to Step 1 until both scope and time window are resolved.

### Step 1: Verify Connection and Resolve Identity + Get Cloud ID (run in parallel)

These two calls are independent — run them at the same time:

**1a.** Call `atlassianUserInfo` (no parameters) to confirm MCP auth and retrieve the current user's account details.

```
atlassianUserInfo()
```

If this fails, stop and tell the user:
> "Jira is not connected. Please run /mcp and authenticate Atlassian Rovo, then try again."

Store the returned `displayName` and `accountId`.

**1b.** Call `getAccessibleAtlassianResources` (no parameters) to retrieve the `cloudId` required for all subsequent Jira calls.

```
getAccessibleAtlassianResources()
```

Use the `id` field from the first result as `cloudId`. If multiple sites are returned, ask the user which Jira site to use.

### Step 2: Resolve Team Member Account IDs (team scope only)

For **team** scope, call `lookupJiraAccountId` for each team member name collected in Step 0.

```
lookupJiraAccountId(cloudId, displayName)
```

- If a lookup returns exactly one match, use that `accountId`.
- If a lookup returns multiple matches, show the candidates (name + email) and ask the user to confirm which one:
  > "I found multiple users named 'Alex Smith'. Which one do you mean?
  > 1. Alex Smith — alex.smith@example.com
  > 2. Alex Smith — asmith@other.com"
- If a lookup returns no matches, warn the user and skip that person:
  > "Couldn't find a Jira user matching 'Jordan'. They will be excluded from results."

Collect all resolved `accountId` values before proceeding.

### Step 3: Query Jira

#### 3a. Issues with a `duedate` set

Call `searchJiraIssuesUsingJql` with the `cloudId` from Step 1b and a JQL query based on the scope and time window from Step 0. Replace `WINDOW` with the resolved upper bound (e.g. `+30d`).

Use these JQL templates:

**my-tasks (default):**
```
assignee = currentUser() AND duedate >= -365d AND duedate <= WINDOW AND statusCategory != Done ORDER BY duedate ASC
```

**team** (use account IDs resolved in Step 2):
```
assignee in (ACCOUNT_ID_1, ACCOUNT_ID_2) AND duedate >= -365d AND duedate <= WINDOW AND statusCategory != Done ORDER BY duedate ASC
```

**project** (use confirmed project key):
```
project = PROJ AND duedate >= -365d AND duedate <= WINDOW AND statusCategory != Done ORDER BY duedate ASC
```

Request these fields: `summary`, `priority`, `status`, `duedate`, `sprint`, `assignee`, `description`, `customfield_10015` (the standard "need by" / start-date custom field).

**Pagination:** `searchJiraIssuesUsingJql` returns at most 50 results per call. If the response indicates `total > 50`, fetch subsequent pages by incrementing `startAt` by 50 until all results are collected. If the total exceeds 200, stop paginating and add a note below the table:
> "Showing the 200 nearest deadlines. Narrow the time window or filter by project to see more."

#### 3b. Issues without a `duedate` but with a "need by" field or date in the description

Run a second query for open issues in the same scope that have **no `duedate`** set but may carry a deadline in a custom field or in the issue text:

**my-tasks:**
```
assignee = currentUser() AND duedate is EMPTY AND statusCategory != Done ORDER BY updated DESC
```

**team:**
```
assignee in (ACCOUNT_ID_1, ACCOUNT_ID_2) AND duedate is EMPTY AND statusCategory != Done ORDER BY updated DESC
```

**project:**
```
project = PROJ AND duedate is EMPTY AND statusCategory != Done ORDER BY updated DESC
```

Request the same fields as in Step 3a. Limit this query to 100 results (`maxResults=100`); do not paginate further.

For each issue returned, extract an **inferred deadline** using this priority order:

1. **`customfield_10015`** (or any custom field whose name contains "need by", "needed by", "target date", or "deadline" — check the field labels in the response). Use the value directly if it is a date string.
2. **Description text** — scan for date-like patterns using these heuristics:
   - Explicit phrases: `need by <date>`, `needed by <date>`, `due <date>`, `deadline: <date>`, `by <date>`, `must be done by <date>`, `must ship by <date>`, `target: <date>` (case-insensitive).
   - Bare date formats adjacent to a deadline keyword: `YYYY-MM-DD`, `MM/DD/YYYY`, `MM/DD/YY`, `Month D YYYY`, `Month D, YYYY` (e.g. "June 30 2026", "Jul 1, 2026").
   - Do **not** extract standalone dates with no surrounding context — only dates paired with a deadline-indicating keyword or phrase.

Discard issues where no inferred deadline can be found, or where the inferred deadline falls outside the time window from Step 0. Merge survivors with the results from Step 3a, deduplicating by issue key. Each issue carries a `deadlineSource` tag:
- `duedate` — came from Step 3a
- `need by field` — inferred from a custom field in Step 3b
- `description` — inferred from issue text in Step 3b

### Step 4: Render Output

Display results as a Markdown table using the format from `example/template_output.md`. See `example/sample_output.md` for a reference rendering.

**Table header — my-tasks / project view:**
```
| Ticket | Summary | Priority | Status | Due Date | Days Remaining | Sprint | Deadline Source |
```

**Table header — team view** (add Assignee column):
```
| Ticket | Summary | Assignee | Priority | Status | Due Date | Days Remaining | Sprint | Deadline Source |
```

**Formatting rules:**
- For each issue, the **Due Date** column shows:
  - The `duedate` field value if `deadlineSource` is `duedate`.
  - The inferred date if `deadlineSource` is `need by field` or `description`.
- Compute **Days Remaining** = effective due date minus today's date (negative if overdue).
- Bold Days Remaining values where `abs(days) ≤ 5` (e.g., `**3**`, `**-2**`).
- Map priority to emoji: 🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Low.
- If `sprint` is not available for an issue, leave that cell blank.
- **Deadline Source** column values:
  - `due date` — the Jira `duedate` field was set
  - `need by field` — date came from a "need by" / target-date custom field
  - `description` — date was parsed from the issue description text
- Title the section with the user's `displayName` from Step 1a (e.g., `## My Deadlines — Sarah Chen`).

**Overdue issues:**
- Split the table into two sections when overdue issues exist:
  1. `### Overdue` — issues where the effective due date (from any source) is before today, sorted ascending (most overdue first).
  2. `### Upcoming` — issues where the effective due date is today or later, sorted ascending.
- If there are no overdue issues, render a single table with no section header.

If no issues are returned, tell the user:
> "No upcoming deadlines found. All issues either have no due date set or are already marked Done."
