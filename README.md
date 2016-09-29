### Preparar CentOS

    cd /root
    yum -y -q install git
    git clone -b master https://github.com/WalterLuis/autoinstall.git
    cd /root/autoinstall
    chmod +777 autoinstall.sh
    ./autoinstall.sh

