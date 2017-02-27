echo "/////////////////////////////////////////////////////////////////////////"
echo "/////////////////// Starting script, waiting please /////////////////////"
echo "/////////////////////////////////////////////////////////////////////////"
echo ""
usuarioActual=$(whoami)
sudo yum -y -q --skip-broken remove mariadb* httpd* php* mysql*
echo ""
echo "#########################################################################"
echo "######   Checking SElinux"
echo "#########################################################################"
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
  echo "######   NOTE: Once restarted, start the script again"
  echo "#########################################################################"
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
fi
echo ""
echo "#########################################################################"
echo "######   Installing IUS, EPEL"
echo "#########################################################################"
echo "procesing..."
sudo yum -y -q --skip-broken install epel-release
sudo wget -q https://centos7.iuscommunity.org/ius-release.rpm
sudo rpm -Uvh ius-release*.rpm
sudo rm -Rf ius-release.rpm
sudo yum clean all
sudo yum -y --skip-broken upgrade
sudo yum -y -q --skip-broken install pwgen iftop
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
echo ""
echo "#########################################################################"
echo "######   To install HTTPS?"
echo "#########################################################################"
select yn in "Yes" "No"; do
  case $yn in
    Yes )
    echo "procesing..."
    sudo yum -y -q --skip-broken install httpd24u-mod_security2 httpd24u-mod_ssl
    #https://mozilla.github.io/server-side-tls/ssl-config-generator/
    sudo sed -i 's/SSLProtocol all -SSLv2/SSLProtocol all -SSLv2 -TLSv1 -TLSv1.1/g' '/etc/httpd/conf.d/ssl.conf'
    sudo sed -i 's/SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5/SSLCipherSuite ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256/g' '/etc/httpd/conf.d/ssl.conf'
    sudo sed -i 's/#SSLHonorCipherOrder on/SSLHonorCipherOrder on/g' '/etc/httpd/conf.d/ssl.conf'
    sudo sed -i 's/;session.cookie_secure =/session.cookie_secure = 1/g' '/etc/php.ini'
    break;;
    No ) break;;
  esac
done
echo ""
echo "#########################################################################"
echo "######   Installing MySQL"
echo "#########################################################################"
echo "procesing..."
sudo yum -y -q --skip-broken install mariadb101u mariadb101u-server mariadb101u-libs mariadb101u-common
sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service
sed -i"my.cnf.bak" '12a  ' /etc/my.cnf
sed -i"my.cnf.bak" '13a max_allowed_packet=16M' /etc/my.cnf
sed -i"my.cnf.bak" '14a innodb_lock_wait_timeout=600' /etc/my.cnf
sed -i"my.cnf.bak" '15a  ' /etc/my.cnf
dbpass=$(pwgen -1cnys 24)
echo ""
echo "#########################################################################"
echo "######   "
echo "###   Password generada de 24bits opcional para password de mysql ->  "$dbpass
echo "######   "
echo "#########################################################################"
if [ $usuarioActual == "root" ];then
  sudo touch /root/dbpass.conf
  sudo echo $dbpass >> /root/dbpass.conf
else
  sudo touch /home/$usuarioActual/dbpass.conf
  sudo echo $dbpass >> /home/$usuarioActual/dbpass.conf
fi
sudo mysql_secure_installation
echo ""
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
sudo sed -i 's/;error_log = syslog/error_log = \/var\/log\/php-fpm\/php_error_log/g' '/etc/php.ini'
sudo sed -i 's/post_max_size = 8M/post_max_size = 256M/g' '/etc/php.ini'
sudo sed -i 's/;always_populate_raw_post_data = -1/always_populate_raw_post_data = -1/g' '/etc/php.ini'
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g' '/etc/php.ini'
sudo sed -i 's/default_socket_timeout = 60/default_socket_timeout = 600/g' '/etc/php.ini'
sudo sed -i 's/;date.timezone =/date.timezone = Atlantic\/Canary/g' '/etc/php.ini'
sudo sed -i 's/;date.default_latitude = 31.7667/date.default_latitude = 28.4716/g' '/etc/php.ini'
sudo sed -i 's/;date.default_longitude = 35.2333/date.default_longitude = -16.2472/g' '/etc/php.ini'
sudo sed -i 's/mysql.connect_timeout = 60/mysql.connect_timeout = 600/g' '/etc/php.ini'
sudo sed -i 's/;browscap = extra\/browscap.ini/browscap = \/etc\/extra\/full_php_browscap.ini/g' '/etc/php.ini'
sudo sed -i 's/session.gc_divisor = 1000/session.gc_divisor = 500/g' '/etc/php.ini'
sudo sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/g' '/etc/php.ini'
sudo sed -i 's/;mbstring.func_overload = 0/mbstring.func_overload = 0/g' '/etc/php.ini'
echo "#########################################################################"
echo "######   Installing librerias de PEAR"
echo "#########################################################################"
echo "procesing..."
sudo pear upgrade-all
sudo pear install --alldeps Auth_SASL
sudo pear install --alldeps Net_SMTP-1.7.3
sudo pear install --alldeps Net_IDNA2-0.1.1
sudo pear install --alldeps Mail_Mime-1.10.0
echo ""
echo "#########################################################################"
echo "######   Desactivar Firewalld e instalar IPtables?"
echo "#########################################################################"
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
echo ""
echo "#########################################################################"
echo "######   Completing installation..."
echo "#########################################################################"
echo "procesing..."
sudo chown apache:apache /etc/extra/full_php_browscap.ini
echo "Stopping and starting services to apply changes..."
sudo systemctl stop httpd.service
sudo systemctl stop mariadb.service
sudo systemctl start httpd.service
sudo systemctl start mariadb.service
echo ""
echo "#########################################################################"
echo "######   What version do you want to install from YetiForceCRM?"
echo "#########################################################################"
select yn in "Stable" "Developer" "Nothing"; do
  case $yn in
    Stable )
    echo "procesing..."
    sudo git clone -b stable https://github.com/YetiForceCompany/YetiForceCRM.git /var/www/html/
    sudo chown -hR apache:apache /var/www/html/
    break;;
    Developer )
    echo "procesing..."
    sudo git clone -b developer https://github.com/YetiForceCompany/YetiForceCRM.git /var/www/html/
    sudo chown -hR apache:apache /var/www/html/
    break;;
    Nothing )
    break;;
  esac
done
echo "Deleting unnecessary files in: "$usuarioActual
echo ""
echo "/////////////////////////////////////////////////////////////////////////"
echo "/////////////////// The script completed successfully ///////////////////"
echo "/////////////////////////////////////////////////////////////////////////"
echo ""
if [ $usuarioActual == "root" ];then
  sudo rm -Rf /root/server/
else
  sudo rm -Rf /home/$usuarioActual/server/
fi
