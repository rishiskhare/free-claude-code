# Custom Features (Fork-Specific)

This fork adds features not present in the upstream repository:

1. **`claude-free` command** — Interactive model picker with fuzzy search
2. **`claude-kimi` alias** — Direct alias to launch with a specific model
3. **`/v1/models` endpoint** — API endpoint listing available NVIDIA NIM models
4. **Per-session model override** — Pass model via auth token `freecc:org/model-name`

## Prerequisites

In addition to upstream requirements:

| Tool | Purpose |
|------|---------|
| fzf | Fuzzy model picker for `claude-free` |

Install: `brew install fzf` (macOS) or `apt-get install fzf` (Linux)

## claude-free (Model Picker)

Install the alias in your `~/.zshrc` or `~/.bashrc`:

```bash
alias claude-free='/full/path/to/free-claude-code/claude-free'
```

Then run:

```bash
claude-free
```

This launches an interactive picker showing all NVIDIA NIM models. Use arrow keys or type to filter (e.g., "kimi" to find Kimi K2.5). Press Enter to launch Claude Code with your selected model.

## Model-Specific Aliases

Skip the picker and launch directly with a model:

```bash
alias claude-kimi='ANTHROPIC_BASE_URL="http://localhost:8082" ANTHROPIC_AUTH_TOKEN="freecc:moonshotai/kimi-k2.5" claude'
alias claude-step='ANTHROPIC_BASE_URL="http://localhost:8082" ANTHROPIC_AUTH_TOKEN="freecc:stepfun-ai/step-3.5-flash" claude'
```

After adding to your shell config: `source ~/.zshrc`

## VSCode Extension with Model Override

In VSCode settings.json, specify model inline:

```json
{
  "name": "ANTHROPIC_AUTH_TOKEN",
  "value": "freecc:moonshotai/kimi-k2.5"
}
```

Or use `freecc` to use the default from `.env`.

## API: List Models

The proxy provides a `/v1/models` endpoint for programmatic access:

```bash
curl http://localhost:8082/v1/models
```

Returns NVIDIA NIM models list in OpenAI-compatible format.

## Syncing with Upstream

These features are kept in separate files to avoid merge conflicts:

- `claude-free` — standalone script
- `api/custom_routes.py` — custom API endpoints
- `CUSTOM_FEATURES.md` — this documentation

The regular sync workflow will preserve these files while updating core code.
