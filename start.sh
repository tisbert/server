echo ""
echo "/////////////////////////////////////////////////////////////////////////"
echo "/////////////////// Starting script, waiting please /////////////////////"
echo "/////////////////////////////////////////////////////////////////////////"
echo ""
usuarioActual=$(whoami)
sudo yum -y -q --skip-broken remove mariadb*
echo ""
echo "#########################################################################"
echo "######   Checking SElinux"
echo "#########################################################################"
echo ""
if [[ -z "$(sestatus | grep disabled)" ]]; then
  echo "procesing..."
  sudo setsebool -P httpd_can_network_connect 1
  sudo setsebool -P httpd_can_network_connect_db 1
  sudo setsebool -P httpd_unified 1
  sudo setsebool -P polyinstantiation_enabled 1
  sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' '/etc/selinux/config'
  sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/g' '/etc/selinux/config'
  sudo setenforce 0
  echo ""
  echo "#########################################################################"
  echo "######   Restart Now? [recommended: Yes]"
  echo "#########################################################################"
  echo ""
  select yn in "Yes" "No"; do
    case $yn in
      Yes )
      sudo reboot now
      break;;
      No ) break;;
    esac
  done
else
  echo ""
  echo "#########################################################################"
  echo "######   SElinux Status"
  sudo cat '/etc/selinux/config' | grep '^SELINUX='
  echo "#########################################################################"
  echo ""
fi

echo ""
echo "#########################################################################"
echo "######   Installing IUS, EPEL"
echo "#########################################################################"
echo ""
sudo yum -y -q --skip-broken install epel-release
sudo wget -q https://centos7.iuscommunity.org/ius-release.rpm
sudo rpm -Uvh ius-release*.rpm
sudo rm -Rf ius-release.rpm
sudo yum clean all
sudo yum -y --skip-broken upgrade

sudo yum -y -q --skip-broken install pwgen iftop
#curl libcurl

#sudo yum -y --skip-broken install yum-plugin-replace
#sudo yum -y replace --replace-with php56u php
#sudo yum -y --skip-broken install axel
#sudo yum -y -q --skip-broken install libsodium dkms nano bzip2 libzip python2-paramiko proj tinyxml bzip2-devel openssl openssl-devel wget lynx bc grep unzip bc coreutils file dos2unix ioping curl libcurl libcurl-devel autoconf automake cmake freetype-devel gcc gcc-c++ libtool make mercurial nasm pkgconfig zlib-devel yasm yasm-devel numactl-devel pwgen patch readline zlib zlib-devel bash libmcrypt libmcrypt-devel kernel-headers kernel-devel libpcap open-vm-tools iftop
#sudo yum -y -q --skip-broken install GeoIP GeoIP-devel --disablerepo=rpmforge

sudo wget -q https://browscap.org/stream?q=Full_PHP_BrowsCapINI -O full_php_browscap.ini
sudo mkdir /etc/extra
sudo rm -Rf /etc/extra/full_php_browscap.ini
sudo mv -f full_php_browscap.ini /etc/extra

echo ""
echo "#########################################################################"
echo "######   Installing APACHE"
echo "#########################################################################"
echo "procesing..."
#sudo yum -y install httpd --skip-broken
sudo yum -y -q --skip-broken install httpd24u httpd24u-tools

sudo systemctl enable httpd.service
sudo systemctl start httpd.service

sudo rm -Rf /etc/httpd/conf.d/welcome.conf
sudo touch /etc/httpd/conf.d/welcome.conf
sudo echo "#" >> /etc/httpd/conf.d/welcome.conf

echo "#########################################################################"
echo "######   To install https? [recommended: NO][Estado: en pruebas]"
echo "#########################################################################"
select yn in "Yes" "No"; do
  case $yn in
    Yes )
    echo "procesing..."
    sudo yum -y -q --skip-broken install httpd24u-mod_security2 httpd24u-mod_ssl
    #sudo yum -y -q --skip-broken install mod_ssl
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
    sudo sed -i 's/;session.cookie_secure =/session.cookie_secure = 1/g' '/etc/php.ini'
    break;;
    No ) break;;
  esac
done

