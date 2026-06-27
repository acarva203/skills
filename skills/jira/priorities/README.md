# /priorities

A Claude Code skill that ranks your open Jira tickets by priority level.

## Usage

/priorities                  # your tickets (default)
/priorities team             # your team's tickets
/priorities project          # all tickets in a project

## What it does

1. Connects to your Jira instance via Atlassian Rovo MCP
2. Fetches all non-closed tickets for the selected scope
3. Ranks them by priority field (P1 → P2 → P3)
4. Outputs your highest-priority (P1) and lowest-priority (P3) tickets,
   plus a recommended next action

## Priority levels

P1  High
P2  Medium
P3  Low

## Requirements

- Atlassian Rovo MCP connected (/mcp → authenticate Atlassian Rovo)
- Jira tickets must use the P1/P2/P3 priority field
