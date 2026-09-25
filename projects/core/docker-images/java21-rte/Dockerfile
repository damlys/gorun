FROM ubuntu:resolute
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["bash"]

ENV LANG="C.UTF-8"
ENV TZ="UTC"

COPY ./Dockerfile.bash /Dockerfile.bash
RUN /Dockerfile.bash && rm /Dockerfile.bash
