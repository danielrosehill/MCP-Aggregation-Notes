// MCP Aggregation Report — Typst source
// Font: IBM Plex Sans

#set document(
  title: "MCP Aggregation, Gateway, and Proxy Tools: State of the Ecosystem (Q1 2026)",
  author: "Daniel Rosehill",
  date: datetime(year: 2026, month: 4, day: 5),
)

#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 8pt, fill: rgb("#666666"))
      MCP Aggregation Ecosystem Report — Q1 2026
      #h(1fr)
      #counter(page).display()
    ]
  },
  footer: context {
    if counter(page).get().first() == 1 [
      #align(center)[
        #set text(size: 8pt, fill: rgb("#999999"))
        Research conducted April 2026. Tool capabilities based on documentation and public sources.
      ]
    ]
  },
)

#set text(font: "IBM Plex Sans", size: 10pt, fill: rgb("#1a1a1a"))
#set par(justify: true, leading: 0.7em)
#set heading(numbering: none)

#show heading.where(level: 1): it => {
  set text(size: 22pt, weight: "bold", fill: rgb("#0d1b2a"))
  block(above: 0pt, below: 12pt, it.body)
}

#show heading.where(level: 2): it => {
  set text(size: 14pt, weight: "bold", fill: rgb("#1b3a5c"))
  block(above: 20pt, below: 8pt, it.body)
}

#show heading.where(level: 3): it => {
  set text(size: 11pt, weight: "bold", fill: rgb("#2d6a4f"))
  block(above: 12pt, below: 4pt, it.body)
}

// Custom styling for tables
#set table(
  stroke: 0.5pt + rgb("#cccccc"),
  inset: 6pt,
)
#show table.cell.where(y: 0): set text(weight: "bold", size: 9pt)

// Utility functions
#let tag(label, color) = {
  box(
    fill: color.lighten(80%),
    stroke: 0.5pt + color,
    radius: 3pt,
    inset: (x: 5pt, y: 2pt),
    text(size: 8pt, weight: "bold", fill: color.darken(20%), label)
  )
}

#let fit-item(body) = {
  text(fill: rgb("#2d6a4f"), sym.checkmark)
  h(4pt)
  body
}

#let gap-item(body) = {
  text(fill: rgb("#c1121f"), sym.times)
  h(4pt)
  body
}

// ─── Title Page ───

#v(3cm)

#align(center)[
  #block(width: 80%)[
    #set text(size: 28pt, weight: "bold", fill: rgb("#0d1b2a"))
    MCP Aggregation, Gateway, and Proxy Tools
  ]
  #v(8pt)
  #block(width: 70%)[
    #set text(size: 16pt, fill: rgb("#415a77"))
    State of the Ecosystem — Q1 2026
  ]
  #v(24pt)
  #line(length: 40%, stroke: 1pt + rgb("#778da9"))
  #v(16pt)
  #set text(size: 11pt, fill: rgb("#555555"))
  Daniel Rosehill \
  April 2026
]

#v(2cm)

#block(
  width: 100%,
  fill: rgb("#f0f4f8"),
  radius: 6pt,
  inset: 16pt,
)[
  #set text(size: 10pt)
  *Abstract.* This report evaluates 17 MCP aggregation, gateway, and proxy tools against a target architecture requiring a three-level hierarchy (Servers → Namespaces → Endpoints), 1:many endpoint-to-namespace mapping, nested federation, and per-client tool visibility. No tool fully satisfies all requirements as of Q1 2026. IBM ContextForge and MetaMCP come closest, with ContextForge leading on federation and MetaMCP on hierarchical organization. The ecosystem has converged on flat aggregation with RBAC — effective for enterprise governance but insufficient for multi-dimensional tool organization.
]

#pagebreak()

// ─── Table of Contents ───

#outline(title: "Contents", indent: 1.5em, depth: 2)

#pagebreak()

// ─── Target Architecture ───

= Target Architecture Requirements

Each tool in this report is evaluated against these eight requirements:

