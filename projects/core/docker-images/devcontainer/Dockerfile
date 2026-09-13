FROM debian:bookworm
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["bash"]

# platform ARGs: https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ENV TARGETOS="${TARGETOS:-linux}"
ENV TARGETARCH="${TARGETARCH:-amd64}"
ENV TARGETVARIANT="${TARGETVARIANT}"

ENV CODE_SERVER_CONFIG="/etc/code-server.yaml"
ENV EXTENSIONS_GALLERY="{\"serviceUrl\":\"https://marketplace.visualstudio.com/_apis/public/gallery\"}"
ENV GOPATH="/root/go"
ENV NODE_ENV="development"
ENV PATH="${PATH}:${GOPATH}/bin:/usr/local/go/bin"
ENV TZ="UTC"
ENV USE_GKE_GCLOUD_AUTH_PLUGIN="True"

COPY ./etc/.bashrc /root/.bashrc
COPY ./etc/code-server.yaml /etc/code-server.yaml
COPY ./etc/pip.conf /etc/pip.conf

COPY ./Dockerfile.bash /Dockerfile.bash
RUN /Dockerfile.bash && rm /Dockerfile.bash
