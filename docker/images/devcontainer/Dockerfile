FROM golang:1.20-bullseye
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["bash"]

# platform ARGs: https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV USE_GKE_GCLOUD_AUTH_PLUGIN="True"

COPY ./etc/.bashrc /root/.bashrc

COPY ./Dockerfile.bash /Dockerfile.bash
RUN /Dockerfile.bash && rm /Dockerfile.bash