echo "#########################################################################"
echo "######   Installing MySQL"
echo "#########################################################################"
echo "procesing..."
sudo yum -y -q --skip-broken install mariadb101u mariadb101u-server mariadb101u-libs mariadb101u-common
#sudo yum -y --skip-broken install mariadb mariadb-server

sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service

sed -i"my.cnf.bak" '12a  ' /etc/my.cnf
sed -i"my.cnf.bak" '13a max_allowed_packet=16M' /etc/my.cnf
sed -i"my.cnf.bak" '14a innodb_lock_wait_timeout=600' /etc/my.cnf
sed -i"my.cnf.bak" '15a  ' /etc/my.cnf

dbpass=$(pwgen -1cnys 24)
echo "#########################################################################"
echo "######   "
echo "###   Password generada de 24bits opcional para password de mysql ->  "$dbpass
echo "######   "
echo "#########################################################################"
sudo touch /root/dbpass.conf
sudo echo $dbpass >> /root/dbpass.conf
sudo mysql_secure_installation

echo "#########################################################################"
echo "######   Installing PHP"
echo "#########################################################################"
echo "procesing..."
sudo yum -y -q --skip-broken install php56u php56u-pdo php56u-dba php56u-gd php56u-imap php56u-ldap php56u-xml php56u-intl php56u-soap php56u-mbstring php56u-pear php56u-mysql php56u-mysqlnd php56u-opcache php56u-fpm-httpd php56u-suhosin php56u-ioncube-loader php56u-mcrypt php56u-pecl-apcu php56u-bcmath php56u-tidy

sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' '/etc/php.ini'
sudo sed -i 's/output_buffering = 4096/output_buffering = On/g' '/etc/php.ini'
sudo sed -i 's/serialize_precision = 17/serialize_precision = -1/g' '/etc/php.ini'
sudo sed -i 's/expose_php = On/expose_php = Off/g' '/etc/php.ini'
sudo sed -i 's/max_execution_time = 30/max_execution_time = 3600/g' '/etc/php.ini'
sudo sed -i 's/max_input_time = 60/max_input_time = 3600/g' '/etc/php.ini'
sudo sed -i 's/; max_input_vars = 1000/max_input_vars = 10000/g' '/etc/php.ini'
sudo sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' '/etc/php.ini'
sudo sed -i 's/error_reporting = E_ALL \& \~E_DEPRECATED \& \~E_STRICT/error_reporting = E_COMPILE_ERROR\|E_RECOVERABLE_ERROR\|E_ERROR\|E_CORE_ERROR/g' '/etc/php.ini'
sudo sed -i 's/log_errors = On/log_errors = Off/g' '/etc/php.ini'
sudo sed -i 's/log_errors_max_len = 1024/log_errors_max_len = 0/g' '/etc/php.ini'
sudo sed -i 's/report_memleaks = On/report_memleaks = Off/g' '/etc/php.ini'
sudo sed -i 's/html_errors = On/html_errors = Off/g' '/etc/php.ini'
sudo sed -i 's/post_max_size = 8M/post_max_size = 256M/g' '/etc/php.ini'
sudo sed -i 's/;always_populate_raw_post_data = -1/always_populate_raw_post_data = -1/g' '/etc/php.ini'
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' '/etc/php.ini'
sudo sed -i 's/default_socket_timeout = 60/default_socket_timeout = 600/g' '/etc/php.ini'
sudo sed -i 's/;date.timezone =/date.timezone = Atlantic\/Canary/g' '/etc/php.ini'
sudo sed -i 's/;date.default_latitude = 31.7667/date.default_latitude = 28.4716/g' '/etc/php.ini'
sudo sed -i 's/;date.default_longitude = 35.2333/date.default_longitude = -16.2472/g' '/etc/php.ini'
sudo sed -i 's/mysql.connect_timeout = 60/mysql.connect_timeout = 600/g' '/etc/php.ini'
sudo sed -i 's/;browscap = extra\/browscap.ini/browscap = \/etc\/extra\/full_php_browscap.ini/g' '/etc/php.ini'
#sudo sed -i 's/session.name = PHPSESSID/session.name = ITOP_SESSID/g' '/etc/php.ini'
sudo sed -i 's/session.gc_divisor = 1000/session.gc_divisor = 500/g' '/etc/php.ini'
sudo sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/g' '/etc/php.ini'
sudo sed -i 's/;mbstring.func_overload = 0/mbstring.func_overload = 0/g' '/etc/php.ini'

