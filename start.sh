echo "Nombre del usuario actual: "
read USER

echo "Deshabilitando SElinux"
sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P httpd_can_network_connect_db 1
sudo setsebool -P httpd_unified 1
sudo setsebool -P polyinstantiation_enabled 1
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' '/etc/selinux/config'
sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/g' '/etc/selinux/config'
sudo setenforce 0
sudo cat '/etc/selinux/config' | grep '^SELINUX='

echo "¿Reiniciar ahora?"
echo "recomendado SOLO después de deshabilitar SElinux [Recomendado: SI]"
select yn in "Si" "No"; do
  case $yn in
    Si ) 
      sudo reboot now
      break;;
    No ) break;;
  esac
done

#Install IUS y EPEL
echo ""
echo "Instalando IUS, EPEL"
echo ""
sudo yum -y install epel-release --skip-broken
sudo wget https://centos7.iuscommunity.org/ius-release.rpm
sudo rpm -Uvh ius-release*.rpm
sudo rm -Rf ius-release.rpm
sudo yum clean all
sudo yum -y upgrade --skip-broken
#sudo yum -y install yum-plugin-replace
#sudo yum -y replace --replace-with php56u php

#Desinstalando mariadb
sudo yum -y remove mariadb*

#Install extras
#echo "Instalar acelerador de descargas 'AXEL'? [Recomendado: SI]"
#select yn in "Si" "No"; do
#  case $yn in
#    Si ) 
#      sudo yum -y install axel --skip-broken
#      break;;
#    No ) break;;
#  esac
#done
echo "Instalar extras? [Recomendado: NO]"
select yn in "Si" "No"; do
  case $yn in
    Si ) 
      echo ""
      echo "Instalando extras"
      echo ""
      sudo yum -y install libsodium dkms nano bzip2 libzip python2-paramiko proj tinyxml bzip2-devel openssl openssl-devel wget lynx bc grep unzip bc coreutils file dos2unix ioping curl libcurl libcurl-devel autoconf automake cmake freetype-devel gcc gcc-c++ libtool make mercurial nasm pkgconfig zlib-devel yasm yasm-devel numactl-devel pwgen patch readline zlib zlib-devel bash libmcrypt libmcrypt-devel kernel-headers kernel-devel libpcap open-vm-tools iftop --skip-broken
      break;;
    No )
      echo ""
      echo "Instalando lo necesario"
      echo ""
      sudo yum -y install libsodium nano openssl curl libcurl pwgen libmcrypt iftop coreutils tinyxml proj python2-paramiko libzip --skip-broken
      break;;
  esac
done
#sudo yum -y install GeoIP GeoIP-devel --disablerepo=rpmforge --skip-broken

sudo wget https://browscap.org/stream?q=Full_PHP_BrowsCapINI -O full_php_browscap.ini
sudo mkdir /etc/extra
sudo mv -f full_php_browscap.ini /etc/extra
#sudo chown -hR apache:apache /etc/extra/full_php_browscap.ini

echo "Instalar Webmin? [Recomendado: SI]"
select yn in "Si" "No"; do
  case $yn in
    Si ) 
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
      sudo echo "enabled=1" >> /etc/yum.repos.d/webmin.repo
      sudo wget http://www.webmin.com/jcameron-key.asc
      sudo rpm --import jcameron-key.asc
      sudo yum -y install webmin --skip-broken
      sudo service webmin restart
      break;;
    No ) break;;
  esac
done

echo "crear un usuario nuevo para Webmin? [Recomendado: SI]"
select yn in "Si" "No"; do
  case $yn in
    Si ) 
      sudo adduser webmin
      sudo passwd webmin
      sudo echo "webmin:x:0:::::::0:0" >> /etc/webmin/miniserv.users
      sudo echo "webmin: backup-config change-user webmincron usermin webminlog webmin servers acl bacula-backup init passwd quota mount fsdump inittab ldap-client ldap-useradmin logrotate mailcap mon pam proc at cron package-updates software man syslog syslog-ng system-status useradmin apache bind8 dhcpd dovecot exim fetchmail jabber ldap-server mysql openslp postfix postgresql proftpd procmail qmailadmin mailboxes sshd samba sendmail spam squid sarg wuftpd webalizer adsl-client bandwidth fail2ban firewalld ipsec krb5 firewall firewall6 exports nis net xinetd inetd pap ppp-client pptp-client pptp-server stunnel shorewall shorewall6 tcpwrappers idmapd filter burner grub raid lvm fdisk lpadmin smart-status time vgetty iscsi-client iscsi-server iscsi-tgtd iscsi-target cluster-passwd cluster-copy cluster-cron cluster-shell cluster-software cluster-usermin cluster-useradmin cluster-webmin heartbeat shell custom filemin tunnel file phpini cpan htaccess-htpasswd telnet status ajaxterm updown dfsadmin ipfilter ipfw smf" >> /etc/webmin/webmin.acl
      sudo service webmin restart
      break;;
    No ) break;;
  esac
