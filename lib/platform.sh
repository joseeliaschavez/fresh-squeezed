#!/usr/bin/env bash
# Platform detection helper — sourced by setup.sh

detect_platform() {
  case "$(uname -s)" in
    Darwin) echo "darwin" ;;
    Linux)
      if [ -f /etc/debian_version ]; then
        echo "debian"
      else
        echo "unsupported"
      fi ;;
    *) echo "unsupported" ;;
  esac
}
