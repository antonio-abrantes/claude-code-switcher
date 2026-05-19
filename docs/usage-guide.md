# 📖 Complete Usage Guide — All CCS Commands

## Quick Reference

| Command | What it does | Example |
|---------|----------|---------|
| `ccs` | Lists all profiles | `ccs` |
| `ccs <name>` | Switches to a profile | `ccs deepseek` |
| `ccs switch <name>` | Switches to a profile | `ccs switch deepseek` |
| `ccs current` | Shows the active profile | `ccs current` |
| `ccs add <name>` | Creates a new profile | `ccs add openrouter` |
| `ccs key <name>` | Updates the API key | `ccs key deepseek` |
| `ccs edit <name>` | Edits the profile in the editor | `ccs edit deepseek` |
| `ccs remove <name>` | Removes a profile | `ccs remove openrouter` |
| `ccs test` | Tests the active profile's connection | `ccs test` |
| `ccs run <name>` | Runs Claude with a specific profile | `ccs run deepseek` |
| `ccs run --provider <p> --model <m>` | Runs without a saved profile | See below |
| `ccs clean` | Session without agents/skills | `ccs clean` |
| `ccs clean <name>` | Clean session + specific profile | `ccs clean deepseek` |
| `ccs clean --restore` | Manually restores agents/skills | `ccs clean --restore` |
| `ccs --help` | Shows help | `ccs --help` |

---

## Detailed Commands with Examples

### 📋 `ccs` or `ccs list` — List Profiles

Shows all available profiles and highlights which one is active.

```bash
$ ccs

* anthropic (active)
  deepseek
  openrouter
```

The `*` indicates which profile is currently active.

---

### 🔄 `ccs switch <name>` or `ccs <name>` — Switch Provider

Switches the active provider. The short form (`ccs deepseek`) works the same as `ccs switch deepseek`.

```bash
# Full form
$ ccs switch deepseek
Switched to deepseek

# Short form (shortcut)
$ ccs deepseek
Switched to deepseek

# Go back to Anthropic
$ ccs anthropic
Switched to anthropic
```

> [!TIP]
> After switching, any new use of `claude` will automatically use the new provider. **No need to restart the terminal.**

---

### 📍 `ccs current` — View Active Profile

Shows details of the active profile (the API key is hidden for security).

```bash
$ ccs current

Active: deepseek
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_EFFORT_LEVEL": "max"
  }
}
```

> [!NOTE]
> The `ANTHROPIC_AUTH_TOKEN` field is automatically removed from the output to not expose your key.

---

### ➕ `ccs add <name>` — Create New Profile

Creates a profile interactively. CCS asks for the necessary information.

```bash
$ ccs add openrouter

BASE URL (ex: https://omniroute... or empty): https://openrouter.ai/api
AUTH TOKEN (Your API Key): sk-or-v1-xxxxxxxxxxxxxxxxxxxxxxxxx
MAIN MODEL (ex: cx/gpt-5.5 or empty): anthropic/claude-sonnet-4-20250514
FAST MODEL (ex: cx/gpt-5.4-mini or empty): anthropic/claude-haiku-3

Profile 'openrouter' created successfully!
Tip: You can manually edit it with 'ccs edit openrouter'
```

**What is requested:**

| Field | Description | Example |
|-------|-----------|---------|
| BASE URL | Provider API endpoint (empty for Anthropic) | `https://api.deepseek.com/anthropic` |
| AUTH TOKEN | Your API key | `sk-xxxxxxxxxxxx` |
| MAIN MODEL | Main model for complex tasks | `deepseek-v4-pro` |
| FAST MODEL | Fast model for simple tasks (agents) | `deepseek-v4-flash` |

> [!TIP]
> If CCS detects the provider by the URL (DeepSeek, OpenRouter, Fireworks), it tries to auto-fill the API key using existing environment variables.

---

### 🔑 `ccs key <name>` — Update API Key

Updates only the API key of an existing profile.

```bash
$ ccs key deepseek

New API key for 'deepseek': ████████████████
Updated API key for deepseek
```

