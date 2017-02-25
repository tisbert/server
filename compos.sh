php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '55d6ead61b29c7bdee5cccfb50076874187bd9f21f65d8991d46ec5cc90518f447387fb9f76ebae1fbbacf329e583e30') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
rm -Rf composer-setup.php
touch composer.json
echo "{}" >> composer.json
php composer.phar install

#Extras - Librerías de composer
#sudo php composer.phar require zendframework/zendframework
#sudo php composer.phar require zendframework/zend-mvc



#Fin
#sudo rm -Rf /usr/share/composer/compos.sh
