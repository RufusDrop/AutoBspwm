#!/bin/sh

ip_target=$(cat ~/.config/bin/target | awk '{print $1}')
name_target=$(cat ~/.config/bin/target | awk '{print $2}')

if [ $ip_target ] && [ $name_target ]; then
	echo "%{F#62A0EA}什%{F#D9E7FF} $ip_target - $name_target"
elif [ $(cat ~/.config/bin/target | wc -w) -eq 1 ]; then
	echo "%{F#62A0EA}什%{F#D9E7FF} $ip_target"
else
	echo "%{F#62A0EA}ﲅ %{u-}%{F#D9E7FF} No target"
fi

