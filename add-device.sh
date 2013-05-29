#!/bin/bash
# Quick way to add new devices to Nagios

# Where to store the new Nagios device config
SPATH="/etc/nagios/objects/switches"

# A list of groups that every device will have
DGROUPS="allhosts,uptime,snmp,ping,switches,backbone"

ONEMORE=true


function switch_info()
{
	echo "This will add a new device to Nagios."
	echo
	read -p "Input device name: " SNAME
	read -p "Input device IP: " IP
	echo "-------------------------"
	echo "Default Groups: $DGROUPS"
	read -p "Input alternative group/s: " AGROUPS
	read -p "Input an alias/description for the device: " DIS
	read -p "Parents: " PARENTS

	FNAME=$(echo $SNAME | /usr/bin/gawk '{print tolower($0)}')".cfg"
	NAME=$(echo $SNAME | /usr/bin/gawk '{print toupper($0)}')
	
	echo
	echo "-------------------------"
	echo
	echo "Name: $NAME"
	echo "IP: $IP"
	echo "Group/s: $AGROUPS"
	echo "Alias/Discription: $DIS"
	echo "Parents: $PARENTS"
	echo "File name: $FNAME"
	echo
	echo "-------------------------"
	echo
}

function restart_nagios()
{
	read -n1 -p "Restart Nagios (y/n)? " R && echo
        if [[ $R =~ [yY] ]]; then /etc/init.d/nagios restart; fi
	echo
	exit 1
}

function create_host()
{
echo "
define host{
 use  generic-switch
 host_name $NAME
 alias  $DIS
 address  $IP
 hostgroups $DGROUPS,$AGROUPS
 parents $PARENTS
}
" > $SPATH/$FNAME
echo "File $SPATH/$FNAME created"
}

while [ $ONEMORE == true ]; do
	# Gather info about switches
	switch_info

	# Create the device config file
	create_host

	read -n1 -p "Add another switch (y/n)? " ANOTHER && echo
	if [[ $ANOTHER =~ [yY] ]]; then
		ONEMORE=true
	else
		ONEMORE=false
	fi
done

read -n1 -p "Restart the Nagios Server (y/n)? " RESTART && echo
if [[ $RESTART =~ [yY] ]]; then
	restart_nagios
fi
exit 1
