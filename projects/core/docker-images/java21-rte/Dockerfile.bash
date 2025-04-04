#!/bin/bash
set -ex

groupadd --gid="1111" deploy
useradd --uid="1111" --gid="1111" --shell="/bin/bash" --create-home deploy

apt update

apt install --yes ca-certificates-java
apt install --yes openjdk-21-jre

# cleanup
apt clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
