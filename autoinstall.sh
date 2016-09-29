SELINUXCONFIGFILE='/etc/selinux/config'

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' $SELINUXCONFIGFILE
sed -i 's/SELINUX=permissive/SELINUX=disabled/g' $SELINUXCONFIGFILE
setenforce 0
cat $SELINUXCONFIGFILE | grep '^SELINUX='

#setsebool -P httpd_can_network_connect 1
#setsebool -P httpd_can_network_connect_db 1
#semanage fcontext -a -t httpd_sys_rw_content_t 'csrf-magic'
#restorecon -v 'csrf-magic'
#setsebool -P httpd_unified 1
#setsebool -P polyinstantiation_enabled 1

echo ""
#Install IUS y EPEL
yum -q clean all
yum -q -y install epel-release pwgen git touch 
yum -q -y upgrade
wget -q https://centos7.iuscommunity.org/ius-release.rpm
sudo rpm -q -Uvh ius-release*.rpm
rm -Rf ius-release.rpm
#Install APACHE
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
#Install MySQL
yum -q -y install mariadb-server mariadb mariadb-libs
systemctl start mariadb.service
systemctl enable mariadb.service
dbpass=$(pwgen -1cnys 24)
echo ""
echo "////////////////////////////////////////////////////"
echo ""
echo "Password generada de 24bits opcional para password de mysql:  "$dbpass
echo ""
echo "////////////////////////////////////////////////////"
echo ""
mysql_secure_installation
#Install PHP 5.6
yum -q -y install php56u php56u-pdo php56u-gd php56u-imap php56u-ldap php56u-xml php56u-intl php56u-soap php56u-mbstring php56u-pear php56u-mysql
systemctl restart httpd.service
systemctl enable httpd.service
#Install PEAR library
pear install Auth_SASL
pear install Net_SMTP-1.7.2
pear install Net_IDNA2-0.1.1
pear install Mail_Mime-1.10.0
pear install Mail-1.3.0
pear install Net_URL2-2.2.1
pear install HTTP_Request2
#Install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
rm -Rf composer-setup.php
mkdir /usr/local/bin/composer
mv composer.phar /usr/local/bin/composer/
cd /usr/local/bin/composer/
touch composer.json
echo "{}" >> composer.json
php composer.phar install
echo "Instalación finalizada"
