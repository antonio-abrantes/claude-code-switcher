# 🚀 How to Run Claude Code with Local Models (Ollama, LiteLLM)

CCS fully supports routing Claude Code to your own locally-hosted LLMs without any modifications to the core codebase. Since CCS dynamically intercepts and manages the standard Anthropic API environment variables, we can easily redirect Claude Code to a local translation server.

This guide provides a comprehensive, step-by-step walkthrough to get Claude Code running locally on your own machine.

---

## 🏗️ Architecture: Why We Need LiteLLM

Claude Code is not a simple chat interface—it is an advanced, autonomous agentic CLI. It reads files, executes shell commands, analyzes git trees, and handles complex task loops. To do this, it relies heavily on Anthropic's native **Tool Use (tool calling)** API structure.

Local model runtimes (like Ollama or LM Studio) natively expose OpenAI-compatible APIs, not Anthropic-compatible APIs. 

To bridge this gap, we use **LiteLLM** as a translation proxy:
1. **Claude Code** sends requests in Anthropic's `/v1/messages` format.
2. **LiteLLM** intercepts these requests and translates them into Ollama's format.
3. **Ollama** runs the model locally and responds.
4. **LiteLLM** translates the response back into the Anthropic schema for Claude Code.

```
[Claude Code] ──(Anthropic API)──> [LiteLLM Proxy] ──(Ollama API)──> [Ollama (Local LLM)]
```

---

## 🛠️ Step-by-Step Setup

### Step 1: Set Up Your Local Model (Ollama)

First, make sure you have [Ollama](https://ollama.com/) installed and running on your system. 

For agentic coding, we highly recommend using a powerful, coding-focused model like **Qwen 2.5 Coder 32B**. Open your terminal (or Command Prompt/PowerShell) and pull/run the model:

```bash
ollama run qwen2.5-coder:32b
```

*(Note: If your hardware is more limited, you can try `qwen2.5-coder:14b` instead.)*

Keep Ollama running in the background.

---

### Step 2: Install and Run LiteLLM

LiteLLM will act as our translation adapter. You need a Python environment installed.

1. **Install LiteLLM:**
   ```bash
   pip install litellm
   ```

2. **Start the LiteLLM Proxy:**
   Point LiteLLM to your active local Ollama model. By default, it will start a local server at `http://localhost:4000`:
   ```bash
   litellm --model ollama/qwen2.5-coder:32b --port 4000
   ```

Keep this terminal window open so the proxy remains active.

---

### Step 3: Add the Local Profile in CCS

Open a **new terminal window** (so the proxy keeps running in the other one) and use CCS to create a new profile:

```powershell
ccs add local
```

You will be prompted for the profile details. Enter the following exact values:

1. **BASE URL:** `http://localhost:4000` *(This is your LiteLLM server address)*
2. **AUTH TOKEN:** `local` *(LiteLLM ignores this token, but CCS requires a non-empty string when a custom URL is defined)*
3. **MAIN MODEL:** `ollama/qwen2.5-coder:32b` *(Must match the model name in LiteLLM)*
4. **FAST MODEL:** `ollama/qwen2.5-coder:7b` *(Or just press Enter to leave it empty and use the main model for all subagents)*

---

### Step 4: Switch and Test the Profile

Switch to your new `local` profile:

```powershell
ccs switch local
```

Now, test the integration to ensure the CCS client can communicate with your local model through the LiteLLM proxy:

```powershell
ccs test
```

Expected output:
```
Testing local (ollama/qwen2.5-coder:32b)... OK
```

If it shows **OK**, the translation loop is working perfectly!

---

### Step 5: Launch Claude Code Locally

Now, simply run Claude Code as you normally would:

```powershell
claude
```

Claude Code will launch, read the active settings file symlinked by CCS, and direct all agentic actions and requests to your local model!

---

## ⚠️ Important Recommendations & Limitations

Agentic workflows are highly demanding. If you encounter issues while running locally, please read these critical considerations:

### 1. Model Size & Reasoning Capabilities
Claude Code was designed and heavily optimized for Anthropic's premier models (like Claude 3.5 Sonnet). It writes complicated instructions and expects the model to strictly follow tool-calling protocols.
* **Under 14B Parameters (Not Recommended):** Small models (like `3B` or `7B` models) will struggle to format tool-calls correctly. They may hallucinate that they edited a file when they didn't, or get stuck in infinite agentic loops. **This is a limitation of the model's capabilities, not an issue with the CCS tool.**
* **14B to 32B Parameters (Good / Fast):** Models like `qwen2.5-coder:14b` or `qwen2.5-coder:32b` provide a good balance. They are smart enough to handle basic file edits, read-only analysis, and simple command executions.
* **70B+ Parameters (Best Local Experience):** Models like `llama3.3:70b` or `deepseek-r1` (via specialized distros) provide the most accurate tool execution and reasoning.

### 2. Hardware Requirements
Running a large model local code-agent requires significant hardware horsepower.
* **VRAM:** For `32B` models, a GPU with at least 16GB–24GB of VRAM is highly recommended to maintain usable token-generation speeds.
* **RAM:** We recommend at least 32GB of system RAM to ensure Ollama and your local IDE can run simultaneously without throttling.

### 3. Latency
Local models will generate text slower than commercial cloud APIs. Expect longer wait times during complex operations as the agent processes its loops.

---

## 🎛️ Quick Command Cheat Sheet

| Action | Command |
| :--- | :--- |
| **Run Ollama Model** | `ollama run qwen2.5-coder:32b` |
| **Run LiteLLM Proxy** | `litellm --model ollama/qwen2.5-coder:32b --port 4000` |
| **Create Profile** | `ccs add local` |
| **Switch Profile** | `ccs switch local` |
| **Test Connection** | `ccs test` |
| **Run Claude Code** | `claude` |
| **Edit Local Config** | `ccs edit local` |
