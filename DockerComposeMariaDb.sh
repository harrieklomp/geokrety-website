#!/bin/bash
# usage: ./launch.sh
#
# issue with executable? try running first /C/Programmes/DockerToolbox/start.sh
# start.sh: GIT BASH HACK
#		DOCKER_MACHINE="/C/Programmes/DockerToolbox/docker-machine.exe"
#		VBOXMANAGE="/C/Programmes/VirtualBox/VBoxManage.exe"
#
MACHINE=geokrety-db
COMPOSE_FILE="DockerComposeMariaDb.yml"
DOCKERMACHINE_VERSION=$(docker-machine -version)

function dockerNeeded {
	echo "requirements: docker-toolbox (version 18 or sup)"
	echo "   This script rely on docker-toolbox to create docker container: docker-machine docker-compose binaries should be in your PATH"
	echo "   windows user could get msi file from https://docs.docker.com/toolbox/toolbox_install_windows/ (recommended), or (using powershell admin)'choco install docker-toolbox'"
	exit 1
}

function die(){
   echo ${1:=Something terrible wrong happen}
   exit 1
}

docker-machine -version || dockerNeeded
docker-compose -version || dockerNeeded

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

echo "database available at ${GK_IP}:3306"