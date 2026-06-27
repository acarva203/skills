# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A collection of Claude Code skills that integrate with Jira via the **Atlassian Rovo MCP**. Each subdirectory is a self-contained skill with its own git history. There is no build system, test suite, or runnable application — the artifacts are Markdown-based skill definitions that Claude executes at runtime.

## Skills

| Skill | Slash Command | Purpose |
|---|---|---|
| `priorities/` | `/priorities` | Ranks open Jira tickets P1→P3 and recommends the next actionable ticket |
| `deadlines/` | `/deadlines` | Lists upcoming/overdue Jira issues sorted by due date |
| `blockers/` | `/blockers` | Analyzes what is blocking the user and what the user is blocking for others |
| `brief/` | `/brief` | Aggregator — runs all three skills above and synthesizes a single digest |

The `brief` skill is a synthesis layer: its `SKILL.md` delegates to the workflows in `deadlines/SKILL.md`, `priorities/SKILL.md`, and `blockers/SKILL.md` rather than duplicating their MCP call logic. Edit those source skills to change behavior; edit `brief/SKILL.md` only to change how the combined output is rendered.

Each skill shares the same three-step auth pattern:
1. `atlassianUserInfo()` — confirm MCP auth and get current user identity
2. `getAccessibleAtlassianResources()` — retrieve `cloudId` (required for all subsequent Jira calls)
3. Scope resolution (`my-tasks` / `team` / `project`) — default is always `my-tasks`

## Skill File Layout

Every skill subdirectory follows this structure:
- `SKILL.md` — frontmatter (`name`, `description`) + ordered workflow steps with exact MCP call signatures; **this is the only logic file**
- `CLAUDE.md` — guidance for editing the skill
- `example/sample_output.md` — reference rendering showing expected output (brief uses `sample_output_today.md` and `sample_output_week.md`)
- `example/template_output.md` — Handlebars-style template with all variable placeholders
- `references/` (blockers only) — severity classification rules

## MCP Dependency

All skills require the **Atlassian Rovo** MCP server to be authenticated. If `atlassianUserInfo()` fails, skills stop and instruct the user to run `/mcp` and authenticate.

## Editing Skills

- To change skill behavior: edit `SKILL.md`. It is the source of truth for runtime logic.
- To change output format: edit `example/template_output.md` first, then update `example/sample_output.md` to match.
- `cloudId` from `getAccessibleAtlassianResources()` must be threaded through all subsequent MCP calls.
- Team/project scopes always require user confirmation before querying.

