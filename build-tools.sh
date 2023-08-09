#!/bin/bash

if [[ -z "$1" ]]; then
  UBUNTU_VERSION="latest"
else
  UBUNTU_VERSION=$1
fi

echo "Building $UBUNTU_VERSION"
docker build -f ./Dockerfile.tools -t "andreygoran/sshd-ubuntu-tools:$UBUNTU_VERSION" --build-arg="UBUNTU_VERSION=$UBUNTU_VERSION" .
