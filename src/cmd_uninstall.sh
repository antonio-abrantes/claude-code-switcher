cmd_uninstall() {
  local keep_profiles=true
  local tmp rc

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  ⚠️  CCS Uninstall"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "The following will be removed:"
  echo "  • CCS binary:     ~/.local/bin/ccs"
  echo "  • Shell aliases:  from ~/.bashrc and ~/.zshrc"
  echo ""
  echo "You will also be asked separately whether to delete your"
  echo "  saved profiles (~/.config/claude-profiles)."
  echo "  ⚠  Profiles contain your API keys — choose carefully."
  echo ""
  printf "Uninstall CCS? [y/N] "
  read -r confirm
  if [[ ! "${confirm:-N}" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    return 0
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Profile deletion"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  Your saved profiles are stored at:"
  echo "    ~/.config/claude-profiles"
  echo ""
  echo "  They contain your provider configurations and API keys."
  echo "  If you answer [Y], this folder will be PERMANENTLY deleted."
  echo "  If you answer [N], the folder is kept — you can reuse it later."
  echo ""
  printf "Permanently delete all saved profiles and API keys? [y/N] "
  read -r del_profiles
  if [[ "${del_profiles:-N}" =~ ^[Yy]$ ]]; then
    keep_profiles=false
  fi

  echo ""

  # ── Remove shell aliases from .bashrc and .zshrc ─────────────────────────
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

  # ── Remove the ccs binary ─────────────────────────────────────────────────
  if [[ -f "$HOME/.local/bin/ccs" ]]; then
    rm -f "$HOME/.local/bin/ccs"
    echo "  Removed ~/.local/bin/ccs"
  fi

  # ── Handle profiles directory ─────────────────────────────────────────────
  if [[ "$keep_profiles" == false ]]; then
    if [[ -d "$HOME/.config/claude-profiles" ]]; then
      rm -rf "$HOME/.config/claude-profiles"
      echo "  Removed ~/.config/claude-profiles"
    fi
  else
    echo "  Profiles kept at ~/.config/claude-profiles"
  fi

  echo ""
  echo "CCS has been uninstalled."
  echo "Open a new terminal to apply shell changes."
  echo ""
}
