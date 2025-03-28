package monorepo

import (
	"strings"
)

func slug(projectPath []string) string {
	projectScope := projectPath[1]

	projectType := projectPath[2]
	switch projectType {
	case "docker-images":
		projectType = "image"
	case "helm-charts":
		projectType = "chart"
	case "helm-releases":
		projectType = "release"
	case "terraform-submodules":
		projectType = "tfsub"
	case "terraform-modules":
		projectType = "tfmod"
	case "go-modules":
		projectType = "gomod"
	}

	projectName := projectPath[3]

	return strings.Join([]string{projectScope, projectType, projectName}, "-")
}
