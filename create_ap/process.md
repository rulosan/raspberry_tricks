
* Primero se instala tanto el isc-dhcp-server y hostapd

```

sudo apt-get install hostapd isc-dhcp-server

```

* Luego vamos a configurar el DHCP Server de manera básica.

```

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

```

