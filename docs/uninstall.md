# 🗑️ CCS Uninstall Guide

## Overview

CCS can be fully removed at any time. The uninstaller:

1. Removes the `ccs` binary (or script on Windows)
2. Cleans the shell aliases added to `.bashrc` / `.zshrc`
3. Removes the PowerShell profile integrations (Windows)
4. **Asks you separately** whether to delete your saved profiles (API keys) — so you don't lose them by accident

---

## Linux / macOS

### Option 1 — `ccs uninstall` (if CCS is already installed)

```bash
ccs uninstall
```

### Option 2 — Standalone script (from the repository)

```bash
bash uninstall.sh
```

### What gets removed

| Item | Path |
| :--- | :--- |
| CCS binary | `~/.local/bin/ccs` |
| Shell aliases (comment + 2 lines) | `~/.bashrc`, `~/.zshrc` |
| Profiles directory *(optional)* | `~/.config/claude-profiles/` |

---

## Windows (PowerShell)

### Option 1 — `ccs uninstall` (if CCS is already installed)

```powershell
ccs uninstall
```

### Option 2 — Standalone script (from the repository)

```powershell
.\uninstall.ps1
```

### What gets removed

| Item | Path |
| :--- | :--- |
| CCS script | `%USERPROFILE%\.local\bin\ccs.ps1` |
| PS5 profile integration | `%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` |
| PS7 profile integration | `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` |
| Profiles directory *(optional)* | `%USERPROFILE%\.config\claude-profiles\` |

---

## The Profile Deletion Prompt

During uninstall, the tool **always asks a second question** before touching your profiles:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Profile deletion
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Your saved profiles are stored at:
    ~/.config/claude-profiles

  They contain your provider configurations and API keys.
  If you answer [Y], this folder will be PERMANENTLY deleted.
  If you answer [N], the folder is kept — you can reuse it later.

Permanently delete all saved profiles and API keys? [y/N]
```

- **Answer `N` (default)** — The binary and aliases are removed, but your profiles survive. You can reinstall CCS later and all your providers will be there.
- **Answer `Y`** — Everything is deleted, including all API keys stored in profiles. This cannot be undone.

---

## After Uninstalling

Open a new terminal session to apply the shell changes. The `ccs` command will no longer be available.

If you kept your profiles, you can reinstall CCS at any time and your configurations will be picked up automatically:

```bash
# Linux / macOS
curl -fsSL https://raw.githubusercontent.com/antonio-abrantes/claude-code-switcher/main/install.sh | bash

# Windows
irm https://raw.githubusercontent.com/antonio-abrantes/claude-code-switcher/main/install.ps1 | iex
```

---

## Troubleshooting

### `ccs: command not found` after reinstalling

Run `source ~/.bashrc` (or `~/.zshrc`) in your current terminal, or open a new terminal window.

### PowerShell profile was not cleaned automatically

Open your profile manually:

```powershell
notepad $PROFILE
```

Remove the block between `# CCS — Claude Code Switcher` and `# CCS-END` (inclusive).
