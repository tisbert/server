### Opcional - pre-install for "VirtualBox Guest Additions"
    sudo yum -y groupinstall "Development Tools"
    sudo mkdir -p /media/cdrom/
    sudo mount /dev/cdrom /media/cdrom/
    sudo KERN_DIR=/usr/src/kernels/3.10.0-327.36.3.el7.x86_64/ sh /media/cdrom/VBoxLinuxAdditions.run

### Preparar CentOS
    sudo yum -y install git
    sudo git clone -b master https://github.com/WalterLuis/server.git
    cd server
    sudo chmod 0700 start.sh
    sudo ./start.sh
