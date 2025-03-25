set -e

function str::is_empty {
  local string="$1"

  if [[ -z "${string}" ]]; then
    return 0
  fi

  return 1
}

function str::equals {
  local string="$1"
  local substr="$2"

  if [[ "${string}" == "${substr}" ]]; then
    return 0
  fi

  return 1
}

function str::contains {
  local string="$1"
  local substr="$2"

  if [[ "${string}" == *"${substr}"* ]]; then
    return 0
  fi

  return 1
}

function str::starts_with {
  local string="$1"
  local prefix="$2"

  if [[ "${string}" == "${prefix}"* ]]; then
    return 0
  fi

  return 1
}

function str::ends_with {
  local string="$1"
  local suffix="$2"

  if [[ "${string}" == *"${suffix}" ]]; then
    return 0
  fi

  return 1
}
