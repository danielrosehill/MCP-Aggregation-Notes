# MCP Aggregation Notes

Notes on how MCP aggregation tools organize and expose MCP servers.

## MetaMCP Hierarchy

MetaMCP uses a three-level hierarchy for aggregating MCP servers:

```
Servers → Namespaces → Endpoints
```

### MCP Servers

The base unit. Each server is an individual MCP server configuration (e.g., a HackerNews server running `uvx mcp-hn`, a GitHub server, etc.).

### Namespaces

Namespaces group one or more MCP servers together. This is the organizational layer where you:

- Enable/disable individual servers or specific tools within those servers
- Apply middleware (e.g., filtering inactive tools)
- Override tool names, descriptions, and annotations

A namespace defines a curated set of tools drawn from its member servers.

### Endpoints

Endpoints are the public-facing URLs that clients connect to. Each endpoint:

- Is assigned exactly **one namespace**
- Exposes that namespace's tools via SSE, Streamable HTTP, or OpenAPI transports
- Can support auth via API key or OAuth (MCP Spec 2025-06-18)

You can one-click switch which namespace an endpoint uses. Multiple endpoints can point to different namespaces, letting you expose different tool sets to different clients.

### Visual Summary

```
┌─────────────────────────────────────────────┐
│ Endpoint (URL)                              │
│   ↓ exposes one                             │
│ ┌─────────────────────────────────────────┐ │
│ │ Namespace                               │ │
│ │   ↓ groups one or more                  │ │
│ │ ┌───────────┐ ┌───────────┐ ┌────────┐ │ │
│ │ │ Server A  │ │ Server B  │ │ Server C│ │ │
│ │ └───────────┘ └───────────┘ └────────┘ │ │
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

## Design Friction: The 1:1 Endpoint-to-Namespace Constraint

### The Problem

The current MetaMCP design enforces a strict **1:1 mapping between endpoints and namespaces**. This creates friction when you need to organize servers along multiple dimensions simultaneously.

In practice, there are at least two natural organizing dimensions for MCP servers:

1. **Context** — *Who is this for?* (e.g., Personal vs Work)
2. **Tool Cluster** — *What kind of tools are these?* (e.g., Dev, Creative, Comms, Analytics)

A third dimension, **Accessing Tool** (which client is connecting — Claude Code, a Telegram bot, OpenClaw, etc.), is also relevant but is more of a federation concern.

### What You'd Want

An endpoint should represent a **context** (Personal, Work), and multiple namespaces representing **tool clusters** should be assignable under it:

```
┌─────────────────────────────────────────────────────────┐
│ Endpoint: "Personal Tools"                              │
│                                                         │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐     │
│ │ NS: Dev      │ │ NS: Creative │ │ NS: Comms    │     │
│ │ ┌──┐ ┌──┐   │ │ ┌──┐ ┌──┐   │ │ ┌──┐ ┌──┐   │     │
│ │ │S1│ │S2│   │ │ │S3│ │S4│   │ │ │S5│ │S6│   │     │
│ │ └──┘ └──┘   │ │ └──┘ └──┘   │ │ └──┘ └──┘   │     │
│ └──────────────┘ └──────────────┘ └──────────────┘     │
└─────────────────────────────────────────────────────────┘
```

This would allow you to maintain logical grouping of tool clusters while exposing them all under a single context-based endpoint.

### What You're Forced to Do Instead

Because of the 1:1 constraint, you must choose one of two compromises:

| Approach | Tradeoff |
|----------|----------|
| **One mega-namespace per context** (e.g., "Personal" namespace with all servers) | Loses tool cluster organization; everything is flat |
| **One endpoint per cluster** (e.g., separate endpoints for "Personal-Dev", "Personal-Creative") | Loses the context grouping; the accessing tool must be configured with multiple endpoints |

Neither preserves both dimensions.

### Proposed Hierarchy (1:Many Endpoint-to-Namespace)

A more flexible design would support:

```
Servers → Namespaces (tool clusters) → Endpoints (contexts)
                                         ↑
                                   1:many relationship
```

With dynamic tool exposure becoming more common, this would let a single endpoint expose a rich, organized set of tools while keeping the cluster-level controls (enable/disable, middleware, overrides) that namespaces provide.

### The Accessing Tool Dimension

The accessing tool (Claude Code, Telegram bot, OpenClaw, etc.) is a separate concern from context and clustering. It could be addressed through:

- **Endpoint-level auth/filtering** — different API keys per client, with tool visibility rules
- **A dedicated "client profile" entity** — that maps which namespaces a given client can see within an endpoint
- **Federation** — where each accessing tool connects to its own aggregator that federates from a shared pool of namespaces

This dimension is orthogonal to the context/cluster hierarchy and would ideally be layered on top rather than shoehorned into the namespace model.
