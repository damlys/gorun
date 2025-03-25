set -e

function changelog::contains_version {
  local project_path="$1"
  local version="$2"
  local changelog_content

  changelog_content="$(cat "${project_path}/CHANGELOG.md")"

  if str::contains "${changelog_content}" "## [${version}] - "; then
    return 0
  fi

  return 1
}
