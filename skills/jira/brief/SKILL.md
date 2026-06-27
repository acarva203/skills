---
name: brief
description: >
  Generate a focused situational awareness digest combining urgent deadlines, priority tickets,
  and active blockers. Trigger on: "/brief", "/brief today", "/brief week", "/brief month",
  "/brief [start-date] [end-date]", "give me a daily brief", "what should I focus on today",
  "weekly digest", "what's urgent".
---

## brief

Produces a compact situational awareness digest by fetching upcoming deadlines, high-priority
tickets, and active blockers, then synthesizing them into a single Markdown report. Scope is
always the current user (`currentUser()` in JQL).

---

## Step 0: Parse Time Filter (before any API calls)

Infer the time window from the user's message before making any API calls.

| User input | `windowEnd` | `filterLabel` |
|---|---|---|
| `/brief` or `/brief today` | Today | `"Today"` |
| `/brief week` | End of current week (next Sunday) | `"This Week"` |
| `/brief month` | Today + 30 days | `"This Month"` |
| `/brief YYYY-MM-DD YYYY-MM-DD` | Explicit end date (inclusive) | `"YYYY-MM-DD → YYYY-MM-DD"` |

`windowStart` is always today, or the explicit start date for a date-range filter.

If an explicit date range is given and `windowStart > windowEnd`, stop immediately:
> "Invalid date range: start date must be before end date."

Do not proceed to Step 1 until the time window is resolved.

---

## Step 1: Verify Connection and Resolve Identity

Call `atlassianUserInfo` (no parameters) to confirm the MCP is authenticated and retrieve
the current user's account details.

```
atlassianUserInfo()
```

Store `displayName` and `accountId`. If this call fails, stop and tell the user:
> "Jira is not connected. Please run /mcp and authenticate Atlassian Rovo, then try again."

---

## Step 2: Get Cloud ID

Call `getAccessibleAtlassianResources` (no parameters) to retrieve the `cloudId` required
for all subsequent Jira calls. Store this value — it is used in every call below.

```
getAccessibleAtlassianResources()
```

Use the `id` field from the first result as `cloudId`. If multiple sites are returned, ask
the user which Jira site to use.

---

## Step 3: Fetch Deadline-Aware Tickets

Call `searchJiraIssuesUsingJql` to fetch issues with a due date within the resolved window.
Use `windowEnd` from Step 0 as the upper bound.

```
searchJiraIssuesUsingJql:
  cloudId: {cloudId}
  jql: "assignee = currentUser() AND duedate >= -365d AND duedate <= {windowEnd} AND statusCategory != Done ORDER BY duedate ASC"
  fields: ["summary", "priority", "status", "duedate", "assignee", "sprint", "description", "customfield_10015"]
  maxResults: 50
```

Tag each result with `deadlineSource: "duedate"`. If the response indicates `total > 50`,
fetch subsequent pages by incrementing `startAt` by 50 until all results are collected; stop
at 200 and add a note in the output.

If the result is empty, proceed — tickets without a set `duedate` may still carry a deadline
in a custom field or description (Step 4).

---

## Step 4: Infer Deadlines from Descriptions

Run a second query for open issues that have **no `duedate`** but may carry a deadline in a
custom field or description text.

```
searchJiraIssuesUsingJql:
  cloudId: {cloudId}
  jql: "assignee = currentUser() AND duedate is EMPTY AND statusCategory != Done ORDER BY updated DESC"
  fields: ["summary", "priority", "status", "duedate", "assignee", "sprint", "description", "customfield_10015"]
  maxResults: 100
```

For each issue returned, extract an inferred deadline using this priority order:

1. **`customfield_10015`** (or any custom field whose name contains "need by", "needed by",
   "target date", or "deadline"). Tag as `deadlineSource: "need by field"`.
2. **Description text** — scan for phrases: `need by`, `needed by`, `due`, `deadline:`, `by`,
   `must be done by`, `must ship by`, `target:` (case-insensitive), paired with a date in
   `YYYY-MM-DD`, `MM/DD/YYYY`, `MM/DD/YY`, `Month D YYYY`, or `Month D, YYYY` format.
   Tag as `deadlineSource: "description"`. Do **not** extract standalone dates with no surrounding
   deadline keyword.

Discard issues where no inferred deadline can be found, or where the inferred deadline falls
outside the window from Step 0. Merge survivors with the Step 3 results, deduplicating by
issue key.

---

## Step 5: Fetch High-Priority Tickets

Call `searchJiraIssuesUsingJql` for open P1/P2 issues regardless of due date. These are used
to surface urgent work that may have no deadline set.

```
searchJiraIssuesUsingJql:
  cloudId: {cloudId}
  jql: "assignee = currentUser() AND priority in (Highest, High) AND statusCategory != Done ORDER BY priority ASC, updated DESC"
  fields: ["summary", "priority", "status", "duedate", "assignee", "sprint"]
  maxResults: 25
```

Merge results with the deadline pool from Steps 3–4, deduplicating by issue key. Issues that
appear in both sets carry their `deadlineSource` tag from Steps 3–4; issues that appear only
here carry `deadlineSource: null`.

---

## Step 6: Fetch Assigned Issues for Blocker Analysis

Call `searchJiraIssuesUsingJql` to fetch issues assigned to the current user in active
statuses. This is the starting pool for blocker resolution.

```
searchJiraIssuesUsingJql:
  cloudId: {cloudId}
  jql: "assignee = currentUser() AND statusCategory != Done ORDER BY priority DESC"
  fields: ["key", "summary", "status", "assignee", "issuelinks", "priority", "created", "updated", "fixVersions"]
  maxResults: 50
```

If the result is empty, skip Steps 7–9 and proceed to Step 10 with an empty blockers set.

