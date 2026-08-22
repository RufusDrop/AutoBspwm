#!/bin/sh

IFACE=$(/usr/sbin/ifconfig | grep tun0 | awk '{print $1}' | tr -d ':')

if [ "$IFACE" = "tun0" ]; then
	echo "%{F#E04468}VPN %{F#F4EDF6}$(/usr/sbin/ifconfig tun0 | grep "inet " | awk '{print $2}')%{u-}"
else
	echo "%{F#E04468}VPN%{u-} %{F#F4EDF6}Disconnected"
fi
