set -e

function semver::validate {
  local number="$1"

  if [[ "$number" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    return 0
  fi

  return 1
}
