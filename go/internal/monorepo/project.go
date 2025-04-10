package monorepo

import (
	"fmt"
	"os"
	"path"
	"strings"
)

type Project struct {
	ProjectPath  string
	ProjectSlug  string
	ProjectScope string
	ProjectType  string
	ProjectName  string
}

func ListProjects(currentPath ...string) ([]Project, error) {
	files, err := os.ReadDir(path.Join(currentPath...))
	if err != nil {
		return nil, fmt.Errorf("directory read error (%s): %v", path.Join(currentPath...), err)
	}

	var projects []Project
	for _, f := range files {
		if f.Name() == ".project.yaml" {
			n := len(currentPath)
			p := Project{
				ProjectPath:  path.Join(currentPath[1:n]...),
				ProjectSlug:  slug(currentPath[1:n]),
				ProjectScope: currentPath[n-3],
				ProjectType:  currentPath[n-2],
				ProjectName:  currentPath[n-1],
			}
			projects = append(projects, p)
		}

		if f.IsDir() && !strings.HasPrefix(f.Name(), ".") {
			nextPath := append(currentPath, f.Name())
			p, err := ListProjects(nextPath...)
			if err != nil {
				return nil, fmt.Errorf("projects list error (%s): %v", path.Join(nextPath...), err)
			}
			projects = append(projects, p...)
		}
	}
	return projects, nil
}
