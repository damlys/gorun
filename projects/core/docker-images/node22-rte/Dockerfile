FROM node:22-bookworm
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["bash"]

ENV NODE_ENV="production"

RUN groupadd --gid="1111" deploy \
  && useradd --uid="1111" --gid="1111" --shell="/bin/bash" --create-home deploy
