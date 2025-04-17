package tmpl

import (
	"fmt"
	"os"
	"text/template"
)

func RenderTemplate(templateFilePath, outputFilePath string, data any) error {
	templateFile, err := template.ParseFiles(templateFilePath)
	if err != nil {
		return fmt.Errorf("template parse error (%s): %v", templateFilePath, err)
	}

	outputFile, err := os.Create(outputFilePath)
	if err != nil {
		return fmt.Errorf("file create error (%s): %v", outputFilePath, err)
	}

	err = templateFile.Execute(outputFile, data)
	if err != nil {
		return fmt.Errorf("template execute error (%s): %v", outputFilePath, err)
	}

	return nil
}