#table(
  columns: (auto, 1fr),
  table.header([*No.*], [*Requirement*]),
  [1], [*Three-level hierarchy* — Servers → Namespaces (tool clusters) → Endpoints (contexts)],
  [2], [*1:many endpoint-to-namespace* — a single endpoint exposes multiple namespaces],
  [3], [*Nested/federated aggregation* — aggregators consuming other aggregators],
  [4], [*Deployment flexibility* — self-hosted, networked via Tailscale/Cloudflare],
  [5], [*Multi-transport* — SSE, Streamable HTTP, OpenAPI],
  [6], [*Tool-level controls* — enable/disable, middleware, description overrides],
  [7], [*Per-endpoint auth* — API key, OAuth],
  [8], [*Client-dimension visibility* — different tool sets per accessing client],
)

#pagebreak()

// ─── Tool Evaluations ───

= Tool Evaluations

== agentgateway #h(6pt) #tag("Linux Foundation", rgb("#0077b6"))

Protocol-aware proxy for MCP, A2A, and LLM traffic with tool federation across multiple MCP servers. v1.0.0 reached March 2026. Fine-grained RBAC via CEL policy engine. JWT, API keys, OAuth. Multi-tenancy with per-tenant policies.

=== Fits
- #fit-item[Strong governance/observability with institutional backing]
- #fit-item[Multi-tenancy with per-tenant policies addresses client dimension]
- #fit-item[v1.0 maturity with production-grade security (rate limiting, TLS)]
- #fit-item[Standalone binary or Kubernetes — flexible deployment]
- #fit-item[Also supports A2A protocol alongside MCP]

=== Gaps
- #gap-item[No namespace hierarchy — tool federation provides a unified flat view only]
- #gap-item[No 1:many endpoint-to-namespace mapping]
- #gap-item[Gateway chaining for nested aggregation not explicitly documented]
- #gap-item[Focused on security/compliance rather than hierarchical tool organization]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== Bifrost #h(6pt) #tag("Maxim AI", rgb("#6a4c93"))

Dual-role Go binary acting as both MCP client and server, exposing aggregated tools via `/mcp`. Also functions as an LLM gateway with OpenAI-compatible API. Virtual keys with per-key tool allow-lists. "Code Mode" reduces token usage by 50%+ when 3+ servers connected.

=== Fits
- #fit-item[Virtual keys with tool allow-lists — closest to client-dimension visibility]
- #fit-item[Code Mode is innovative for token optimization at scale]
- #fit-item[OAuth 2.0 with automatic token refresh]
- #fit-item[Lightweight self-hosted deployment (single Go binary)]
- #fit-item[Dual LLM + MCP gateway is a differentiator]

=== Gaps
- #gap-item[No hierarchical namespace model — flat aggregation only]
- #gap-item[No 1:many endpoint-to-namespace]
- #gap-item[No federation or nested aggregation]
- #gap-item[No tool description overrides or middleware]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== Cloudflare MCP Server Portals #h(6pt) #tag("Managed", rgb("#e76f51"))

Managed portal-based grouping on Cloudflare's Workers edge network. Multiple MCP servers assigned to a portal with per-server Access policies. Dual-layer auth (portal login + per-server OAuth). Zero Trust integration. Free tier: 100K requests/day.

=== Fits
- #fit-item[Production-ready managed service with Zero Trust auth]
- #fit-item[Per-server Access policies provide partial client-dimension visibility]
- #fit-item[Dual-layer auth model (portal + per-server OAuth)]
- #fit-item[Tool and prompt template curation per portal]

=== Gaps
- #gap-item[No self-hosted option — managed Cloudflare only]
- #gap-item[No intermediate namespace/tool cluster abstraction]
- #gap-item[No 1:many endpoint-to-namespace]
- #gap-item[No federation or nested aggregation]
- #gap-item[Not suitable for local server/Tailscale deployment]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== IBM ContextForge #h(6pt) #tag("IBM", rgb("#0f62fe")) #h(3pt) #tag("Tier 1", rgb("#2d6a4f"))

