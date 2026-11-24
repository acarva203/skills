# Agent Skills Research Digest — 2026-11-24

Curated by the "Agent skills research" scheduled task. Items marked **NEW** appeared or shipped in roughly the last 6 weeks.

## Skills & Prompting
- **Agent Skills Specification** — agentskills.io / GitHub — https://github.com/agentskills/agentskills — The open SKILL.md spec (name/description frontmatter + instructions + bundled files), now supported by dozens of clients incl. Claude Code, Codex, Gemini CLI, Copilot, Cursor.
- **Equipping agents for the real world with Agent Skills** — Anthropic Engineering — https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills — Canonical explanation of progressive disclosure (metadata → SKILL.md → linked files) and how to design skills.
- **Agent Skills Open Standard: portability notes** — AgentsCamp — https://agentscamp.com/guides/skills/agent-skills-open-standard — Clarifies which fields are portable vs. client-specific extensions (allowed-tools, context: fork, model, hooks).
- **OpenAI Agents SDK — Agent definitions** — OpenAI docs — https://developers.openai.com/api/docs/guides/agents/define-agents — Official guidance on scoping instructions, smallest-viable agents, and tool_choice.

## Context Engineering
- **Effective context engineering for AI agents** — Anthropic — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents — Still the reference text: "smallest set of high-signal tokens", compaction, sub-agent isolation.
- **Context Engineering for AI Agents (architecture page)** — JetBrains — https://www.jetbrains.com/pages/ai-agents/architecture/context-engineering/ — Practical failure modes; warns that "giving a struggling agent more to read" is the most common mistake.

## Tool Integration & Protocols
- **MCP 2026-07-28 Specification** — modelcontextprotocol.io — https://blog.modelcontextprotocol.io/posts/2026-07-28/ — Stateless core (no initialize handshake/session ID), multi-round-trip requests, cacheable tools/list with ttlMs, header-based routing, auth hardening (iss validation, CIMD). Next spec targeted for March 2027.
- **Scaling agent infrastructure with MCP stateless updates** — Google Developers Blog — https://developers.googleblog.com/scaling-ai-agent-infrastructure-with-the-mcp-stateless-updates/ — How the stateless spec simplifies horizontally scaled MCP servers.
- **NEW — Personal Agent Protocol ("Poppy") 1.0** — Sierra & Meta — https://sierra.ai/blog/releasing-poppy — OAuth-based standard for how personal agents authenticate to and act on business sites/APIs (guest vs. read/write access); complements MCP rather than replacing it. Announced Oct 6, 1.0 reported ~mid-Nov 2026 (date not independently verified).

## Frameworks
- **NEW — Microsoft Agent Framework (Python 1.26.0, Nov 12 2026)** — https://markaicode.com/tutorial/microsoft-agent-framework-guide/ — MIT-licensed AutoGen/Semantic Kernel successor; actively releasing.
- **NEW — CopilotKit OpenBot 1.0 (Nov 9 2026)** — via https://munderdiffl.in/blog/agent-tools-today-2026-11-24/ — MIT template for "AI coworkers" where every action passes a policy gateway and is audit-logged (underlying intelligence layer licensed separately).
- **Vercel eve (1.0 RCs since late Oct 2026)** — via https://www.firecrawl.dev/blog/best-open-source-agent-frameworks — Apache-2.0 TypeScript agent framework nearing 1.0.
- **AG2 v1.0** — Apache-2.0 community successor to the original AutoGen line (July 2026).

## Reasoning & Planning
- **Efficient Agentic Reasoning Through Self-Regulated Simulative Planning** — arXiv 2605.22138 — https://arxiv.org/abs/2605.22138 — Learned controller decides *when* to plan; 25–95% fewer reasoning tokens at comparable accuracy.
- **PreFlect: Prospective Reflection in LLM Agents** — arXiv 2602.07187 — https://arxiv.org/pdf/2602.07187 — Reflect on the plan *before* execution using distilled error patterns.
- **ReflectFact** — arXiv 2608.12877 — https://arxiv.org/abs/2608.12877 — Step-level self-reflection and regeneration for multi-hop fact verification.
- **Awesome-Agentic-Reasoning** — GitHub — https://github.com/weitianxin/Awesome-Agentic-Reasoning — Maintained paper list accompanying the "Agentic Reasoning for LLMs" survey.

## Evaluation
- **Survey on Evaluation of LLM-based Agents (v2, Apr 2026)** — arXiv 2503.16416 — https://arxiv.org/abs/2503.16416 — Broad map of agent benchmarks; trend toward live, continuously updated evals.
- **General AgentBench / test-time scaling** — arXiv 2602.18998 — https://arxiv.org/html/2602.18998v1 — Shows big drops when agents leave domain-specific benchmarks; limits of scaling steps/samples.
- **EnterpriseBench** — arXiv 2609.37658 — https://arxiv.org/abs/2609.37658v1 — Interactive enterprise decision-making (e.g., supply-chain sim).
- **AgentPerfBench** — arXiv 2609.34683 — https://arxiv.org/abs/2609.34683v1 — Measures inference cost/latency of agentic workloads, not just accuracy.
- **Pilot audit of agent benchmark papers** — arXiv 2605.21404 — https://arxiv.org/abs/2605.21404 — Benchmarks average 0.38/1.0 on disclosure; inference cost rarely reported. Useful checklist when choosing evals.

## Security note
- Typosquatted skills were reported on a public skill registry earlier in 2026 — read SKILL.md and bundled scripts before installing third-party skills.

## Caveats
Several framework/version details come from aggregator pages; verify on each project's release page. sierra.ai was not reachable from this session, so the Poppy 1.0 details are from search snippets only. No notable reasoning papers dated Oct–Nov 2026 surfaced in search (index may lag).
