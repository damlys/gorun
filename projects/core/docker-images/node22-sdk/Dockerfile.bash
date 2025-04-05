#!/bin/bash
set -ex

npm install --global \
  typescript

# cleanup
npm cache clean --force && rm -rf /root/.npm/*
