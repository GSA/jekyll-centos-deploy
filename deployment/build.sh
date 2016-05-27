#!/bin/bash

set -e

# pick unique name for your app, and a good secret for webhook 
APPNAME=myjekyll
SECRET=abcdefghijk

# yum install necessary packages
yum update -y
yum install -y httpd python-setuptools
yum -y groupinstall "Development Tools"

# install supervisord and gt conf files
easy_install https://pypi.python.org/packages/source/p/pip/pip-1.3.1.tar.gz
pip install supervisor
curl -Lo /etc/supervisord.conf \
    https://github.com/GSA/jekyll-centos-deploy/raw/master/deployment/etc/supervisord.conf
curl -Lo /etc/init/supervisor.conf \
    https://github.com/GSA/jekyll-centos-deploy/raw/master/deployment/etc/init/supervisor.conf

# install ryby 2.3.0 and jekyll gems
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm reload
rvm install 2.3.0
rvm use 2.3.0@$APPNAME --create
gem install jekyll jekyll-rebuilder


cd /var/www
git clone https://github.com/GSA/jekyll-centos-deploy.git
mv jekyll-centos-deploy $APPNAME
rm -rf html && ln -s $APPNAME/_site html
cd /var/www/$APPNAME
jekyll build
# make things easier to use the rvm
echo "rvm use 2.3.0@$APPNAME" > .rvmrc
export rvm_ignore_gemsets_flag=1
echo "rvm_ignore_gemsets_flag=1" >> /root/.rvmrc

cat <<EOF >> /etc/httpd/conf/httpd.conf
RewriteEngine on
ProxyPreserveHost On
RewriteRule ^/webhook/_APPNAME_PLACEHOLDER_/(.*) http://localhost:8000/\$1 [P]
<Proxy *>
    Order deny,allow
    Allow from all
    Allow from localhost
</Proxy>
EOF

# customize configs
sed -i -e "s/_APPNAME_PLACEHOLDER_/$APPNAME/g" /etc/supervisord.conf
sed -i -e "s/_SECRET_PLACEHOLDER_/$SECRET/g" /etc/supervisord.conf
sed -i -e "s/_APPNAME_PLACEHOLDER_/$APPNAME/g" /etc/httpd/conf/httpd.conf

# start the engine
chkconfig --level 2345 httpd on
service httpd start
initctl start supervisor

# dont let iptables gets in the way on a test box
chkconfig --level 2345 iptables off
service iptables stop
setsebool -P httpd_can_network_connect 1
