### Opcional - pre-install for "VirtualBox Guest Additions"
    sudo yum -y install epel-release
    sudo yum -y upgrade
    sudo yum -y install binutils gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel dkms bzip2
    sudo yum groupinstall "Development Tools"

### Paso 1 - Preparar CentOS
    cd /root
    sudo yum -y install git
    sudo git clone -b master https://github.com/WalterLuis/autoinstall.git
    cd /root/autoinstall
    sudo chmod +777 autoinstall.sh
    sudo ./autoinstall.sh

### Paso 2 - Instalación -> composer
    sudo mkdir /usr/share/composer
    sudo cd /usr/share/composer
    sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    sudo php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    sudo php composer-setup.php
    sudo php -r "unlink('composer-setup.php');"
    sudo rm -Rf composer-setup.php
    sudo touch composer.json
    sudo echo "{}" >> composer.json
    sudo php composer.phar install
    
### Paso 3 - Instalación -> YetiForce
    cd /var/www/html/
    sudo git clone -b developer https://github.com/YetiForceCompany/YetiForceCRM.git .
    sudo chown -hR apache:apache .
    

### Extras - Librerías de composer
    cd /usr/share/composer
    sudo php composer.phar require zendframework/zendframework
    sudo php composer.phar require zendframework/zend-mvc
