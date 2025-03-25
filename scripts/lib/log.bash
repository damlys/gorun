set -e

function log::error {
  local msg="$1"

  printf "error: %s\n" "${msg}"
}

function log::warning {
  local msg="$1"

  printf "warning: %s\n" "${msg}"
}

function log::info {
  local msg="$1"

  printf "info: %s\n" "${msg}"
}
