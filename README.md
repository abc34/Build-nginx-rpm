# Update-Rockstor-nginx
Update to nginx-1.11.6 with
- openssl-1.1.0c, pcre-8.39, zlib-1.2.8
- ngx-brotli module
- headers-more-nginx-module
- nginx-dav-ext-module

Install command:
```
service rockstor stop
rpm -Uvh --force nginx-1.11.6-1.el7.centos.ngx.x86_64.rpm
service rockstor start
```

Build command:
```
bash build.sh
```

Tested on CentOS 7.2.1511-Minimal (build and update) and Rockstor 3.8.15 (only update).

Not done:
 - nginx directive `listen 443 ssl http2 default_server;` not persistent.<br/>
After reboot `ssl http2` disappear.<br/>
See source [services.py](https://github.com/rockstor/rockstor-core/blob/3.8.15/src/rockstor/system/services.py).
 - Workaround:  
 `listen 443 default_server`  
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
   `ssl http2;`

Resources:
 - https://github.com/ajhaydock/BoringNginx
 - https://github.com/Wonderfall/dockerfiles/tree/master/boring-nginx
 

