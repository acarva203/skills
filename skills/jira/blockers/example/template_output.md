# Blocker Analysis Report
**Generated:** [DATE] at [TIME]
**User:** [USER display name]
**Scope:** [my-tasks | team | project]
**Jira Issues Analyzed:** [N]

---

## 🚨 Executive Summary

- **[N] tasks** currently blocked ([avg] days average)
- **[N] tasks** where you're blocking others
- **[N] critical blocker(s)** affecting [N] people
- **[N] actionable items** you can resolve today

**⚡ Top Priority:** [Single most urgent action — one sentence]

---

## 🚫 What's Blocking You

<!-- Include one subsection per severity tier. Omit the entire tier if no blockers exist at that level. -->

### 🔴 Critical Blockers

**[TASK-KEY]: [Task title]**
- **Blocked by:** [BLOCKER-KEY] ([brief blocker description])
- **Owner:** [team or person responsible for unblocking]
- **Blocked since:** [date] ([N] days)
- **Impact:** [who and what is affected downstream]
- **Downstream tasks affected:** [TASK-KEY, TASK-KEY, ...]

**Immediate Actions:**
- [ ] [Action] — [TODAY / by date]

---

### 🟡 Medium Priority Blockers

**[TASK-KEY]: [Task title]**
- **Blocked by:** [description]
- **Owner:** [owner]
- **Blocked since:** [date] ([N] days)
- **Impact:** [impact]
- **Next step:** [specific next step]

---

### 🟢 Low Priority Blockers

**[TASK-KEY]: [Task title]**
- **Blocked by:** [description]
- **Owner:** [owner]
- **Blocked since:** [date] ([N] days)
- **Next step:** [specific next step]

---

## 🚧 What You're Blocking Others

<!-- Sort by days_waiting descending. Include one entry per outward-linked task. -->

### **[TASK-KEY]: [Task title]** ⏱️ *[estimated time to resolve]*
- **Blocking:** [Person name] ([BLOCKED-KEY]: [blocked task title])
- **Waiting since:** [date] ([N] days)
- **Impact:** [what they can't do until this is resolved]
- **Action:** [what the user needs to do]

---

## 📊 Critical Path Analysis

### Longest Dependency Chain
```
[TASK-KEY] → [TASK-KEY] → [TASK-KEY] → [TASK-KEY]
([label])     ([label])    ([label])    ([label])
```
**Total Risk:** If [first task] is delayed by [N] days, the entire chain delays by [estimate].

### Bottleneck Analysis
1. **[Person or team]** — [description of what they are blocking and how many people are affected]
2. **[Person or team]** — [description]

---

## ✅ Action Plan

### 🔥 Today (High Impact)
- [ ] **[Action]** ([time estimate]) — *[who or what this unblocks]*

### 📅 This Week
- [ ] **[Action]** — [description]

### 🔄 Process Improvements
- [ ] **[Improvement]** — [description]

---

## 📈 Blocker Metrics

| Metric | Current | Target | Trend |
|--------|---------|--------|-------|
| Avg Days Blocked | [N] | <3 | [⬆️/➡️/⬇️] [text] |
| Active Blockers | [N] | <2 | [⬆️/➡️/⬇️] [text] |
| People Affected | [N] | <4 | [⬆️/➡️/⬇️] [text] |
| Resolution Rate | [N]% | >80% | [⬆️/➡️/⬇️] [text] |

---

## 💡 Insights & Recommendations

### Pattern Analysis
- **[N]% of blockers** [pattern description — e.g. involve external approvals]

### Recommended Solutions
1. **[Solution title]** — [description]

---

## 📞 Follow-up Schedule

| Date | Action | Owner |
|------|--------|-------|
| **[date]** | [action] | [owner] |

---

## 🎯 Success Criteria

**This Week:**
- [ ] [criterion]

**Next Sprint:**
- [ ] [criterion]

---

*Next blocker analysis: [date]*
