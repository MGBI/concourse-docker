#!/bin/bash -
source .env

TAG=$CONCOURSE_VERSION

test $TAG
test $PRIVATE_REPOSITORY

docker build -f dockerfiles/concourse-web -t ${PRIVATE_REPOSITORY}/concourse-web:$TAG \
    --build-arg CONCOURSE_VERSION=$CONCOURSE_VERSION .
docker build -f dockerfiles/concourse-worker -t ${PRIVATE_REPOSITORY}/concourse-worker:$TAG \
    --build-arg CONCOURSE_VERSION=$CONCOURSE_VERSION .
docker push ${PRIVATE_REPOSITORY}/concourse-web:$TAG
docker push ${PRIVATE_REPOSITORY}/concourse-worker:$TAG
