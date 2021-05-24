#!/bin/bash
#

TAG="go-debug:v1"

docker build -t $TAG . && \
docker run --rm -it $TAG sh 