> [!NOTE]
> The key is typed silently (does not appear on the screen), for security.

---

### ✏️ `ccs edit <name>` — Edit Profile

Opens the profile JSON file in your default text editor.

```bash
# Uses $EDITOR (or vi as fallback on Linux, notepad on Windows)
$ ccs edit deepseek
```

The file will be opened for direct editing. You can modify any field.

**Example of full profile for editing:**
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "sk-your-key",
    "ANTHROPIC_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_EFFORT_LEVEL": "max"
  }
}
```

---

### 🗑️ `ccs remove <name>` — Remove Profile

Permanently deletes a profile.

```bash
$ ccs remove openrouter
Removed: openrouter
```

> [!WARNING]
> If the removed profile is the active one, the symbolic link is removed and you will be left without an active profile. Use `ccs switch <other>` to select another one.

---

### 🧪 `ccs test` — Test Connection

Makes a real call to the active provider's API to check if it's working.

```bash
# Success
$ ccs test
Testing deepseek (deepseek-v4-pro[1m])... OK

# Failure (invalid key)
$ ccs test
Testing deepseek (deepseek-v4-pro[1m])... FAIL (HTTP 401: Invalid API key)
```

> [!IMPORTANT]
> This command makes a **real** API call. If the provider charges per call, it will be billed (however it uses `max_tokens: 1`, so the cost is minimal).

---

### 🚀 `ccs run <name>` — Run Claude with Specific Profile

Starts Claude Code using a profile **without changing the active profile**.

```bash
# Run with DeepSeek without changing active
$ ccs run deepseek

# Run with DeepSeek and pass extra arguments to Claude
$ ccs run deepseek --print "explain this code"

# Run with OpenRouter
$ ccs run openrouter
```

**Difference between `switch` and `run`:**

| `ccs switch deepseek` | `ccs run deepseek` |
|---|---|
| Changes the active profile **permanently** | Uses the profile **only for this execution** |
| Next calls to `claude` use DeepSeek | The active profile remains the previous one |

---

### ⚡ `ccs run --provider --model` — Ephemeral Mode (No Saved Profile)

Runs Claude with a provider **without having a saved profile**. Useful for quick tests.

```bash
# Ephemeral mode with DeepSeek
$ ccs run --provider deepseek --model deepseek-v4-pro --key sk-my-key

# Ephemeral mode with OpenRouter
$ ccs run --provider openrouter --model anthropic/claude-sonnet-4-20250514 --key sk-or-key

# With additional small model
$ ccs run --provider deepseek --model deepseek-v4-pro --small-model deepseek-v4-flash
```

**Ephemeral mode parameters:**

| Flag | Required | Description |
|------|------------|-----------|
| `--provider` | ✅ | Provider name (`deepseek`, `openrouter`, `fireworks`) |
| `--model` | ✅ | Main model name |
| `--key` | ⚠️ | API Key (uses env var if not provided) |
| `--small-model` | ❌ | Model for smaller tasks |

> [!TIP]
> If you have the provider's environment variable configured (e.g. `DEEPSEEK_API_KEY`), you don't need to pass `--key`.

---

### 🧹 `ccs clean` — Clean Session (No Agents/Skills)

Starts Claude Code **without custom agents and skills**, saving context tokens.

```bash
# Clean session with active profile
$ ccs clean

ccs: disabled agents for this session
ccs: disabled skills for this session
# ... Claude starts ...
# When exiting Claude:
ccs: restored agents
ccs: restored skills

# Clean session with specific profile
$ ccs clean deepseek

# Clean session with ephemeral provider
$ ccs clean --provider deepseek --model deepseek-v4-pro
```

> [!IMPORTANT]
> Agents and skills are **automatically restored** when Claude closes. If the process crashes, use `ccs clean --restore` to restore manually.

**Manual restoration:**
```bash
$ ccs clean --restore

ccs: restored agents
ccs: restored skills
ccs: cleanup complete
```

---

## Daily Scenarios

### Scenario 1: "I want to save money day-to-day"

```bash
# Use DeepSeek as default (cheaper)
ccs switch deepseek

