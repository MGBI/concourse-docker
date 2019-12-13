#!/bin/bash -e
# Deployment:
# ./s/prod-compose-up.sh
source load_rancher_env.sh

STACK_NAME=${RANCHER_STACK_NAME:-concourse}

rancher \
	--file docker-compose.yml \
	--file docker-compose.rancher.yml \
	up -d \
	--env-file .env \
	--stack $STACK_NAME \
	--description "Concourse continuous integration tool"
