# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased] - 2026-05-19

This release brings major enhancements to Claude Code Switcher (CCS), including full **OmniRoute** and custom API integration, dynamic ephemeral running modes, reasoning effort level configurations, secure installer updates (key preservation), and a new interactive **Uninstallation** mechanism for Windows and Unix.

### Added
- **Interactive Uninstallation Mechanism:**
  - Added a built-in `ccs uninstall` subcommand to the CLI.
  - Added standalone `uninstall.sh` (Unix) and `uninstall.ps1` (Windows) scripts in the repository root for direct execution.
  - Interactive prompts that warn the user and clean up shell configurations (`.bashrc`, `.zshrc` aliases and PowerShell profile wrappers).
  - Smart choice allowing the user to perform a **Full Uninstall** (deletes all custom profiles and saved API keys) or **Partial Uninstall** (keeps profiles and API keys for future installations).
- **OmniRoute & Custom Base URLs:**
  - Native integration for custom proxy endpoints like **OmniRoute**.
  - Support for `OMNIROUTE_BASE_URL` and `OMNIROUTE_API_KEY` environment variables.
  - Intelligent auto-detection in `ccs add` when a user enters custom base URLs (pre-fills default provider and target models like `cc/claude-opus-4-6`).
- **Reasoning Effort Control (`CLAUDE_CODE_EFFORT_LEVEL`):**
  - Integrated effort configurations (`default`, `low`, `medium`, `high`, `max`) directly inside profile definitions.
- **Cost Optimization & Model Locking:**
  - Added native locked-model options to prevent Claude Code from switching to expensive models.
- **Disable/Off Commmand:**
  - Added `ccs disable` / `ccs off` command to bypass CCS routing and revert to the system's global credentials.
- **Enhanced Documentation:**
  - Added standard, detailed English guides under `docs/`:
    - `usage-guide.md` (complete command reference and ephemeral execution)
    - `installation-guide.md` (detailed step-by-step setup guides)
    - `omniroute-guide.md` (how to run and optimize custom proxy servers)
    - `model-optimization-guide.md` (cost reduction and model locking techniques)
    - `uninstall.md` (comprehensive instructions for safe removals)
    - `about.md` (the mechanics under the hood of CCS)

### Changed
- **Secure Installer Updates (Key Preservation):**
  - Modified installers (`install-local.ps1`, `install.ps1`, and `install.sh`) to automatically detect if profiles already exist.
  - Skips copying or downloading default JSON profiles if they already exist in the target directory, **preventing accidental loss of user-saved API keys and custom profiles** during program updates.
  - Skips rewriting the `active` profile symlink if it is already configured.
- **Dynamic Ephemeral Running Mode:**
  - Upgraded `ccs run` to support `--url` overrides.
  - Allowed immediate ephemeral usage without pre-saving profiles via `ccs run --provider <name> --url <url> --model <model> --key <key>`.
- **Refined PowerShell wrappers:**
  - Optimized the PowerShell integration wrappers for smoother token separation, bypassing profile routing during authentication (`auth`, `login`) commands.
- **README Updates:**
  - Revamped `README.md` to reference the new modular guides, OmniRoute features, locked models, and uninstallation.