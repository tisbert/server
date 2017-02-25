### Opcional - pre-install for "VirtualBox Guest Additions"
    sudo yum -y groupinstall "Development Tools"
    
    sudo mkdir -p /media/cdrom/
    sudo mount /dev/cdrom /media/cdrom/
    sudo KERN_DIR=/usr/src/kernels/3.??.?-???.??.?.???.x86_64/ sh /media/cdrom/VBoxLinuxAdditions.run

### Install LAMP in CentOS 7.3.XXXX -> Apache 2.4.XX, MariaDB 10.1.XX, PHP 5.6.XX
    sudo yum -y -q install git
    sudo git clone -b master https://github.com/WalterLuis/server.git
    cd server
    sudo chmod 0700 start.sh
    sudo ./start.sh