Gateway with "Virtual Servers" bundling tools from multiple sources into custom logical interfaces. "Spaces" for multi-tenancy. Federation via mDNS auto-discovery across instances. Broadest transport support: HTTP, JSON-RPC, WebSocket, SSE, STDIO, Streamable HTTP, gRPC-to-MCP. 3.5K stars, IBM-backed.

=== Fits
- #fit-item[Virtual servers approximate the namespace/tool-cluster concept]
- #fit-item[Best-in-class federation via mDNS auto-discovery]
- #fit-item[Broadest transport support (7+ protocols including gRPC translation)]
- #fit-item[Fully self-hosted with flexible deployment (PyPI, Docker, K8s)]
- #fit-item[Strong community (3.5K stars, 2,554 commits)]
- #fit-item[Spaces and RBAC for multi-tenancy]

=== Gaps
- #gap-item[1:many endpoint-to-virtual-server mapping not definitively documented]
- #gap-item[No tool description overrides]
- #gap-item[Kubernetes-focused docs may overstate complexity for single-server use]
- #gap-item[Virtual server composition model needs hands-on verification]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== Kong #h(6pt) #tag("43K stars", rgb("#003049"))

Cloud-native API gateway with MCP support via the AI MCP Proxy plugin. "Listener mode" aggregates MCP proxy instances via shared tags. 60+ plugins for auth, rate limiting, ACLs, transformations. MCP traffic governance, security, observability, and auto-generation from RESTful APIs.

=== Fits
- #fit-item[Mature, battle-tested API gateway infrastructure (43K stars)]
- #fit-item[Full plugin ecosystem for auth, rate limiting, transformations]
- #fit-item[Consumer/ACL model provides per-client tool visibility]
- #fit-item[Tag-based aggregation via listener mode]
- #fit-item[MCP auto-generation from existing REST APIs]
- #fit-item[Hybrid deployment (control plane / data plane separation)]

=== Gaps
- #gap-item[MCP support is a plugin, not the core product — requires Kong infrastructure]
- #gap-item[No namespace hierarchy — flat tag model]
- #gap-item[No 1:many endpoint-to-namespace]
- #gap-item[No nested/federated aggregation beyond listener tag discovery]
- #gap-item[Not standalone — requires Kong Gateway 3.12+ (3.14 for aggregation)]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== MCP-Gateway (aiguicai) #h(6pt) #tag("Rust", rgb("#dea584"))

Local MCP server gateway unifying multiple servers behind one entry point. Unique command approval workflow (Approve/Reject). Policy rules system with `allow / confirm / deny` actions. Two-tier token system. Cross-platform binary.

=== Fits
- #fit-item[Command approval workflow is unique in the MCP gateway space]
- #fit-item[Policy rules system with JSON definitions]
- #fit-item[Two-tier token auth (admin vs. service endpoints)]
- #fit-item[Execution timeout and output size limits]
- #fit-item[SSE and Streamable HTTP transport]

=== Gaps
- #gap-item[No namespace hierarchy or grouping — flat name-based routing]
- #gap-item[No 1:many endpoint-to-namespace]
- #gap-item[No federation or nested aggregation]
- #gap-item[No per-client tool visibility]
- #gap-item[Single-instance local deployment only]
- #gap-item[Early maturity (104 stars)]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== MCP Mesh #h(6pt) #tag("deco.cx", rgb("#7b2d8e"))

Centralized control plane with "Virtual MCPs" bundling tools into purpose-built toolsets per team or role. Three exposure patterns: passthrough, smart tool selection (two-stage narrowing), and code execution mode (sandbox). RBAC at model, server, and tool levels.

=== Fits
- #fit-item[Virtual MCPs approximate namespace/tool-cluster concept]
- #fit-item[Multi-level RBAC (model, server, tool) enables per-client visibility]
- #fit-item[Smart tool selection strategies are a differentiator]
- #fit-item[Code execution mode for sandboxed operations]
- #fit-item[Flexible self-hosted deployment (Bun, Node, Docker, K8s)]

