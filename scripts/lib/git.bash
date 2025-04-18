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
  local current_branch
  local retry_count=5
  local retry_seconds=0

  current_branch="$(git rev-parse --abbrev-ref HEAD)"

  git restore --staged .
  git add "./${files_path}"
  git commit --message="${commit_message}"

  log::info "git: pushing"
  while ! git push origin "${current_branch}"; do
    log::warning "git: failed to push"

    log::info "git: pulling"
    while ! git pull --rebase origin "${current_branch}"; do
      git rebase --abort

      if ((retry_count > 0)); then
        retry_seconds=$((3 + RANDOM % 8)) # between 3 and 10
        log::warning "git: failed to pull: retrying in ${retry_seconds} seconds, ${retry_count} tries left"
        sleep "${retry_seconds}"
      else
        log::error "git: failed to pull"
        return 1
      fi
      retry_count=$((retry_count - 1))
    done
    log::info "git: pulled"
  done
  log::info "git: pushed"
}
