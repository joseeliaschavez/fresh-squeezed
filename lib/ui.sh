#!/usr/bin/env bash
# Terminal colors and banner. Colors are disabled when stdout is not a TTY
# or NO_COLOR is set. Compatible with bash 3.2 (macOS default).

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_ORANGE=$'\033[38;5;208m'
  C_GREEN=$'\033[38;5;70m'
  C_YELLOW=$'\033[38;5;220m'
  C_RED=$'\033[38;5;196m'
else
  C_RESET="" C_BOLD="" C_DIM="" C_ORANGE="" C_GREEN="" C_YELLOW="" C_RED=""
fi

print_banner() {
  printf '\n'
  printf '%s        ,%s\n'              "$C_GREEN"  "$C_RESET"
  printf '%s      _/_%s\n'              "$C_GREEN"  "$C_RESET"
  printf '%s    .'"'"'   '"'"'.%s\n'      "$C_ORANGE" "$C_RESET"
  printf '%s   (  . .  )%s\n'           "$C_ORANGE" "$C_RESET"
  printf '%s   ( . . . )%s\n'           "$C_ORANGE" "$C_RESET"
  printf '%s    '"'"'.___.'"'"'%s\n'    "$C_ORANGE" "$C_RESET"
  printf '\n'
  printf '  %s%sfresh-squeezed%s\n' "$C_BOLD" "$C_ORANGE" "$C_RESET"
  printf '  %sNo pulp, no bloat — just a freshly squeezed dev environment.%s\n\n' "$C_DIM" "$C_RESET"
}
