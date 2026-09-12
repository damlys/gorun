#!/bin/bash
set -ex

# format check
shfmt --indent=2 --diff ./scripts

# lint check
shellcheck --exclude=1090 $(find ./scripts -type f)
