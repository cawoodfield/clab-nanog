/usr/bin/sleep 2
/usr/bin/echo root:root | chpasswd
/usr/sbin/ip address add 10.100.0.2/24 dev eth1
/usr/sbin/ip address add 2001:db8:10:100::2/64 dev eth1
/usr/sbin/ip route add 10.0.0.0/8 via 10.100.0.1 dev eth1
/usr/sbin/ip route add 192.168.0.0/24 via 10.100.0.1 dev eth1
/usr/sbin/ip route add 2001:db8::/32 via 2001:db8:10:100::1 dev eth1
