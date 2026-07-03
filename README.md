# agent-skills

Reusable [Claude Code](https://claude.com/claude-code) skills I've built for specific,
repeatable tasks. Each skill is a self-contained Markdown definition — there is no build
step or runtime code; Claude executes the workflow in `SKILL.md` when the skill is invoked.

Skills split on one axis: **who invokes them**.
- **User-invoked** skills run only when you type them, e.g. `/deadlines`.
- **Model-invoked** skills are triggered automatically by the agent when the task matches
  the skill's `description`.

## Skill catalog

### Jira — `skills/jira/`

Skills for managing and completing Jira tickets. All require the **Atlassian Rovo** MCP
server to be authenticated (see [Requirements](#requirements)).

| Skill | Command | Invocation | What it does |
|-------|---------|-----------|--------------|
| [priorities](skills/jira/priorities/) | `/priorities` | user + model | Ranks open tickets P1→P3 and recommends the next actionable ticket |
| [deadlines](skills/jira/deadlines/) | `/deadlines` | user + model | Lists upcoming and overdue issues sorted by due date |
| [blockers](skills/jira/blockers/) | `/blockers` | user + model | Analyzes what is blocking you and what you are blocking for others |
| [brief](skills/jira/brief/) | `/brief` | user + model | Aggregates the three skills above into a single situational digest |

### Meta — `skills/meta/`

Placeholder for skills that build or manipulate other skills. Nothing shipping here yet.

## Installation

Skills live in a Claude Code skills directory. To use one, copy its folder into your
personal skills directory:

```bash
# Clone this repo
git clone <this-repo-url> agent-skills

# Copy a skill into your Claude Code user skills directory
cp -R agent-skills/skills/jira/deadlines ~/.claude/skills/deadlines
```

Restart Claude Code (or start a new session) and the skill becomes available as its slash
command (e.g. `/deadlines`).

## Requirements

- **Claude Code** (the skills are authored for and tested against the Claude Code CLI).
- The Jira skills require the **Atlassian Rovo** MCP server. Authenticate it once:
  ```bash
  claude mcp login atlassian
  ```
  In Claude Desktop / web, enable the Atlassian Rovo connector in the chat instead.

## Repository structure

```
skills/
  jira/          # Jira skill family
    <skill>/
      SKILL.md              # frontmatter + workflow (the only logic file)
      README.md             # human-facing overview and usage
      example/
        template_output.md  # output template with placeholders
        sample_output.md    # a worked reference rendering
      references/           # optional supporting rules (blockers only)
  meta/          # skills that build skills (placeholder)
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the conventions a new skill must follow, and
run `./scripts/validate_skills.sh` to check the repository structure.

## License

Released under the [MIT License](LICENSE).

---

Inspired by: https://github.com/Minda/skills
