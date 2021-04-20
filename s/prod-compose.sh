#!/bin/bash -e
# Deployment:
# ./s/prod-compose.sh
if [ ! -f rancher_cli.env ]; then
	echo "ERROR: You have to create rancher_cli.env file from rancher_cli.env.template"
	exit 1
fi

rancher_cli () {
	rancher --file docker-compose.yml --file docker-compose.rancher.yml \
		--rancher-file rancher-compose.yml "$@"
}

disable_https () {
	sed -i -e "/certs:/,+1d" -e "/default_cert:/d" -e "/protocol: https/,+3d" rancher-compose.yml
}

enable_https () {
	# revert any changes
	git checkout rancher-compose.yml
}

# load Rancher access data
source rancher_cli.env

RANCHER_STACK_NAME=${RANCHER_STACK_NAME:-concourse}
test $RANCHER_URL
test $RANCHER_ACCESS_KEY
test $RANCHER_SECRET_KEY

# disable https protocol if the load balancer is not running yet
# (acme challenge could not be passed yet and the certificate is not ready)
rancher ps $RANCHER_STACK_NAME/lb || { disable_https && DISABLED_HTTPS=1 && trap enable_https EXIT; }

rancher_cli up -d --pull --upgrade --confirm-upgrade \
	--stack $RANCHER_STACK_NAME \
	--env-file .env \
	--description "Concourse continuous integration tool"

if [ "$DISABLED_HTTPS" = 1 ]; then
	echo "Waiting for the SSL certificate. Please deploy load-balancer once again when it is ready"
fi