=== Gaps
- #gap-item[No explicit federation or nested aggregation]
- #gap-item[Whether multiple Virtual MCPs compose under a single endpoint is unconfirmed]
- #gap-item[No 1:many mapping documented]
- #gap-item[Sparse documentation compared to competitors]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== mcp-proxy (tbxark) #h(6pt) #tag("Go", rgb("#00add8"))

Lightweight aggregation proxy consolidating multiple MCP servers behind a single HTTP entrypoint. Tool filtering per server via `toolFilter` with allow or block modes. Per-server auth tokens with bearer validation. 676 stars.

=== Fits
- #fit-item[Tool filtering with allow/block modes per server]
- #fit-item[Per-server auth tokens with proxy-level fallback]
- #fit-item[SSE, Streamable HTTP, and STDIO transport]
- #fit-item[Lightweight Go binary with Docker Compose support]
- #fit-item[Token-in-URL for clients that can't set headers]

=== Gaps
- #gap-item[No namespace hierarchy — flat server map]
- #gap-item[No 1:many endpoint-to-namespace]
- #gap-item[No federation or nested aggregation]
- #gap-item[No per-client tool visibility]
- #gap-item[No tool description overrides or middleware]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== MCPJungle #h(6pt) #tag("Go", rgb("#00add8")) #h(3pt) #tag("Tier 2", rgb("#e9c46a"))

Self-hosted MCP gateway with "Tool Groups" curating subsets of tools from across servers. Each group gets its own endpoint. Canonical tool naming via `{server}__{tool}`. Enterprise mode with per-client server allowlisting. CLI management. 951 stars.

=== Fits
- #fit-item[Tool Groups with `included_tools`, `included_servers`, `excluded_tools`]
- #fit-item[Each group gets a unique endpoint — closest to namespace-per-endpoint]
- #fit-item[Enterprise mode with per-client server allowlisting]
- #fit-item[CLI for granular tool enable/disable management]
- #fit-item[PostgreSQL-backed for production, SQLite for dev]

=== Gaps
- #gap-item[Endpoint maps to exactly one group — still 1:1]
- #gap-item[No three-level hierarchy (groups are a single layer)]
- #gap-item[No federation or nested aggregation]
- #gap-item[OAuth not yet supported (bearer tokens only)]
- #gap-item[SSE marked "currently not mature"]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== MCProxy (igrigorik) #h(6pt) #tag("Rust", rgb("#dea584"))

Lightweight proxy presenting a unified aggregated tool list from multiple upstream servers. Two-tier middleware: ClientMiddleware (per-server logging, regex filtering) and ProxyMiddleware (description enrichment, tool search). Dynamic updates via `toolListChanged`.

=== Fits
- #fit-item[Two-tier middleware architecture is well-designed]
- #fit-item[Regex-based tool filtering and description enrichment]
- #fit-item[Dynamic tool list updates for live changes]
- #fit-item[Automatic tool search/filtering for large tool counts]

=== Gaps
- #gap-item[No namespace or grouping — all tools in one flat list]
- #gap-item[No 1:many endpoint-to-namespace]
- #gap-item[No federation or nested aggregation]
- #gap-item[No per-client auth on exposed endpoint]
- #gap-item[Early stage (19 stars, no releases)]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== MCPX #h(6pt) #tag("Lunar.dev", rgb("#f4a261"))

Centralized enterprise gateway aggregating multiple servers into a single endpoint. Tool-level RBAC, tool prefixing for conflict resolution, audit logs, dynamic tool discovery. Managed SaaS and self-hosted.

=== Fits
- #fit-item[Granular tool-level RBAC for client-dimension visibility]
- #fit-item[Tool prefixing for conflict resolution across servers]
- #fit-item[Comprehensive audit logs]
- #fit-item[Centralized secret management]
- #fit-item[Both SaaS and self-hosted deployment]

