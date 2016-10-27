### Opcional - pre-install for "VirtualBox Guest Additions"
    sudo yum -y install epel-release
    sudo yum -y upgrade
    sudo yum -y install binutils gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel dkms bzip2
    sudo yum groupinstall "Development Tools"

### Paso 1 - Preparar CentOS
    cd /root
    sudo yum -y install git
    sudo git clone -b master https://github.com/WalterLuis/server.git .
    #sudo chmod +777 start.sh
    sudo chmod 0700 start.sh
    sudo ./start.sh

### Paso 2 - Instalación -> composer
    cd /usr/share/composer
    sudo ./compos.sh
    
### Paso 3 - Instalación -> YetiForce
    cd /var/www/html/
    sudo git clone -b developer https://github.com/YetiForceCompany/YetiForceCRM.git .
    sudo chown -hR apache:apache .
