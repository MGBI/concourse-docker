#!/bin/bash -e
# Deployment:
# ./s/prod-compose.sh up
source load_rancher_env.sh

STACK_NAME=${RANCHER_STACK_NAME:-concourse}

rancher-compose \
	-e .env \
	-p $STACK_NAME \
	-f docker-compose.yml \
	$@