=== Gaps
- #gap-item[No namespace hierarchy — single aggregated endpoint model]
- #gap-item[No 1:many endpoint-to-namespace]
- #gap-item[No federation or nested aggregation]
- #gap-item[Transport specifics poorly documented]
- #gap-item[Incubating product — maturity unclear]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== MetaMCP #h(6pt) #tag("Tier 1", rgb("#2d6a4f"))

Three-level hierarchy: Servers, Namespaces, Endpoints. Namespaces group servers with tool-level controls; endpoints expose namespaces via SSE, Streamable HTTP, or OpenAPI. Web UI. Docker-based, self-hosted. API key, OAuth, OIDC. Tool name/description overrides and automatic prefixing.

=== Fits
- #fit-item[*Only tool with explicit three-level S/N/E hierarchy*]
- #fit-item[Tool description overrides and name prefixing]
- #fit-item[Enable/disable at both server and individual tool level per namespace]
- #fit-item[Multiple transport options including OpenAPI]
- #fit-item[One-click namespace switching per endpoint]
- #fit-item[Web UI for management]
- #fit-item[Closest terminology match to target architecture]

=== Gaps
- #gap-item[*1:1 endpoint-to-namespace constraint* — the exact limitation the target seeks to overcome]
- #gap-item[No federation — manual aggregator-of-aggregators only]
- #gap-item[Single-node only (cluster scaling on roadmap)]
- #gap-item[No first-class client profile entity]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== Microsoft MCP Gateway #h(6pt) #tag("Enterprise", rgb("#003049"))

Two-plane architecture (control + data) with adapters and tools as first-class resources. Tool Gateway Router for dynamic routing. Azure Entra ID with RBAC. Kubernetes-native. 562 stars.

=== Fits
- #fit-item[Enterprise-grade RBAC with Azure Entra ID]
- #fit-item[Control plane / data plane separation]
- #fit-item[Tools as first-class resources with management APIs]
- #fit-item[Dynamic routing based on tool definitions]
- #fit-item[Infrastructure-as-code templates for K8s]

=== Gaps
- #gap-item[No namespace hierarchy — adapters/tools are flat resources]
- #gap-item[No 1:many endpoint-to-namespace]
- #gap-item[No federation or nested aggregation]
- #gap-item[Azure Entra ID only — no generic API key auth]
- #gap-item[Overkill for single-server / home lab deployment]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== Obot #h(6pt) #tag("Platform", rgb("#e76f51"))

Open-source platform for hosting, discovering, and securing MCP servers with built-in chat client. Admin-governed catalog. OAuth 2.1. Docker/Kubernetes. Backed by Acorn Labs. Integrates with n8n, LangGraph, ChatGPT, Claude Desktop, Copilot. 690 stars.

=== Fits
- #fit-item[MCP hosting platform with admin-governed catalog]
- #fit-item[Built-in chat client with consistent MCP support]
- #fit-item[OAuth 2.1 with managed token handling]
- #fit-item[Broad client integration ecosystem]

=== Gaps
- #gap-item[Platform/hosting play, not an aggregation proxy]
- #gap-item[No namespace hierarchy or tool grouping]
- #gap-item[No 1:many endpoint-to-namespace]
- #gap-item[No federation or nested aggregation]
- #gap-item[No per-tool enable/disable documented]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== Portkey AI Gateway #h(6pt) #tag("LLM Gateway", rgb("#e76f51")) #h(3pt) #tag("11K stars", rgb("#003049"))

Primarily an LLM API gateway (250+ providers) with MCP Gateway feature for proxying MCP server access. Per-user tool enable/disable, credential injection, 40+ guardrails. npm, Docker, Workers, K8s, managed cloud.

=== Fits
- #fit-item[Per-user tool controls and logging]
- #fit-item[Credential injection for upstream servers]
- #fit-item[40+ pre-built guardrails for input/output validation]
- #fit-item[Flexible deployment options]
- #fit-item[Virtual keys with RBAC and enterprise SSO]

