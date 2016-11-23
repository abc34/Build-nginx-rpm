#!/bin/bash

CENTVER="7"
NGINX="nginx-1.11.6"
#OPENSSL="openssl-1.1.0c"
PCRE="8.39"
ZLIB="zlib-1.2.8"
B_DIR="$PWD/build"



#stopping rockstor service
#service rockstor stop

sudo mkdir -p $B_DIR && sudo rm -rf $B_DIR/* && sudo chown -R $USER "$B_DIR"

sudo yum clean all; sudo yum upgrade -y
sudo yum -y groupinstall 'Development Tools'
sudo yum -y install wget cmake go; #libxml2-devel libxslt-devel gd-devel zlib-devel perl-ExtUtils-Embed GeoIP-devel
  
sudo useradd builder
sudo groupadd builder

# nginx
cd $B_DIR && rpm -ivh --define "_topdir $B_DIR/rpmbuild" http://nginx.org/packages/mainline/centos/$CENTVER/SRPMS/$NGINX-1.el$CENTVER.ngx.src.rpm
# BoringSSL
cd "$B_DIR" && git clone "https://boringssl.googlesource.com/boringssl" "boringssl"
mkdir -p "boringssl/build" && cd "boringssl/build"
cmake -DCMAKE_BUILD_TYPE=Release ../ && make
mkdir -p "$B_DIR/boringssl/.openssl/lib"
cd "$B_DIR/boringssl/.openssl" && ln -s ../include
cd "$B_DIR/boringssl" && cp "build/crypto/libcrypto.a" "build/ssl/libssl.a" ".openssl/lib"
# pcre
cd "$B_DIR" && wget https://sourceforge.net/projects/pcre/files/pcre/$PCRE/pcre-$PCRE.tar.gz && tar -zxvf pcre-$PCRE.tar.gz
# zlib
cd "$B_DIR" && wget http://zlib.net/$ZLIB.tar.gz && tar -zxvf $ZLIB.tar.gz

mkdir -p $B_DIR/modules
# Google Brotli module
#cd $B_DIR/modules && git clone "https://github.com/google/ngx_brotli"
# OpenResty Headers More module
cd $B_DIR/modules && git clone "https://github.com/openresty/headers-more-nginx-module"


echo "Edit nginx.spec file..."
sed -i "s|^Source0: http|Source0: https|g" $B_DIR/rpmbuild/SPECS/nginx.spec
sed -i "s|^Requires: openssl|#Requires: openssl|g" $B_DIR/rpmbuild/SPECS/nginx.spec
sed -i "s|^BuildRequires: openssl-devel|#BuildRequires: openssl-devel|g" $B_DIR/rpmbuild/SPECS/nginx.spec
sed -i "s|^BuildRequires: pcre-devel|#BuildRequires: pcre-devel|g" $B_DIR/rpmbuild/SPECS/nginx.spec
sed -i "s|^BuildRequires: zlib-devel|#BuildRequires: zlib-devel|g" $B_DIR/rpmbuild/SPECS/nginx.spec
sed -i "s|--with-http_ssl_module|--with-http_ssl_module --with-openssl=$B_DIR/boringssl|g" $B_DIR/rpmbuild/SPECS/nginx.spec
sed -i "s|--with-http_ssl_module|--with-http_ssl_module --with-pcre=$B_DIR/pcre-$PCRE --with-pcre-jit|g" $B_DIR/rpmbuild/SPECS/nginx.spec
sed -i "s|--with-http_ssl_module|--with-http_ssl_module --with-zlib=$B_DIR/$ZLIB|g" $B_DIR/rpmbuild/SPECS/nginx.spec
sed -i "s|--with-http_ssl_module|--with-http_ssl_module --add-module=$B_DIR/modules/headers-more-nginx-module|g" $B_DIR/rpmbuild/SPECS/nginx.spec
sed -i "s|--with-cc-opt=\"%{WITH_CC_OPT}\"|--with-cc-opt=\"%{WITH_CC_OPT} -Wno-deprecated-declarations\"|g" $B_DIR/rpmbuild/SPECS/nginx.spec
sed -i "s|^make %{?_smp_mflags}|touch $B_DIR/boringssl/.openssl/include/openssl/ssl.h \&\& make %{?_smp_mflags}|g" $B_DIR/rpmbuild/SPECS/nginx.spec
echo "Done."

rpmbuild -bb --define "_topdir $B_DIR/rpmbuild" $B_DIR/rpmbuild/SPECS/nginx.spec

echo "To install or update "
echo "    rpm -Uvh --force $B_DIR/rpmbuild/RPMS/x86_64/$NGINX-1.el$CENTVER.centos.ngx.x86_64.rpm"
sudo rpm -Uvh --force $B_DIR/rpmbuild/RPMS/x86_64/$NGINX-1.el$CENTVER.centos.ngx.x86_64.rpm

#starting rockstor service
#service rockstor start
