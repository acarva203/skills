# /brief

A situational awareness digest for engineers and PMs. Combines the output of the `/deadlines`, `/priorities`, and `/blockers` skills into a single compact report.

## Trigger phrases

- `/brief` — today's digest (default)
- `/brief today` — same as `/brief`
- `/brief week` — deadlines and blockers through end of current week
- `/brief month` — deadlines and blockers through the next 30 days
- `/brief 2026-06-25 2026-07-10` — explicit date range (YYYY-MM-DD YYYY-MM-DD)
- "give me a daily brief"
- "what should I focus on today"
- "weekly digest"
- "what's urgent"

## Filter syntax

| Command | Window |
|---|---|
| `/brief` / `/brief today` | Today + overdue |
| `/brief week` | Today → next Sunday |
| `/brief month` | Today → +30 days |
| `/brief YYYY-MM-DD YYYY-MM-DD` | Explicit inclusive range |

## Output sections

1. **🔴 Urgent Now** — overdue, highest-priority, or long-blocked tickets
2. **📅 Upcoming Deadlines** — deadline-bearing tickets not already in section 1
3. **🚧 Active Blockers** — what's blocking you and what you're blocking for others
4. **✅ Suggested Focus** — 2–3 concrete next actions (today filter only)

## Dependencies

Requires the **Atlassian Rovo** MCP server to be authenticated. If the connection fails, run `/mcp` and authenticate before retrying.

This skill delegates to the workflows defined in `../deadlines/SKILL.md`, `../priorities/SKILL.md`, and `../blockers/SKILL.md`. Those skills do not need to be invoked separately — `/brief` runs all three and synthesizes the result.
