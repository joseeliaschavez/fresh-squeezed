# Run fastfetch at most once per hour
_FASTFETCH_STAMP="${XDG_CACHE_HOME:-$HOME/.cache}/fastfetch_last_run"

if command -v fastfetch &>/dev/null; then
  mkdir -p "$(dirname "$_FASTFETCH_STAMP")"
  _now=$(date +%s)
  _last=$(cat "$_FASTFETCH_STAMP" 2>/dev/null || echo 0)
  if (( _now - _last >= 3600 )); then
    fastfetch
    echo "$_now" > "$_FASTFETCH_STAMP"
  fi
  unset _now _last
fi
unset _FASTFETCH_STAMP
