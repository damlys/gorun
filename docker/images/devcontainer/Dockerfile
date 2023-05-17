FROM golang:1.20-bullseye
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["bash"]

# platform ARGs: https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

RUN apt update && apt install --yes \
  apt-transport-https \
  bash-completion \
  build-essential \
  ca-certificates \
  curl \
  git \
  gnupg \
  iputils-ping \
  less \
  lsb-release \
  man \
  nano \
  nmap \
  openssh-client \
  sudo \
  tar \
  tree \
  unzip \
  vim \
  wget \
  zip \
  && apt clean && rm -rf /var/lib/apt/lists/* \
  && echo "ALL ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# docker: https://docs.docker.com/engine/install/debian/#install-using-the-repository
RUN mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch=${TARGETARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# github: https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=${TARGETARCH} signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list

# google: https://cloud.google.com/sdk/docs/install#deb
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# goreleaser: https://goreleaser.com/install/#apt
RUN echo "deb [trusted=yes] https://repo.goreleaser.com/apt/ /" | tee /etc/apt/sources.list.d/goreleaser.list

RUN apt update && apt install --yes \
  docker-ce-cli \
  docker-compose-plugin \
  gh \
  google-cloud-sdk \
  google-cloud-sdk-gke-gcloud-auth-plugin \
  goreleaser \
  jq \
  kubectl \
  shellcheck \
  && apt clean && rm -rf /var/lib/apt/lists/* \
  && gh completion -s bash > /etc/bash_completion.d/gh \
  && goreleaser completion bash > /etc/bash_completion.d/goreleaser \
  && kubectl completion bash > /etc/bash_completion.d/kubectl
ENV USE_GKE_GCLOUD_AUTH_PLUGIN="True"

RUN true \
  && go install github.com/go-delve/delve/cmd/dlv@latest \
  && go install github.com/posener/complete/gocomplete@v1.2.3 \
  && go install golang.org/x/tools/gopls@latest \
  && go install golang.org/x/vuln/cmd/govulncheck@latest \
  && go clean -cache && rm -rf /root/.cache/go-build/* \
  && go clean -modcache && rm -rf /go/pkg/*

# container-structure-test: https://github.com/GoogleContainerTools/container-structure-test/releases
ARG CST_VERSION="1.15.0"
ADD https://github.com/GoogleContainerTools/container-structure-test/releases/download/v${CST_VERSION}/container-structure-test-${TARGETOS}-${TARGETARCH} \
  /usr/local/bin/container-structure-test
RUN chmod a+x /usr/local/bin/container-structure-test

# golangci-lint: https://github.com/golangci/golangci-lint/releases
ARG GOLANGCI_LINT_VERSION="1.52.2"
ADD https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz \
  /tmp/golangci-lint.tar.gz
RUN cd /tmp \
  && tar -zxvf golangci-lint.tar.gz \
  && mv golangci-lint-${GOLANGCI_LINT_VERSION}-${TARGETOS}-${TARGETARCH}/golangci-lint /usr/local/bin/golangci-lint \
  && rm -r /tmp/* \
  && golangci-lint completion bash > /etc/bash_completion.d/golangci-lint

# hclq: https://github.com/mattolenik/hclq/releases
ARG HCLQ_VERSION="0.5.3"
RUN wget https://github.com/mattolenik/hclq/releases/download/${HCLQ_VERSION}/hclq-${TARGETOS}-$([ "$TARGETARCH" = "arm64" ] && echo "arm" || echo "$TARGETARCH") --output-document=/usr/local/bin/hclq \
  && chmod a+x /usr/local/bin/hclq

# helm: https://github.com/helm/helm/releases
ARG HELM_VERSION="3.11.3"
ADD https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz \
  /tmp/helm.tar.gz
RUN cd /tmp \
  && tar -zxvf helm.tar.gz \
  && mv ${TARGETOS}-${TARGETARCH}/helm /usr/local/bin/helm \
  && rm -r /tmp/* \
  && helm completion bash > /etc/bash_completion.d/helm

# shfmt: https://github.com/mvdan/sh/releases
ARG SHFMT_VERSION="3.6.0"
ADD https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_${TARGETOS}_${TARGETARCH} \
  /usr/local/bin/shfmt
RUN chmod a+x /usr/local/bin/shfmt

# skaffold: https://github.com/GoogleContainerTools/skaffold/releases
ARG SKAFFOLD_VERSION="2.3.1"
ADD https://github.com/GoogleContainerTools/skaffold/releases/download/v${SKAFFOLD_VERSION}/skaffold-${TARGETOS}-${TARGETARCH} \
  /usr/local/bin/skaffold
RUN chmod a+x /usr/local/bin/skaffold \
  && skaffold completion bash > /etc/bash_completion.d/skaffold

# sops: https://github.com/mozilla/sops/releases
ARG SOPS_VERSION="3.7.3"
ADD https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.${TARGETOS}.${TARGETARCH} \
  /usr/local/bin/sops
RUN chmod a+x /usr/local/bin/sops

# terraform: https://developer.hashicorp.com/terraform/downloads
ARG TERRAFORM_VERSION="1.4.5"
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TARGETOS}_${TARGETARCH}.zip \
  /tmp/terraform.zip
RUN cd /tmp \
  && unzip terraform.zip \
  && mv terraform /usr/local/bin/terraform \
  && rm -r /tmp/*

# yq: https://github.com/mikefarah/yq/releases
ARG YQ_VERSION="4.33.3"
ADD https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${TARGETOS}_${TARGETARCH} \
  /usr/local/bin/yq
RUN chmod a+x /usr/local/bin/yq \
  && yq shell-completion bash > /etc/bash_completion.d/yq

COPY ./bashrc /root/.bashrc
