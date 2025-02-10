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

ENV GOPATH="/root/go"
ENV PATH="${PATH}:/root/go/bin:/usr/local/go/bin"
ENV USE_GKE_GCLOUD_AUTH_PLUGIN="True"

COPY ./etc/.bashrc /root/.bashrc

COPY ./Dockerfile.bash /Dockerfile.bash
RUN /Dockerfile.bash && rm /Dockerfile.bash
