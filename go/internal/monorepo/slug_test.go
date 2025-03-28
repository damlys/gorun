package monorepo

import "testing"

func TestSlug(t *testing.T) {
	testcases := [...]struct {
		projectPath []string
		want        string
	}{
		{[]string{"projects", "core", "kubernetes-manifests", "example"}, "core-kubernetes-manifests-example"},
		{[]string{"projects", "demo", "kubernetes-manifests", "example"}, "demo-kubernetes-manifests-example"},

		// short project types
		{[]string{"projects", "core", "docker-images", "example"}, "core-image-example"},
		{[]string{"projects", "core", "helm-charts", "example"}, "core-chart-example"},
		{[]string{"projects", "core", "helm-releases", "example"}, "core-release-example"},
		{[]string{"projects", "core", "terraform-submodules", "example"}, "core-tfsub-example"},
		{[]string{"projects", "core", "terraform-modules", "example"}, "core-tfmod-example"},
		{[]string{"projects", "core", "go-modules", "example"}, "core-gomod-example"},

		// do not change project name
		{[]string{"projects", "core", "terraform-submodules", "gcp-docker-images-registry"}, "core-tfsub-gcp-docker-images-registry"},
		{[]string{"projects", "core", "terraform-submodules", "gcp-helm-charts-registry"}, "core-tfsub-gcp-helm-charts-registry"},
		{[]string{"projects", "core", "terraform-submodules", "gcp-terraform-modules-registry"}, "core-tfsub-gcp-terraform-modules-registry"},
	}

	for _, tc := range testcases {
		if got := slug(tc.projectPath); got != tc.want {
			t.Errorf("slug(%v) = %s, wanted %s", tc.projectPath, got, tc.want)
		}
	}
}
