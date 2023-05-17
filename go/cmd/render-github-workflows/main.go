package main

import (
	"fmt"
	"log"
	"os"
	"path"

	"github.com/damlys/gorun/go/internal/monorepo"
	"github.com/damlys/gorun/go/internal/tpl"
)

func main() {
	wd, err := os.Getwd()
	if err != nil {
		panic(fmt.Errorf("working directory get error: %v", err))
	}
	log.Printf("working directory: %s\n", wd)

	projects, err := monorepo.ListProjects(wd)
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

func renderWorkflow(wd string, project monorepo.Project) error {
	err := tpl.RenderTemplate(
		path.Join(wd, ".github", "workflow.yaml.gotpl"),
		path.Join(wd, ".github", "workflows", fmt.Sprintf("%s.gotpl.yaml", project.WorkflowFilename)),
		project,
	)
	if err != nil {
		return fmt.Errorf("template render error (%s): %v", project.WorkflowFilename, err)
	}

	return nil
}
