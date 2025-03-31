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

function git::is_main_branch {
  if str::equals "$(git rev-parse --abbrev-ref HEAD)" "main"; then
    return 0
  fi
  return 1
}

function git::commit {
  local files_path="$1"
  local commit_message="$2"

  git restore --staged .
  git add "./${files_path}"
  git commit --message="${commit_message}"

  if ! str::is_empty "${GITHUB_HEAD_REF}"; then
    git push origin "${GITHUB_HEAD_REF}"
  elif ! str::is_empty "${GITHUB_REF}"; then
    git push origin "${GITHUB_REF}"
  else
    git push origin "$(git rev-parse --abbrev-ref HEAD)"
  fi
}
