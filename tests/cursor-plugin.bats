#!/usr/bin/env bats

setup() {
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    MARKETPLACE="$REPO_ROOT/.cursor-plugin/marketplace.json"
    MANIFEST="$REPO_ROOT/.cursor-plugin/plugin.json"
}

@test "Cursor team marketplace exposes AgentKey through a GitHub source" {
    python3 - "$MARKETPLACE" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    marketplace = json.load(handle)

assert marketplace["name"] == "agentkey"
assert marketplace["owner"] == {"name": "Chainbase Labs"}
assert marketplace["metadata"]["description"]
assert len(marketplace["plugins"]) == 1

plugin = marketplace["plugins"][0]
assert plugin["name"] == "agentkey"
assert plugin["source"] == {
    "source": "github",
    "repo": "chainbase-labs/Agentkey",
}
assert plugin["source"] != "./"
PY
}

@test "Cursor plugin manifest bundles the shared skill and remote MCP server" {
    python3 - "$MANIFEST" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    manifest = json.load(handle)

assert manifest["name"] == "agentkey"
assert manifest["skills"] == "./skills/"
assert manifest["mcpServers"] == {
    "agentkey": {
        "url": "https://api.agentkey.app/v1/mcp",
    }
}
PY

    [ -f "$REPO_ROOT/skills/agentkey/SKILL.md" ]
}

@test "Cursor marketplace entry and plugin manifest names stay synchronized" {
    python3 - "$MARKETPLACE" "$MANIFEST" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    marketplace = json.load(handle)
with open(sys.argv[2], encoding="utf-8") as handle:
    manifest = json.load(handle)

assert marketplace["plugins"][0]["name"] == manifest["name"]
PY
}
