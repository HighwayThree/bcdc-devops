#!/bin/bash
# KF 2016/01/21:  Add datapusher details, modify ckan version

CKAN_VERSION=master
JDK_VERSION=7u79
PY_VERSION=2.7.12
SOLR_VERSION=4.10.3
REDIS_VERSION=3.2.4

echo "Installing CKAN version: $CKAN_VERSION"

# Install and activate the Extra Packages for Enterprise Linux (EPEL) Repository
rpm -Uvh https://dl.fedoraproject.org/pub/epel/6Server/x86_64/epel-release-6-8.noarch.rpm
yum -y install gcc gcc-c++ make xalan-j2 unzip libxslt libxslt-devel libxml2 libxml2-devel zlib zlib-devel wget openssl openssl-devel xml-commons git subversion pcre perl pcre-devel zlib zlib-devel GeoIP GeoIP-devel lsof httpd-devel sqlite-devel geos-devel nodejs npm tcl
yum -y update
wget -O /tmp/curl-7.36.0.tar.bz2 http://curl.haxx.se/download/curl-7.36.0.tar.bz2
tar -xvf /tmp/curl-7.36.0.tar.bz2 -C /tmp
cd /tmp/curl-7.36.0
./configure && make && make install
wget -O /tmp/postgres-9.1.13-1.x86_64.openscg.rpm http://oscg-downloads.s3.amazonaws.com/packages/postgres-9.1.13-1.x86_64.openscg.rpm
yum -y localinstall /tmp/postgres-9.1.13-1.x86_64.openscg.rpm
ln -s /opt/postgres/9.1 /usr/pgsql-9.1

# Install JDK7
wget -O /tmp/jdk-7u79-linux-x64.rpm --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm"
yum -y localinstall /tmp/jdk-7u79-linux-x64.rpm

# Install Solr
wget -O /tmp/solr-4.10.3.tgz http://archive.apache.org/dist/lucene/solr/4.10.3/solr-4.10.3.tgz
tar -xvf /tmp/solr-4.10.3.tgz -C /apps
chown -R vagrant /apps/solr-4.10.3
ln -s /apps/solr-4.10.3 /apps/solr

# Install Python
wget -O /tmp/Python-2.7.12.tgz https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz
wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
tar -xvf /tmp/Python-2.7.12.tgz -C /tmp
cd /tmp/Python-2.7.12
./configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-L/usr/pgsql-9.1/lib,-rpath /usr/local/lib"
make && make altinstall
/usr/local/bin/python2.7 /tmp/get-pip.py
/usr/local/bin/pip2.7 install virtualenv
/usr/local/bin/pip2.7 install uwsgi

# Install Redis
wget -O /tmp/redis-3.2.4.tar.gz http://download.redis.io/releases/redis-3.2.4.tar.gz
tar -xzvf /tmp/redis-3.2.4.tar.gz -C /tmp
cd /tmp/redis-3.2.4
make test
make && make install
PORT=6379
CONFIG_FILE=/etc/redis/6379.conf
LOG_FILE=/var/log/redis_6379.log
DATA_DIR=/var/lib/redis/6379
EXECUTABLE=/usr/local/bin/redis-server
echo -e \
  "${PORT}\n${CONFIG_FILE}\n${LOG_FILE}\n${DATA_DIR}\n${EXECUTABLE}\n" | \
  ./utils/install_server.sh

# END of OS provisioning
echo "OS is now ready for Installing CKAN $CKAN_VERSION"
echo "login using 'vagrant ssh'"
