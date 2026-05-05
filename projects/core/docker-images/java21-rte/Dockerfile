FROM ubuntu:noble
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["bash"]

ENV TZ="UTC"

COPY ./Dockerfile.bash /Dockerfile.bash
RUN /Dockerfile.bash && rm /Dockerfile.bash
