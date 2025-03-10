package main

import (
	"fmt"
	"log"
	"os"
	"path"

	"github.com/damlys/gorun/go/internal/monorepo"
	"github.com/damlys/gorun/go/internal/tmpl"
)

func main() {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("working directory get error: %v\n", err)
	}
	log.Printf("working directory: %s\n", wd)

	projects, err := monorepo.ListProjects(wd)
	if err != nil {
		log.Fatalf("projects list error: %v\n", err)
	}
	log.Printf("projects count: %d\n", len(projects))

	for _, p := range projects {
		templateFilePath := path.Join(wd, ".github", "workflow.yaml.gotmpl")
		outputFilePath := path.Join(wd, ".github", "workflows", fmt.Sprintf("%s.gotmpl.yaml", p.ProjectSlug))
		log.Printf("rendering: %s\n", p.ProjectSlug)
		err := tmpl.RenderTemplate(templateFilePath, outputFilePath, p)
		if err != nil {
			log.Fatalf("template render error (%s): %v\n", p.ProjectSlug, err)
		}
	}

	log.Print("done!\n")
}
