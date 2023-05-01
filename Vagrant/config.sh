#!/usr/bin/env bash
set -eo pipefail


cd /home/vagrant && curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x /home/vagrant/openvpn-install.sh
chmod +x /home/vagrant/openvpn-client/client.sh

export APPROVE_INSTALL=y
export APPROVE_IP=y
export IPV6_SUPPORT=n
export PORT_CHOICE=1
export PROTOCOL_CHOICE=1
export DNS=1
export COMPRESSION_ENABLED=n
export CUSTOMIZE_ENC=n
export CLIENT=clientname
export PASS=1

# Start install script
/home/vagrant/openvpn-install.sh

# Make directory 
mkdir /etc/openvpn/ccd/template
cp -r /home/vagrant/openvpn-client/template /etc/openvpn/ccd