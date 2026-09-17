FROM europe-central2-docker.pkg.dev/gogcp-main-9/private-docker-images/gorun/core/devcontainer:0.9.102

# platform ARGs: https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ENV TARGETOS="${TARGETOS:-linux}"
ENV TARGETARCH="${TARGETARCH:-amd64}"
ENV TARGETVARIANT="${TARGETVARIANT}"

ENV CODE_SERVER_CONFIG="/etc/code-server.yaml"
ENV EDITOR="code-server --wait"
ENV EXTENSIONS_GALLERY='{"serviceUrl":"https://marketplace.visualstudio.com/_apis/public/gallery"}'

COPY ./etc/code-server.yaml /etc/code-server.yaml

COPY ./Dockerfile.bash /Dockerfile.bash
RUN /Dockerfile.bash && rm /Dockerfile.bash

USER code:code
WORKDIR /home/code
ENTRYPOINT ["code-server"]
CMD []
EXPOSE 8080
