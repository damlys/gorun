locals {
  short_project_types = {
    "docker-images"        = "image"
    "helm-charts"          = "chart"
    "terraform-submodules" = "tfsub"
    "terraform-modules"    = "tfmod"
  }

  monorepo_root = "${path.module}/../../../.."

  _monorepo_projects = [
    for _, v in fileset("${local.monorepo_root}/projects", "**/.project.yaml") :
    {
      project_scope = split("/", v)[0]
      project_type  = split("/", v)[1]
      project_name  = split("/", v)[2]
    }
  ]

  monorepo_projects = {
    for _, v in local._monorepo_projects :
    join("/", ["projects", v.project_scope, v.project_type, v.project_name]) => {
      project_path  = join("/", ["projects", v.project_scope, v.project_type, v.project_name])
      project_slug  = join("-", [v.project_scope, local.short_project_types[v.project_type], v.project_name])
      project_scope = v.project_scope
      project_type  = v.project_type
      project_name  = v.project_name
    }
  }
}
