# Update-Rockstor-nginx
Update to nginx-1.11.6 with openssl-1.1.0c
```
service rockstor stop
rpm -Uvh --force nginx-1.11.6-1.el7.ngx.x86_64.rpm
service rockstor start
```
Tested on Rockstor 3.8.15.
