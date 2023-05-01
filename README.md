# Openvpn-client
Add client via openvpn-client.sh script.

# Install openvpn:
https://github.com/angristan/openvpn-install

## Template 
First you must config this template!
```cmd
root# ❯ /etc/openvpn/ccd/template# ls -al
total 24
drwxr-xr-x 2 root root 4096 Feb 20 08:36 .
drwxr-xr-x 3 root root 4096 Feb 20 08:35 ..
-rw-r--r-- 1 root root   41 Feb 20 08:37 admin-table
-rw-r--r-- 1 root root  392 Feb 20 08:37 admin-template
-rw-r--r-- 1 root root 1847 Feb 20 08:37 client-table
-rw-r--r-- 1 root root  164 Feb 20 08:35 node-table
-rw-r--r-- 1 root root    0 Feb 20 08:36 node-template
```
## Usage
```cmd
./client.sh
```
E.g. output:
```cmd
root# ❯ ./client.sh 
1) Create client with default expiration date
2) Create client with custom expiration date
3) List all clients
4) Quit
Please enter your choice: 
```
