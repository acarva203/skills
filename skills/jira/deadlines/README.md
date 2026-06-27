## Introduction
/deadlines is a Claude skill that when combined with the Atlassian MCP should provide the user with a list of their upcoming deadlines within the CLI. Limited to Claude Code and optimized for individual use, but can be expanded for team view for managers.


## Usage
### Claude Code
This skill can be used in Claude Code with trigger phrases like "What's due this week?" or explicitly using the skill as "/deadlines".

This skill will provide an executive summary of blockers for yourself in Jira. It requires the Atlassian Rovo MCP server.

Add it with the following line of code:
```
claude mcp login atlassian
```
### Claude Desktop/Web
Explicitly call skill or use one of the trigger phrases in combination with turning on the Atlassian Rovo connector in chat.
