#!/bin/bash
# usage: ./install.sh
#
# Goal: automate the way to create geokrety-server docker-machine: apache + php++ + mariadb + adminer
#
MACHINE=geokrety-server
COMPOSE_FILE="docker-compose.yml"

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
	echo " * Create docker machine $MACHINE"
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

function alternate_scp {
	echo " o Hum... seems 'docker-machine scp' doesn't work ($DOCKERMACHINE_VERSION), try alternate way.."
	# retrieve docker default machine SSH PORT
	# cat ~/.docker/machine/machines/default/default/default.vbox|grep Forwarding
	# using grep regexp to isolate forwarded port number only
	SSHPORT=`cat ~/.docker/machine/machines/$MACHINE/$MACHINE/$MACHINE.vbox|grep Forwarding| grep -oP "hostport=\"\K\d+"`
	# echo " * retrieve ssh forwarded port: $SSHPORT"
	# using generated pk
	SSHIDFILE="~/.docker/machine/machines/$MACHINE/id_rsa"
	# echo "   using identity: $SSHIDFILE"

	SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=quiet -3 -o IdentitiesOnly=yes "
	# echo " * Copy resources (alternate way)"
	scp.exe $SSHOPTS -o Port=$SSHPORT -o IdentityFile="$SSHIDFILE" -r docker/configs docker@127.0.0.1: || die "Unable to scp machine $MACHINE"
	scp.exe $SSHOPTS -o Port=$SSHPORT -o IdentityFile="$SSHIDFILE" -r docker/mariadb docker@127.0.0.1: || die "Unable to scp machine $MACHINE"
}

echo " * Copy resources"
docker-machine ssh $MACHINE sudo rm -rf /home/docker/configs
docker-machine scp -r docker/configs $MACHINE: 2>/dev/null 1>/dev/null || alternate_scp
docker-machine scp -r docker/mariadb $MACHINE: 2>/dev/null 1>/dev/null || alternate_scp

echo " * Convert machine resources (using dos2unix)"
docker-machine ssh $MACHINE 'find configs -type f -exec dos2unix {} \;'  || die "Unable to convert resources"

export GK_IP=$(docker-machine ip $MACHINE)
export COMPOSE_CONVERT_WINDOWS_PATHS=1

echo " * Docker compose ($COMPOSE_FILE)"
docker-compose -f $COMPOSE_FILE up -d --force-recreate || die "compose error"

echo "adminer http://${GK_IP}:8880/ - System: MySQL - Server: mariadb - username: root - Database: geokrety-db"
echo "open http://${GK_IP}/"
start "" "http://${GK_IP}/"