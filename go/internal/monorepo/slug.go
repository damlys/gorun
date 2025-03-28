package monorepo

import (
	"strings"
)

func slug(projectPath []string) string {
	scope := projectPath[2]
	switch scope {
	case "docker-images":
		scope = "image"
	case "helm-charts":
		scope = "chart"
	case "helm-releases":
		scope = "release"
	case "terraform-submodules":
		scope = "tfsub"
	case "terraform-modules":
		scope = "tfmod"
	case "go-modules":
		scope = "gomod"
	}

	return strings.Join([]string{projectPath[1], scope, projectPath[3]}, "-")
}
