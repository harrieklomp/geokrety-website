# Geokrety installation on a local filesystem

If you note other requirements, feel free to add it here.

## requirements:

* apache / apache2 + mod_rewrite
* php
* imagemagick
* smarty 2 + smarty-gettext plugin

## configuration steps

* copy readme/konfig-mysql.tmpl.php to templates/konfig-mysql.php and change settings to fit your local ones
* copy readme/konfig-local.tmpl.php to templates/konfig-local.php and change settings to fit your local ones
* make sure those path are writable (eg chmod a+rwx compile)
 * obrazek.png
 * mapki/
 * obrazki/
 * obrazki-dowonu/
 * obrazki-male/
 * templates/compile/
 * templates/wykresy/
 * templates/cache
 * templates/htmlpurifier/library/HTMLPurifier/DefinitionCache/Serializer/
 * files/


## Extra links

For Windows (for example XAMPP) - by szymon
* smarty plugin: http://svn.civicrm.org/civicrm/trunk/packages/Smarty/gettext/block.t.php
* imagemagick - http://valokuva.org/magick/ ?


# Installation using Docker Toolbox

* create a local database server (mariadb container)

If Docker Toolbox is missing, you will have some help to install it.

    DockerComposeMariaDb.sh

* configure your database server

		* open your favorite mysql workbench (ex. https://dev.mysql.com/downloads/workbench/ )
		* connect (maria db ip):3306 as "root" using password from DockerComposeMariaDb.yml
		* execute the following SQL statement

    CREATE DATABASE  IF NOT EXISTS `geokrety-db` /*!40100 DEFAULT CHARACTER SET utf8 */;
    USE `geokrety-db`;

		* unzip and execute readme/geokrety.sql.gz
		NB: geokrety exports are located here : https://cdn.geokrety.org/exports/

* copy readme/konfig-mysql.tmpl.php to website/templates/konfig-mysql.php and change settings to fit your local ones

    $config['host'] = '192.168.99.102';
    $config['username'] = 'root';
    $config['pass'] = 'password';
    $config['db'] = 'geokrety-db';
    $config['charset'] = 'utf8';
    
    define('CONFIG_HOST', '192.168.99.102');
    define('CONFIG_USERNAME', 'root');
    define('CONFIG_PASS', 'password');
    define('CONFIG_DB', 'geokrety-db');
    define('CONFIG_CHARSET', 'utf8');

* copy readme/konfig-local.tmpl.php to templates/konfig-local.php and change settings to fit your local ones

	update $config['adres']

* create a local geokrety server (apache+php container)

     DockerCompose.sh

* update application configuration

	# TODO: move into refreshConfig script
     MACHINE=geokrety-server
     SSHPORT=`cat ~/.docker/machine/machines/$MACHINE/$MACHINE/$MACHINE.vbox|grep Forwarding| grep -oP "hostport=\"\K\d+"`
     SSHIDFILE="~/.docker/machine/machines/$MACHINE/id_rsa"
     SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=quiet -3 -o IdentitiesOnly=yes "
     scp.exe $SSHOPTS -o Port=$SSHPORT -o IdentityFile="$SSHIDFILE" website/templates/konfig-mysql.php docker@127.0.0.1:
     scp.exe $SSHOPTS -o Port=$SSHPORT -o IdentityFile="$SSHIDFILE" website/templates/konfig-local.php docker@127.0.0.1:
     docker-machine ssh $MACHINE

	 docker ps
	 docker exec -it geokretywebsite_geokrety_1 ls -la /var/www/html
	 docker cp konfig-mysql.php geokretywebsite_geokrety_1:/var/www/html/templates
	 docker cp konfig-local.php geokretywebsite_geokrety_1:/var/www/html/templates

	 # TODO: move into Dockerfile
     docker exec -it geokretywebsite_geokrety_1 chmod a+rwx /var/www/html/files /var/www/html/mapki/ /var/www/html/obrazki/ /var/www/html/obrazki-dowonu/ /var/www/html/obrazki-male/ /var/www/html/templates/compile/ /var/www/html/templates/wykresy/ /var/www/html/templates/htmlpurifier/library/HTMLPurifier/DefinitionCache/Serializer/
	 exit

     # useless ? # docker exec -it geokretywebsite_geokrety_1 touch /var/www/html/obrazek.png
	 # useless ? # docker exec -it geokretywebsite_geokrety_1 chmod a+rwx /var/www/html/obrazek.png
	 