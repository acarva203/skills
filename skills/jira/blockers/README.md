## Introduction
This skill allows managers and engineers alike to save time by quickly identifying the tickets that they are blocking in Jira as well as the tickets/people that are blocking them.

## Usage

### Claude Code
This skill can be used in Claude Code with trigger phrases like "What is blocking me in Jira?" or explicitly using the skill as "/blockers".


This skill will provide an executive summary of blockers for yourself in Jira. It requires the Atlassian Rovo MCP server. 

Add it with the following line of code:
```
claude mcp login atlassian
```
### Claude Desktop/Web

Explicitly call the skill or use one of the trigger phrases in combination with turning on the Atlassian Rovo connector in chat.

## Output

Produces a structured report: executive summary, what's blocking you (by severity),
what you're blocking for others, critical-path analysis, and a prioritized action plan.
See [`example/sample_output.md`](example/sample_output.md) for a full worked example.