# Geokrety installation on a local filesystem

If you note other requirements, feel free to add it here.

## Website requirements

* apache / apache2 + mod_rewrite
* php
* imagemagick
* smarty 2 + smarty-gettext plugin

# How to install using Docker Toolbox

* create a local geokrety server ([custom](../Dockerfile) [apache+php5](https://hub.docker.com/_/php/), [mariadb](https://hub.docker.com/_/mariadb/), [adminer](https://hub.docker.com/_/adminer/))

     ./install.sh

* the script will output you server ip and how to connect to your geokrety instance.

### Extra links

For Windows (for example XAMPP) - by szymon
* smarty plugin: http://svn.civicrm.org/civicrm/trunk/packages/Smarty/gettext/block.t.php
* imagemagick - http://valokuva.org/magick/ ?
