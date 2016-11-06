### Opcional - pre-install for "VirtualBox Guest Additions"
    sudo yum -y install epel-release
    sudo yum -y upgrade
    sudo yum -y install dkms kernel-headers kernel-devel
    sudo yum groupinstall "Development Tools"
    sudo reboot now
    sudo sh /run/media/root/VBOXADDITIONS_5.1.8_111374/VBoxLinuxAdditions.run
!<--- binutils gcc make patch libgomp glibc-headers glibc-devel bzip2 --->

    sudo yum -y groupinstall "Development Tools"
    sudo yum -y install kernel
    sudo reboot now
    sudo mkdir -p /media/cdrom/
    sudo mount /dev/cdrom /media/cdrom/
    sudo KERN_DIR=/usr/src/kernels/3.10.0-327.36.3.el7.x86_64/ sh /VBoxLinixAdditions.run

### Paso 1 - Preparar CentOS
    cd /root
    sudo yum -y install git
    sudo git clone -b master https://github.com/WalterLuis/server.git
    cd server
    sudo chmod 0700 start.sh
    sudo ./start.sh

### Paso 2 - Instalación -> composer
    cd /usr/share/composer
    sudo ./compos.sh
    
### Paso 3 - Instalación -> YetiForce
    cd /var/www/html/
    sudo git clone -b developer https://github.com/YetiForceCompany/YetiForceCRM.git .
    sudo chown -hR apache:apache .
