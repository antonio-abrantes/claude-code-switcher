#!/usr/bin/env bash
# CCS Standalone Uninstaller — Linux / macOS
# Usage: bash uninstall.sh
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
CCS_DIR="$HOME/.config/claude-profiles"
CCS_BIN="$INSTALL_DIR/ccs"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ⚠️  CCS Uninstall"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "The following will be removed:"
echo "  • CCS binary:     $CCS_BIN"
echo "  • Shell aliases:  from ~/.bashrc and ~/.zshrc"
echo ""
echo "You will also be asked separately whether to delete your"
echo "  saved profiles ($CCS_DIR)."
echo "  ⚠  Profiles contain your API keys — choose carefully."
echo ""
printf "Uninstall CCS? [y/N] "
read -r confirm
if [[ ! "${confirm:-N}" =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Profile deletion"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Your saved profiles are stored at:"
echo "    $CCS_DIR"
echo ""
echo "  They contain your provider configurations and API keys."
echo "  If you answer [Y], this folder will be PERMANENTLY deleted."
echo "  If you answer [N], the folder is kept — you can reuse it later."
echo ""
printf "Permanently delete all saved profiles and API keys? [y/N] "
read -r del_profiles
keep_profiles=true
if [[ "${del_profiles:-N}" =~ ^[Yy]$ ]]; then
  keep_profiles=false
fi

echo ""

# ── Remove shell aliases from .bashrc and .zshrc ──────────────────────────
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [[ -f "$rc" ]]; then
    tmp="$(mktemp)"
    grep -Ev "^# ccs — Claude Code Switcher aliases$" "$rc" \
      | grep -Ev "^alias claude='claude --settings.*claude-profiles/active'" \
      | grep -Ev "^alias deepseek='ccs run deepseek'" \
      > "$tmp"
    mv "$tmp" "$rc"
    echo "  Cleaned aliases from $rc"
  fi
done

# ── Remove the ccs binary ──────────────────────────────────────────────────
if [[ -f "$CCS_BIN" ]]; then
  rm -f "$CCS_BIN"
  echo "  Removed $CCS_BIN"
fi

# ── Handle profiles directory ──────────────────────────────────────────────
if [[ "$keep_profiles" == false ]]; then
  if [[ -d "$CCS_DIR" ]]; then
    rm -rf "$CCS_DIR"
    echo "  Removed $CCS_DIR"
  fi
else
  echo "  Profiles kept at $CCS_DIR"
fi

echo ""
echo "CCS has been uninstalled."
echo "Open a new terminal to apply shell changes."
echo ""
