#!/bin/bash
set -ex

cd /tmp
apt update

apt install --yes \
  unzip \
  wget

apt install --yes ca-certificates-java
apt install --yes openjdk-21-jdk

# gradle: https://gradle.org/releases/
gradle_version="8.13"
wget "https://downloads.gradle.org/distributions/gradle-${gradle_version}-bin.zip" \
  --no-verbose \
  --output-document=/tmp/gradle.zip
unzip gradle.zip
mv gradle-${gradle_version} /usr/local/share/gradle

# maven: https://maven.apache.org/download.cgi
maven_version="3.9.9"
wget "https://dlcdn.apache.org/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.zip" \
  --no-verbose \
  --output-document=/tmp/maven.zip
unzip maven.zip
mv apache-maven-${maven_version} /usr/local/share/maven

# cleanup
apt clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
rm -rf /tmp/*
