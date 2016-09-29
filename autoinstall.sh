SELINUXCONFIGFILE='/etc/selinux/config'
SELINUXCHECK=`grep '^SELINUX=' /etc/selinux/config | cut -d '=' -f2`
if [[$SELINUXCHECK=='enforcing']]; then
  cecho "---------------------------------------------" $boldyellow
	echo "SELinux habilitado (Recomendado: deshabilitar)"
	read -ep "Quieres deshabilitar SELinux ? [y/n]: " disableselinux
  cecho "---------------------------------------------" $boldyellow
	if [[$disableselinux==[yY]]]; then
    cecho "---------------------------------------------" $boldyellow
  	echo "deshabilitando SELinux..."
  	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' $SELINUXCONFIGFILE
      sed -i 's/SELINUX=permissive/SELINUX=disabled/g' $SELINUXCONFIGFILE
  	setenforce 0
    cecho "---------------------------------------------" $boldyellow
  	echo "checking $SELINUXCONFIGFILE"
  	cat $SELINUXCONFIGFILE | grep '^SELINUX='
    cecho "---------------------------------------------" $boldyellow
  	exit
	else
    getsebool -a | grep httpd_can_network_connect
    setsebool -P httpd_can_network_connect 1
    setsebool -P httpd_can_network_connect_db 1
    semanage fcontext -a -t httpd_sys_rw_content_t 'csrf-magic'
    restorecon -v 'csrf-magic'
    setsebool -P httpd_unified 1
    setsebool -P polyinstantiation_enabled 1
  	exit
	fi
else
  getsebool -a | grep httpd_can_network_connect
  setsebool -P httpd_can_network_connect 1
  setsebool -P httpd_can_network_connect_db 1
  semanage fcontext -a -t httpd_sys_rw_content_t 'csrf-magic'
  restorecon -v 'csrf-magic'
  setsebool -P httpd_unified 1
  setsebool -P polyinstantiation_enabled 1
  cecho "---------------------------------------------" $boldyellow
	echo "comprobando $SELINUXCONFIGFILE"
	echo "SELinux está actualmente deshabilitado"
	echo "SELINUX=$SELINUXCHECK"
  cecho "---------------------------------------------" $boldyellow
	exit
fi

yum -q clean all
yum -q -y install epel-release pwgen git
yum -q -y upgrade
wget https://centos7.iuscommunity.org/ius-release.rpm
sudo rpm -Uvh ius-release*.rpm
rm -Rf ius-release.rpm
yum -q -y install httpd
systemctl start httpd.service
systemctl enable httpd.service
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-service http
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-service https
firewall-cmd --permanent --add-port=21/tcp
firewall-cmd --permanent --add-service=ftp
systemctl restart firewalld.service
yum -q -y install mariadb-server mariadb mariadb-libs
systemctl start mariadb.service
systemctl enable mariadb.service
dbpass=$(pwgen -1cnys 21)
mysql_secure_installation
y
$dbpass
$dbpass
y
y
y
y
yum -q -y install php56u php56u-pdo php56u-gd php56u-imap php56u-ldap php56u-xml php56u-intl php56u-soap php56u-mbstring php56u-pear php56u-mysql
systemctl restart httpd.service
systemctl enable httpd.service
pear install Auth_SASL
pear install Net_SMTP-1.7.2
pear install Net_IDNA2-0.1.1
pear install Mail_Mime-1.10.0
pear install Net_URL2
pear install HTTP_Request2
