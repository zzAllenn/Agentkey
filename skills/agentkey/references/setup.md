# AgentKey — Setup details

Two ways to connect the hosted MCP server. Use the client-attributed endpoint
when one is listed below; otherwise use `https://api.agentkey.app/v1/mcp`.
**Prefer OAuth.** Use the API-key fallback only when the client can't do MCP
OAuth, or the OAuth flow fails.

## OAuth registration (preferred)

First check whether the client already lists an `agentkey` MCP server. Plugin
and extension installs bundle that entry, so authenticate it in place. Do not
add a second server and do not run `@agentkey/cli --auth-login` for that client.

### Gemini CLI extension

1. Confirm `agentkey` is active with `/extensions list`.
2. On the first connection, the extension's `oauth.enabled` setting asks
   Gemini to start its native browser authorization automatically. Complete
   that flow when it opens.
3. If Gemini only reports that authentication is required, or the browser flow
   was closed, run `/mcp auth agentkey` to start it manually.
4. Run `/mcp reload`, then `/mcp list` and confirm `agentkey` is connected.
5. Retry the original request only after `find_tools`, `describe_tool`, and
   `execute_tool` are visible.

A warning that `~/.agents/skills/agentkey` overrides the extension's bundled
skill is separate from MCP authentication. Gemini gives user skills higher
precedence than extension skills. If both copies are the same version, the
warning is harmless. Remove the user copy only when no other agent relies on
that shared skill directory.

### Antigravity plugin

AgentKey supports dynamic client registration, so keep `mcp_config.json`
credential-free and authenticate the bundled `serverUrl` entry:

- **Antigravity 2.0:** open **Settings → Customizations → Installed MCP
  Servers**, click **Authenticate** next to AgentKey, complete the browser
  flow, copy the authorization code, paste it into the settings panel, and
  submit it. The server reconnects automatically; use **Refresh** if its status
  does not update.
- **Antigravity CLI:** open `/mcp`, select the `agentkey` server, choose
  **Authenticate**, and follow the browser/code prompts shown by the manager.
  Reload the server in the same panel, inspect its logs if it remains
  disconnected, and retry only after the AgentKey tools appear.

Do not put OAuth client secrets, access tokens, or an `Authorization` header in
the plugin package.

### Other clients

If no AgentKey server entry exists, add the server with **no API key** and let
the client run its own browser OAuth. The exact step depends on the client;
these are examples, not the only supported clients:

- **Claude Code:** `claude mcp add --transport http agentkey https://api.agentkey.app/claude/v1/mcp`,
  then `/mcp` → agentkey → **Authenticate**.
- **Claude Desktop:** add `https://api.agentkey.app/claude/v1/mcp` as a remote
  MCP server in settings with no auth header.
- **Cursor:** use `https://api.agentkey.app/cursor/v1/mcp`.
- **Codex:** use `https://api.agentkey.app/codex/v1/mcp`.
- **Gemini CLI:** use `https://api.agentkey.app/gemini/v1/mcp`.
- **Kimi CLI:** use `https://api.agentkey.app/kimi/v1/mcp`.
- **Another client:** add `https://api.agentkey.app/v1/mcp` as an HTTP MCP server with no
  `Authorization` header. If the client supports MCP OAuth it prompts to
  authorize on first connect; if it doesn't, use the API-key fallback below.

After authorizing, the AgentKey tools (`find_tools`, `describe_tool`,
`execute_tool`, plus the deprecated `list_tools`) appear once the agent
reconnects/restarts.

## API-key fallback

Use only when the client can't do MCP OAuth, or its native OAuth flow failed.
An extension/plugin server that merely starts as disconnected is not a reason
to fall back; complete its client-specific authentication flow first.

1. Grab a key at https://console.agentkey.app/
2. Choose the same client-specific URL listed above. If the client is not
   listed, use the generic `https://api.agentkey.app/v1/mcp` endpoint.
3. Paste this into the agent's MCP config (path varies per agent), replacing
   the generic `url` value with the selected client-specific URL when one is
   listed above:
   ```json
   {
     "mcpServers": {
       "agentkey": {
         "type": "http",
         "url": "https://api.agentkey.app/v1/mcp",
         "headers": { "Authorization": "Bearer ak_..." }
       }
     }
   }
   ```
4. Restart the agent.

If you don't know the user's agent, ask which one they're using (Claude Code,
Claude Desktop, Cursor, Codex, …).
