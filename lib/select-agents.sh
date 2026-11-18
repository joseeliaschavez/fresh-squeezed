#!/usr/bin/env bash
# Numbered prompt for choosing which AI agents to install.
#
# Result is exported as FS_AI_AGENTS: "all", "none", or a comma-separated list
# (e.g. "claude,codex"). Presetting FS_AI_AGENTS skips the prompt. With no TTY
# the default is "all". Compatible with bash 3.2 (macOS default).

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_LIB_DIR/ui.sh"

ai_agents_for_platform() {
  case "${1:-}" in
    darwin) echo "claude copilot codex opencode pi omp" ;;
    *)      echo "claude copilot codex opencode pi omp" ;;
  esac
}

# True if the agent was selected (or selection is "all").
ai_agent_selected() {
  case ",${FS_AI_AGENTS:-all}," in
    *,all,*|*",$1,"*) return 0 ;;
    *) return 1 ;;
  esac
}

# True if at least one agent is selected.
ai_any_agent_selected() {
  [ "${FS_AI_AGENTS:-all}" != "none" ]
}

_have_tty() { ( : </dev/tty ) 2>/dev/null; }

select_ai_agents() {
  local platform="${1:-}"
  [ -n "${FS_AI_AGENTS:-}" ] && return 0

  if ! _have_tty; then
    export FS_AI_AGENTS="all"
    return 0
  fi

  local agents i
  agents=($(ai_agents_for_platform "$platform"))
  local count=${#agents[@]}

  while true; do
    printf '%s%sWhich AI agents do you want to install?%s\n\n' "$C_BOLD" "$C_ORANGE" "$C_RESET"
    for i in "${!agents[@]}"; do
      printf '  %s%d)%s %s\n' "$C_GREEN" $((i + 1)) "$C_RESET" "${agents[$i]}"
    done
    printf '\n  %sEnter numbers separated by spaces or commas (e.g. 1 3),%s\n' "$C_DIM" "$C_RESET"
    printf '  %s"a" or Enter for all, "n" for none.%s\n\n' "$C_DIM" "$C_RESET"
    printf '%s>%s ' "$C_ORANGE" "$C_RESET"

    local reply
    read -r reply </dev/tty || reply=""
    reply=$(printf '%s' "$reply" | tr '[:upper:],' '[:lower:] ')

    case "$reply" in
      ""|a|all) export FS_AI_AGENTS="all"; printf '\n'; return 0 ;;
      n|none)   export FS_AI_AGENTS="none"; printf '\n'; return 0 ;;
    esac

    local valid=1 chosen="" token
    for token in $reply; do
      case "$token" in
        *[!0-9]*) valid=0; break ;;
      esac
      if [ "$token" -lt 1 ] || [ "$token" -gt "$count" ]; then valid=0; break; fi
      case ",$chosen," in
        *",${agents[$((token - 1))]},"*) ;;
        *) chosen="${chosen:+$chosen,}${agents[$((token - 1))]}" ;;
      esac
    done

    if [ "$valid" -eq 1 ] && [ -n "$chosen" ]; then
      export FS_AI_AGENTS="$chosen"
      printf '\n  %sSelected:%s %s\n\n' "$C_GREEN" "$C_RESET" "$chosen"
      return 0
    fi
    printf '\n  %sInvalid choice — enter numbers from 1 to %d.%s\n\n' "$C_RED" "$count" "$C_RESET"
  done
}