done

#Install APACHE
echo ""
echo "Instalando APACHE"
echo ""
sudo yum -y install httpd --skip-broken
#sudo yum -y install httpd24u httpd24u-tools --skip-broken

#Configurando https (pendiente)
echo "Activar https? [Recomendado: NO][Estado: en pruebas]"
select yn in "Si" "No"; do
  case $yn in
    Si ) 
      #sudo yum -y install httpd24u-mod_security2 httpd24u-mod_ssl --skip-broken
      sudo yum install -y mod_ssl
      #sudo mkdir /root/certificados/
      #sudo openssl genrsa -out /root/certificados/CA.key 4096
      #echo "################################################# IMPORTANTE"
      #echo ""
      #echo "#################### Es el que se visualiza en el certificado"
      #echo "#################### Common Name: localhost"
      #echo ""
      #echo "#################################################"
      #sudo openssl req -new -x509 -sha512 -days 1825 -key /root/certificados/CA.key -out /root/certificados/CA.crt
      #sudo openssl genrsa -out /root/certificados/IA.key 4096
      #echo "################################################# IMPORTANTE"
      #echo ""
      #echo "#################### Common Name tiene que ser diferente al anterior"
      #echo "#################### Common Name: localhost.localdomain"
      #echo ""
      #echo "#################################################"
      #sudo openssl req -new -sha512 -key /root/certificados/IA.key -out /root/certificados/IA.csr
      #sudo openssl x509 -req -sha512 -days 1825 -in /root/certificados/IA.csr -CA /root/certificados/CA.crt -CAkey /root/certificados/CA.key -set_serial 01 -out /root/certificados/IA.crt
      #sudo openssl pkcs12 -export -out /root/certificados/IA.p12 -inkey /root/certificados/IA.key -in /root/certificados/IA.crt -chain -CAfile /root/certificados/CA.crt
      #sudo chmod -R 0400 /root/certificados/
      #sudo rm -Rf /etc/pki/tls/certs/CA.crt
      #sudo rm -Rf /etc/pki/tls/certs/IA.crt
      #sudo rm -Rf /etc/pki/tls/certs/CA.key
      #sudo rm -Rf /etc/httpd/conf.d/ssl.conf
      #sudo cp /root/certificados/CA.crt /etc/pki/tls/certs/
      #sudo cp /root/certificados/IA.crt /etc/pki/tls/certs/
      #sudo cp /root/certificados/CA.key /etc/pki/tls/private/
      #sudo cp ssl.conf /etc/httpd/conf.d/
      break;;
    No ) break;;
  esac
done
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
sudo chown apache:apache /etc/extra/full_php_browscap.ini

#Desactivar Firewalld e instalar IPtables
echo "Desactivar Firewalld e instalar IPtables? [Recomendado: NO]"
select yn in "Si" "No"; do
  case $yn in
    Si ) 
      sudo systemctl mask firewalld
      sudo systemctl stop firewalld
      sudo yum -y install iptables-services
      sudo systemctl enable iptables
      sudo yum -y remove firewalld
      sudo service iptables stop
      break;;
    No )
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
      break;;
  esac
done

#Install MySQL
echo ""
echo "Instalando MySQL"
echo ""
#sudo yum -y install mariadb101u mariadb101u-server mariadb101u-libs mariadb101u-common --skip-broken
yum -y install mariadb mariadb-server mariadb-libs mariadb-common --skip-broken
#mysql-conector-java para Spoon de Pentaho
sudo yum -y install mysql-connector-java --skip-broken
sudo systemctl start mariadb.service
sudo systemctl enable mariadb.service
dbpass=$(pwgen -1cnys 24)
echo "#################################################"
echo ""
echo "Password generada de 24bits opcional para password de mysql:  "$dbpass
echo ""
echo "#################################################"
sudo touch /root/dbpass.conf
sudo echo $dbpass >> /root/dbpass.conf
sudo mysql_secure_installation

