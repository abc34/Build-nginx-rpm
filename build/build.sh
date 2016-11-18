#!/bin/bash

CENTVER="7"
OPENSSL="openssl-1.1.0c"
NGINX="nginx-1.11.6"

OPT_DIR="/opt/lib"

#stop rockstor service
service rockstor stop

yum clean all
# Install epel packages (required for GeoIP-devel)
yum -y install http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y groupinstall 'Development Tools'
yum -y install wget openssl-devel pcre-devel libxml2-devel libxslt-devel gd-devel zlib-devel perl-ExtUtils-Embed GeoIP-devel
  
useradd builder
groupadd builder

rm -r $OPT_DIR
mkdir -p $OPT_DIR

# Untar, but don't compile openssl to /opt/lib
wget https://www.openssl.org/source/$OPENSSL.tar.gz -O $OPT_DIR/$OPENSSL.tar.gz
tar -zxvf $OPT_DIR/open* -C $OPT_DIR

# Build source nginx (no auto-updates), statically link to /opt/lib/openssl* (no OS effects)
rpm -ivh http://nginx.org/packages/mainline/centos/$CENTVER/SRPMS/$NGINX-1.el$CENTVER.ngx.src.rpm

echo "Edit or replace nginx.spec file to new one and run command"
echo "    rpmbuild -ba ~/rpmbuild/SPECS/nginx.spec"
cp -f nginx.spec ~/rpmbuild/SPECS/nginx.spec
sed -i "s|--with-http_ssl_module|--with-http_ssl_module --with-openssl=$OPT_DIR/$OPENSSL|g" ~/rpmbuild/SPECS/nginx.spec
rpmbuild -ba ~/rpmbuild/SPECS/nginx.spec
echo "To update "
echo "    rpm -Uvh --force ~/rpmbuild/RPMS/x86_64/$NGINX-1.el$CENTVER.ngx.x86_64.rpm"
rpm -Uvh --force ~/rpmbuild/RPMS/x86_64/$NGINX-1.el$CENTVER.ngx.x86_64.rpm
echo "After update start rockstor service:"
echo "    service rockstor start"
service rockstor start
