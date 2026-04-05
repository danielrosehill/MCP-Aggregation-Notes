# MCP Aggregation, Gateway, and Proxy Tools: State of the Ecosystem (Q1 2026)

## Purpose

This document evaluates the current landscape of MCP (Model Context Protocol) aggregation, gateway, and proxy tools as of early 2026. Each tool is assessed against a target architecture requiring:

1. **Three-level hierarchy** — Servers → Namespaces (tool clusters) → Endpoints (contexts)
2. **1:many endpoint-to-namespace mapping** — a single endpoint exposes multiple namespaces
3. **Nested/federated aggregation** — aggregators consuming other aggregators
4. **Deployment flexibility** — self-hosted, networked via Tailscale/Cloudflare
5. **Multi-transport** — SSE, Streamable HTTP, OpenAPI
6. **Tool-level controls** — enable/disable, middleware, description overrides
7. **Per-endpoint auth** — API key, OAuth
8. **Client-dimension visibility** — different tool sets per accessing client

---

## agentgateway (Linux Foundation / Solo.io)

**Source:** [GitHub](https://github.com/agentgateway/agentgateway) | [Website](https://agentgateway.dev/)

Protocol-aware proxy for MCP, A2A, and LLM traffic with tool federation across multiple MCP servers. v1.0.0 reached March 2026. Linux Foundation project with standalone binary or Kubernetes deployment. Fine-grained RBAC via CEL policy engine. JWT, API keys, OAuth. Multi-tenancy with per-tenant policies.

### Fits

- Strong governance/observability with institutional backing
- Multi-tenancy with per-tenant policies addresses client dimension
- v1.0 maturity with production-grade security (rate limiting, TLS)
- Standalone binary or Kubernetes — flexible deployment
- Also supports A2A protocol alongside MCP

### Gaps

- No namespace hierarchy — tool federation provides a unified flat view only
- No 1:many endpoint-to-namespace mapping
- Gateway chaining for nested aggregation not explicitly documented
- Focused on security/compliance rather than hierarchical tool organization

---

## Bifrost (Maxim AI)

**Source:** [GitHub](https://github.com/maximhq/bifrost) | [Docs](https://docs.getbifrost.ai/mcp/gateway-url)

Dual-role Go binary acting as both MCP client and MCP server, exposing aggregated tools via `/mcp`. Also functions as an LLM gateway with OpenAI-compatible API. Virtual keys with per-key tool allow-lists. "Code Mode" replaces direct tool exposure with 4 meta-tools when 3+ servers are connected, reducing token usage by 50%+. Docker, NPX, Apache 2.0.

### Fits

- Virtual keys with tool allow-lists — closest to client-dimension visibility of any tool
- Code Mode is innovative for token optimization at scale
- OAuth 2.0 with automatic token refresh
- Lightweight self-hosted deployment (single Go binary)
- Dual LLM + MCP gateway is a differentiator

### Gaps

- No hierarchical namespace model — flat aggregation only
- No 1:many endpoint-to-namespace
- No federation or nested aggregation
- No tool description overrides or middleware

---

## Cloudflare MCP Server Portals

**Source:** [Cloudflare Docs](https://developers.cloudflare.com/cloudflare-one/access-controls/ai-controls/mcp-portals/)

Managed portal-based grouping on Cloudflare's Workers edge network. Multiple MCP servers assigned to a portal with per-server Access policies. Dual-layer auth (portal login + per-server OAuth). Zero Trust integration. Gateway routing added March 2026. Free tier: 100K requests/day.

### Fits

- Production-ready managed service with Zero Trust auth
- Per-server Access policies provide partial client-dimension visibility
- Dual-layer auth model (portal + per-server OAuth)
- Tool and prompt template curation per portal

### Gaps

- No self-hosted option — managed Cloudflare only
- No intermediate namespace/tool cluster abstraction (flat servers-to-portal)
- No 1:many endpoint-to-namespace
- No federation or nested aggregation
- Not suitable for local server/Tailscale deployment

---

## IBM ContextForge

**Source:** [GitHub](https://github.com/IBM/mcp-context-forge) | [Docs](https://ibm.github.io/mcp-context-forge/)

Gateway with "Virtual Servers" that bundle tools from multiple sources into custom logical interfaces. "Spaces" for multi-tenancy. Federation via mDNS auto-discovery across multiple ContextForge instances. Broadest transport support of any tool evaluated (HTTP, JSON-RPC, WebSocket, SSE, STDIO, Streamable HTTP, gRPC-to-MCP). 3.5K stars, IBM-backed. PyPI, Docker, Kubernetes via Helm.

### Fits

- Virtual servers approximate the namespace/tool-cluster concept
- Best-in-class federation via mDNS auto-discovery — addresses nested aggregation
- Broadest transport support (7+ protocols including gRPC translation)
- Fully self-hosted with flexible deployment (PyPI, Docker, K8s)
- Strong community (3.5K stars, 2,554 commits)
- Spaces and RBAC for multi-tenancy

### Gaps

- 1:many endpoint-to-virtual-server mapping not definitively documented
- No tool description overrides
- Kubernetes-focused docs may overstate complexity for single-server use
- Virtual server composition model needs hands-on verification

---

## Kong

**Source:** [GitHub](https://github.com/Kong/kong) | [AI MCP Proxy Plugin](https://developer.konghq.com/plugins/ai-mcp-proxy/) | [MCP Aggregation Guide](https://developer.konghq.com/mcp/aggregate-mcp-tools/)

Cloud-native API gateway (43.1K stars, 145 releases) with MCP support via the AI MCP Proxy plugin. "Listener mode" aggregates multiple MCP proxy instances via shared tags. Inherits Kong's full plugin ecosystem (60+ plugins for auth, rate limiting, ACLs, transformations). MCP traffic governance, security, observability, and auto-generation from RESTful APIs. Kubernetes-native with declarative/hybrid deployment models.

### Fits

- Mature, battle-tested API gateway infrastructure (43K stars)
- Full plugin ecosystem for auth (OAuth, JWT, API key, ACL), rate limiting, transformations
- Consumer/ACL model provides per-client tool visibility
- Tag-based aggregation via listener mode
- MCP auto-generation from existing REST APIs
- Hybrid deployment (control plane / data plane separation)

### Gaps

- MCP support is a plugin feature, not the core product — requires existing Kong infrastructure
- No namespace hierarchy — flat tag model, not three-level
- No 1:many endpoint-to-namespace
- No nested/federated aggregation beyond listener tag discovery
- Not standalone — requires Kong Gateway 3.12+ (3.14 for aggregation mode)

---

## MCP-Gateway (aiguicai)

**Source:** [GitHub](https://github.com/aiguicai/MCP-Gateway)

Local MCP server gateway in Rust that unifies multiple servers behind one entry point. Unique command approval workflow (Approve/Reject pending commands). Policy rules system with `allow / confirm / deny` actions using JSON rule definitions. Two-tier token system (admin token + MCP token). Cross-platform binary.

### Fits

- Command approval workflow is unique in the MCP gateway space
- Policy rules system (`allow / confirm / deny`) with JSON definitions
- Two-tier token auth (admin vs. service endpoints)
- Execution timeout and output size limits for safety
- Path whitelisting for filesystem security
- SSE and Streamable HTTP transport

### Gaps

- No namespace hierarchy or grouping — flat name-based routing
- No 1:many endpoint-to-namespace
- No federation or nested aggregation
- No per-client tool visibility
- Single-instance local deployment only
- Early maturity (104 stars)

---

## MCP Mesh (deco.cx)

**Source:** [deco.cx blog](https://www.decocms.com/blog/post/mcp-mesh)

Centralized control plane with "Virtual MCPs" that bundle tools from multiple servers into purpose-built toolsets per team or role. Three exposure patterns: passthrough, smart tool selection (two-stage narrowing), and code execution mode (sandbox). RBAC at model, server, and tool levels. OAuth 2.1 + API keys. Self-hosted with Docker Compose, Bun/Node, or Kubernetes.

### Fits

- Virtual MCPs approximate namespace/tool-cluster concept
- Multi-level RBAC (model, server, tool) enables per-client visibility
- Smart tool selection strategies are a differentiator (two-stage narrowing)
- Code execution mode for sandboxed operations
- Flexible self-hosted deployment (Bun, Node, Docker, K8s)

### Gaps

- No explicit federation or nested aggregation
- Whether multiple Virtual MCPs compose under a single endpoint is unconfirmed
- No 1:many mapping documented
- Sparse documentation compared to competitors
- Transport protocol details not well documented

---

## mcp-proxy (tbxark)

**Source:** [GitHub](https://github.com/tbxark/mcp-proxy)

Lightweight Go aggregation proxy that consolidates multiple MCP servers behind a single HTTP entrypoint. Tool filtering per server via `toolFilter` with `allow` or `block` modes. Per-server `authTokens` array with bearer token validation. Web-based config converter tool. 676 stars.

### Fits

- Tool filtering with allow/block modes per server
- Per-server auth tokens with proxy-level fallback
- SSE, Streamable HTTP, and STDIO transport support
- Lightweight Go binary with Docker Compose support
- Token-in-URL support for clients that can't set headers
- Clean, focused codebase

### Gaps

- No namespace hierarchy — flat server map
- No 1:many endpoint-to-namespace
- No federation or nested aggregation
- No per-client tool visibility — all servers visible to any authenticated client
- No tool description overrides or middleware
- No grouping mechanism

---

## MCPJungle

**Source:** [GitHub](https://github.com/mcpjungle/MCPJungle)

Self-hosted MCP gateway in Go with "Tool Groups" that curate subsets of tools from across servers. Each group gets its own endpoint (`/v0/groups/{name}/mcp`). Canonical tool naming via `{server}__{tool}`. Enterprise mode with API token-based client auth and per-client server allowlisting. CLI management (`mcpjungle disable tool ...`). 951 stars.

### Fits

- Tool Groups approximate namespace concept with `included_tools`, `included_servers`, `excluded_tools`
- Each group gets a unique endpoint — closest to namespace-per-endpoint model
- Enterprise mode with per-client server allowlisting
- CLI for granular tool enable/disable management
- Streamable HTTP transport with STDIO for local servers
- PostgreSQL-backed for production, SQLite for dev

### Gaps

- An endpoint maps to exactly one group, not many — still 1:1
- No three-level hierarchy (groups are a single organizational layer)
- No federation or nested aggregation
- OAuth not yet supported (bearer tokens only)
- SSE marked "currently not mature"

---

## MCProxy (igrigorik)

**Source:** [GitHub](https://github.com/igrigorik/MCProxy)

Lightweight Rust proxy connecting to multiple upstream MCP servers and presenting a unified aggregated tool list. Two-tier middleware system: ClientMiddleware (per-server logging, regex filtering, input validation) and ProxyMiddleware (description enrichment, tool search on aggregated list). Dynamic tool list updates via `toolListChanged`.

### Fits

- Two-tier middleware architecture is well-designed
- Regex-based tool filtering and description enrichment
- Dynamic tool list updates for live changes
- Automatic tool search/filtering for large tool counts
- Lightweight Rust binary

### Gaps

- No namespace or grouping — all tools aggregated into one flat list
- No 1:many endpoint-to-namespace
- No federation or nested aggregation
- No per-client auth on exposed endpoint
- No client-dimension visibility
- Early stage (19 stars, no releases)

---

## MCPX (Lunar.dev)

**Source:** [PulseMCP](https://www.pulsemcp.com/servers/lunar-mcpx-control-plane) | [TM Dev Lab](https://www.tmdevlab.com/mcpx-gateway-incubating.html)

Centralized enterprise gateway aggregating multiple upstream MCP servers into a single endpoint. Tool-level governance with RBAC, tool prefixing for conflict resolution, comprehensive audit logs, dynamic tool discovery. Managed SaaS and self-hosted options. Backed by Lunar.dev.

### Fits

- Granular tool-level RBAC — partial answer to client-dimension visibility
- Tool prefixing for conflict resolution across servers
- Comprehensive audit logs
- Centralized secret management for API keys and OAuth tokens
- Both SaaS and self-hosted deployment options

### Gaps

- No namespace hierarchy — single aggregated endpoint model
- No 1:many endpoint-to-namespace
- No federation or nested aggregation
- Transport specifics poorly documented
- Incubating product — maturity unclear

---

## MetaMCP

**Source:** [GitHub](https://github.com/metatool-ai/metamcp) | [Docs](https://docs.metamcp.com/en)

Three-level hierarchy: Servers, Namespaces, Endpoints. Namespaces group servers with tool-level controls; endpoints expose namespaces via SSE, Streamable HTTP, or OpenAPI. Web UI for management. Docker-based, self-hosted. API key, OAuth, OIDC. Tool name/description overrides and automatic `{ServerName}__{toolName}` prefixing.

### Fits

- Only tool with explicit three-level Servers/Namespaces/Endpoints hierarchy
- Tool description overrides and name prefixing
- Enable/disable at both server and individual tool level per namespace
- Multiple transport options including OpenAPI
- One-click namespace switching per endpoint
- Web UI for management
- Closest terminology match to target architecture

### Gaps

- **1:1 endpoint-to-namespace constraint** — the exact limitation the target architecture seeks to overcome
- No federation — manual aggregator-of-aggregators only
- Single-node only (cluster scaling on roadmap)
- No first-class client profile entity
- Middleware system is thin on specifics

---

## Microsoft MCP Gateway

**Source:** [GitHub](https://github.com/microsoft/mcp-gateway)

Two-plane architecture (control plane + data plane) with adapters and tools as first-class resources. Tool Gateway Router for dynamic routing. Azure Entra ID with RBAC (`mcp.engineer`, `mcp.admin`). Kubernetes-native (StatefulSets, headless services). 562 stars.

### Fits

- Enterprise-grade RBAC with Azure Entra ID
- Control plane / data plane separation
- Tools as first-class resources with management APIs
- Dynamic routing based on tool definitions
- Infrastructure-as-code templates for K8s deployment

### Gaps

- No namespace hierarchy — adapters/tools are flat resources
- No 1:many endpoint-to-namespace
- No federation or nested aggregation
- Azure Entra ID only — no generic API key auth
- Overkill for single-server / home lab deployment
- Kubernetes-only production deployment

---

## Obot

**Source:** [GitHub](https://github.com/obot-platform/obot) | [obot.ai](https://obot.ai)

Open-source platform for hosting, discovering, and securing MCP servers with a built-in chat client. Curated catalog with admin-approved server discovery. OAuth 2.1, built-in token handling, shared credentials. Docker/Kubernetes. Backed by Acorn Labs. Integrates with n8n, LangGraph, ChatGPT, Claude Desktop, GitHub Copilot. 690 stars.

### Fits

- MCP hosting platform with admin-governed catalog
- Built-in chat client with consistent MCP support
- OAuth 2.1 with managed token handling
- Project-wide memory across conversations
- Broad client integration ecosystem

### Gaps

- Platform/hosting play, not an aggregation proxy
- No namespace hierarchy or tool grouping
- No 1:many endpoint-to-namespace
- No federation or nested aggregation
- No per-tool enable/disable documented
- No transport flexibility (STDIO/HTTP only)

---

## Portkey AI Gateway

**Source:** [GitHub](https://github.com/Portkey-AI/gateway) | [Docs](https://portkey.ai/docs)

Primarily an LLM API gateway (250+ providers, 11.2K stars) with an MCP Gateway feature added for proxying and managing MCP server access. Per-user tool enable/disable, credential injection for upstream servers, 40+ guardrails. npm, Docker, Cloudflare Workers, AWS CloudFormation, Kubernetes, or managed cloud.

### Fits

- Per-user tool controls and logging — addresses client dimension partially
- Credential injection for upstream servers (OAuth, API keys, identity headers)
- 40+ pre-built guardrails for input/output validation
- Flexible deployment (npm, Docker, Workers, K8s, managed cloud)
- Virtual keys with RBAC and enterprise SSO
- Workspace-scoped access controls

### Gaps

- Fundamentally an LLM gateway — MCP support is a secondary feature
- No namespace hierarchy or multi-level grouping
- No 1:many endpoint-to-namespace
- No federation or nested aggregation
- Single gateway endpoint per server, not aggregated tool lists

---

## Supergateway

**Source:** [GitHub](https://github.com/supercorp-ai/supergateway)

CLI transport bridge converting MCP STDIO-based servers to SSE, WebSocket, or Streamable HTTP with a single command. Bidirectional conversion (e.g., SSE-to-STDIO for consuming remote servers locally). Both stateful and stateless Streamable HTTP modes. npx, Docker (base/uvx/deno variants), ngrok integration. 2,546 stars.

### Fits

- Best transport bridge in the ecosystem — STDIO to/from SSE, WebSocket, Streamable HTTP
- Bidirectional conversion (remote-to-local and local-to-remote)
- Zero-config instant deployment via npx
- ngrok integration for public exposure
- Stateful and stateless Streamable HTTP modes
- Widely used as a building block in MCP architectures

### Gaps

- **Not an aggregator** — pure transport converter, one server per invocation
- No tool-level controls, grouping, or hierarchy
- No auth beyond bearer token passthrough
- No client-dimension visibility
- No namespace or federation concepts
- Multiple servers require multiple separate invocations

---

## Unla (AmoyLab)

**Source:** [GitHub](https://github.com/AmoyLab/Unla)

Lightweight, high-availability gateway in TypeScript that converts existing MCP servers and RESTful APIs into MCP-compliant endpoints. Web UI for management. Multi-replica HA support. Hot-reloading configuration. OAuth-based pre-auth for upstream servers. Docker, bare metal, VMs, ECS, Kubernetes. 2,076 stars.

### Fits

- REST-to-MCP conversion — unique protocol bridge capability
- High-availability with multi-replica support
- Hot-reloading configuration changes
- Configuration version control
- Web UI for management
- Multi-tenant with role-based access and JWT auth
- Flexible deployment (Docker, bare metal, K8s with Helm)

### Gaps

- **Server grouping/aggregation explicitly listed as unimplemented** (roadmap only)
- No namespace hierarchy
- No 1:many endpoint-to-namespace
- No federation or nested aggregation
- No per-client tool filtering
- gRPC and WebSocket conversion still planned

---

## Comparative Matrix

| Requirement | agentgateway | Bifrost | CF Portals | ContextForge | Kong | MCP-Gateway (aiguicai) | MCP Mesh | mcp-proxy (tbxark) | MCPJungle | MCProxy | MCPX | MetaMCP | MS Gateway | Obot | Portkey | Supergateway | Unla |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **Three-level hierarchy** | No | No | No | Partial | No | No | Partial | No | Partial | No | No | **Yes** | No | No | No | No | No |
| **1:many endpoint-to-namespace** | No | No | No | Possibly | No | No | Possibly | No | No (1:1) | N/A | No | No (1:1) | N/A | No | No | N/A | No |
| **Nested/federated aggregation** | Partial | No | No | **Yes** | No | No | No | No | No | No | No | No | No | No | No | No | No |
| **Self-hosted** | Yes | Yes | No | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| **SSE** | Yes | Yes | No | Yes | No | Yes | ? | Yes | Partial | No | ? | Yes | No | No | No | Yes | Yes |
| **Streamable HTTP** | Yes | Yes | Yes | Yes | Yes | Yes | ? | Yes | Yes | Yes | ? | Yes | Yes | No | No | Yes | Yes |
| **Tool enable/disable** | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | No | Yes | No | Yes |
| **Tool description overrides** | No | No | No | No | No | No | No | No | No | Yes | No | **Yes** | No | No | No | No | No |
| **Middleware** | Yes (CEL) | No | No | Yes | Yes | Yes (policy) | Yes | No | No | Yes | No | Partial | No | No | Yes (guardrails) | No | No |
| **API key auth** | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Partial | Yes | Yes | No | No | Yes | Partial | Yes |
| **OAuth** | Yes | Yes | Yes | Yes | Yes | No | Yes | No | No | No | Yes | Yes | Yes | Yes | Yes | No | Yes |
| **Client-dimension visibility** | Yes | **Yes** | Partial | Partial | Partial | No | Partial | No | Yes | No | Partial | No | Partial | No | Partial | No | No |

---

## Analysis: Closest to Target Architecture

### No tool fully satisfies all requirements.

The ecosystem has converged on flat aggregation with RBAC, which addresses enterprise governance but not the multi-dimensional organization model described in the target architecture.

**Tier 1 — Closest overall:**

| Tool | Why | Primary gap |
|------|-----|-------------|
| **IBM ContextForge** | Virtual servers ≈ namespaces, mDNS federation, broadest transport support, strong community | 1:many endpoint-to-virtual-server mapping unverified |
| **MetaMCP** | Only tool with explicit S/N/E hierarchy, tool description overrides | 1:1 endpoint-to-namespace constraint, no federation |

**Tier 2 — Strong in specific dimensions:**

| Tool | Strength | Primary gap |
|------|----------|-------------|
| **MCPJungle** | Tool Groups with include/exclude, per-client allowlisting | Still 1:1 group-to-endpoint, no federation |
| **Bifrost** | Virtual keys for client-dimension visibility, Code Mode | No hierarchy, no federation |
| **MCP Mesh** | Virtual MCPs, multi-level RBAC, smart selection | No federation, sparse docs |
| **agentgateway** | Governance, multi-tenancy, v1.0 maturity | No namespace hierarchy |

**Tier 3 — Useful as components:**

| Tool | Role in architecture |
|------|---------------------|
| **Supergateway** | Transport bridge for making STDIO servers remotely accessible |
| **Unla** | REST-to-MCP protocol conversion |
| **Kong** | Enterprise API gateway with MCP plugin for existing Kong users |
| **mcp-proxy (tbxark)** | Lightweight aggregation with tool filtering |

### Recommended investigation path

1. **ContextForge** — verify whether virtual servers can be composed under a single endpoint (1:many) and whether federation supports true nested aggregation (gateway consuming gateway)
2. **MetaMCP** — monitor for 1:many endpoint-to-namespace support; the maintainers are aware of this as a design limitation
3. **MCPJungle** — evaluate Tool Groups as a practical alternative to MetaMCP namespaces
4. **Hybrid approach** — MetaMCP for namespace/endpoint management + manual federation by registering one MetaMCP endpoint as a server in another instance (works today without first-class support)

### The ecosystem gap

No tool provides all of: (a) a clean three-level hierarchy with 1:many endpoint-to-namespace, (b) first-class nested/federated aggregation, (c) per-client tool visibility as a distinct dimension, and (d) lightweight self-hosted deployment. This remains an open design space as of Q1 2026.

---

## Other Notable Tools

**Toolhouse:** Managed tool marketplace with MCP compatibility. "Bundles" group tools. Not an aggregator/gateway. No self-hosting.

**MCP Gateway & Registry (agentic-community):** Enterprise-ready with OAuth (Keycloak/Entra), tool aliasing, version pinning, per-tool scope-based access. No namespace hierarchy or federation.

**Composio:** Managed SaaS with 500+ integrations. Unified auth. SOC2/ISO. A tool provider platform, not a hierarchical aggregator.

**Docker MCP Gateway:** Container-isolated MCP servers with signed images and secrets management. Container-native but no namespace hierarchy or federation.

**mcp-batchit:** Batching optimization layer for reducing round-trips to a single downstream server. STDIO only, local only. Not an aggregator — a performance utility.

---

*Research conducted April 2026. Tool capabilities based on documentation and public sources; features may have changed since publication.*

### Sources

- [agentgateway](https://github.com/agentgateway/agentgateway)
- [Bifrost](https://github.com/maximhq/bifrost)
- [Cloudflare MCP Portals](https://developers.cloudflare.com/cloudflare-one/access-controls/ai-controls/mcp-portals/)
- [IBM ContextForge](https://github.com/IBM/mcp-context-forge)
- [Kong](https://github.com/Kong/kong)
- [Kong AI MCP Proxy Plugin](https://developer.konghq.com/plugins/ai-mcp-proxy/)
- [MCP-Gateway (aiguicai)](https://github.com/aiguicai/MCP-Gateway)
- [MCP Mesh](https://www.decocms.com/blog/post/mcp-mesh)
- [mcp-proxy (tbxark)](https://github.com/tbxark/mcp-proxy)
- [MCPJungle](https://github.com/mcpjungle/MCPJungle)
- [MCProxy](https://github.com/igrigorik/MCProxy)
- [MCPX / Lunar.dev](https://www.pulsemcp.com/servers/lunar-mcpx-control-plane)
- [MetaMCP](https://github.com/metatool-ai/metamcp) | [Docs](https://docs.metamcp.com/en)
- [Microsoft MCP Gateway](https://github.com/microsoft/mcp-gateway)
- [Obot](https://github.com/obot-platform/obot)
- [Portkey AI Gateway](https://github.com/Portkey-AI/gateway)
- [Supergateway](https://github.com/supercorp-ai/supergateway)
- [Unla](https://github.com/AmoyLab/Unla)
- [awesome-mcp-gateways](https://github.com/e2b-dev/awesome-mcp-gateways)
