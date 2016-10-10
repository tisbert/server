SELINUXCONFIGFILE='/etc/selinux/config'

sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' $SELINUXCONFIGFILE
sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/g' $SELINUXCONFIGFILE
sudo setenforce 0
sudo cat $SELINUXCONFIGFILE | grep '^SELINUX='

#setsebool -P httpd_can_network_connect 1
#setsebool -P httpd_can_network_connect_db 1
#semanage fcontext -a -t httpd_sys_rw_content_t 'csrf-magic'
#restorecon -v 'csrf-magic'
#setsebool -P httpd_unified 1
#setsebool -P polyinstantiation_enabled 1

#Install IUS y EPEL
sudo yum clean all
sudo yum -y install epel-release pwgen git touch 
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

#
yum -y install libpcap iftop

#
yum -y install open-vm-tools

#Install APACHE
sudo yum -y install httpd
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

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
