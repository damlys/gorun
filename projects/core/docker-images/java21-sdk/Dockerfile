FROM ubuntu:noble
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["bash"]

ENV PATH="$PATH:/usr/local/share/gradle/bin:/usr/local/share/maven/bin"

COPY ./Dockerfile.bash /Dockerfile.bash
RUN /Dockerfile.bash && rm /Dockerfile.bash
