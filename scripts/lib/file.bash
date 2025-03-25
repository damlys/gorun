set -e

function file::exists {
  local path="$1"

  if [[ -f "${path}" ]]; then
    return 0
  fi

  return 1
}

function file::is_dir {
  local path="$1"

  if [[ -d "${path}" ]]; then
    return 0
  fi

  return 1
}
