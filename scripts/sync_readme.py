#!/usr/bin/env python3
from __future__ import annotations

import os
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM_REF = os.environ.get("UPSTREAM_REF", "upstream/main")
TOP_NOTE = "> Based on [Alishahryar1/free-claude-code](https://github.com/Alishahryar1/free-claude-code). This fork adds simplified setup and easy custom model selection."
QUICK_START_SECTION = """## Quick Start (5 minutes)

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
git clone https://github.com/rishiskhare/free-claude-code.git
cd free-claude-code
cp .env.example .env
```

Now open `.env` in any text editor and paste your NVIDIA API key on the first line:

```dotenv
NVIDIA_NIM_API_KEY=nvapi-paste-your-key-here
```

Save the file. That's the only thing you need to edit.

> **Want to use a different provider?** See [Providers](#providers) for OpenRouter (hundreds of models) or LM Studio (fully local).

### Step 3: Start the proxy server

```bash
pm2 start "uv run uvicorn server:app --host 0.0.0.0 --port 8082" --name "claude-proxy"
```

That's it - the proxy is now running in the background. You can close this terminal and it keeps going. Use these commands to manage it:

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
5. **If you see the login screen** ("How do you want to log in?"): Click **Anthropic Console**, then authorize. The extension will start working. You may be redirected to buy credits in the browser - ignore that; the extension already works.

That's it - the Claude Code panel in VSCode now uses NVIDIA NIM for free. To switch back to Anthropic, remove or comment out the block above and reload.

> **Tip:** To use a specific model from VSCode, set the token to `freecc:model-id` (e.g., `"freecc:moonshotai/kimi-k2.5"`). Otherwise it uses the `MODEL` value from your `.env`.
"""
MODEL_ALIASES_SECTION = """## Model-Specific Aliases (Optional)

You can also create aliases that skip the picker and go straight into a specific model. Add this to your `~/.zshrc` or `~/.bashrc`:

```bash
alias claude-kimi='ANTHROPIC_BASE_URL="http://localhost:8082" ANTHROPIC_AUTH_TOKEN="freecc:moonshotai/kimi-k2.5" claude'
```

Swap out the model ID after `freecc:` to use any model. Then run `source ~/.zshrc` (or `source ~/.bashrc`).
"""


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def git_show(ref: str, relpath: str) -> str | None:
    try:
        return subprocess.check_output(
            ["git", "show", f"{ref}:{relpath}"],
            cwd=ROOT,
            text=True,
        )
    except subprocess.CalledProcessError:
        return None


def ensure_top_note(text: str, note: str) -> str:
    if note.strip() in text:
        return text
    match = re.search(r"^# .+$", text, re.M)
    if match:
        insert_at = match.end()
        return text[:insert_at] + "\n\n" + note.strip() + "\n" + text[insert_at:]
    return note.strip() + "\n\n" + text


def replace_section(text: str, heading_pattern: str, new_section: str) -> str:
    pattern = re.compile(
        rf"^{heading_pattern}\n.*?(?=^##\s+|\Z)",
        re.S | re.M,
    )
    new_block = new_section.strip() + "\n\n"
    if pattern.search(text):
        return pattern.sub(new_block, text, count=1)
    return text.rstrip() + "\n\n" + new_block


def main() -> None:
    upstream_readme = git_show(UPSTREAM_REF, "README.md")
    if upstream_readme is None:
        upstream_readme = read_text(ROOT / "README.md")

    updated = ensure_top_note(upstream_readme, TOP_NOTE)
    updated = replace_section(updated, r"##\s+Quick Start.*", QUICK_START_SECTION)
    updated = replace_section(updated, r"##\s+Model-Specific Aliases.*", MODEL_ALIASES_SECTION)

    (ROOT / "README.md").write_text(updated.rstrip() + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
