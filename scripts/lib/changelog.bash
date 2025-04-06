set -e

function changelog::update_header {
  local project_path="$1"
  local version="$2"
  local today
  local changelog_path="${project_path}/CHANGELOG.md"
  local changelog_content

  today="1993-05-08" # TODO restore
  changelog_content="$(cat "${changelog_path}")"

  if git::is_main_branch; then
    log::info "changelog: skipping header update on main branch"
    return 0
  fi

  if str::contains "${changelog_content}" "## [${version}] - ${today}"; then
    log::info "changelog: header is ok"
    return 0
  fi

  if str::contains "${changelog_content}" "## [${version}] - "; then
    log::info "changelog: updating header date"
    local old="## \[${version}\] - .*$"
    local new="## \[${version}\] - ${today}"
    sed --in-place "s/${old}/${new}/g" "${changelog_path}"
  else
    log::info "changelog: adding header"
    local old="## \[Unreleased\]"
    local new="## \[Unreleased\]\n\n## \[${version}\] - ${today}"
    sed --in-place "s/${old}/${new}/g" "${changelog_path}"
  fi

  git::commit "./${changelog_path}" "chore: update ${changelog_path} header (v${version}) [skip ci] [ci skip]"
}
