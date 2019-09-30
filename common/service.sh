#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode
until [[ $(getprop sys.boot_completed) = 1 ]] && [[ $(getprop dev.bootcomplete) = 1 ]] && [[ $(getprop service.bootanim.exit) = 1 ]] && [[ $(getprop init.svc.bootanim) = stopped ]] || [[ ${COUNT} -eq 240 ]]; do
    sleep 5
    ((++COUNT))
done

sleep 5

$MODDIR/system/xbin/smartdns -c $MODDIR/config/smartdns.conf -p $MODDIR/smartdns.pid
iptables -t nat -I OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 5335
iptables -t nat -I OUTPUT -p udp -m owner --uid-owner 0 --dport 53 -j ACCEPT
iptables -t nat -I POSTROUTING -p udp -d 127.0.0.1 --dport 5335 -j SNAT --to-source 127.0.0.1
iptables -I INPUT -p tcp -d 119.29.29.29 -m tcp --dport 80 -j REJECT --reject-with tcp-reset
iptables -I INPUT -p tcp -d 180.76.76.200 -m tcp --dport 80 -j REJECT --reject-with tcp-reset
iptables -I INPUT -p tcp -d 180.76.76.200 -m tcp --dport 443 -j REJECT --reject-with tcp-reset
iptables -I INPUT -p tcp -m tcp --tcp-flags SYN,RST,URG ACK,FIN,PSH --sport 80 -j DROP

while true;do
	setprop net.dns1=127.0.0.1
	sleep 300
done