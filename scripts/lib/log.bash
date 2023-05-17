function log::error {
  local log="$1"

  printf "Error: %s\n" "${log}"
}

function log::warning {
  local log="$1"

  printf "Warning: %s\n" "${log}"
}
