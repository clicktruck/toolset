#!/usr/bin/env bash

# Build Toolset Image

BUILDER=${1:-docker}
IMAGE_NAME="clicktruck/toolset"

if [ "docker" == "${BUILDER}" ]
then
  docker build -t ${IMAGE_NAME}:latest .
else
  nerdctl build -t ${IMAGE_NAME}:latest .
fi
