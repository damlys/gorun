FROM ubuntu:resolute
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["bash"]

ENV LANG="C.UTF-8"
ENV PATH="$PATH:/usr/local/share/gradle/bin:/usr/local/share/maven/bin"
ENV TZ="UTC"

COPY ./Dockerfile.bash /Dockerfile.bash
RUN /Dockerfile.bash && rm /Dockerfile.bash
