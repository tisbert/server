echo "Deshabilitando SElinux"
sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P httpd_can_network_connect_db 1
sudo setsebool -P httpd_unified 1
sudo setsebool -P polyinstantiation_enabled 1
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' '/etc/selinux/config'
sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/g' '/etc/selinux/config'
sudo setenforce 0
sudo cat '/etc/selinux/config' | grep '^SELINUX='

#Install IUS y EPEL
echo ""
echo "Instalando IUS, EPEL y librerias varias"
echo ""
sudo yum -y upgrade
sudo yum -y install epel-release
sudo yum -y install pwgen libmcrypt libmcrypt-devel kernel-headers kernel-devel perl perl-Net-SSLeay openssl perl-IO-Tty bc wget gcc gcc-c++ make patch libgomp glibc-headers binutils glibc-devel nano openssl-devel touch mod_ssl zlib* bzip2 bzip2-devel dkms
sudo wget https://centos7.iuscommunity.org/ius-release.rpm
sudo rpm -Uvh ius-release*.rpm
sudo rm -Rf ius-release.rpm

#Install webmin
echo ""
echo "Instalando webmin"
echo ""
sudo rm -Rf /etc/yum.repos.d/webmin.repo
sudo touch /etc/yum.repos.d/webmin.repo
sudo echo "[Webmin]" >> /etc/yum.repos.d/webmin.repo
sudo echo "name=Webmin Distribution Neutral" >> /etc/yum.repos.d/webmin.repo
sudo echo "#baseurl=http://download.webmin.com/download/yum" >> /etc/yum.repos.d/webmin.repo
sudo echo "mirrorlist=http://download.webmin.com/download/yum/mirrorlist" >> /etc/yum.repos.d/webmin.repo
sudo echo "enabled=0" >> /etc/yum.repos.d/webmin.repo
sudo wget http://www.webmin.com/jcameron-key.asc
sudo rpm --import jcameron-key.asc
sudo yum clean all
sudo wget http://prdownloads.sourceforge.net/webadmin/webmin-1.820-1.noarch.rpm
sudo rpm -U webmin-1.820-1.noarch.rpm
#sudo yum -y install webmin
#Prueba permisos a usuario para webmin
sudo adduser webmin_root
sudo passwd webmin_root
#sudo rm -Rf /etc/webmin/miniserv.users
#sudo touch /etc/webmin/miniserv.users
sudo echo "webmin_root:x:0:::::::0:0" >> /etc/webmin/miniserv.users
#sudo rm -Rf /etc/webmin/webmin.acl
#sudo touch /etc/webmin/webmin.acl
sudo echo "webmin_root: acl adsl-client apache at backup-config bacula-backup bandwidth bind8 burner cfengine change-user cluster-copy cluster-cron cluster-passwd cluster-shell cluster-software cluster-useradmin cluster-usermin cluster-webmin cpan cron custom dfsadmin dhcpd dnsadmin dovecot exim exports fdisk fetchmail file filter firewall frox fsdump grub heartbeat htaccess-htpasswd idmapd inetd init inittab ipfilter ipfw ipsec jabber krb5 ldap-client ldap-server ldap-useradmin lilo logrotate lpadmin lvm mailboxes mailcap majordomo man mon mount net nis openslp pam pap passwd phpini postfix postgresql ppp-client pptp-client pptp-server procmail proc pserver qmailadmin quota raid samba sarg sendmail sentry servers shell shorewall smart-status smf software spam squid sshd status stunnel syslog syslog-ng tcpwrappers telnet time tunnel updown useradmin usermin vgetty webalizer webminlog webmin xinetd vsftpd mysql package-updates system-status webmincron ajaxterm" >> /etc/webmin/webmin.acl
sudo service webmin restart

#Install extras
echo ""
echo "Instalando extras"
echo ""
sudo yum -y install libpcap open-vm-tools iftop
#full_asp_browscap.ini
sudo wget https://browscap.org/stream?q=Full_PHP_BrowsCapINI -O full_php_browscap.ini
sudo mkdir /etc/extra
sudo mv -f full_php_browscap.ini /etc/extra

#Install APACHE
echo ""
echo "Instalando APACHE"
echo ""
sudo yum -y install httpd
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

#Configurando https (pendiente)
# https://www.digitalocean.com/community/tutorials/how-to-set-up-apache-virtual-hosts-on-centos-7
# https://wiki.centos.org/es/HowTos/Https

#Abrir puertos del firewalld
echo ""
echo "Abriendo puertos"
echo ""
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
echo ""
echo "Instalando MySQL"
echo ""
sudo yum -y install mariadb-server mariadb mariadb-libs
sudo systemctl start mariadb.service
sudo systemctl enable mariadb.service
sudo dbpass=$(pwgen -1cnys 24)
echo "////////////////////////////////////////////////////"
echo ""
echo "Password generada de 24bits opcional para password de mysql:  "$dbpass
echo ""
echo "////////////////////////////////////////////////////"
sudo touch /root/dbpass.conf
sudo echo $dbpass >> /root/dbpass.conf
sudo mysql_secure_installation

#Install PHP 5.6
echo ""
echo "Instalando PHP"
echo ""
sudo yum -y install php56u php56u-pdo php56u-gd php56u-imap php56u-ldap php56u-xml php56u-intl php56u-soap php56u-mbstring php56u-pear php56u-mysql
sudo systemctl restart httpd.service
sudo systemctl enable httpd.service

#Install PEAR library
echo ""
echo "Instalando librerias de PEAR"
echo ""
sudo pear upgrade-all
sudo pear install --alldeps Auth_SASL
sudo pear install --alldeps Net_SMTP-1.7.2
sudo pear install --alldeps Net_IDNA2-0.1.1
sudo pear install --alldeps Mail_Mime-1.10.0
sudo pear install --alldeps Mail-1.3.0
sudo pear install --alldeps Net_URL2-2.2.1
sudo pear install --alldeps HTTP_Request2

#Quitar pagina de bienvenida
echo ""
echo "Quitando página de bienvenida"
echo ""
sudo rm -Rf /etc/httpd/conf.d/welcome.conf
sudo touch /etc/httpd/conf.d/welcome.conf
sudo echo "#" >> /etc/httpd/conf.d/welcome.conf

#Configuracion de PHP
sudo mv -f php.ini /etc/

#Configuracion de MySQL
sudo mv -f my.cnf /etc/

#Finalizando instalación
sudo systemctl restart httpd.service
echo "Primera parte finalizada"
echo ""
echo "Acceder a webmin por 'https://0.0.0.0:10000'"

sudo mkdir /usr/share/composer
sudo mv -f compos.sh /usr/share/composer
sudo chmod 0700 /usr/share/composer/compos.sh
echo "No olvides reiniciar para que se deshabilite completamente SELinux"
echo "Para instalar compose:"
echo "1.- cd /usr/share/composer/"
echo "2.- ./compos.sh"
sudo rm -Rf /root/server/
