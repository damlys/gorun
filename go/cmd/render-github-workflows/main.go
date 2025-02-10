package main

import (
	"fmt"
	"log"
	"os"
	"path"
	"strings"

	"github.com/damlys/gogcp/go/internal/tmpl"
)

type project struct {
	ProjectScope     string
	ProjectName      string
	ProjectPath      string
	ProjectType      string
	WorkflowFilename string
}

func main() {
	wd, err := os.Getwd()
	if err != nil {
		panic(fmt.Errorf("working directory get error: %v", err))
	}
	log.Printf("working directory: %s\n", wd)

	projects, err := listProjects(wd)
	if err != nil {
		panic(fmt.Errorf("projects list error: %v", err))
	}
	log.Printf("projects count: %d\n", len(projects))

	for _, p := range projects {
		log.Printf("rendering: %s\n", p.ProjectPath)
		if err := renderWorkflow(wd, p); err != nil {
			panic(fmt.Errorf("workflow render error (%s): %v", p.WorkflowFilename, err))
		}
	}

	log.Print("done!\n")
}

func listProjects(currentPath ...string) ([]project, error) {
	files, err := os.ReadDir(path.Join(currentPath...))
	if err != nil {
		return nil, fmt.Errorf("dir read error (%s): %v", path.Join(currentPath...), err)
	}

	var projects []project
	for _, f := range files {
		if f.Name() == ".project.yaml" {
			n := len(currentPath)
			p := project{
				ProjectScope:     currentPath[n-3],
				ProjectName:      currentPath[n-1],
				ProjectPath:      path.Join(currentPath[1:n]...),
				ProjectType:      currentPath[n-2],
				WorkflowFilename: strings.Join(currentPath[1:n], "-"),
			}
			projects = append(projects, p)
		}

		if f.IsDir() && !strings.HasPrefix(f.Name(), ".") {
			nextPath := append(currentPath, f.Name())
			p, err := listProjects(nextPath...)
			if err != nil {
				return nil, fmt.Errorf("projects list error (%s): %v", path.Join(nextPath...), err)
			}
			projects = append(projects, p...)
		}
	}
	return projects, nil
}

func renderWorkflow(wd string, project project) error {
	err := tmpl.RenderTemplate(
		path.Join(wd, ".github", "workflow.yaml.gotmpl"),
		path.Join(wd, ".github", "workflows", fmt.Sprintf("%s.gotmpl.yaml", project.WorkflowFilename)),
		project,
	)
	if err != nil {
		return fmt.Errorf("template render error (%s): %v", project.WorkflowFilename, err)
	}

	return nil
}
