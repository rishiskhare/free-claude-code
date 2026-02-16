<div align="center">

Use **Claude Code CLI for free** with NVIDIA NIM's free API (unlimited usage, 40 requests/min). This lightweight proxy converts Claude Code's Anthropic API requests to NVIDIA NIM format. **Includes Telegram bot integration** for remote control from your phone!

### Use Claude Code CLI & VSCode — for free. No Anthropic API key required.

[![GitHub Stars](https://img.shields.io/github/stars/Alishahryar1/free-claude-code?style=for-the-badge&logo=github)](https://github.com/Alishahryar1/free-claude-code/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/Alishahryar1/free-claude-code?style=for-the-badge&logo=github)](https://github.com/Alishahryar1/free-claude-code/network/members)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Python 3.14](https://img.shields.io/badge/python-3.14-3776ab.svg?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/downloads/)

[![uv](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/uv/main/assets/badge/v0.json&style=for-the-badge)](https://github.com/astral-sh/uv)
[![Tested with Pytest](https://img.shields.io/badge/testing-Pytest-00c0ff.svg?style=for-the-badge)](https://github.com/Alishahryar1/free-claude-code/actions/workflows/tests.yml)
[![Type checking: Ty](https://img.shields.io/badge/type%20checking-ty-ffcc00.svg?style=for-the-badge)](https://pypi.org/project/ty/)
[![Code style: Ruff](https://img.shields.io/badge/code%20formatting-ruff-f5a623.svg?style=for-the-badge)](https://github.com/astral-sh/ruff)
[![Logging: Loguru](https://img.shields.io/badge/logging-loguru-4ecdc4.svg?style=for-the-badge)](https://github.com/Delgan/loguru)

A lightweight proxy server that translates Claude Code's Anthropic API calls into **NVIDIA NIM**, **OpenRouter**, or **LM Studio** format.
Get **40 free requests/min** on NVIDIA NIM, access **hundreds of models** on OpenRouter, or run **fully local** with LM Studio.

[Features](#features) · [Quick Start](#quick-start) · [How It Works](#how-it-works) · [Providers](#providers) · [Discord Bot](#discord-bot) · [Configuration](#configuration)

---

</div>

<div align="center">
  <img src="pic.png" alt="Free Claude Code in action" width="700">
  <p><em>Claude Code running via NVIDIA NIM — completely free</em></p>
</div>

## Features

| Feature | Description |
|---------|-------------|
| **Zero Cost** | 40 req/min free on NVIDIA NIM. Free models on OpenRouter. Fully local with LM Studio |
| **Drop-in Replacement** | Set 2 env vars — no modifications to Claude Code CLI or VSCode extension needed |
| **3 Providers** | NVIDIA NIM, OpenRouter (hundreds of models), LM Studio (local & offline) |
| **Thinking Token Support** | Parses `  <think> ` tags and `reasoning_content` into native Claude thinking blocks |
| **Heuristic Tool Parser** | Models outputting tool calls as text are auto-parsed into structured tool use |
| **Request Optimization** | 5 categories of trivial API calls intercepted locally — saves quota and latency |
| **Discord Bot** | Remote autonomous coding with tree-based threading, session persistence, and live progress |
| **Telegram Bot** | Alternative messaging platform for mobile control |
| **Smart Rate Limiting** | Proactive rolling-window throttle + reactive 429 exponential backoff across all providers |
| **Subagent Control** | Task tool interception forces `run_in_background=False` — no runaway subagents |
| **Extensible** | Clean `BaseProvider` and `MessagingPlatform` ABCs — add new providers or platforms easily |

---

## Quick Start (5 minutes)

### Step 1: Install the prerequisites

You need these before starting:

| What | Where to get it |
| --- | --- |
| NVIDIA API key (free) | [build.nvidia.com/settings/api-keys](https://build.nvidia.com/settings/api-keys) |
| Claude Code CLI | [github.com/anthropics/claude-code](https://github.com/anthropics/claude-code) |
| uv (Python package runner) | [github.com/astral-sh/uv](https://github.com/astral-sh/uv) |
| PM2 (keeps the proxy running) | `npm install -g pm2` |
| fzf (fuzzy model picker) | [github.com/junegunn/fzf](https://github.com/junegunn/fzf) |


### Step 2: Clone the repo and add your API key

```bash
cp .env.example .env
```

Now open `.env` in any text editor and paste your NVIDIA API key on the first line:

```dotenv
NVIDIA_NIM_API_KEY=nvapi-paste-your-key-here
```

Save the file. That's the only thing you need to edit.

### Step 3: Start the proxy server

```bash
pm2 start "uv run uvicorn server:app --host 0.0.0.0 --port 8082" --name "claude-proxy"
```

That's it — the proxy is now running in the background. You can close this terminal and it keeps going. Use these commands to manage it:

| Command | What it does |
| --- | --- |
| `pm2 logs claude-proxy` | See server logs (useful for troubleshooting) |
| `pm2 stop claude-proxy` | Stop the proxy |
| `pm2 restart claude-proxy` | Restart it (e.g., after editing `.env`) |
| `pm2 list` | Check if the proxy is running |

### Step 4: Launch Claude Code

#### Option A: Terminal (CLI)

Add this alias to your `~/.zshrc` (macOS) or `~/.bashrc` (Linux):

```bash
alias claude-free='/full/path/to/free-claude-code/claude-free'
```

Replace the path with where you cloned the repo (e.g., `/Users/yourname/Downloads/free-claude-code/`), then reload your shell:

```bash
source ~/.zshrc # or: source ~/.bashrc
```

Now you can run it from any directory:

```bash
claude-free
```

You'll see a searchable list of every available model. Pick one and go. Just type a few letters to filter (e.g., type "kimi" to find Kimi K2.5 instantly).

#### Option B: VSCode Extension

If you use the [Claude Code VSCode extension](https://marketplace.visualstudio.com/items?itemName=anthropics.claude-code), you can point it at the proxy too:

1. Open VSCode Settings (`Cmd + ,` on macOS, `Ctrl + ,` on Linux/Windows).
2. Search for `claude-code.environmentVariables`.
3. Click **Edit in settings.json** and add:

```json
"claude-code.environmentVariables": [
  { "name": "ANTHROPIC_BASE_URL", "value": "http://localhost:8082" },
  { "name": "ANTHROPIC_AUTH_TOKEN", "value": "freecc" }
]
```

4. Reload the extension (or restart VSCode).

That's it — the Claude Code panel in VSCode now uses NVIDIA NIM for free. To switch back to Anthropic, remove or comment out the block above and reload.

> **Tip:** To use a specific model from VSCode, set the token to `freecc:model-id` (e.g., `"freecc:moonshotai/kimi-k2.5"`). Otherwise it uses the `MODEL` value from your `.env`.

---

## Model-Specific Aliases (Optional)

You can also create aliases that skip the picker and go straight into a specific model. Add this to your `~/.zshrc` or `~/.bashrc`:

```bash
alias claude-kimi='ANTHROPIC_BASE_URL="http://localhost:8082" ANTHROPIC_AUTH_TOKEN="freecc:moonshotai/kimi-k2.5" claude'
```

Swap out the model ID after `freecc:` to use any model. Then run `source ~/.zshrc` (or `source ~/.bashrc`).

---

## How It Works

```
┌─────────────────┐     ┌──────────────────────┐     ┌──────────────────┐
│  Claude Code    │────>│  Free Claude Code    │────>│  LLM Provider    │
│  CLI / VSCode   │<────│  Proxy (:8082)       │<────│  NIM / OR / LMS  │
└─────────────────┘     └──────────────────────┘     └──────────────────┘
       Anthropic API    │  Optimizations             OpenAI-compatible
       format (SSE)     ├─ Quota probes              format (SSE)
                          ├─ Title gen skip
                          ├─ Prefix detect
                          ├─ Suggestion skip
                          └─ Filepath mock
```

- **Transparent proxy** — Claude Code sends standard Anthropic API requests to the proxy server
- **Request optimization** — 5 categories of trivial requests (quota probes, title generation, prefix detection, suggestions, filepath extraction) are intercepted and responded to instantly without using API quota
- **Format translation** — Real requests are translated from Anthropic format to the provider's OpenAI-compatible format and streamed back
- **Thinking tokens** — `  <think> ` tags and `reasoning_content` fields are converted into native Claude thinking blocks so Claude Code renders them correctly

---

## Providers

Switch providers by changing `PROVIDER_TYPE` in `.env`:

| Provider | Cost | Rate Limit | Models | Best For |
|----------|------|------------|--------|----------|
| **NVIDIA NIM** | Free | 40 req/min | Kimi K2, GLM5, Devstral, MiniMax | Daily driver — generous free tier |
| **OpenRouter** | Free / Pay | Varies | 200+ (GPT-4o, Claude, Step, etc.) | Model variety, fallback options |
| **LM Studio** | Free (local) | Unlimited | Any GGUF model | Privacy, offline use, no rate limits |

| Provider | `PROVIDER_TYPE` | API Key Variable | Base URL |
|----------|-----------------|------------------|----------|
| NVIDIA NIM | `nvidia_nim` | `NVIDIA_NIM_API_KEY` | `integrate.api.nvidia.com/v1` |
| OpenRouter | `open_router` | `OPENROUTER_API_KEY` | `openrouter.ai/api/v1` |
| LM Studio | `lmstudio` | (none) | `localhost:1234/v1` |

OpenRouter gives access to hundreds of models (StepFun, OpenAI, Anthropic, etc.) through a single API. Set `MODEL` to any OpenRouter model ID.

LM Studio runs locally — start the server in LM Studio's Developer tab or via `lms server start`, load a model, and set `MODEL` to the model identifier.

### Popular Models

| Model | ID | Notes |
| --- | --- | --- |
| Kimi K2.5 | `moonshotai/kimi-k2.5` | Great all-rounder |
| Step 3.5 Flash | `stepfun-ai/step-3.5-flash` | Fast |
| GLM 4.7 | `z-ai/glm4.7` | Strong reasoning |
| MiniMax M2.1 | `minimaxai/minimax-m2.1` | |
| Devstral 2 | `mistralai/devstral-2-123b-instruct-2512` | Code-focused |

The full list is in [`nvidia_nim_models.json`](nvidia_nim_models.json). Browse all NVIDIA NIM models at [build.nvidia.com](https://build.nvidia.com/explore/discover).

To refresh the model list with the latest from NVIDIA:

```bash
curl "https://integrate.api.nvidia.com/v1/models" > nvidia_nim_models.json
```

---

## Discord Bot

Control Claude Code remotely from Discord. Send tasks, watch live progress, and manage multiple concurrent sessions.

**Capabilities:**
- Tree-based message threading — reply to messages to fork conversations
- Session persistence across server restarts
- Live streaming of thinking tokens, tool calls, and results
- Up to 10 concurrent Claude CLI sessions
- Commands: `/stop` (cancel tasks), `/clear` (reset all sessions), `/stats`

### Setup

1. **Create a Discord Bot** — Go to [Discord Developer Portal](https://discord.com/developers/applications), create an application, add a bot, and copy the token. Enable **Message Content Intent** under Bot settings.

2. **Edit `.env`:**

```dotenv
MESSAGING_PLATFORM=discord
DISCORD_BOT_TOKEN=your_discord_bot_token
ALLOWED_DISCORD_CHANNELS=123456789,987654321
```

> Enable Developer Mode in Discord (Settings → Advanced), then right-click a channel and "Copy ID" to get channel IDs. Comma-separate multiple channels. If empty, no channels are allowed.

3. **Configure the workspace** (where Claude will operate):

```dotenv
CLAUDE_WORKSPACE=./agent_workspace
ALLOWED_DIR=/Users/yourname/projects
```

4. **Start the server:**

```bash
uv run uvicorn server:app --host 0.0.0.0 --port 8082
```

5. **Invite the bot** to your server (OAuth2 → URL Generator, scopes: `bot`, permissions: Read Messages, Send Messages, Manage Messages, Read Message History). Send a message in an allowed channel with a task. Claude responds with thinking tokens, tool calls as they execute, and the final result. Reply `/stop` to a running task to cancel it.

---

## Telegram Bot Integration (Alternative)

Control Claude Code remotely from your phone via Telegram. Send tasks, watch Claude work, get results.

### Setup

1. **Create a bot:** Message [@BotFather](https://t.me/BotFather) on Telegram, send `/newbot`, follow the prompts, and copy the API token it gives you.

2. **Find your user ID:** Message [@userinfobot](https://t.me/userinfobot) on Telegram. It will reply with your numeric user ID.

3. **Add both to your `.env` file:**

```dotenv
MESSAGING_PLATFORM=telegram
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrSTUvwxYZ
ALLOWED_TELEGRAM_USER_ID=your_numeric_user_id
```

4. **Optionally set the workspace** (the directory Claude is allowed to work in):

```dotenv
CLAUDE_WORKSPACE=./agent_workspace
ALLOWED_DIR=/Users/yourname/projects
```

5. **Start the server** (`uv run uvicorn server:app --host 0.0.0.0 --port 8082`) and send a message to your bot. Send `/stop` to cancel running tasks.

---

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `claude-free` says "command not found" | Make sure you added the alias to your shell config and ran `source ~/.zshrc` (or `source ~/.bashrc`) |
| "nvidia_nim_models.json not found" | Run `curl "https://integrate.api.nvidia.com/v1/models" > nvidia_nim_models.json` |
| NVIDIA API errors | Check that your `NVIDIA_NIM_API_KEY` in `.env` is correct and not expired |
| "Connection refused" when running Claude | Make sure the proxy server is running in another terminal (Step 3) |
| Model not working | Not all models in the list support chat. Try a popular one like `moonshotai/kimi-k2.5` |

---

## Configuration Reference

The only setting most users need is `NVIDIA_NIM_API_KEY` in `.env`. Everything else has sensible defaults.

| Variable | Description | Default |
| --- | --- | --- |
| `NVIDIA_NIM_API_KEY` | Your NVIDIA API key | **required** |
| `PROVIDER_TYPE` | Provider: `nvidia_nim`, `open_router`, or `lmstudio` | `nvidia_nim` |
| `MODEL` | Model to use for all requests | `stepfun-ai/step-3.5-flash` |
| `OPENROUTER_API_KEY` | OpenRouter API key (OpenRouter provider) | `""` |
| `LM_STUDIO_BASE_URL` | LM Studio server URL | `http://localhost:1234/v1` |
| `PROVIDER_RATE_LIMIT` | LLM API requests per window | `40` |
| `PROVIDER_RATE_WINDOW` | Rate limit window (seconds) | `60` |
| `CLAUDE_WORKSPACE` | Directory for agent workspace | `./agent_workspace` |
| `ALLOWED_DIR` | Allowed directories for agent | `""` |
| `MAX_CLI_SESSIONS` | Max concurrent CLI sessions | `10` |
| `FAST_PREFIX_DETECTION` | Enable fast prefix detection | `true` |
| `ENABLE_NETWORK_PROBE_MOCK` | Enable network probe mock | `true` |
| `ENABLE_TITLE_GENERATION_SKIP` | Skip title generation | `true` |
| `ENABLE_SUGGESTION_MODE_SKIP` | Skip suggestion mode | `true` |
| `ENABLE_FILEPATH_EXTRACTION_MOCK` | Enable filepath extraction mock | `true` |
| `MESSAGING_PLATFORM` | Messaging platform: `discord` or `telegram` | `telegram` |
| `DISCORD_BOT_TOKEN` | Discord Bot Token | `""` |
| `ALLOWED_DISCORD_CHANNELS` | Comma-separated channel IDs (empty = none allowed) | `""` |
| `TELEGRAM_BOT_TOKEN` | Telegram Bot Token | `""` |
| `ALLOWED_TELEGRAM_USER_ID` | Allowed Telegram User ID | `""` |
| `MESSAGING_RATE_LIMIT` | Messaging messages per window | `40` |
| `MESSAGING_RATE_WINDOW` | Messaging window (seconds) | `1` |

The NVIDIA NIM base URL is fixed to `https://integrate.api.nvidia.com/v1`.

<details>
<summary><strong>Advanced: NIM model settings (most users should skip this)</strong></summary>

These control how the AI model generates responses. The defaults work well. Only change these if you understand what they do.

| Variable | Description | Default |
| --- | --- | --- |
| `NVIDIA_NIM_TEMPERATURE` | Sampling temperature | `1.0` |
| `NVIDIA_NIM_TOP_P` | Top-p nucleus sampling | `1.0` |
| `NVIDIA_NIM_TOP_K` | Top-k sampling | `-1` |
| `NVIDIA_NIM_MAX_TOKENS` | Max tokens for generation | `81920` |
| `NVIDIA_NIM_PRESENCE_PENALTY` | Presence penalty | `0.0` |
| `NVIDIA_NIM_FREQUENCY_PENALTY` | Frequency penalty | `0.0` |
| `NVIDIA_NIM_MIN_P` | Min-p sampling | `0.0` |
| `NVIDIA_NIM_REPETITION_PENALTY` | Repetition penalty | `1.0` |
| `NVIDIA_NIM_SEED` | RNG seed (blank = unset) | unset |
| `NVIDIA_NIM_STOP` | Stop string (blank = unset) | unset |
| `NVIDIA_NIM_PARALLEL_TOOL_CALLS` | Parallel tool calls | `true` |
| `NVIDIA_NIM_RETURN_TOKENS_AS_TOKEN_IDS` | Return token ids | `false` |
| `NVIDIA_NIM_INCLUDE_STOP_STR_IN_OUTPUT` | Include stop string in output | `false` |
| `NVIDIA_NIM_IGNORE_EOS` | Ignore EOS token | `false` |
| `NVIDIA_NIM_MIN_TOKENS` | Minimum generated tokens | `0` |
| `NVIDIA_NIM_CHAT_TEMPLATE` | Chat template override | unset |
| `NVIDIA_NIM_REQUEST_ID` | Request id override | unset |
| `NVIDIA_NIM_REASONING_EFFORT` | Reasoning effort | `high` |
| `NVIDIA_NIM_INCLUDE_REASONING` | Include reasoning in response | `true` |

All `NVIDIA_NIM_*` settings are strictly validated; unknown keys with this prefix will cause startup errors.

</details>

See [`.env.example`](.env.example) for all supported parameters.