echo "#########################################################################"
echo "######   Installing librerias de PEAR"
echo "#########################################################################"
sudo pear upgrade-all
sudo pear install --alldeps Auth_SASL
sudo pear install --alldeps Net_SMTP-1.7.2
sudo pear install --alldeps Net_IDNA2-0.1.1
sudo pear install --alldeps Mail_Mime-1.10.0
sudo pear install --alldeps Mail-1.3.0
sudo pear install --alldeps Net_URL2-2.2.1
sudo pear install --alldeps HTTP_Request2

echo ""
echo "#########################################################################"
echo "######   To install Webmin? [recommended: SI]"
echo "#########################################################################"
select yn in "Yes" "No"; do
  case $yn in
    Yes )
    echo "procesing..."
    sudo rm -Rf /etc/yum.repos.d/webmin.repo
    sudo touch /etc/yum.repos.d/webmin.repo
    sudo echo "[Webmin]" >> /etc/yum.repos.d/webmin.repo
    sudo echo "name=Webmin Distribution Neutral" >> /etc/yum.repos.d/webmin.repo
    sudo echo "#baseurl=http://download.webmin.com/download/yum" >> /etc/yum.repos.d/webmin.repo
    sudo echo "mirrorlist=http://download.webmin.com/download/yum/mirrorlist" >> /etc/yum.repos.d/webmin.repo
    sudo echo "enabled=1" >> /etc/yum.repos.d/webmin.repo
    sudo wget -q http://www.webmin.com/jcameron-key.asc
    sudo rpm --import jcameron-key.asc
    sudo yum -y -q --skip-broken install webmin
    echo ""
    echo "#########################################################################"
    echo "######   Create a new user for Webmin? [recommended: SI]"
    echo "######      NOTE: Root user will not have permissions on webmin"
    echo "######      User: superwebmin"
    echo "######      Pass: superwebmin"
    echo "#########################################################################"
    echo ""
    select yn in "Yes" "No"; do
      case $yn in
        Yes )
        echo "procesing..."
        sudo adduser superwebmin
        sudo passwd superwebmin
        # OLD sudo echo "webmin:x:0:::::::0:0" >> /etc/webmin/miniserv.users
        sudo echo "superwebmin:x:0" >> /etc/webmin/miniserv.users
        sudo echo "superwebmin: acl adsl-client ajaxterm apache at backup-config bacula-backup bandwidth bind8 burner change-user cluster-copy cluster-cron cluster-passwd cluster-shell cluster-software cluster-useradmin cluster-usermin cluster-webmin cpan cron custom dfsadmin dhcpd dovecot exim exports fail2ban fdisk fetchmail file filemin filter firewall firewall6 firewalld fsdump grub heartbeat htaccess-htpasswd idmapd inetd init inittab ipfilter ipfw ipsec iscsi-client iscsi-server iscsi-target iscsi-tgtd jabber krb5 ldap-client ldap-server ldap-useradmin logrotate lpadmin lvm mailboxes mailcap man mon mount mysql net nis openslp package-updates pam pap passwd phpini postfix postgresql ppp-client pptp-client pptp-server proc procmail proftpd qmailadmin quota raid samba sarg sendmail servers shell shorewall shorewall6 smart-status smf software spam squid sshd status stunnel syslog-ng syslog system-status tcpwrappers telnet time tunnel updown useradmin usermin vgetty webalizer webmin webmincron webminlog wuftpd xinetd" >> /etc/webmin/webmin.acl
        break;;
        No ) break;;
      esac
    done
    break;;
    No ) break;;
  esac
done

echo "#########################################################################"
echo "######   To install Workbench community 6.3.9? "
echo "#########################################################################"
select yn in "Yes" "No"; do
  case $yn in
    Yes )
    echo "procesing..."
    sudo yum -y -q --skip-broken install gtkmm30 libzip proj python2-crypto python2-paramiko mysql-connector-odbc libpqxx
    sudo wget -q https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community-6.3.9-1.el7.x86_64.rpm
    sudo rpm -Uvh mysql-workbench-community*.rpm
    sudo rm -Rf mysql-workbench-community*.rpm
    break;;
    No ) break;;
  esac
done

