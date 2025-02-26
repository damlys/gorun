package slug

import "regexp"

func Make(text string) string {
	re := regexp.MustCompile("[^a-zA-Z0-9]+")
	return re.ReplaceAllString(text, "-")
}
