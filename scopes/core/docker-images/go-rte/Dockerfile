FROM debian:bookworm
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["bash"]

RUN groupadd --gid="1000" deploy \
  && useradd --uid="1000" --gid="1000" --shell="/bin/bash" --create-home deploy
