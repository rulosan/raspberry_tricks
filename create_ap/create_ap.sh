#!/bin/bash

sudo apt-get install hostapad isc-dhcp-server

#########################################################################
#   Configuramos y activamos el servidor de DHCP con los rangos de red  #
#   de las ips que va estar repartiendo                                 #
#########################################################################

sudo cat << __EOT__ >  /etc/dhcp/dhcpd.conf
ddns-update-style none;
default-lease-time 600;
max-lease-time 7200;
authoritative;
log-facility local7;
subnet 192.168.50.0 netmask 255.255.255.0 {
	range 192.168.50.10 192.168.50.50;
	option broadcast-address 192.168.50.255;
	option routers 192.168.50.1;
	default-lease-time 600;
	max-lease-time 7200;
	option domain-name "local";
	option domain-name-servers 8.8.8.8;
}
__EOT__

# Activacion del dhcp server

sudo cat << __EOT__ > /etc/default/isc-dhcp-server
# Path to dhcpd's config file (default: /etc/dhcp/dhcpd.conf).
#DHCPD_CONF=/etc/dhcp/dhcpd.conf

# Path to dhcpd's PID file (default: /var/run/dhcpd.pid).
#DHCPD_PID=/var/run/dhcpd.pid

# Additional options to start dhcpd with.
#	Don't use options -cf or -pf here; use DHCPD_CONF/ DHCPD_PID instead
#OPTIONS=""

# On what interfaces should the DHCP server (dhcpd) serve DHCP requests?
#	Separate multiple interfaces with spaces, e.g. "eth0 eth1".
INTERFACES="wlan1"
__EOT__


#########################################################################
#   Configuramos de manera estatica el ip de la tarjeta inalambrica     #
#########################################################################

sudo ifconfig wlan1 down
sudo ifconfig wlan1 192.168.50.1

sudo cat << __EOT__ > /etc/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

iface eth0 inet manual

allow-hotplug wlan0
iface wlan0 inet manual
#    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

allow-hotplug wlan1
iface wlan1 inet static
	address 192.168.50.1
	netmask 255.255.255.0

#iface wlan1 inet manual
#    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

up iptables-restore < /etc/iptables.ipv4.nat
__EOT__


#########################################################################
#   Configuramos hostapd para poder generar el access point             #
#########################################################################

sudo cat << __EOT__ > /etc/hostapd/hostapd.conf
interface=wlan1
driver=nl80211

#driver=rtl871xdrv
#driver=nl80211
#ieee80211n=1 

ssid=.:: Starbucks ::.
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0

#wpa=2
#wpa_passphrase=w3lcom3H4ck3rs
#wpa_key_mgmt=WPA-PSK
#wpa_pairwise=TKIP
#rsn_pairwise=CCMP
__EOT__

sudo cat << __EOT__ > /etc/default/hostapd
# Defaults for hostapd initscript
#
# See /usr/share/doc/hostapd/README.Debian for information about alternative
# methods of managing hostapd.
#
# Uncomment and set DAEMON_CONF to the absolute path of a hostapd configuration
# file and hostapd will be started during system boot. An example configuration
# file can be found at /usr/share/doc/hostapd/examples/hostapd.conf.gz
#
DAEMON_CONF="/etc/hostapd/hostapd.conf"

# Additional daemon options to be appended to hostapd command:-
# 	-d   show more debug messages (-dd for even more)
# 	-K   include key data in debug messages
# 	-t   include timestamps in some debug messages
#
# Note that -B (daemon mode) and -P (pidfile) options are automatically
# configured by the init.d script and must not be added to DAEMON_OPTS.
#
#DAEMON_OPTS="-d"
__EOT__

#########################################################################
#   Configuramos iptables y la redireccion de paquetes                  #
#########################################################################


sudo cat /etc/sysctl.conf | sed -e 's/net.ipv4.ip_forward=0/net.ipv4.ip_forward=1/g' > /etc/sysctl.conf

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"


sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan1 -o eth0 -j ACCEPT

sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

sudo service isc-dhcp-server start
sudo service hostapd start

sudo update-rc.d hostapd defaults
sudo update-rc.d isc-dhcp-server defaults

