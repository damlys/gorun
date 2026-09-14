#!/bin/bash
set -ex

cd /tmp
apt update

# code: https://github.com/coder/code-server
curl -fsSL https://code-server.dev/install.sh | sh

code-server \
  --extensions-dir=/usr/lib/code-server/lib/vscode/extensions \
  --install-extension="docker.docker" \
  --install-extension="esbenp.prettier-vscode" \
  --install-extension="foxundermoon.shell-format@7.2.5" \
  --install-extension="golang.go" \
  --install-extension="google.geminicodeassist" \
  --install-extension="googlecloudtools.cloudcode" \
  --install-extension="hashicorp.hcl" \
  --install-extension="hashicorp.terraform" \
  --install-extension="ms-kubernetes-tools.vscode-kubernetes-tools" \
  --install-extension="ms-python.autopep8" \
  --install-extension="ms-python.python" \
  --install-extension="redhat.vscode-xml" \
  --install-extension="redhat.vscode-yaml" \
  --install-extension="timonwong.shellcheck"

groupadd --gid="1111" code
useradd --uid="1111" --gid="1111" --shell="/bin/bash" --create-home code

# cleanup
apt clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
rm -rf /tmp/*
