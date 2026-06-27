# /brief Output Template

## 🗓 Brief — {{displayName}} | {{filterLabel}} | {{todayDate}}

---

### 🔴 Urgent Now

- [{{PROJ-XXX}}] · {{priorityEmoji}} · {{status}} · Due: {{dueDate or "overdue by N days"}} · {{summary}}
- [{{PROJ-XXX}}] · {{priorityEmoji}} · {{status}} · Due: {{dueDate or "overdue by N days"}} · {{summary}}

_If none:_ `_Nothing urgent right now._`

---

### 📅 Upcoming Deadlines

_(Omit tickets already listed in Urgent Now)_

| Ticket | Summary | Priority | Status | Due Date | Days Left |
|--------|---------|----------|--------|----------|-----------|
| [{{PROJ-XXX}}] | {{summary}} | {{priorityEmoji}} | {{status}} | {{dueDate}} | {{daysLeft}} |
| [{{PROJ-XXX}}] | {{summary}} | {{priorityEmoji}} | {{status}} | {{dueDate}} | **{{daysLeft ≤ 5}}** |

_If > 10 rows:_ `_Showing 10 of {{N}} upcoming deadlines. Use /deadlines for the full list._`

_If none:_ `_No upcoming deadlines in this window._`

---

### 🚧 Active Blockers

**Blocking you:**
- [{{PROJ-XXX}}] {{summary}} — blocked by [{{PROJ-YYY}}] ({{assignee}}) · {{N}}d
- [{{PROJ-XXX}}] {{summary}} — blocked by [{{PROJ-YYY}}] ({{assignee}}) · {{N}}d

**You're blocking:**
- [{{PROJ-XXX}}] {{summary}} — your ticket [{{PROJ-YYY}}] is needed · {{assigneeWaiting}}
- [{{PROJ-XXX}}] {{summary}} — your ticket [{{PROJ-YYY}}] is needed · {{assigneeWaiting}}

_If none:_ `_No active blockers._`

---

### ✅ Suggested Focus

_(Today filter only — omit for week / month / date-range)_

1. {{actionSentence}}
2. {{actionSentence}}
3. {{actionSentence (optional)}}
