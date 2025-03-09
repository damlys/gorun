set -e

function log::error {
  local msg="$1"

  printf "Error: %s\n" "${msg}"
}

function log::warning {
  local msg="$1"

  printf "Warning: %s\n" "${msg}"
}

function log::info {
  local msg="$1"

  printf "Info: %s\n" "${msg}"
}
