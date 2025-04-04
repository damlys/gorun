FROM ubuntu:noble
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["bash"]

COPY ./Dockerfile.bash /Dockerfile.bash
RUN /Dockerfile.bash && rm /Dockerfile.bash
