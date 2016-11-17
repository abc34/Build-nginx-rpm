# Update-Rockstor-nginx
Update to nginx-1.11.6 with openssl-1.1.0c:
```
service rockstor stop
rpm -Uvh --force nginx-1.11.6-1.el7.ngx.x86_64.rpm
service rockstor start
```
Tested on Rockstor 3.8.15.

Not done:
 - Not persistent `listen 443 ssl http2 default_config;` nginx configuration directive.
After reboot `ssl http2` disappear.
See source https://github.com/rockstor/rockstor-core/blob/3.8.15/src/rockstor/system/services.py.

