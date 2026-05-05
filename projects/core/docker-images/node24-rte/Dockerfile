FROM node:24-bookworm
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["bash"]

ENV NODE_ENV="production"
ENV TZ="UTC"

RUN groupadd --gid="1111" deploy \
  && useradd --uid="1111" --gid="1111" --shell="/bin/bash" --create-home deploy
