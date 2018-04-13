#!/bin/bash
# usage: ./DockerCompose.sh
#
# Goal: automate the way to create geokrety-server docker-machine: apache + php + extra modules
# Requirement: MySql; cf. DockerComposeMariaDb.sh
#
MACHINE=geokrety-server
COMPOSE_FILE="DockerCompose.yml"

function dockerNeeded {
	echo "requirements: docker-toolbox (version 18 or sup)"
	echo "   This script rely on docker-toolbox to create docker container: docker-machine docker-compose binaries should be in your PATH"
	echo "   windows user could get msi file from https://docs.docker.com/toolbox/toolbox_install_windows/ (recommended),"
    echo "   or (using powershell admin)'choco install docker-toolbox'"
	exit 1
}

function die(){
   echo ${1:=Something terrible wrong happen}
   exit 1
}

docker-machine -version 2>&1 1>/dev/null || dockerNeeded
docker-compose -version 2>&1 1>/dev/null || dockerNeeded
DOCKERMACHINE_VERSION=$(docker-machine -version)

if [ "$1" == "revert" ]; then
	if docker-machine ls | grep $MACHINE ; then
		echo " * Remove docker machine $MACHINE (you will have to confirm)..."
		docker-machine rm $MACHINE
	else
		echo " * there is no docker machine $MACHINE $revert"
	fi
	exit 0
fi

if ! docker-machine ls | grep --quiet $MACHINE; then
	echo " * Create docker machine"
    docker-machine create $MACHINE || die "Unable to create machine $MACHINE"
fi

if ! docker-machine ls | grep -i Running | grep --quiet $MACHINE ; then
	echo " * Start docker machine $MACHINE"
	docker-machine start $MACHINE
else
	echo " * docker machine $MACHINE already started"
fi

echo " * Load env for $MACHINE docker machine"
eval $(docker-machine env $MACHINE) || die "Unable to set machine $MACHINE env"

export GK_IP=$(docker-machine ip $MACHINE)
export COMPOSE_CONVERT_WINDOWS_PATHS=1

echo " * Docker compose ($COMPOSE_FILE)"
docker-compose -f $COMPOSE_FILE up -d --force-recreate || die "compose error"

echo "open http://${GK_IP}/"
start "" "http://${GK_IP}/"