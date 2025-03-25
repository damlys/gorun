set -e

function git::tag_exists {
  local tag="$1"
  local remote_tag

  remote_tag="$(git ls-remote origin "refs/tags/${tag}")"

  if str::is_empty "${remote_tag}"; then
    return 1
  fi

  return 0
}

function git::tag {
  local tag="$1"
  local remote_tag

  remote_tag="$(git ls-remote origin "refs/tags/${tag}")"

  if ! str::is_empty "${remote_tag}"; then
    # tag exists

    if str::contains "${remote_tag}" "$(git rev-parse HEAD)"; then
      # tag matches HEAD
      return 0
    fi

    # tag does not match HEAD
    log::error "git tag exists but does not match HEAD: ${tag}"
    return 1
  fi

  # tag does not exist
  git tag "${tag}"
  git push origin "${tag}"
}
