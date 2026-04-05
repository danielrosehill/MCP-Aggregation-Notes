# MCP Aggregation, Gateway, and Proxy Tools: State of the Ecosystem (Q1 2026)

## Purpose

This document evaluates the current landscape of MCP (Model Context Protocol) aggregation, gateway, and proxy tools as of early 2026. Each tool is assessed against a target architecture requiring: a three-level hierarchy (Servers, Namespaces/tool clusters, Endpoints/contexts), 1:many endpoint-to-namespace mapping, nested/federated aggregation, flexible deployment (self-hosted, networked via Tailscale/Cloudflare), multi-transport support (SSE, Streamable HTTP, OpenAPI), tool-level controls (enable/disable, middleware, description overrides), per-endpoint auth (API key, OAuth), and client-dimension tool visibility.

---

## 1. MetaMCP

**Source:** [GitHub - metatool-ai/metamcp](https://github.com/metatool-ai/metamcp) | [Docs](https://docs.metamcp.com/en)

**Organization model:** Three-level hierarchy: Servers, Namespaces, Endpoints. Closest match to the target architecture's terminology. Namespaces group servers; endpoints expose namespaces.

**1:many endpoint-to-namespace:** Not supported. The current architecture enforces a **1:1 mapping** between endpoints and namespaces. An endpoint points to exactly one namespace. You can switch which namespace an endpoint uses, and multiple endpoints can point to different namespaces, but a single endpoint cannot aggregate multiple namespaces. This is the primary design friction identified in the target architecture notes.

**Nested/federated aggregation:** Not documented. MetaMCP assumes a single flat aggregation layer. Multi-level aggregation (aggregator consuming another aggregator) must be configured manually by pointing one MetaMCP instance at another's endpoint as if it were a regular MCP server. There is no first-class federation support.

**Transport:** SSE (legacy), Streamable HTTP (standard), OpenAPI endpoints, STDIO via proxy layer.

**Tool-level controls:** Enable/disable individual tools per namespace, enable/disable servers within a namespace, tool name/title/description overrides, automatic tool prefixing (`{ServerName}__{toolName}`). Middleware system for observability and security is mentioned but specifics are thin.

**Auth:** API key, OAuth (MCP Spec 2025-06-18), OIDC for enterprise SSO, session cookies. Rate limiting per endpoint or per user.

**Deployment:** Docker-based, self-hosted. Requires 2-4 GB RAM minimum. Single-node only currently; cluster scaling is on the roadmap.

**Client dimension:** Multiple endpoints with different namespaces serve as a proxy for client-dimension visibility, but there is no first-class "client profile" entity.

**Maturity:** Active development, Docker-packaged, used in production. Has a web UI for management.

**Verdict:** Closest conceptual match to the target hierarchy, but the 1:1 endpoint-to-namespace constraint is the exact limitation the target architecture seeks to overcome. No federation support.

---

## 2. MCProxy (igrigorik)

**Source:** [GitHub - igrigorik/MCProxy](https://github.com/igrigorik/MCProxy)

**Organization model:** Flat single-level aggregation. Connects to multiple upstream MCP servers and presents a unified aggregated tool list. No namespace or grouping abstraction.

**1:many endpoint-to-namespace:** N/A. No namespace concept exists. All tools are aggregated into one flat list.

**Nested/federated aggregation:** Not supported as a first-class feature. Since it exposes a Streamable HTTP endpoint, another proxy could theoretically consume it, but this is not designed for or documented.

**Transport:** STDIO (local servers) and HTTP (remote servers) as upstream connections. Exposes aggregated tools via Streamable HTTP with CORS support.

**Tool-level controls:** Two-tier middleware system: ClientMiddleware (per-server: logging, regex-based tool filtering, input validation/security) and ProxyMiddleware (on aggregated list: description enrichment, tool search). Dynamic tool list updates via `toolListChanged` notifications. Automatic tool search/filtering when tool count is large.

**Auth:** Bearer token auth for HTTP upstream connections. No per-client auth on the exposed endpoint documented.

**Deployment:** Rust binary, self-hosted. Lightweight. Configurable host/port.

**Client dimension:** Not supported.

**Maturity:** Early stage. 19 stars, 23 commits, no releases. Single developer project. Rust codebase.

**Verdict:** Excellent middleware architecture for a lightweight proxy. Good for simple aggregation with filtering. No hierarchy, no namespace support, no federation. Best suited as a building block, not a complete solution for the target architecture.

---

## 3. Microsoft MCP Gateway

**Source:** [GitHub - microsoft/mcp-gateway](https://github.com/microsoft/mcp-gateway)

**Organization model:** Two-plane architecture: control plane (managing adapters/tools via REST APIs) and data plane (routing requests). Resources organized under `/adapters` and `/tools` scopes. No namespace abstraction equivalent to MetaMCP's model.

**1:many endpoint-to-namespace:** Not applicable. Uses adapters (MCP server wrappers) and tools as first-class resources. A "Tool Gateway Router" dynamically routes tool calls based on definitions. No hierarchical grouping of tool clusters under contexts.

**Nested/federated aggregation:** Not supported. Single-organization focused.

**Transport:** Streamable HTTP as primary transport. Persistent HTTP connections for MCP communication.

**Tool-level controls:** Tools are first-class resources with dedicated management APIs. Dynamic routing based on tool definitions and input schemas. RBAC for read/write access.

**Auth:** Azure Entra ID integration with bearer token validation. Role-based access (e.g., `mcp.engineer`, `mcp.admin`).

**Deployment:** Kubernetes-native (StatefulSets, headless services). Docker Desktop for local dev, AKS for production. Infrastructure-as-code templates provided.

**Client dimension:** Authorization scopes could support per-client visibility, but not explicitly documented.

**Maturity:** 562 stars, 59 forks, 37 commits. Active development. Enterprise-grade Kubernetes focus.

**Verdict:** Strong enterprise/Kubernetes deployment story with proper RBAC. Missing hierarchical namespace model and federation. Overkill for single-server deployment; designed for large-scale Kubernetes environments.

---

## 4. MCPX (Lunar.dev)

**Source:** [PulseMCP - MCPX](https://www.pulsemcp.com/servers/lunar-mcpx-control-plane) | [TM Dev Lab](https://www.tmdevlab.com/mcpx-gateway-incubating.html)

**Organization model:** Centralized gateway aggregating multiple upstream MCP servers into a single endpoint. Tool-level governance with RBAC. No documented namespace hierarchy.

**1:many endpoint-to-namespace:** Not supported. Single aggregated endpoint model.

**Nested/federated aggregation:** Not documented.

**Transport:** MCP protocol support. Specific transports not detailed in available documentation.

**Tool-level controls:** Granular tool-level RBAC. Tool prefixing for conflict resolution when multiple servers expose same-named tools. Comprehensive audit logs. Dynamic tool discovery.

**Auth:** Layered authentication for interactive users and programmatic access. Centralized secret management for API keys and OAuth tokens.

**Deployment:** Managed SaaS and self-hosted options. Enterprise-focused.

**Client dimension:** Tool-level RBAC could enable per-client visibility via role assignments.

**Maturity:** Incubating/enterprise product. Backed by Lunar.dev.

**Verdict:** Strong governance and RBAC story. Good for enterprise compliance. Missing hierarchical organization and federation capabilities. Tool-level RBAC is a partial answer to client-dimension visibility.

---

## 5. Bifrost (Maxim AI)

**Source:** [GitHub - maximhq/bifrost](https://github.com/maximhq/bifrost) | [Docs](https://docs.getbifrost.ai/mcp/gateway-url)

**Organization model:** Dual-role binary acting as both MCP client (connecting to upstream servers) and MCP server (exposing aggregated tools via `/mcp`). Flat aggregation with virtual key scoping.

**1:many endpoint-to-namespace:** Not directly. However, virtual keys with per-key tool allow-lists provide a functional equivalent: different keys can expose different tool subsets from the same aggregated pool.

**Nested/federated aggregation:** Not documented.

**Transport:** STDIO, HTTP, SSE. Also functions as an LLM gateway with OpenAI-compatible API.

**Tool-level controls:** Per-virtual-key tool allow-lists (e.g., allow `filesystem_read` but block `filesystem_write`). "Code Mode" replaces direct tool exposure with 4 meta-tools when 3+ servers are connected, reducing token usage by 50%+ and latency by 30-40%. OAuth 2.0 with automatic token refresh.

**Auth:** OAuth 2.0 with token refresh. Virtual keys for scoped credentials per consumer.

**Deployment:** Self-hosted. Docker and NPX. Apache 2.0 license. Single Go binary.

**Client dimension:** Virtual keys with tool-level scoping directly address the client dimension: each client gets a key with its own tool visibility rules.

**Maturity:** Active open-source project. Dual LLM+MCP gateway is a differentiator.

**Verdict:** Virtual keys with tool allow-lists are the closest any tool comes to client-dimension visibility. Code Mode is innovative for token optimization. But no hierarchical namespace model and no federation. Single-level aggregation only.

---

## 6. Cloudflare MCP Server Portals

**Source:** [Cloudflare Docs - MCP Portals](https://developers.cloudflare.com/cloudflare-one/access-controls/ai-controls/mcp-portals/)

**Organization model:** Portal-based grouping. Multiple MCP servers assigned to a portal. Per-server Access policies control visibility. Hub-and-spoke centralization onto a single HTTP endpoint per portal.

**1:many endpoint-to-namespace:** Partially. A portal can contain multiple MCP servers, and administrators can curate which tools are exposed per portal. But there is no intermediate "namespace" or "tool cluster" abstraction. It is effectively servers-to-portal (flat grouping).

**Nested/federated aggregation:** Not supported. Single-organization, single-portal model.

**Transport:** HTTPS (Workers edge network). Portal endpoint at `https://<subdomain>.<domain>/mcp`.

**Tool-level controls:** Administrators can select specific tools and prompt templates per portal. Manual refresh or 24-hour automatic sync. Per-server policy-based visibility.

**Auth:** Cloudflare Access identity provider integration. Dual-layer: portal login + per-server OAuth. Admin vs. user credential modes. Zero Trust integration.

**Deployment:** Cloudflare-hosted (managed). Optional Gateway routing for DLP scanning and HTTP logging. Free tier: 100K requests/day.

**Client dimension:** Per-server Access policies mean different users see different servers within a portal, which partially addresses client-dimension visibility.

**Maturity:** Production-ready managed service. Gateway routing added March 2026. Part of Cloudflare One platform.

**Verdict:** Excellent for teams already on Cloudflare. Strong auth and Zero Trust integration. No hierarchical namespace model. No self-hosted option. Not suitable as a self-hosted aggregator on a local server/Tailscale network.

---

## 7. IBM ContextForge

**Source:** [GitHub - IBM/mcp-context-forge](https://github.com/IBM/mcp-context-forge) | [Docs](https://ibm.github.io/mcp-context-forge/)

**Organization model:** Gateway, Servers, and Tools as hierarchical entities. "Virtual Servers" bundle tools from multiple sources into custom logical interfaces. "Spaces" for multi-tenancy and organizational isolation.

**1:many endpoint-to-namespace:** Closest match via virtual servers. Multiple virtual servers (analogous to namespaces/tool clusters) can be composed and exposed. However, the exact endpoint-to-virtual-server cardinality is not definitively documented as 1:many.

**Nested/federated aggregation:** Best-in-class for federation. Multi-gateway federation via auto-discovery (mDNS). Multiple ContextForge instances automatically find and share tool registries without manual configuration. Redis-backed caching for multi-cluster environments. Whether a gateway can explicitly consume another gateway as a nested MCP server is not confirmed, but the federation model enables coordinated multi-gateway deployments.

**Transport:** HTTP, JSON-RPC, WebSocket, SSE (configurable keepalive), STDIO, Streamable HTTP, gRPC-to-MCP translation via automatic reflection-based service discovery. Broadest transport support of any tool evaluated.

**Tool-level controls:** Tool-level registration, versioning, input validation, concurrency controls. Tools associated with specific virtual servers with governance policies.

**Auth:** User-scoped OAuth tokens, X-Upstream-Authorization header support, JWT-based API auth, rate limiting. Admin UI with RBAC.

**Deployment:** PyPI, Docker/Podman, Kubernetes via Helm, local dev. Fully self-hosted. Multi-cluster Kubernetes support.

**Client dimension:** Spaces and RBAC could enable per-client visibility, though not explicitly documented as a first-class feature.

**Maturity:** 3.5K stars, 614 forks, 2,554 commits. Very active. IBM-backed open source.

**Verdict:** Strongest federation story and broadest transport support. Virtual servers approximate the namespace/tool-cluster concept. The most architecturally complete solution, though the exact 1:many endpoint-to-virtual-server mapping needs verification. Federation via mDNS auto-discovery is a standout feature for multi-node deployments.

---

## 8. MCP Mesh (deco.cx)

**Source:** [deco.cx blog - MCP Mesh](https://www.decocms.com/blog/post/mcp-mesh)

**Organization model:** Centralized control plane between apps and MCP servers. "Virtual MCPs" bundle tools from multiple servers into purpose-built toolsets per team or role.

**1:many endpoint-to-namespace:** Virtual MCPs are the closest equivalent. Platform teams compose curated toolsets exposing only specific tools per role. Whether multiple virtual MCPs can be exposed under a single endpoint is not confirmed.

**Nested/federated aggregation:** Not documented.

**Transport:** OAuth proxy for MCP auth. Dev-time tunneling via deco.host. Specific transport protocols not detailed.

**Tool-level controls:** Three exposure patterns: passthrough (all tools), smart tool selection (two-stage narrowing), and code execution mode (sandbox). RBAC at model, MCP server, and individual tool levels.

**Auth:** OAuth 2.1 + API keys. Encrypted token vault.

**Deployment:** Self-hosted. Zero-config local, Docker Compose (SQLite/Postgres), Bun/Node, Kubernetes via Helm.

**Client dimension:** RBAC at multiple levels could enable per-client tool visibility.

**Maturity:** Production-ready (Q4 2025). Roadmap includes bindings and visual workflow builders (Q1 2026).

**Verdict:** Virtual MCPs and multi-level RBAC are architecturally interesting. Smart tool selection strategies are a differentiator. Missing explicit federation support. Documentation is less detailed than competitors.

---

## 9. agentgateway (Linux Foundation / Solo.io)

**Source:** [GitHub - agentgateway/agentgateway](https://github.com/agentgateway/agentgateway) | [Website](https://agentgateway.dev/)

**Organization model:** Protocol-aware proxy for MCP, A2A, and LLM traffic. Tool federation across multiple MCP servers. Not a traditional aggregator with namespace hierarchy.

**1:many endpoint-to-namespace:** Not supported as a hierarchy concept. Tool federation provides a unified view.

**Nested/federated aggregation:** Designed for multi-tenancy and shared infrastructure. Whether gateways can chain is not explicitly documented, but the architecture supports complex routing.

**Transport:** Multiple MCP transport options. Also supports A2A protocol.

**Tool-level controls:** Fine-grained RBAC with CEL policy engine. Rate limiting, TLS.

**Auth:** JWT, API keys, OAuth.

**Deployment:** Standalone binary or Kubernetes. Linux Foundation backed.

**Client dimension:** Multi-tenancy with per-tenant policies.

**Maturity:** Hit v1.0.0 in March 2026. Linux Foundation project. Strong institutional backing.

**Verdict:** Best governance/observability story with Linux Foundation backing. v1.0 maturity. Focused on security and compliance rather than hierarchical tool organization. Not a namespace-oriented aggregator.

---

## 10. Kong AI MCP Proxy

**Source:** [Kong Docs - AI MCP Proxy](https://developer.konghq.com/plugins/ai-mcp-proxy/) | [Aggregation Guide](https://developer.konghq.com/mcp/aggregate-mcp-tools/)

**Organization model:** Plugin-based. MCP-to-HTTP translation layer within the Kong API Gateway. "Listener mode" aggregates multiple AI MCP Proxy instances via shared tags.

**1:many endpoint-to-namespace:** Tags provide a grouping mechanism. A listener instance discovers tools from all instances sharing a tag. Multiple tag groups could achieve namespace-like separation, but this is a flat tag model, not a hierarchy.

**Nested/federated aggregation:** Not documented beyond listener aggregation of tagged instances.

**Transport:** HTTP conversion from MCP protocol. Inherits Kong's full transport stack.

**Tool-level controls:** Inherits Kong's rate limiting, authentication, and ACL plugins. Per-tool ACLs mentioned in v3.14 aggregation mode.

**Auth:** Inherits Kong's auth plugins (OAuth, API key, JWT, etc.).

**Deployment:** Plugin on existing Kong Gateway infrastructure. Not standalone.

**Client dimension:** Kong's consumer/ACL model could provide per-client tool visibility.

**Maturity:** Kong Gateway 3.12+ for basic MCP proxy, 3.14 for aggregation mode (released/releasing early 2026).

**Verdict:** Best for teams already running Kong. Leverages existing API gateway infrastructure. Not a standalone MCP aggregator. No namespace hierarchy. MCP support is a plugin feature, not the core product.

---

## 11. Other Notable Tools

**Toolhouse:** Managed platform providing a library of pre-built tool connectors. Users create "bundles" (groups of tools). Not an aggregator/gateway in the architectural sense; more of a tool marketplace with MCP compatibility. No namespace hierarchy, no federation, no self-hosting.

**MCP Gateway & Registry (agentic-community):** Enterprise-ready with OAuth (Keycloak/Entra), tool aliasing, version pinning, per-tool scope-based access, session multiplexing. No documented namespace hierarchy or federation.

**Composio:** Managed SaaS with 500+ integrations. Unified auth layer. SOC2/ISO certified. Cloud-hosted or self-hosted. A tool provider platform, not a hierarchical aggregator.

**Docker MCP Gateway:** Container-isolated MCP servers with signed images and secrets management. Container-native but no namespace hierarchy or federation.

---

## Comparative Matrix

| Requirement | MetaMCP | MCProxy | MS Gateway | MCPX | Bifrost | CF Portals | ContextForge | MCP Mesh | agentgateway | Kong |
|---|---|---|---|---|---|---|---|---|---|---|
| **Three-level hierarchy** | Yes (S/N/E) | No | No | No | No | No | Partial (virtual servers) | Partial (virtual MCPs) | No | No |
| **1:many endpoint-to-namespace** | No (1:1) | N/A | N/A | N/A | No (but virtual keys) | No | Possibly | Possibly | N/A | No |
| **Nested/federated aggregation** | No | No | No | No | No | No | Yes (mDNS auto-discovery) | No | Partial | No |
| **Self-hosted deployment** | Yes (Docker) | Yes (binary) | Yes (K8s) | Yes | Yes (Docker/NPX) | No (managed) | Yes (Docker/K8s/PyPI) | Yes (Docker/K8s) | Yes (binary/K8s) | Yes (plugin) |
| **SSE transport** | Yes | No | No | Unknown | Yes | No | Yes | Unknown | Yes | No |
| **Streamable HTTP** | Yes | Yes | Yes | Unknown | Yes | Yes | Yes | Unknown | Yes | Yes |
| **OpenAPI** | Yes | No | Yes | Unknown | No | No | Yes | Unknown | No | No |
| **Tool enable/disable** | Yes | Yes (filter) | Yes | Yes | Yes (per-key) | Yes | Yes | Yes | Yes | Yes (ACL) |
| **Tool description overrides** | Yes | Yes (enrich) | No | No | No | No | No | No | No | No |
| **Middleware** | Partial | Yes (2-tier) | No | No | No | No | Yes | Yes (strategies) | Yes (CEL) | Yes (plugins) |
| **API key auth** | Yes | Partial | No (Entra) | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| **OAuth per endpoint** | Yes | No | Yes (Entra) | Yes | Yes | Yes (CF Access) | Yes | Yes | Yes | Yes |
| **Client-dimension visibility** | No | No | Partial | Partial (RBAC) | Yes (virtual keys) | Partial | Partial (Spaces) | Partial (RBAC) | Yes (multi-tenant) | Partial (consumers) |

---

## Analysis: Closest to Target Architecture

### No tool fully satisfies all requirements.

**MetaMCP** comes closest in terminology and hierarchy (Servers/Namespaces/Endpoints) but is blocked by the 1:1 endpoint-to-namespace constraint and lack of federation.

**IBM ContextForge** is the strongest overall candidate for the target architecture:
- Virtual servers approximate namespaces/tool clusters
- Federation via mDNS auto-discovery addresses the nested aggregation requirement
- Broadest transport support (HTTP, WebSocket, SSE, Streamable HTTP, STDIO, gRPC)
- Self-hosted with Docker/K8s/PyPI flexibility
- Active development with strong community (3.5K stars)
- Main gap: the exact 1:many endpoint-to-virtual-server mapping is not definitively documented

**Bifrost** best addresses the client-dimension requirement via virtual keys with per-key tool allow-lists, and is a lightweight self-hosted option, but lacks hierarchy and federation.

**MCP Mesh** has the right conceptual primitives (virtual MCPs, multi-level RBAC, runtime strategies) but lacks federation and detailed documentation.

### Recommended investigation path:

1. **ContextForge** — verify whether virtual servers can be composed under a single endpoint (1:many) and whether federation supports true nested aggregation (gateway consuming gateway)
2. **MetaMCP** — monitor for 1:many endpoint-to-namespace support; the maintainers are aware of this as a design limitation
3. **Hybrid approach** — MetaMCP for namespace/endpoint management + manual federation by registering one MetaMCP endpoint as a server in another instance. This is the pattern already described in the target architecture's "multi-level aggregation" section and works today, just without first-class support

### The ecosystem gap:

No tool in the current landscape provides all of: (a) a clean three-level hierarchy with 1:many endpoint-to-namespace, (b) first-class nested/federated aggregation, (c) per-client tool visibility as a distinct dimension, and (d) lightweight self-hosted deployment. This remains an open design space as of Q1 2026. The market has converged on flat aggregation with RBAC, which addresses enterprise governance but not the multi-dimensional organization model described in the target architecture.

---

*Research conducted April 2026. Tool capabilities based on documentation and public sources; features may have changed since publication.*

### Sources

- [MetaMCP GitHub](https://github.com/metatool-ai/metamcp)
- [MetaMCP Docs](https://docs.metamcp.com/en)
- [Microsoft MCP Gateway](https://github.com/microsoft/mcp-gateway)
- [MCProxy](https://github.com/igrigorik/MCProxy)
- [IBM ContextForge](https://github.com/IBM/mcp-context-forge)
- [MCP Mesh](https://www.decocms.com/blog/post/mcp-mesh)
- [Bifrost](https://github.com/maximhq/bifrost)
- [agentgateway](https://github.com/agentgateway/agentgateway)
- [Cloudflare MCP Portals](https://developers.cloudflare.com/cloudflare-one/access-controls/ai-controls/mcp-portals/)
- [Kong AI MCP Proxy](https://developer.konghq.com/plugins/ai-mcp-proxy/)
- [MCPX / Lunar.dev](https://www.pulsemcp.com/servers/lunar-mcpx-control-plane)
- [awesome-mcp-gateways](https://github.com/e2b-dev/awesome-mcp-gateways)
