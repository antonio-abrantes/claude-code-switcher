cmd_help() {
  cat << 'USAGE'
ccs — Claude Code Switcher

Usage: ccs <command> [args]

Commands:
  list                 List all profiles (default)
  switch <name>        Set active profile
  switch off/disable   Disable CCS routing and use native global credentials
  current              Show active profile configuration
  add <name>           Add a new profile interactively
  edit <name>          Edit a profile in $EDITOR
  key <name>           Update the API key for a profile
  remove <name>        Delete a profile
  test                 Test the active profile connection (real API call)
  clean [name]         Launch Claude with zero custom agents/skills
  clean --restore      Manually restore agents/skills (if session crashed)
  run <name> [...]     Run Claude once with a specific profile
  run --provider <p> --model <m> --key <k> [...]  Run Claude in ephemeral mode without saving a profile
  uninstall            Remove CCS, aliases, and (optionally) saved profiles

Available providers:
USAGE
  cmd_list
}
