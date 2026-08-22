#!/bin/sh

echo "%{F#88C0D0} %{F#ECEFF4}$(/usr/sbin/ifconfig eth0 | grep "inet " | awk '{print $2}')%{u-}"