=== Gaps
- #gap-item[Fundamentally an LLM gateway — MCP support is secondary]
- #gap-item[No namespace hierarchy or multi-level grouping]
- #gap-item[No 1:many endpoint-to-namespace]
- #gap-item[No federation or nested aggregation]
- #gap-item[Single gateway endpoint per server]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== Supergateway #h(6pt) #tag("Transport Bridge", rgb("#264653"))

CLI transport bridge converting STDIO-based MCP servers to SSE, WebSocket, or Streamable HTTP. Bidirectional conversion. Stateful and stateless modes. npx, Docker, ngrok integration. 2,546 stars.

=== Fits
- #fit-item[Best transport bridge in the ecosystem]
- #fit-item[Bidirectional conversion (remote-to-local and local-to-remote)]
- #fit-item[Zero-config instant deployment via npx]
- #fit-item[ngrok integration for public exposure]
- #fit-item[Widely used as a building block in MCP architectures]

=== Gaps
- #gap-item[*Not an aggregator* — pure transport converter]
- #gap-item[One server per invocation — no aggregation]
- #gap-item[No tool-level controls, grouping, or hierarchy]
- #gap-item[No auth beyond bearer token passthrough]
- #gap-item[No client-dimension visibility]

#line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

== Unla (AmoyLab) #h(6pt) #tag("TypeScript", rgb("#3178c6"))

High-availability gateway converting MCP servers and RESTful APIs into MCP-compliant endpoints. Web UI. Multi-replica HA. Hot-reloading config. Docker, bare metal, K8s. 2,076 stars.

=== Fits
- #fit-item[REST-to-MCP conversion — unique protocol bridge capability]
- #fit-item[High-availability with multi-replica support]
- #fit-item[Hot-reloading configuration changes]
- #fit-item[Configuration version control]
- #fit-item[Web UI for management]
- #fit-item[Flexible deployment (Docker, bare metal, K8s)]

=== Gaps
- #gap-item[*Server grouping/aggregation explicitly unimplemented* (roadmap only)]
- #gap-item[No namespace hierarchy]
- #gap-item[No 1:many endpoint-to-namespace]
- #gap-item[No federation or nested aggregation]
- #gap-item[No per-client tool filtering]

#pagebreak()

// ─── Analysis ───

= Analysis

== Tiered Assessment

No tool fully satisfies all target requirements. The ecosystem has converged on flat aggregation with RBAC — effective for enterprise governance but insufficient for multi-dimensional tool organization.

#v(8pt)

*Tier 1 — Closest overall:*

#table(
  columns: (auto, 1fr, 1fr),
  table.header([*Tool*], [*Strength*], [*Primary Gap*]),
  [IBM ContextForge], [Virtual servers ≈ namespaces, mDNS federation, broadest transport], [1:many mapping unverified],
  [MetaMCP], [Only tool with explicit S/N/E hierarchy, tool description overrides], [1:1 endpoint-to-namespace, no federation],
)

#v(8pt)

*Tier 2 — Strong in specific dimensions:*

#table(
  columns: (auto, 1fr, 1fr),
  table.header([*Tool*], [*Strength*], [*Primary Gap*]),
  [MCPJungle], [Tool Groups with include/exclude, per-client allowlisting], [Still 1:1, no federation],
  [Bifrost], [Virtual keys for client-dimension visibility, Code Mode], [No hierarchy, no federation],
  [MCP Mesh], [Virtual MCPs, multi-level RBAC, smart selection], [No federation, sparse docs],
  [agentgateway], [Governance, multi-tenancy, v1.0 maturity], [No namespace hierarchy],
)

#v(8pt)

*Tier 3 — Useful as components:*

#table(
  columns: (auto, 1fr),
  table.header([*Tool*], [*Role in Architecture*]),
  [Supergateway], [Transport bridge for making STDIO servers remotely accessible],
  [Unla], [REST-to-MCP protocol conversion],
  [Kong], [Enterprise API gateway with MCP plugin for existing Kong users],
  [mcp-proxy (tbxark)], [Lightweight aggregation with tool filtering],
)

== Recommended Investigation Path

