sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P httpd_can_network_connect_db 1
sudo semanage fcontext -a -t httpd_sys_rw_content_t 'csrf-magic'
sudo restorecon -v 'csrf-magic'
sudo setsebool -P httpd_unified 1
sudo setsebool -P polyinstantiation_enabled 1

SELINUXCONFIGFILE='/etc/selinux/config'
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' $SELINUXCONFIGFILE
sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/g' $SELINUXCONFIGFILE
sudo setenforce 0
sudo cat $SELINUXCONFIGFILE | grep '^SELINUX='

#Install IUS y EPEL
sudo yum clean all
sudo yum -y install epel-release pwgen git touch mod_ssl openssl
sudo yum -y upgrade
sudo wget https://centos7.iuscommunity.org/ius-release.rpm
sudo sudo rpm -Uvh ius-release*.rpm
sudo rm -Rf ius-release.rpm

#Install webmin
sudo yum -y install nano wget
sudo touch /etc/yum.repos.d/webmin.repo
sudo echo "[Webmin]" >> /etc/yum.repos.d/webmin.repo
sudo echo "name=Webmin Distribution Neutral" >> /etc/yum.repos.d/webmin.repo
sudo echo "#baseurl=http://download.webmin.com/download/yum" >> /etc/yum.repos.d/webmin.repo
sudo echo "mirrorlist=http://download.webmin.com/download/yum/mirrorlist" >> /etc/yum.repos.d/webmin.repo
sudo wget http://www.webmin.com/jcameron-key.asc
sudo rpm --import jcameron-key.asc
sudo yum -y install webmin
#Prueba permisos a usuario para webmin
sudo adduser webmin_root
sudo passwd webmin_root
sudo rm -Rf /etc/webmin/miniserv.users
sudo touch /etc/webmin/miniserv.users
sudo echo "webmin_root:x:0:::::::0:0" >> /etc/webmin/miniserv.users
sudo rm -Rf /etc/webmin/webmin.acl
sudo touch /etc/webmin/webmin.acl
sudo echo "webmin_root: acl adsl-client apache at backup-config bacula-backup bandwidth bind8 burner cfengine change-user cluster-copy cluster-cron cluster-passwd cluster-shell cluster-software cluster-useradmin cluster-usermin cluster-webmin cpan cron custom dfsadmin dhcpd dnsadmin dovecot exim exports fdisk fetchmail file filter firewall frox fsdump grub heartbeat htaccess-htpasswd idmapd inetd init inittab ipfilter ipfw ipsec jabber krb5 ldap-client ldap-server ldap-useradmin lilo logrotate lpadmin lvm mailboxes mailcap majordomo man mon mount net nis openslp pam pap passwd phpini postfix postgresql ppp-client pptp-client pptp-server procmail proc pserver qmailadmin quota raid samba sarg sendmail sentry servers shell shorewall smart-status smf software spam squid sshd status stunnel syslog syslog-ng tcpwrappers telnet time tunnel updown useradmin usermin vgetty webalizer webminlog webmin xinetd vsftpd mysql package-updates system-status webmincron ajaxterm" >> nano /etc/webmin/webmin.acl

#Install extras
sudo yum -y install libpcap open-vm-tools iftop

#Install APACHE
sudo yum -y install httpd
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

#Configurando https (pendiente)
# https://www.digitalocean.com/community/tutorials/how-to-set-up-apache-virtual-hosts-on-centos-7
# https://wiki.centos.org/es/HowTos/Https

#Abrir puertos del firewalld
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-service http
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-service https
sudo firewall-cmd --permanent --add-port=21/tcp
sudo firewall-cmd --permanent --add-service=ftp
sudo firewall-cmd --permanent --add-port=10000/tcp
sudo systemctl restart firewalld.service

#Desactivar Firewalld e instalar IPtables
#sudo systemctl mask firewalld
#sudo systemctl stop firewalld
#sudo yum -y install iptables-services
#sudo systemctl enable iptables
#sudo yum -y remove firewalld
#sudo service iptables stop

#Install MySQL
sudo yum -y install mariadb-server mariadb mariadb-libs
sudo systemctl start mariadb.service
sudo systemctl enable mariadb.service
sudo dbpass=$(pwgen -1cnys 24)
echo ""
echo "////////////////////////////////////////////////////"
echo ""
echo "Password generada de 24bits opcional para password de mysql:  "$dbpass
echo ""
echo "////////////////////////////////////////////////////"
echo ""
sudo mysql_secure_installation

#Install PHP 5.6
sudo yum -y install php56u php56u-pdo php56u-gd php56u-imap php56u-ldap php56u-xml php56u-intl php56u-soap php56u-mbstring php56u-pear php56u-mysql
sudo systemctl restart httpd.service
sudo systemctl enable httpd.service

#Install PEAR library
sudo pear install Auth_SASL
sudo pear install Net_SMTP-1.7.2
sudo pear install Net_IDNA2-0.1.1
sudo pear install Mail_Mime-1.10.0
sudo pear install Mail-1.3.0
sudo pear install Net_URL2-2.2.1
sudo pear install HTTP_Request2

#Quitar pagina de bienvenida
sudo rm -Rf /etc/httpd/conf.d/welcome.conf
sudo touch /etc/httpd/conf.d/welcome.conf
sudo echo "#" >> /etc/httpd/conf.d/welcome.conf

#Configuracion de PHP
sudo mv -f php.ini /etc/

#Configuracion de MySQL
sudo mv -f my.cnf /etc/

#Finalizando instalación
sudo systemctl restart httpd.service
echo "Instalación finalizada"
echo ""
echo "Acceder a webmin por 'https://0.0.0.0:10000'"