# When you need something more powerful, switch temporarily
ccs run anthropic

# Or switch back
ccs anthropic
```

### Scenario 2: "I want to quickly test a new model"

```bash
# Test without creating profile
ccs run --provider openrouter --model meta-llama/llama-3.1-405b --key sk-or-key

# If you like it, create a permanent profile
ccs add llama
```

### Scenario 3: "Claude is consuming too many tokens"

```bash
# Start a clean session (no agents/skills)
ccs clean

# Or clean session with specific provider
ccs clean deepseek
```

### Scenario 4: "I need to check if my API key still works"

```bash
# Test active provider
ccs test

# If it fails, update the key
ccs key deepseek
```

### Scenario 5: "I want to see my current settings"

```bash
# See which provider is active and its settings
ccs current

# See all available profiles
ccs
```

---

## Ready-to-Use Profile Examples

### Anthropic (Default)
```json
{
  "env": {}
}
```

### DeepSeek
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "sk-YOUR-DEEPSEEK-KEY",
    "ANTHROPIC_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-flash"
  }
}
```

### OpenRouter
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://openrouter.ai/api",
    "ANTHROPIC_AUTH_TOKEN": "sk-or-YOUR-OPENROUTER-KEY",
    "ANTHROPIC_MODEL": "anthropic/claude-sonnet-4-20250514",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "anthropic/claude-sonnet-4-20250514",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "anthropic/claude-sonnet-4-20250514",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "anthropic/claude-haiku-3",
    "CLAUDE_CODE_SUBAGENT_MODEL": "anthropic/claude-haiku-3",
    "CLAUDE_CODE_EFFORT_LEVEL": "default"
  }
}
```

### Fireworks AI
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.fireworks.ai/inference",
    "ANTHROPIC_AUTH_TOKEN": "fw-YOUR-FIREWORKS-KEY",
    "ANTHROPIC_MODEL": "accounts/fireworks/models/llama-v3p1-405b-instruct",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "accounts/fireworks/models/llama-v3p1-405b-instruct",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "accounts/fireworks/models/llama-v3p1-405b-instruct",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "accounts/fireworks/models/llama-v3p1-8b-instruct",
    "CLAUDE_CODE_SUBAGENT_MODEL": "accounts/fireworks/models/llama-v3p1-8b-instruct",
    "CLAUDE_CODE_EFFORT_LEVEL": "default"
  }
}
```

### OmniRoute
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:20128/v1",
    "ANTHROPIC_AUTH_TOKEN": "YOUR-OMNIROUTE-KEY",
    "ANTHROPIC_MODEL": "cc/claude-opus-4-6",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "cc/claude-opus-4-6",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "cc/claude-sonnet-4-20250514",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "cc/claude-haiku-3",
    "CLAUDE_CODE_SUBAGENT_MODEL": "cc/claude-haiku-3",
    "CLAUDE_CODE_EFFORT_LEVEL": "max"
  }
}
```

> For detailed OmniRoute configuration, see [omniroute-guide.md](omniroute-guide.md).

---

## Environment Variables in Profiles

| Variable | Description | Required |
|----------|-----------|-------------|
| `ANTHROPIC_BASE_URL` | Provider API base URL | ✅ (for non-Anthropic providers) |
| `ANTHROPIC_AUTH_TOKEN` | API auth token | ✅ (for non-Anthropic providers) |
| `ANTHROPIC_MODEL` | Main model to be used | Recommended |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for Opus level | Optional |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for Sonnet level | Optional |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for Haiku level | Optional |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model used by sub-agents | Optional |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level (`low`, `default`, `high`, `max`) | Optional |

---

## Final Tip

> [!TIP]
> The most common workflow is:
> 1. `ccs switch deepseek` → use DeepSeek daily (cheaper)
> 2. `ccs run anthropic` → when you need "original" Claude for complex things
> 3. `ccs test` → always test after changing key or setting up new provider
