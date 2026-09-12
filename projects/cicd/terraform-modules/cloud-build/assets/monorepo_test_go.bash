#!/bin/bash
set -ex

# format check
files="$(gofmt -l ./go)" && echo "$files" && test -z "$files"

# lint check (go vet)
go vet ./go/...

# lint check (golangci-lint)
golangci-lint run ./go/...

# unit tests
go test -v ./go/...