---

## Step 7: Resolve Issue Link Details per Assigned Issue

For each issue returned in Step 6, call `getJiraIssue` to retrieve the full `issuelinks` graph.

```
getJiraIssue:
  cloudId: {cloudId}
  issueIdOrKey: {issue.key}
  fields: ["summary", "status", "assignee", "issuelinks", "priority", "created", "updated", "fixVersions", "labels", "components"]
```

From each response, extract two link directions:

- **Inward links** (`fields.issuelinks[].inwardIssue`): issues that are blocking this task
- **Outward links** (`fields.issuelinks[].outwardIssue`): issues that this task is blocking

Only process links where `issuelinks[].type.name` is one of: `"Blocks"`, `"Is blocked by"`,
`"Depends on"`. Skip any linked issue whose status is `"Done"` or `"Closed"`.

---

## Step 8: Fetch Blocker and Reverse-Blocker Details

**For each inward link** found in Step 7, call `getJiraIssue` to get blocker details:

```
getJiraIssue:
  cloudId: {cloudId}
  issueIdOrKey: {inwardIssue.key}
  fields: ["summary", "status", "assignee", "created", "updated", "priority"]
```

Calculate `days_blocked`: today's date minus `fields.created` of the blocking issue.

**For each outward link** found in Step 7, call `getJiraIssue` to get details of the issue
the user is blocking:

```
getJiraIssue:
  cloudId: {cloudId}
  issueIdOrKey: {outwardIssue.key}
  fields: ["summary", "status", "assignee", "priority"]
```

Collect all unique `fields.assignee` values across outward-link issues — this is
`people_waiting`. Count them to determine how many people the user is blocking.

---

## Step 9: Classify Blocker Severity

Apply severity to each blocker identified in Step 8.

**Critical (🔴)** if ANY of:
- `people_waiting` > 2
- `days_blocked` > 5
- Parent issue has a non-empty `fields.fixVersions`
- Parent issue has a customer-facing label or component

**Medium (🟡)** if ANY of:
- `people_waiting` is 1–2
- `days_blocked` is 2–5
- Internal dependency with no stated workaround

**Low (🟢)** if ALL of:
- Blocked on own subtask or self-assigned prerequisite
- `days_blocked` < 2
- Blocker issue status is `"In Progress"` or `"In Review"`

---

## Step 10: Apply Urgency Flags and Deduplicate

Merge the full pool — deadline tickets (Steps 3–5) and blocker-linked issues (Steps 6–9) —
deduplicating by issue key.

Mark each ticket `URGENT` if ANY of:
- Due today or overdue (effective due date ≤ today, from any `deadlineSource`)
- Priority = Highest or Critical with no resolution path visible
- `days_blocked` > 5 (from Step 9)

Assign a priority emoji to each ticket:
- 🔴 Critical / Highest
- 🟠 High
- 🟡 Medium
- 🟢 Low / Lowest

---

## Step 11: Edge Cases

**No tickets found across all three queries**: stop and tell the user:
> "No tickets found for this period. All items may be Done or unassigned."

**Jira not authenticated**: already handled in Step 1. If a mid-workflow call fails with an
auth error, stop and tell the user:
> "Jira is not connected. Please run /mcp and authenticate Atlassian Rovo, then try again."

**No deadline-bearing tickets after Step 5**: render `_No upcoming deadlines in this window._`
in Section 3 of the output.

**No blockers after Step 9**: render `_No active blockers._` in Section 4 of the output.

**Section 5 (Suggested Focus) has no candidates**: omit the section entirely — do not render
an empty list.

---

## Step 12: Generate the Brief

Produce the report in this order. For the `today` filter, keep total output under ~60 lines.

### Section 1 — Header

```
## 🗓 Brief — {displayName} | {filterLabel} | {today's date}
```

### Section 2 — 🔴 Urgent Now

Flat bulleted list of all URGENT-flagged tickets. No table.
```
- [PROJ-123] · {priorityEmoji} · {status} · Due: {date, or "overdue by N days"} · {summary}
```
If none: `_Nothing urgent right now._`

### Section 3 — 📅 Upcoming Deadlines

Compact table of deadline-bearing tickets from Steps 3–5. **Omit any ticket already listed in
Section 2.** Cap at 10 rows; if more exist add:
> _Showing 10 of {N} upcoming deadlines. Use `/deadlines` for the full list._

```
| Ticket | Summary | Priority | Status | Due Date | Days Left |
|--------|---------|----------|--------|----------|-----------|
```

Compute **Days Left** = effective due date minus today (negative = overdue). Bold values where
`abs(days) ≤ 5`.

If no tickets remain after deduplication with Section 2: `_No upcoming deadlines in this window._`

### Section 4 — 🚧 Active Blockers

Two sub-lists. Omit a sub-list (not the whole section) if it has no entries.

**Blocking you:**
```
- [PROJ-456] {summary} — blocked by [PROJ-789] ({blocker assignee}) · {days_blocked}d
```

**You're blocking:**
```
- [PROJ-321] {summary} — your ticket [PROJ-123] is needed · {assignee waiting}
```

If neither sub-list has entries: `_No active blockers._`

### Section 5 — ✅ Suggested Focus

**Only include this section for the `today` filter.** Omit entirely for `week`, `month`, and
date-range filters.

Derive 2–3 next actions using this priority order:
1. Any URGENT ticket that is overdue → `Resolve [PROJ-X]: overdue by N days`
2. Any ticket blocking > 1 person → `Unblock [PROJ-X]: N people waiting`
3. Highest-priority ticket due soonest not yet shown in Sections 2–4

```
### ✅ Suggested Focus
1. {action sentence}
2. {action sentence}
```
