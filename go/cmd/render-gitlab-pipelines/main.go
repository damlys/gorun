package main

import (
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

	templateFilePath := path.Join(wd, ".gitlab-ci.yml.gotmpl")
	outputFilePath := path.Join(wd, ".gitlab-ci.yml")
	log.Printf("rendering\n")
	err = tmpl.RenderTemplate(templateFilePath, outputFilePath, projects)
	if err != nil {
		log.Fatalf("template render error: %v\n", err)
	}

	log.Print("done!\n")
}
