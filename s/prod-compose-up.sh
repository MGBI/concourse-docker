#!/bin/bash -e
# Deployment:
# ./s/prod-compose-up.sh
source load_rancher_env.sh

STACK_NAME=${RANCHER_STACK_NAME:-concourse}

disable_https () {
	sed -i -e "/certs:/,+1d" -e "/default_cert:/d" -e "/protocol: https/,+3d" rancher-compose.yml
}

enable_https () {
	# revert any changes
	git checkout rancher-compose.yml
}

# disable https protocol if the load balancer is not running yet
# (acme challenge could not be passed yet and the certificate is not ready)
rancher ps $STACK_NAME/lb || { disable_https && DISABLED_HTTPS=1 && trap enable_https EXIT; }

rancher \
	--file docker-compose.yml \
	--file docker-compose.rancher.yml \
	up -d --pull --upgrade --confirm-upgrade \
	--env-file .env \
	--stack $STACK_NAME \
	--description "Concourse continuous integration tool"

if [ "$DISABLED_HTTPS" = 1 ]; then
	echo "Waiting for the SSL certificate. Please deploy lb once again when it is ready"
fi
