# 📉 Token Saving & Optimization Guide (Model Locking)

Claude Code is an incredibly powerful tool, but by default, it has the freedom to switch between different models (like Opus, Sonnet, and Haiku) depending on the task. While this is smart, **it can consume a lot of tokens and make your usage expensive**, especially if it decides to use Opus for tasks that Sonnet could perfectly solve.

With **Claude Code Switcher (CCS)**, you can "lock" the tool to exclusively use the models you define, ensuring full control over your costs on the official Anthropic API.

---

## 🎯 The Ideal Scenario: Sonnet + Haiku

The best cost-benefit configuration currently is:
- **Main Model:** `claude-3-7-sonnet-latest` (To generate code and solve complex problems).
- **Subagent/Fast Model:** `claude-3-5-haiku-latest` (To read directories, analyze the system, and do low-cost invisible background tasks).

---

## 🛠️ Step-by-Step Configuration

### 1. Create an optimized profile
Open your terminal and create a new profile in CCS (let's call it `official-optimized`):

```powershell
ccs add official-optimized
```

### 2. Fill out the wizard correctly
The terminal will ask you 4 questions. **Pay attention to the blank fields!**

1. **BASE URL:** Press only **`Enter`** (Leaving it blank forces the system to use Anthropic's original servers).
2. **AUTH TOKEN:** Press only **`Enter`** (Leaving it blank tells the system to use your browser login).
3. **MAIN MODEL:** Type `claude-3-7-sonnet-latest` and press Enter.
4. **FAST MODEL:** Type `claude-3-5-haiku-latest` and press Enter.

*(Note: Using the `-latest` tag ensures you won't have problems with deprecated models in the future).*

### 3. Make the Official Login
Since we left the `AUTH TOKEN` blank, Claude needs you to be logged into your official Anthropic account. To ensure everything works:

1. Disable CCS temporarily:
   ```powershell
   ccs disable
   ```
2. Log into Anthropic:
   ```powershell
   claude auth login
   ```
   *(A browser window will open for you to authorize access).*

### 4. Activate and Use!
Now just turn on your new optimized profile:
```powershell
ccs switch official-optimized
```

Done! When you type `claude`, you will be using your official Anthropic account, but Claude will be strictly forbidden from using Opus, saving you thousands of tokens in your sessions!

---

## 🔑 What if I want to use an API Key instead of the Login?
If you prefer to inject a direct Anthropic API key (instead of logging in through the browser), the process is almost identical. 

The only difference is that, in **Step 2**, when the wizard asks for the `AUTH TOKEN`, you paste your key that starts with `sk-ant-api03...`. CCS will prioritize this key and ignore the browser login.
