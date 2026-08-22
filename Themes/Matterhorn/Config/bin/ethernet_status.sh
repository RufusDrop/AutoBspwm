#!/bin/sh

echo "%{F#62A0EA} %{F#D9E7FF}$(/usr/sbin/ifconfig eth0 | grep "inet " | awk '{print $2}')%{u-}"
