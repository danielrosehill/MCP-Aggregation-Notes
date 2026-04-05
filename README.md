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
