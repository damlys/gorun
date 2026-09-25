FROM node:24-trixie
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["bash"]

ENV LANG="C.UTF-8"
ENV NODE_ENV="development"
ENV TZ="UTC"

COPY ./Dockerfile.bash /Dockerfile.bash
RUN /Dockerfile.bash && rm /Dockerfile.bash
