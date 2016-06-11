#!/usr/bin/env bash
# Pi-hole: A black hole for Internet advertisements
# (c) 2015, 2016 by Jacob Salmela
# Network-wide ad blocking via your Raspberry Pi
# http://pi-hole.net
# Pauses and resumes Pi-hole ad blocking
#
# Pi-hole is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version

#rootcheck
if [[ $EUID -eq 0 ]];then
	echo "::: You are root."
else
	echo "::: sudo will be used."
	# Check if it is actually installed
	# If it isn't, exit because the install cannot complete
	if [[ $(dpkg-query -s sudo) ]];then
		export SUDO="sudo"
	else
		echo "::: Please install sudo or run this script as root."
		exit 1
	fi
fi

# The addn-hosts option in the dnsmasq config file points to the list of domains to block
# By commenting this option out, all queries will get forwarded to the upstream DNS server
# This allows Pi-hole to still log the queries but not block anything (because it doesn't have a list to check)
# We use sed to comment/uncomment this option and then simply reload dnsmasq so it reads the config file.
grep '^addn\-hosts' /etc/dnsmasq.d/01-pihole.conf

# If the command was successful, Pi-hole was blocking so we need pause it by commenting out the option
if [[ $? -eq 0 ]];then
	echo "Pausing Pi-hole..."
	$SUDO sed -i 's/^addn-hosts/#addn-hosts/' /etc/dnsmasq.d/01-pihole.conf
	$SUDO service dnsmasq restart
else
	# If it was unsuccessful, we should re-enable Pi-hole by uncommenting it
	echo "Resuming Pi-hole..."
	$SUDO sed -i 's/^#addn-hosts/addn-hosts/' /etc/dnsmasq.d/01-pihole.conf
	$SUDO service dnsmasq restart
fi
