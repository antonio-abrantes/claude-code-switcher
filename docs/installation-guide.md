# 🛠️ Step-by-Step Installation Guide — CCS

## Index

1. [Prerequisites](#1-prerequisites)
2. [Windows Installation](#2-windows-installation)
3. [Linux / macOS Installation](#3-linux--macos-installation)
4. [VPS Installation (Ubuntu/Debian)](#4-vps-installation-ubuntudebian)
5. [Initial Setup](#5-initial-setup)
6. [Verifying it Works](#6-verifying-it-works)
7. [Common Issues](#7-common-issues)

---

## 1. Prerequisites

Before installing CCS, you must have installed:

### Required

- **Claude Code** — Anthropic's AI tool for the terminal
  - Site: https://code.claude.com/docs
  - Must be accessible via terminal (running `claude` in the terminal should work)

### Recommended

- **jq** — For JSON manipulation
- **curl** — For installation and testing

---

## 2. Windows Installation

### Step 1: Open PowerShell as Administrator

> [!IMPORTANT]
> It must be **Administrator** because CCS creates symbolic links (symlinks), and in Windows this requires elevated privileges.

1. Press `Win + X`
2. Click on **"Terminal (Admin)"** or **"Windows PowerShell (Admin)"**

### Step 2: Install CCS

You have two options to install:

**Option A: Install from the Web (Recommended)**
Paste and run the following command to download and install automatically from the repository:
```powershell
irm https://raw.githubusercontent.com/antonio-abrantes/claude-code-switcher/main/install.ps1 | iex
```

**Option B: Install Locally (If you downloaded the code)**
Navigate to the extracted folder and run:
```powershell
.\install-local.ps1
```

**What the installer does:**
- Creates the `C:\Users\YourUser\.local\bin\` folder
- Copies the `ccs.ps1` script there
- Copies the default profiles
- Creates the `active` symlink pointing to the Anthropic profile

### Step 3: Automatic Setup

The installer does all the heavy lifting for you:

1. **Unlocks ExecutionPolicy:** It alters the Windows Registry to allow CCS to run, without you needing to type complex commands.
2. **Injects the Profile:** It automatically locates your PowerShell profiles (both the older Windows PowerShell 5.1 and modern PowerShell 7) and injects the Claude Code interceptor into them.

You **do not need to configure any aliases manually**.

Simply **close your current terminal and open a new one** for the changes to take effect.

### Step 4: Test the installation

```powershell
ccs
```

It should show the list of available profiles:
```
* anthropic (active)
  deepseek
```

✅ **Windows installation complete!**

---

## 3. Linux / macOS Installation

### Step 1: Open the terminal

### Step 2: Install dependencies

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install -y jq curl
```

**macOS (Homebrew):**
```bash
brew install jq curl
```

**Fedora/RHEL:**
```bash
sudo dnf install -y jq curl
```

### Step 3: Install CCS

```bash
curl -fsSL https://raw.githubusercontent.com/antonio-abrantes/claude-code-switcher/main/install.sh | bash
```

**What this command does:**
- Downloads all scripts from GitHub
- Combines everything into a single executable `ccs` in `~/.local/bin/`
- Downloads the default profiles (Anthropic and DeepSeek)
- Configures the symbolic link `active` → `anthropic.json`
- Adds aliases to your `.bashrc` or `.zshrc`:
  - `claude` → executes with the active profile
  - `deepseek` → shortcut for `ccs run deepseek`

### Step 4: Activate changes

```bash
source ~/.bashrc
# or, if using Zsh:
source ~/.zshrc
```

### Step 5: Verify if ~/.local/bin is in PATH

```bash
echo $PATH | grep -o "$HOME/.local/bin"
```

If nothing appears, add it manually:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Step 6: Test the installation

```bash
ccs
```

It should show:
```
* anthropic (active)
  deepseek
```

✅ **Linux/macOS installation complete!**

---

## 4. VPS Installation (Ubuntu/Debian)

> [!NOTE]
> CCS works perfectly on a VPS! The only difference is you need to install **Claude Code** via Node.js/npm first, since VPSs are usually headless.

### Step 1: Connect to VPS via SSH

```bash
ssh user@your-vps-ip
```

### Step 2: Install Node.js (if necessary)

```bash
# Using NodeSource (Node.js 20 LTS)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

Verify:
```bash
node --version   # should show v20.x.x
npm --version    # should show 10.x.x
```

### Step 3: Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

Verify:
```bash
claude --version
```

### Step 4: Install CCS dependencies

```bash
sudo apt update && sudo apt install -y jq curl
```

### Step 5: Install CCS

```bash
curl -fsSL https://raw.githubusercontent.com/antonio-abrantes/claude-code-switcher/main/install.sh | bash
```

### Step 6: Activate changes

```bash
source ~/.bashrc
```

### Step 7: Test

```bash
ccs
```

✅ **VPS installation complete!**

---

## 5. Initial Setup

After installation, you need to **configure at least one provider with an API key**.

### Example: Configuring DeepSeek

#### On Linux/macOS:

```bash
# Update the API key for the DeepSeek profile
ccs key deepseek
```

The terminal will ask:
```
New API key for 'deepseek': 
```

Paste your DeepSeek key (e.g., `sk-xxxxxxxxxxxxxxxx`) and press Enter.

#### On Windows (PowerShell):

```powershell
ccs key deepseek
```

Works the same way.

### Example: Adding a new provider (OpenRouter)

```bash
ccs add openrouter
```

The terminal will ask questions interactively:

```
BASE URL (ex: https://omniroute... or empty): https://openrouter.ai/api
AUTH TOKEN (Your API Key): sk-or-your-key-here
MAIN MODEL (ex: cx/gpt-5.5 or empty): anthropic/claude-sonnet-4-20250514
FAST MODEL (ex: cx/gpt-5.4-mini or empty): anthropic/claude-haiku-3
```

Done! Profile created.

---

## 6. Verifying it Works

### Switch to DeepSeek and test

```bash
# Switch active provider to DeepSeek
ccs switch deepseek

# Verify which one is active
ccs current

# Test the connection (makes a real API call)
ccs test
```

Expected result from `ccs test`:
```
Testing deepseek (deepseek-v4-pro[1m])... OK
```

If it shows **OK**, everything is working! 🎉

---

## 7. Common Issues

### ❌ "ccs: command not found"

**Cause:** The directory `~/.local/bin` is not in PATH.

**Linux/macOS Solution:**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Windows Solution:** Verify if the installation script ran correctly and open a new PowerShell window.

### ❌ "error: profile 'xxx' has no API key set"

**Cause:** You are trying to use a profile without an API key.

**Solution:**
```bash
ccs key profile-name
# Paste your key when prompted
```

### ❌ "error: jq is required"

**Cause:** `jq` is not installed.

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq
```

### ❌ Symlink doesn't work on Windows

**Cause:** PowerShell needs administrator privileges to create symlinks.

**Solution:** Run PowerShell as Administrator (Right click → Run as Administrator).

### ❌ "Testing ... FAIL (HTTP 401: ...)"

**Cause:** The API key is incorrect or expired.

**Solution:**
```bash
ccs key profile-name
# Paste the correct key
```

### ❌ Claude aliases don't work after switching profile

**Cause:** The `claude` alias wasn't configured.

**Linux/macOS Solution:**
```bash
# Add manually
echo "alias claude='claude --settings \$HOME/.config/claude-profiles/active'" >> ~/.bashrc
source ~/.bashrc
```