+ *ContextForge* — verify whether virtual servers can be composed under a single endpoint (1:many) and whether federation supports true nested aggregation (gateway consuming gateway)
+ *MetaMCP* — monitor for 1:many endpoint-to-namespace support; maintainers are aware of this limitation
+ *MCPJungle* — evaluate Tool Groups as a practical alternative to MetaMCP namespaces
+ *Hybrid approach* — MetaMCP for namespace/endpoint management + manual federation by registering one MetaMCP endpoint as a server in another instance (works today without first-class support)

== The Ecosystem Gap

#block(
  width: 100%,
  fill: rgb("#fff3cd"),
  stroke: 0.5pt + rgb("#ffc107"),
  radius: 6pt,
  inset: 14pt,
)[
  No tool provides all of: (a) a clean three-level hierarchy with 1:many endpoint-to-namespace, (b) first-class nested/federated aggregation, (c) per-client tool visibility as a distinct dimension, and (d) lightweight self-hosted deployment.

  This remains an open design space as of Q1 2026.
]

#pagebreak()

// ─── Other Notable Tools ───

= Other Notable Tools

These tools were evaluated but fall outside the core aggregation/gateway category:

#table(
  columns: (auto, 1fr),
  table.header([*Tool*], [*Notes*]),
  [Toolhouse], [Managed tool marketplace with "bundles." Not an aggregator. No self-hosting.],
  [MCP Gateway & Registry (agentic-community)], [Enterprise-ready with OAuth, tool aliasing, version pinning. No namespace hierarchy.],
  [Composio], [Managed SaaS, 500+ integrations. Tool provider platform, not an aggregator.],
  [Docker MCP Gateway], [Container-isolated MCP servers. No namespace hierarchy or federation.],
  [mcp-batchit], [Batching optimization for reducing round-trips. STDIO only. Not an aggregator.],
)

#v(16pt)

// ─── Sources ───

= Sources

#set text(size: 9pt)

#columns(2)[
  - agentgateway — #link("https://github.com/agentgateway/agentgateway")[GitHub]
  - Bifrost — #link("https://github.com/maximhq/bifrost")[GitHub]
  - Cloudflare MCP Portals — #link("https://developers.cloudflare.com/cloudflare-one/access-controls/ai-controls/mcp-portals/")[Docs]
  - IBM ContextForge — #link("https://github.com/IBM/mcp-context-forge")[GitHub]
  - Kong — #link("https://github.com/Kong/kong")[GitHub]
  - Kong AI MCP Proxy — #link("https://developer.konghq.com/plugins/ai-mcp-proxy/")[Docs]
  - MCP-Gateway (aiguicai) — #link("https://github.com/aiguicai/MCP-Gateway")[GitHub]
  - MCP Mesh — #link("https://www.decocms.com/blog/post/mcp-mesh")[Blog]
  - mcp-proxy (tbxark) — #link("https://github.com/tbxark/mcp-proxy")[GitHub]
  #colbreak()
  - MCPJungle — #link("https://github.com/mcpjungle/MCPJungle")[GitHub]
  - MCProxy — #link("https://github.com/igrigorik/MCProxy")[GitHub]
  - MCPX — #link("https://www.pulsemcp.com/servers/lunar-mcpx-control-plane")[PulseMCP]
  - MetaMCP — #link("https://github.com/metatool-ai/metamcp")[GitHub] | #link("https://docs.metamcp.com/en")[Docs]
  - Microsoft MCP Gateway — #link("https://github.com/microsoft/mcp-gateway")[GitHub]
  - Obot — #link("https://github.com/obot-platform/obot")[GitHub]
  - Portkey AI Gateway — #link("https://github.com/Portkey-AI/gateway")[GitHub]
  - Supergateway — #link("https://github.com/supercorp-ai/supergateway")[GitHub]
  - Unla — #link("https://github.com/AmoyLab/Unla")[GitHub]
  - awesome-mcp-gateways — #link("https://github.com/e2b-dev/awesome-mcp-gateways")[GitHub]
]
