# Contributing

This repository holds Claude Code skills. Each skill is a directory of Markdown files
that describe a workflow Claude runs at invocation time — there is no compiled code.
These guidelines keep every skill structurally consistent so they are easy to read,
review, and validate.

## Repository layout

Skills are grouped by area under `skills/<area>/` (e.g. `skills/jira/`). Each skill is
its own directory named after its slash command.

## Required files for a skill

A skill directory **must** contain:

| Path | Purpose |
|------|---------|
| `SKILL.md` | YAML frontmatter (`name`, `description`) followed by the ordered workflow. This is the only logic file. |
| `README.md` | Human-facing overview: what the skill does, how to invoke it, and requirements. |
| `example/template_output.md` | The output template, using placeholders. |
| `example/sample_output.md` | A concrete reference rendering that matches the template. |

Optional:

- `references/` — supporting rules or data the workflow cites (e.g. severity tables).
- `CLAUDE.md` — local editing notes. These are **git-ignored by convention** and stay
  out of version control.

`brief` is an exception to the single `sample_output.md` rule: because it renders
different output per time filter, it ships `sample_output_today.md` and
`sample_output_week.md` instead.

## `SKILL.md` frontmatter

```yaml
---
name: <slash-command-name>
description: >
  One to three sentences describing when the skill should trigger, including concrete
  trigger phrases. This is what the model matches on to auto-invoke the skill.
---
```

Both `name` and `description` are required. `name` should match the directory name and
the slash command.

## Conventions

- **Workflow steps** follow the pattern: prose description → fenced block showing the
  exact tool/MCP call and its parameters.
- **Keep templates and samples in sync.** When you change the output format, edit
  `example/template_output.md` first, then update `example/sample_output.md` to match.
- **Scope defaults to the current user.** Team/project scopes must require explicit user
  confirmation before querying.
- **MCP failures** stop the workflow with an actionable message telling the user how to
  authenticate.

## Before opening a pull request

Run the repository validator and make sure it passes:

```bash
./scripts/validate_skills.sh
```

CI runs the same check on every pull request.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/) where practical
(`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `ci:`, `chore:`). Keep each commit a
single logical change.