#Install PHP 5.6
echo ""
echo "Instalando PHP"
echo ""
#sudo yum -y remove php*
sudo yum -y install php56u php56u-pdo php56u-dba php56u-gd php56u-imap php56u-ldap php56u-xml php56u-intl php56u-soap php56u-mbstring php56u-pear php56u-mysql php56u-mysqlnd php56u-opcache php56u-fpm-httpd php56u-suhosin php56u-ioncube-loader php56u-mcrypt php56u-pecl-apcu php56u-bcmath php56u-tidy --skip-broken
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
sudo sed -i 's/short_open_tag = Off/short_open_tag = On;ADD/g' '/etc/php.ini'
sudo sed -i 's/output_buffering = 4096/output_buffering = On;ADD/g' '/etc/php.ini'
sudo sed -i 's/expose_php = On/expose_php = Off;ADD/g' '/etc/php.ini'
sudo sed -i 's/max_execution_time = 30/max_execution_time = 600;ADD/g' '/etc/php.ini'
sudo sed -i 's/max_input_time = 60/max_input_time = 600;ADD/g' '/etc/php.ini'
sudo sed -i 's/; max_input_vars = 1000/max_input_vars = 10000;ADD/g' '/etc/php.ini'
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M;ADD/g' '/etc/php.ini'
sudo sed -i 's/error_reporting = E_ALL \& \~E_DEPRECATED \& \~E_STRICT/error_reporting = E_WARNING \& E_ERROR \& ~E_NOTICE \& \~E_DEPRECATED \& \~E_STRICT;ADD/g' '/etc/php.ini'
sudo sed -i 's/log_errors = On/log_errors = Off;ADD/g' '/etc/php.ini'
sudo sed -i 's/log_errors_max_len = 1024/log_errors_max_len = 0;ADD/g' '/etc/php.ini'
sudo sed -i 's/report_memleaks = On/report_memleaks = Off;ADD/g' '/etc/php.ini'
sudo sed -i 's/html_errors = On/html_errors = Off;ADD/g' '/etc/php.ini'
sudo sed -i 's/post_max_size = 8M/post_max_size = 64M;ADD/g' '/etc/php.ini'
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M;ADD/g' '/etc/php.ini'
sudo sed -i 's/default_socket_timeout = 60/default_socket_timeout = 600;ADD/g' '/etc/php.ini'
sudo sed -i 's/;date.timezone =/date.timezone = Atlantic\/Canary;ADD/g' '/etc/php.ini'
sudo sed -i 's/;date.default_latitude = 31.7667/date.default_latitude = 28.4716;ADD/g' '/etc/php.ini'
sudo sed -i 's/;date.default_longitude = 35.2333/date.default_longitude = -16.2472;ADD/g' '/etc/php.ini'
sudo sed -i 's/mysql.connect_timeout = 60/mysql.connect_timeout = 600;ADD/g' '/etc/php.ini'
sudo sed -i 's/;browscap = extra\/browscap.ini/browscap = \/etc\/extra\/full_php_browscap.ini;ADD/g' '/etc/php.ini'
sudo sed -i 's/session.name = PHPSESSID/session.name = ITOP_SESSID;ADD/g' '/etc/php.ini'
sudo sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400;ADD/g' '/etc/php.ini'
sudo sed -i 's/;mbstring.func_overload = 0/mbstring.func_overload = 7;ADD/g' '/etc/php.ini'

#Configuracion de MySQL
#sudo mv -f my.cnf /etc/

#Instalar workbench community
echo "Instalar Workbench community 6.3.8-1.el7.x86_64? "
select yn in "Si" "No"; do
  case $yn in
    Si ) 
      sudo yum -y install libodbc* libpq* gtkmm30
      sudo wget https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community-6.3.9-1.el7.x86_64.rpm
      sudo rpm -Uvh mysql-workbench-community*.rpm
      sudo rm -Rf mysql-workbench-community*.rpm
      break;;
    No ) break;;
  esac
done

#Instalar Atom io
echo "Instalar editor de texto Atom? "
select yn in "Si" "No"; do
  case $yn in
    Si ) 
      sudo yum -y install libX*
      sudo wget https://github.com/atom/atom/releases/download/v1.14.1/atom.x86_64.rpm
      sudo yum -y install lsb-core-noarch
      sudo rpm -Uvh atom.x86_64.rpm
      sudo rm -Rf atom.x86_64.rpm
      break;;
    No ) break;;
  esac
done

#Finalizando instalación
sudo systemctl restart httpd.service
echo ""
echo "Acceder a webmin por 'https://0.0.0.0:10000'"
echo ""

sudo mkdir /usr/share/composer
sudo mv -f compos.sh /usr/share/composer
sudo chmod 0700 /usr/share/composer/compos.sh

echo "Eliminando archivos innecesarios en: "$USER
if [ "$USER" == "root" ] || [ "$USER" == "" ]; then
  sudo rm -Rf /root/server/
else
  sudo rm -Rf /home/$USER/server/
fi
