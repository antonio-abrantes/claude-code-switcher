# 🚀 How to Install and Use CCS with OmniRoute

This guide uses the **local source code** that has already been modified with OmniRoute support.
**DO NOT install from GitHub** — install from here, the folder you already have.

---

## Step 1: Install local CCS

Open **PowerShell as Administrator** and navigate to the project folder:

```powershell
cd C:\Users\Antonio\Downloads\claude-code-switcher-main\claude-code-switcher-main
```

Run the local installer:

```powershell
.\install-local.ps1
```

This will:
- ✅ Copy `ccs.ps1` (with OmniRoute support) to `~\.local\bin\`
- ✅ Copy the profiles to `~\.config\claude-profiles\profiles\`
- ✅ Create the `active` symlink pointing to anthropic
- ✅ Unlock the Windows `ExecutionPolicy` automatically via the Registry
- ✅ Inject the Claude interceptor into ALL your PowerShell profiles (legacy and modern PS7)

**Afterwards, close and reopen PowerShell** to apply the settings.

---

## Step 2: Configure the OmniRoute API key

```powershell
ccs key omniroute
```

It will ask:
```
New API key for 'omniroute': ████████████
```

Paste your OmniRoute API key and press Enter.

---

## Step 3: Activate OmniRoute

```powershell
ccs switch omniroute
```

Output:
```
Switched to omniroute
```

---

## Step 4: Test

```powershell
ccs test
```

Expected output:
```
Testing omniroute (cx/gpt-5.5)... OK
```

If it shows **OK**, everything is working!

---

## Step 5: Use

```powershell
claude
```

Done. Claude Code is now using OmniRoute with the `cx/gpt-5.5` models.

---

## Verify current configuration

```powershell
ccs current
```

Shows:
```
Active: omniroute
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://omniroute.services.softcomia.com/v1",
    "ANTHROPIC_MODEL": "cx/gpt-5.5",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "cx/gpt-5.5-xhigh",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "cx/gpt-5.5",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "cx/gpt-5.4-mini",
    "ANTHROPIC_API_KEY": "",
    "CLAUDE_CODE_SUBAGENT_MODEL": "cx/gpt-5.4-mini",
    "CLAUDE_CODE_EFFORT_LEVEL": "default"
  }
}
```

(The API key is hidden for security)

---

## Understanding `CLAUDE_CODE_EFFORT_LEVEL`

This variable controls the **"reasoning effort"** that the model will apply before giving you an answer. Newer models (like the "thinking" family or more advanced ones) can "think" internally before generating code.

**Possible values:**
- `"default"`: Recommended for most cases. The model decides the default effort. It does not cause compatibility errors with smaller models (like `gpt-5-mini` or `haiku`).
- `"low"`: Fast and basic reasoning. Faster responses, consumes fewer "thinking" tokens.
- `"medium"`: Intermediate effort.
- `"high"`: High effort. Ideal for complex code problems, difficult algorithms, or deep refactoring.
- `"max"`: Maximum effort limit (in some providers translates to `xhigh`). Tries to explore all possibilities before answering.

> [!WARNING]
> **Careful when changing to `high` or `max`:** Smaller and faster models (like `gpt-5-mini`, `gpt-5.4-mini`, or `haiku`) usually **do not support** reasoning effort configuration. If you set it to `"max"` on an incompatible model, the OmniRoute API will return a **400 Error**. If you're not sure, always leave it as `"default"`.

---

## Switching models

The OmniRoute profile is pre-configured with `cx/gpt-5.5`. To change it:

```powershell
ccs edit omniroute
```

Notepad opens. Change the `ANTHROPIC_MODEL` to whatever you want:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://omniroute.services.softcomia.com/v1",
    "ANTHROPIC_AUTH_TOKEN": "your-key",
    "ANTHROPIC_MODEL": "cx/gpt-5.5-xhigh",
    ...
  }
}
```

Save and close. The next time you run `claude`, it will use the new model.

**Available models:**

| Model | Description |
|--------|-----------|
| `cx/gpt-5.5` | Default |
| `cx/gpt-5.5-xhigh` | More powerful |
| `cx/gpt-5.5-high` | High performance |
| `cx/gpt-5.5-medium` | Medium |
| `cx/gpt-5.5-low` | Economical |
| `cx/gpt-5.4` | Previous version |
| `cx/gpt-5.4-mini` | Fast and cheap |
| `cx/gpt-5.3-codex-spark` | Fast code |
| `cx/gpt-5.3-codex` | Advanced code |
| `cx/gpt-5.2` | Older |

---

## Changing the OmniRoute URL

If the URL changes in the future:

```powershell
ccs edit omniroute
```

Change the `ANTHROPIC_BASE_URL` field to the new URL. Save. Done.

---

## Switching between providers

```powershell
ccs switch omniroute    # use OmniRoute
ccs switch anthropic    # go back to direct Anthropic
ccs switch deepseek     # use DeepSeek

ccs                     # see all profiles
```

---

## Ephemeral mode (without saving profile)

To test a model quickly without editing anything:

```powershell
ccs run --provider omniroute --url https://omniroute.services.softcomia.com/v1 --model cx/gpt-5.3-codex --key your-key
```

---

## Command Summary

| What you want to do | Command |
|-----------------|---------|
| Install | `.\install-local.ps1` |
| Configure key | `ccs key omniroute` |
| Activate OmniRoute | `ccs switch omniroute` |
| Test connection | `ccs test` |
| Use Claude | `claude` |
| Change model | `ccs edit omniroute` |
| See active profile | `ccs current` |
| See all profiles | `ccs` |
| Go back to Anthropic | `ccs switch anthropic` |