echo "#########################################################################"
echo "######   To install text editor: Atom? "
echo "#########################################################################"
select yn in "Yes" "No"; do
  case $yn in
    Yes )
    echo "procesing..."
    sudo yum -y -q --skip-broken install lsb-core-noarch
    sudo wget -q https://github.com/atom/atom/releases/download/v1.14.3/atom.x86_64.rpm
    sudo rpm -Uvh atom.x86_64.rpm
    sudo rm -Rf atom.x86_64.rpm
    break;;
    No ) break;;
  esac
done

echo "#########################################################################"
echo "######   To install Google Chrome? "
echo "#########################################################################"
select yn in "Yes" "No"; do
  case $yn in
    Yes )
    echo "procesing..."
    sudo rm -Rf /etc/yum.repos.d/google-chrome.repo
    sudo touch /etc/yum.repos.d/google-chrome.repo
    sudo echo "[google-chrome]" >> /etc/yum.repos.d/webmin.repo
    sudo echo "name=google-chrome" >> /etc/yum.repos.d/webmin.repo
    sudo echo 'baseurl=http://dl.google.com/linux/chrome/rpm/stable/$basearch' >> /etc/yum.repos.d/webmin.repo
    sudo echo "enabled=1" >> /etc/yum.repos.d/webmin.repo
    sudo echo "gpgcheck=1" >> /etc/yum.repos.d/webmin.repo
    sudo echo 'gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub' >> /etc/yum.repos.d/webmin.repo
    sudo yum -y -q --skip-broken install google-chrome-stable
    break;;
    No ) break;;
  esac
done

# Conecto java para spoon
#sudo yum -y --skip-broken install mysql-connector-java

echo ""
echo "#########################################################################"
echo "######   Desactivar Firewalld e instalar IPtables? [recommended: YES]"
echo "#########################################################################"
echo ""
select yn in "Yes" "No"; do
  case $yn in
    Yes )
    echo "procesing..."
    sudo systemctl mask firewalld
    sudo systemctl stop firewalld
    sudo yum -y -q remove firewalld
    sudo yum -y -q --skip-broken install iptables-services
    sudo systemctl enable iptables
    sudo service iptables stop
    sudo service iptables start
    break;;
    No )
    #Abrir puertos del firewalld
    echo "#########################################################################"
    echo "######   Abriendo puertos"
    echo "#########################################################################"
    echo "procesing..."
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

echo "#########################################################################"
echo "######   To install Composer? "
echo "#########################################################################"
select yn in "Yes" "No"; do
  case $yn in
    Yes )
    echo "procesing..."
    sudo mkdir /usr/share/composer
    sudo mv -f compos.sh /usr/share/composer
    sudo chmod 0700 /usr/share/composer/compos.sh
    sudo sh /usr/share/composer/compos.sh
    break;;
    No ) break;;
  esac
done

echo ""
echo "#########################################################################"
echo "######   Completing installation...
echo "#########################################################################"
echo "procesing..."

sudo chown apache:apache /etc/extra/full_php_browscap.ini

sudo systemctl stop httpd.service
sudo systemctl stop mariadb.service
sudo service webmin stop
sudo systemctl start httpd.service
sudo systemctl start mariadb.service
sudo service webmin start

echo "Deleting unnecessary files in: "$usuarioActual
if [ $usuarioActual == "root" ];then
  sudo rm -Rf /root/server/
else
  sudo rm -Rf /home/$usuarioActual/server/
fi

#echo "What version do you want to install? "
#select yn in "Stable" "Developer"; do
#  case $yn in
#    Stable )
#sudo git clone -b stable https://github.com/YetiForceCompany/YetiForceCRM.git /var/www/html/
#sudo chown -hR apache:apache /var/www/html/
#      break;;
#    Developer )
#sudo git clone -b developer https://github.com/YetiForceCompany/YetiForceCRM.git /var/www/html/
#sudo chown -hR apache:apache /var/www/html/
#      break;;
#  esac
#done

echo ""
echo "#########################################################################"
echo "######   Access webmin by 'https://localhost:10000'"
echo "#########################################################################"

echo ""
echo "/////////////////////////////////////////////////////////////////////////"
echo "/////////////////// The script completed successfully ///////////////////"
echo "/////////////////////////////////////////////////////////////////////////"
echo ""
