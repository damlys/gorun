package monorepo

import (
	"fmt"
	"os"
	"path"
	"strings"
)

type Project struct {
	ProjectName      string
	ProjectPath      string
	ProjectType      string
	WorkflowFilename string
}

func ListProjects(currentPath ...string) ([]Project, error) {
	files, err := os.ReadDir(path.Join(currentPath...))
	if err != nil {
		return nil, fmt.Errorf("dir read error (%s): %v", path.Join(currentPath...), err)
	}

	var projects []Project
	for _, f := range files {
		if f.Name() == ".project.yaml" {
			n := len(currentPath)
			p := Project{
				ProjectName:      currentPath[n-1],
				ProjectPath:      path.Join(currentPath[1:n]...),
				ProjectType:      path.Join(currentPath[1 : n-1]...),
				WorkflowFilename: strings.Join(currentPath[1:n], "-"),
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
