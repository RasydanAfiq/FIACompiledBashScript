#!/bin/bash

trap '' 2
trap '' SIGTSTP

checktmp=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab`

if [ -z "$checktmp" ]
then
	echo "1. /tmp - FAILED (A separate /tmp partition has not been created.)"
else
	checknodev=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nodev`
	checknodev1=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep nodev`
	if [ -z "$checknodev" -a -z "$checknodev1" ]
	then
		echo "1. /tmp - FAILED (/tmp not mounted with nodev option)"
	elif [ -z "$checknodev" -a -n "$checknodev1" ]
	then
		echo "1. /tmp - FAILED (/tmp not mounted persistently with nodev option)"
	elif [ -n "$checknodev" -a -z "$checknodev1" ]
	then
		echo "1. /tmp - FAILED (/tmp currently not mounted with nodev option)"
	else
		checknosuid=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nosuid`
		checknosuid1=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep nosuid`
		if [ -z "$checknosuid" -a -z "$checknosuid1" ]
		then
			echo "1. /tmp - FAILED (/tmp not mounted with nosuid option)"
		elif [ -z "$checknosuid" -a -n "$checknosuid1" ]
		then
			echo "1. /tmp - FAILED (/tmp not mounted persistently with nosuid option)"
		elif [ -n "$checknosuid" -a -z "$checknosuid1" ]
		then
			echo "1. /tmp - FAILED (/tmp currently not mounted with nosuid option)"
		else	
			checknoexec=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep noexec`
			checknoexec1=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep noexec`
			if [ -z "$checknoexec" -a -z "$checknoexec1" ]
			then
				echo "1. /tmp - FAILED (/tmp not mounted with noexec option)"
			elif [ -z "$checknoexec" -a -n "$checknoexec1" ]
			then
				echo "1. /tmp - FAILED (/tmp not mounted persistently with noexec option)"
			elif [ -n "$checknoexec" -a -z "$checknoexec1" ]
			then
				echo "1. /tmp - FAILED (/tmp currently not mounted with noexec option)"
			else
				echo "1. /tmp - PASSED (/tmp is a separate partition with nodev,nosuid,noexec option)"
			fi
		fi
	fi
fi
 
checkvar=` grep "[[:space:]]/var[[:space:]]" /etc/fstab`
if [ -z "$checkvar" ]
then
	echo "2. /var - FAILED (A separate /var partition has not been created.)"
else 
	echo "2. /var - PASSED (A separate /var partition has been created)"
fi	

checkbind=`grep -e "^/tmp[[:space:]]" /etc/fstab | grep /var/tmp` 
checkbind1=`mount | grep /var/tmp`
if [ -z "$checkbind" -a -z "$checkbind1" ]
then
	echo "3. /var/tmp - FAILED (/var/tmp mount is not bounded to /tmp)"
elif [ -z "$checkbind" -a -n "$checkbind1" ]
then
	echo "3. /var/tmp - FAILED (/var/tmp mount has not been binded to /tmp persistently.)"
elif [ -n "$checkbind" -a -z "$checkbind1" ]
then
	echo "3. /var/tmp - FAILED (/var/tmp mount is not currently bounded to /tmp)"
else 
	echo "3. /var/tmp - PASSED (/var/tmp has been binded and mounted to /tmp)"
fi

checkvarlog=`grep "[[:space:]]/var/log[[:space:]]" /etc/fstab`
if [ -z "$checkvarlog" ]
then
	echo "4. /var/log - FAILED (A separate /var/log partition has not been created.)"
else 
	echo "4. /var/log - PASSED (A separate /var/log partition has been created)"
fi	

checkvarlogaudit=`grep "[[:space:]]/var/log/audit[[:space:]]" /etc/fstab`
if [ -z "$checkvarlogaudit" ]
then
	echo "5. /var/log/audit - FAILED (A separate /var/log/audit partition has not been created.)"
else 
	echo "5. /var/log/audit - PASSED (A separate /var/log/audit partition has been created)"
fi	

checkhome=` grep "[[:space:]]/home[[:space:]]" /etc/fstab`
if [ -z "$checkhome" ]
then
	echo "6. /home - FAILED (A separate /home partition has not been created.)"
else 
	 checknodevhome=`grep "[[:space:]]/home[[:space:]]" /etc/fstab | grep nodev`
	 checknodevhome1=`mount | grep "[[:space:]]/home[[:space:]]" | grep nodev`
	
		if [ -z "$checknodevhome" -a -z "$checknodevhome1" ]
		then
			echo "6. /home - FAILED (/home not mounted with nodev option)"
		elif [ -z "$checknodevhome" -a -n "$checknodevhome1" ]
		then
			echo "6. /home - FAILED (/home not mounted persistently with nodev option)"
		elif [ -n "$checknodevhome" -a -z "$checknodevhome1" ]
		then
			echo "6. /home - FAILED (/home currently not mounted with nodev option)"
	else
		echo "6. /home - PASSED (/home is a separate partition with nodev option)"
	fi
fi

cdcheck=`grep cd /etc/fstab`
if [ -n "$cdcheck" ]
then
	cdnodevcheck=`grep cdrom /etc/fstab | grep nodev`
	cdnosuidcheck=`grep cdrom /etc/fstab | grep nosuid`
	cdnosuidcheck=`grep cdrom /etc/fstab | grep noexec`
	if [ -z "$cdnosuidcheck" ]
	then
			echo "7. /cdrom - FAILED (/cdrom not mounted with nodev option)"
	elif [ -z "$cdnosuidcheck" ]
	then
			echo "7. /cdrom - FAILED (/cdrom not mounted with nosuid option)"
	elif [ -z "$cdnosuidcheck" ]
	then
			echo "7. /cdrom - FAILED (/cdrom not mounted with noexec option)"
	else
		"7. /cdrom - PASSED (/cdrom is a mounted with nodev,nosuid,noexec option)"
	fi
else
	echo "7. /cdrom - PASSED (/cdrom not mounted)"
fi
 
checkstickybit=`df --local -P | awk {'if (NR1=1) print $6'} | xargs -l '{}' -xdev -type d \(--perm -0002 -a ! -perm -1000 \) 2> /dev/null`
if [ -n "$checkstickybit" ]
then
	echo "8. Sticky Bit - FAILED (Sticky bit is not set on all world-writable directories)"
else
	echo "8. Sticky Bit - PASSED (Sticky bit is set on all world-writable directories)"
fi

checkcramfs=`/sbin/lsmod | grep cramfs`
checkfreevxfs=`/sbin/lsmod | grep freevxfs`
checkjffs2=`/sbin/lsmod | grep jffs2`
checkhfs=`/sbin/lsmod | grep hfs`
checkhfsplus=`/sbin/lsmod | grep hfsplus`
checksquashfs=`/sbin/lsmod | grep squashfs`
checkudf=`/sbin/lsmod | grep udf`

if [ -n "$checkcramfs" -o -n "$checkfreevxfs" -o -n "$checkjffs2" -o -n "$checkhfs" -o -n "$checkhfsplus" -o -n "$checksquashfs" -o -n "$checkudf" ]
then
	echo "8. Legacy File Systems - FAILED (Not all legacy file systems are disabled i.e. cramfs, freevxfs, jffs2, hfs, hfsplus, squashfs and udf)"
else
	echo "8. Legacy File Systems - PASSED (All legacy file systems are disabled i.e. cramfs, freevxfs, jffs2, hfs, hfsplus, squashfs and udf)"
fi

printf "\n"
printf "Services\n"

services=( "telnet" "telnet-server" "rsh-server" "rsh" "ypserv" "ypbind" "tftp" "tftp-server" "xinetd" )

count=1
for eachservice in ${services[*]}
do 
	yum -q list installed $eachservice &>/dev/null && echo "$count. $eachservice - FAILED ($eachservice is Installed)" || echo "$count. $eachservice - PASSED ($eachservice is not installed) "
	((count++))
done 	


chkservices=( "chargen-stream" "daytime-dgram" "daytime-stream" "echo-dgram" "echo-stream" "tcpmux-server" ) 

for eachchkservice in ${chkservices[*]}
do 
	checkxinetd=`yum list xinetd | grep "Available Packages"`
	if [ -n "$checkxinetd" ]
	then
		echo "$count. Xinetd is not installed, hence $eachchkservice is not installed"
		((count++))
	else
		checkchkservices=`chkconfig --list $eachchkservice | grep "off"`
		if [ -n "$checkchkservices" ]
		then 
			echo "$count. $eachchkservice - PASSED ($eachchkservice is not active) "
			((count++))
		else 
			echo "$count. $eachchkservice - FAILED ($eachchkservice is active)"
			((count++))
		fi
	fi
done

printf "\n"
printf "Special Purpose Services\n"

checkumask=`grep ^umask /etc/sysconfig/init`

if [ "$checkumask" == "umask 027" ]
then 
	echo "1. Umask - PASSED (umask is set to 027)"
else 
	echo "1. Umask - FAILED (umask is not set to 027)"
fi

checkxsystem=`ls -l /etc/systemd/system/default.target | grep graphical.target` #Must return empty
checkxsysteminstalled=`rpm  -q xorg-x11-server-common`	#Must return something
	
if [ -z "$checkxsystem" -a -z "$checkxsysteminstalled" ]
then 
	echo "2. X Window System - FAILED (Xorg-x11-server-common is installed)"
elif [ -z "$checkxsystem" -a -n "$checkxsysteminstalled" ]
then
	echo "2. X Window System - PASSED (Xorg-x11-server-common is not installed and is not the default graphical interface)"
elif [ -n "$checkxsystem" -a -z "$checkxsysteminstalled" ]
then
	echo "2. X Window System - FAILED (Xorg-x11-server-common is not installed and is the default graphical interface)"
else 
	echo "2. X Window System - FAILED (Xorg-x11-server-common is installed and is the default graphical interface)"
fi
count=3
	checkavahi=`systemctl status avahi-daemon | grep inactive`
	checkavahi1=`systemctl status avahi-daemon | grep disabled`
	if [ -n "$checkavahi" -a -n "$checkavahi1" ]
	then 
		echo "$count. Avahi-daemon - PASSED (Avahi-daemon is inactive and disabled) "
		((count++))
	elif [ -n "$checkavahi" -a -z "$checkavahi1" ]
	then 
		echo "$count. Avahi-daemon - FAILED (Avahi-daemon is inactive but not disabled)"
		((count++))
	elif [ -z "$checkavahi" -a -n "$checkavahi1" ]
	then 
		echo "$count. Avahi-daemon - FAILED (Avahi-daemon is disabled but active)"
		((count++))
	else 
		echo "$count. Avahi-daemon - FAILED (Avahi-daemon is active and enabled)"
		((count++))
	fi
	
	checkcups=`systemctl status cups | grep inactive`
	checkcups1=`systemctl status cups | grep disabled`
	
if [ -n "$checkcups" -a -n "$checkcups1" ]
	then 
		echo "$count. Cups - PASSED (Cups is inactive and disabled) "
		((count++))
	elif [ -n "$checkcups" -a -z "$checkcups1" ]
	then 
		echo "$count. Cups - FAILED (Cups is inactive but not disabled)"
		((count++))
	elif [ -z "$checkcups" -a -n "$checkcups1" ]
	then 
		echo "$count. Cups - FAILED (Cups is disabled but active)"
		((count++))
	else 
		echo "$count. Cups - FAILED (Cups is active and enabled)"
		((count++))
	fi


checkyumdhcp=`yum list dhcp | grep "Available Packages" `
checkyumdhcpactive=`systemctl status dhcp | grep inactive `
checkyumdhcpenable=`systemctl status dhcp | grep disabled `
if [ -n "$checkyumdhcp" ]
then 
	echo "$count. DHCP Server - PASSED (DHCP is not installed) "
	((count++))
else 
	if [ -z "$checkyumdhcpactive" -a -z "$checkyumdhcpenable" ]
	then 
		echo "$count. DHCP - FAILED (DHCP is active and enabled)"
		((count++))
	elif [ -z "$checkyumdhcpactive" -a -n "$checkyumdhcpenable" ]
	then 
		echo "$count. DHCP - FAILED (DHCP is active but disabled)"
		((count++))
	elif [ -n "$checkyumdhcpactive" -a -z "$checkyumdhcpenable" ]
	then
		echo "$count. DHCP - FAILED (DHCP is inactive but enabled)"
		((count++))
	else 
		echo "$count. DHCP - FAILED (DHCP is inactive but disabled)"
		((count++))
	fi
fi

checkntp1=`grep "^restrict default kod nomodify notrap nopeer noquery" /etc/ntp.conf`
checkntp2=`grep "^restrict -6 default kod nomodify notrap nopeer noquery" /etc/ntp.conf` 
checkntp3=`grep "^server" /etc/ntp.conf | grep server`
checkntp4=`grep 'OPTIONS="-u ntp:ntp -p /var/run/ntpd.pid"' /etc/sysconfig/ntpd `

if [ -n "$checkntp1" ]
then 
	if [ -n "$checkntp2" ]
	then 
		if [ -n "$checkntp3" ]
			then 
				if [ -n "$checkntp4" ]
				then
					echo "$count. NTP - PASSED (NTP has been properly configured)"
					((count++))
				else 
					echo "$count. NTP - FAILED (Option has not been configured in /etc/sysconfig/ntpd)" 
					((count++))
				fi
		else
			echo "$count. NTP - FAILED (Failed to list down NTP servers)"
			((count++))
		fi
	else 
		echo "$count. NTP - FAILED (Failed to implement restrict -6 default kod nomodify notrap nopeer noquery)"
		((count++))
	fi
else 
	echo "$count. NTP - FAILED (Failed to implement restrict default kod nomodify notrap nopeer noquery)"
	((count++))
fi 

checkldapclients=`yum list openldap-clients | grep 'Available Packages'`
checkldapservers=`yum list openldap-servers | grep 'Available Packages'`

if [ -n "checkldapclients" -a -n "checkldapservers" ]
then 
	echo "$count. LDAP - PASSED (LDAP server and client are both not installed)"
	((count++))
elif [ -n "checkldapclients" -a -z "checkldapservers" ]
then
	echo "$count. LDAP - FAILED (LDAP server is installed)"
	((count++))
elif [ -z "checkldapclients" -a -n "checkldapservers" ]
then
	echo "$count. LDAP - FAILED (LDAP client is installed)"
	((count++))
else 
	echo "$count. LDAP - FAILED (Both LDAP client and server are installed)"
	((count++))
fi 

nfsservices=( "nfs-lock" "nfs-secure" "rpcbind" "nfs-idmap" "nfs-secure-server" )

for eachnfsservice in ${nfsservices[*]}
do 
	checknfsservices=`systemctl is-enabled $eachnfsservice | grep enabled`
	if [ -z "$checknfsservices" ]
	then 
		echo "$count. $eachnfsservice - PASSED ($eachnfsservice is disabled) "
		((count++))
	else 
		echo "$count. $eachnfsservice - FAILED ($eachnfsservice is enabled)"
		((count++))
	fi
done 	

standardservices=( "named" "vsftpd" "httpd" "sshd" "snmpd") 


for eachstandardservice in ${standardservices[*]}
do 
	checkserviceexist=`systemctl status $eachstandardservice | grep not-found`
	if [ -n "$checkserviceexist" ]
	then
		echo "$count. $eachstandardservice - PASSED ($eachstandardservice does not exist in the system)"
		((count++))
	else
		checkstandardservices=`systemctl status $eachstandardservice | grep disabled`
		checkstandardservices1=`systemctl status $eachstandardservice | grep inactive`
		if [ -z "$checkstandardservices" -a -z "$checkstandardservices1" ]
		then 
			echo "$count. $eachstandardservice - FAILED ($eachstandardservice is active and enabled) "
			((count++))
		elif [ -z "$checkstandardservices" -a -n "$checkstandardservices1" ]
		then 
			echo "$count. $eachstandardservice - FAILED ($eachstandardservice is inactive but enabled) "
			((count++))
		elif [ -n "$checkstandardservices" -a -z "$checkstandardservices1" ]
		then 
			echo "$count. $eachstandardservice - FAILED ($eachstandardservice is disabled but active) "
			((count++))
		else 
			echo "$count. $eachstandardservice - PASSED ($eachstandardservice is disabled and inactive)"
			((count++))
		fi
	fi
done 	

checkmailtransferagent=`netstat -an | grep ":25[[:space:]]"`

if [ -n "$checkmailtransferagent" ]
then
	checklistening=`netstat -an | grep LISTEN`
	if [ -n "$checklistening" ]
	then
		checklocaladdress=`netstat -an | grep [[:space:]]127.0.0.1:25[[:space:]] | grep LISTEN`
		if [ -n "$checklocaladdress" ]
		then
			echo "$count. MTA - PASSED (Mail Transfer Agent is listening on the loopback address)"
		else
			echo "$count. MTA - FAILED (Mail Transfer Agent is not listening on the loopback address)"
		fi
	else
		echo "$count. MTA - FAILED (Mail Transfer Agent is not in listening mode)"
	fi
else
	echo "$count. MTA - FAILED (Mail Transfer Agent is not configured/installed)"
fi


#!/bin/bash

#To stop “Control-C”
trap '' 2

#To stop “Control-Z”
trap '' SIGTSTP

printf "\n"

# 4.1 and 4.2
echo -e "\e[4m4.1 and 4.2 : Set User/Group Owner and Permissions on /boot/grub2/grub.cfg\e[0m\n"
checkgrubowner=`stat -L -c "owner=%U group=%G" /boot/grub2/grub.cfg`

if  [ "$checkgrubowner" == "owner=root group=root" ]
then
	checkgrubpermission=`stat -L -c "%a" /boot/grub2/grub.cfg | cut -b 2,3`

	if [ "$checkgrubpermission" == "00" ]
	then
		echo "/boot/grub2/grub.cfg - PASSED (Owner, group owner and permission of file is configured correctly)"

	else
		echo "/boot/grub2/grub.cfg - FAILED (Permission of file is configured incorrectly)"
	fi

else
	echo "/boot/grub2/grub.cfg - FAILED (Owner and group owner of file is configured incorrectly)"
fi

printf "\n\n"

# 4.3
echo -e "\e[4m4.3 : Set Boot Loader Password\e[0m\n"
checkbootloaderuser=`grep "^set superusers" /boot/grub2/grub.cfg`

if [ -z "$checkbootloaderuser" ]
then
	echo "Boot Loader Password - FAILED (Boot loader is not configured with any superuser)"

else
	checkbootloaderpassword=`grep "^passwd" /boot/grub2/grub.cfg`

	if [ -z "$checkbootloaderpassword" ]
	then
		echo "Boot Loader Password - FAILED (Boot loader is not configured with a password)"

	else
		echo "Boot Loader Password - PASSED (Boot loader is configured with a superuser and password)"
	fi

fi	

printf "\n\n"
# 5.1
echo -e "\e[4m5.1 : Restrict Core Dumps\e[0m\n"
checkcoredump=`grep "hard core" /etc/security/limits.conf`
coredumpval="* hard core 0"

if [ "$checkcoredump" == "$coredumpval" ]
then
	checksetuid=`sysctl fs.suid_dumpable`
	setuidval="fs.suid_dumpable = 0"

	if [ "$checksetuid" == "$setuidval" ]
	then
		echo "Core Dump - PASSED (Core dumps are restricted and setuid programs are prevented from dumping core)"

	else
		echo "Core Dump - FAILED (Setuid programs are not prevented from dumping core)"
	fi

else
	echo "Core Dump - FAILED (Core dumps are not restricted)"
fi

printf "\n\n"

# 5.2
echo -e "\e[4m5.2 : Enable Randomized Virtual Memory Region Placement\e[0m\n"
checkvirtualran=`sysctl kernel.randomize_va_space`
virtualranval="kernel.randomize_va_space = 2"

if [ "$checkvirtualran" == "$virtualranval" ]
then
	echo "Randomized Virtual Memory Region Placement - PASSED (Virtual memory is randomized)"

else
	echo "Randomized Virtual Memory Region Placement - FAILED (Virtual memory is not randomized)"
fi

printf "\n\n"

# 6.1
printf "============================================================================\n"
printf "6.1 : Configure rsyslog\n"
printf "============================================================================\n"
printf "\n"

# 6.1.1 and 6.1.2
echo -e "\e[4m6.1.1 and 6.1.2 : Install the rsyslogpackage and Activate the rsyslog Service\e[0m\n"
checkrsyslog=`rpm -q rsyslog | grep "^rsyslog"`
if [ -n "$checkrsyslog" ]
then
	checkrsysenable=`systemctl is-enabled rsyslog`

	if [ "$checkrsysenable" == "enabled" ]
	then
		echo "Rsyslog - PASSED (Rsyslog is installed and enabled)"

	else
		echo "Rsyslog - FAILED (Rsyslog is disabled)"
	fi

else
	echo "Rsyslog - FAILED (Rsyslog is not installed)"
fi

printf "\n\n"

# 6.1.3
echo -e "\e[4m6.1.3 and 6.1.4 : Configure /etc/rsyslog.conf and Create and Set Permissions on rsyslog Log Files\e[0m\n"
checkvarlogmessageexist=`ls -l /var/log/ | grep messages`

if [ -n "$checkvarlogmessageexist" ]
then
	checkvarlogmessageown=`ls -l /var/log/messages | cut -d ' ' -f3,4`

	if [ "$checkvarlogmessageown" == "root root" ]
	then
		checkvarlogmessagepermit=`ls -l /var/log/messages | cut -d ' ' -f1`

		if [ "$checkvarlogmessagepermit" == "-rw-------." ]
		then
			checkvarlogmessage=`grep /var/log/messages /etc/rsyslog.conf`

			if [ -n "$checkvarlogmessage" ]
			then
				checkusermessage=`grep /var/log/messages /etc/rsyslog.conf | grep "^auth,user.*"`

				if [ -n "$checkusermessage" ]
				then
					echo "/var/log/messages - PASSED (Owner, group owner, permissions, facility are configured correctly; messages logging is set)"

				else
					echo "/var/log/messages - FAILED (Facility is not configured correctly)"
				fi

			else
				echo "/var/log/messages - FAILED (messages logging is not set)"
			fi

		else
			echo "/var/log/messages - FAILED (Permissions of file is configured incorrectly)"
		fi

	else
		echo "/var/log/messages - FAILED (Owner and group owner of file is configured incorrectly)"
	fi

else
	echo "/var/log/messages - FAILED (/var/log/messages file does not exist)"
fi

printf "\n"

checkvarlogkernexist=`ls -l /var/log/ | grep kern.log`

if [ -n "$checkvarlogkernexist" ]
then
	checkvarlogkernown=`ls -l /var/log/kern.log | cut -d ' ' -f3,4`

	if [ "$checkvarlogkernown" == "root root" ]
	then
		checkvarlogkernpermit=`ls -l /var/log/kern.log | cut -d ' ' -f1`

		if [ "$checkvarlogkernpermit" == "-rw-------." ]
		then
			checkvarlogkern=`grep /var/log/kern.log /etc/rsyslog.conf`

			if [ -n "$checkvarlogkern" ]
			then
				checkuserkern=`grep /var/log/kern.log /etc/rsyslog.conf | grep "^kern.*"`

				if [ -n "$checkuserkern" ]
				then
					echo "/var/log/kern.log - PASSED (Owner, group owner, permissions, facility are configured correctly; kern.log logging is set)"

				else
					echo "/var/log/kern.log - FAILED (Facility is not configured correctly)"
				fi

			else
				echo "/var/log/kern.log - FAILED (kern.log logging is not set)"
			fi

		else
			echo "/var/log/kern.log - FAILED (Permissions of file is configured incorrectly)"
		fi

	else
		echo "/var/log/kern.log - FAILED (Owner and group owner of file is configured incorrectly)"
	fi

else
	echo "/var/log/kern.log - FAILED (/var/log/kern.log file does not exist)"
fi

printf "\n"

checkvarlogdaemonexist=`ls -l /var/log/ | grep daemon.log`

if [ -n "$checkvarlogdaemonexist" ]
then
	checkvarlogdaemonown=`ls -l /var/log/daemon.log | cut -d ' ' -f3,4`

	if [ "$checkvarlogdaemonown" == "root root" ]
	then
		checkvarlogdaemonpermit=`ls -l /var/log/daemon.log | cut -d ' ' -f1`

		if [ "$checkvarlogdaemonpermit" == "-rw-------." ]
		then
			checkvarlogdaemon=`grep /var/log/daemon.log /etc/rsyslog.conf`

			if [ -n "$checkvarlogdaemon" ]
			then
				checkuserdaemon=`grep /var/log/daemon.log /etc/rsyslog.conf | grep "^daemon.*"`

				if [ -n "$checkuserdaemon" ]
				then
					echo "/var/log/daemon.log - PASSED (Owner, group owner, permissions, facility are configured correctly; daemon.log logging is set)"

				else
					echo "/var/log/daemon.log - FAILED (Facility is not configured correctly)"
				fi

			else
				echo "/var/log/daemon.log - FAILED (daemon.log logging is not set)"
			fi

		else
			echo "/var/log/daemon.log - FAILED (Permissions of file is configured incorrectly)"
		fi

	else
		echo "/var/log/daemon.log - FAILED (Owner and group owner of file is configured incorrectly)"
	fi

else
	echo "/var/log/daemon.log - FAILED (/var/log/daemon.log file does not exist)"
fi

printf "\n"

checkvarlogsyslogexist=`ls -l /var/log/ | grep syslog.log`

if [ -n "$checkvarlogsyslogexist" ]
then
	checkvarlogsyslogown=`ls -l /var/log/syslog.log | cut -d ' ' -f3,4`

	if [ "$checkvarlogsyslogown" == "root root" ]
	then
		checkvarlogsyslogpermit=`ls -l /var/log/syslog.log | cut -d ' ' -f1`

		if [ "$checkvarlogsyslogpermit" == "-rw-------." ]
		then
			checkvarlogsyslog=`grep /var/log/syslog.log /etc/rsyslog.conf`

			if [ -n "$checkvarlogsyslog" ]
			then
				checkusersyslog=`grep /var/log/syslog.log /etc/rsyslog.conf | grep "^syslog.*"`

				if [ -n "$checkusersyslog" ]
				then
					echo "/var/log/syslog.log - PASSED (Owner, group owner, permissions, facility are configured correctly; syslog.log logging is set)"

				else
					echo "/var/log/syslog.log - FAILED (Facility is not configured correctly)"
				fi

			else
				echo "/var/log/syslog.log - FAILED (syslog.log logging is not set)"
			fi

		else
			echo "/var/log/syslog.log - FAILED (Permissions of file is configured incorrectly)"
		fi

	else
		echo "/var/log/syslog.log - FAILED (Owner and group owner of file is configured incorrectly)"
	fi

else
	echo "/var/log/syslog.log - FAILED (/var/log/syslog.log file does not exist)"
fi

printf "\n"

checkvarlogunusedexist=`ls -l /var/log/ | grep unused.log`

if [ -n "$checkvarlogunusedexist" ]
then
	checkvarlogunusedown=`ls -l /var/log/unused.log | cut -d ' ' -f3,4`

	if [ "$checkvarlogunusedown" == "root root" ]
	then
		checkvarlogunusedpermit=`ls -l /var/log/unused.log | cut -d ' ' -f1`

		if [ "$checkvarlogunusedpermit" == "-rw-------." ]
		then
			checkvarlogunused=`grep /var/log/unused.log /etc/rsyslog.conf`

			if [ -n "$checkvarlogunused" ]
			then
				checkuserunused=`grep /var/log/unused.log /etc/rsyslog.conf | grep "^lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.*"`

				if [ -n "$checkuserunused" ]
				then
					echo "/var/log/unused.log - PASSED (Owner, group owner, permissions, facility are configured correctly; unused.log logging is set)"

				else
					echo "/var/log/unused.log - FAILED (Facility is not configured correctly)"
				fi

			else
				echo "/var/log/unused.log - FAILED (unused.log logging is not set)"
			fi

		else
			echo "/var/log/unused.log - FAILED (Permissions of file is configured incorrectly)"
		fi

	else
		echo "/var/log/unused.log - FAILED (Owner and group owner of file is configured incorrectly)"
	fi

else
	echo "/var/log/unused.log - FAILED (/var/log/unused.log file does not exist)"
fi

printf "\n\n"

# 6.1.5
echo -e "\e[4m6.1.5 : Configure rsyslogto Send Logs to a Remote Log Host\e[0m\n"
checkloghost=$(grep "^*.*[^|][^|]*@" /etc/rsyslog.conf)
if [ -z "$checkloghost" ]  # If there is no log host
then
	printf "Remote Log Host : FAILED (Remote log host has not been configured)\n"
else
	printf "Remote Log Host : PASSED (Remote log host has been configured)\n"
fi

printf "\n\n"
# 6.1.6
echo -e "\e[4m6.1.6 : Accept Remote rsyslog Messages Only on Designated Log Hosts\e[0m\n"
checkrsysloglis=`grep '^$ModLoad imtcp.so' /etc/rsyslog.conf`
checkrsysloglis1=`grep '^$InputTCPServerRun' /etc/rsyslog.conf`

if [ -z "$checkrsysloglis" -o -z "$checkrsysloglis1" ]
then
	echo "Remote rsyslog - FAILED (Rsyslog is not listening for remote messages)"

else
	echo "Remote rsyslog - PASSED (Rsyslog is listening for remote messages)"
fi

printf "\n\n"

printf "============================================================================\n"
printf "6.2 : Configure System Accounting\n"
printf "============================================================================\n"
printf "\n"
echo "----------------------------------------------------------------------------"
printf "6.2.1 : Configure Data Retention\n"
echo "----------------------------------------------------------------------------"
printf "\n"

# 6.2.1.1
echo -e "\e[4m6.2.1.1 : Configure Audit Log Storage Size\e[0m\n"
checklogstoragesize=`grep max_log_file[[:space:]] /etc/audit/auditd.conf | awk '{print $3}'`

if [ "$checklogstoragesize" == 5 ]
then
	echo "Audit Log Storage Size - PASSED (Maximum size of audit log files is configured correctly)"

else
	echo "Audit Log Storage Size - FAILED (Maximum size of audit log files is not configured correctly)"
fi

printf "\n\n"

# 6.2.1.2
echo -e "\e[4m6.2.1.2 : Keep All Auditing Information\e[0m\n"
checklogfileaction=`grep max_log_file_action /etc/audit/auditd.conf | awk '{print $3}'`
 
if [ "$checklogfileaction" == keep_logs ]
then
	echo "Audit Log File Action - PASSED (Action of the audit log file is configured correctly)"

else
	echo "Audit Log File Action - FAILED (Action of the audit log file is not configured correcly)"
fi

printf "\n\n"

# 6.2.1.3
echo -e "\e[4m6.2.1.3 : Disable System on Audit Log Full\e[0m\n"
checkspaceleftaction=`grep space_left_action /etc/audit/auditd.conf | grep "email"`

if [ -n "$checkspaceleftaction" ]
then
	checkactionmailacc=`grep action_mail_acct /etc/audit/auditd.conf | awk '{print $3}'`
	if [ "$checkactionmailacc" == root ]
	then
		checkadminspaceleftaction=`grep admin_space_left_action /etc/audit/auditd.conf | awk '{print $3}'`
		if [ "$checkadminspaceleftaction" == halt ]
		then
			echo "Disable System - PASSED (Auditd is correctly configured to notify the administrator and halt the system when audit logs are full)"
		else
			echo "Disable System - FAILED (Auditd is not configured to halt the system when audit logs are full)"
		fi

	else
		echo "Disable System - FAILED (Auditd is not configured to notify the administrator when audit logs are full)"
	fi
	
else
	echo "Disable System - FAILED (Auditd is not configured to notify the administrator by email when audit logs are full)"
fi

printf "\n\n"

# 6.2.1.4
echo -e "\e[4m6.2.1.4 : Enable auditd Service\e[0m\n"
checkauditdservice=`systemctl is-enabled auditd`

if [ "$checkauditdservice" == enabled ]
then
	echo "Auditd Service - PASSED (Auditd is enabled)"

else
	echo "Auditd Service - FAILED (Auditd is not enabled)"
fi

printf "\n\n"

# 6.2.1.5
echo -e "\e[4m6.2.1.5 : Enable Auditing for Processes That Start Prior to auditd\e[0m\n"
checkgrub=$(grep "linux" /boot/grub2/grub.cfg | grep "audit=1") 
if [ -z "$checkgrub" ]
then
	printf "System Log Processes : FAILED (System is not configured to log processes that start prior to auditd\n"

else
	printf "System Log Processes : PASSED (System is configured to log processes that start prior to auditd\n"
fi

printf "\n\n"

# 6.2.1.6
echo -e "\e[4m6.2.1.6 : Record Events That Modify Date and Time Information\e[0m\n"
checksystem=`uname -m | grep "64"`
checkmodifydatetimeadjtimex=`egrep 'adjtimex|settimeofday|clock_settime' /etc/audit/audit.rules`

if [ -z "$checksystem" ]
then
	echo "It is a 32-bit system."
	printf "\n"
	if [ -z "$checkmodifydatetimeadjtimex" ]
	then
        echo "Date & Time Modified Events - FAILED (Events where system date and/or time has been modified are not captured)"

	else
		echo "Date & Time Modified Events - PASSED (Events where system date and/or time has been modified are captured)"
	fi

else
	echo "It is a 64-bit system."
	printf "\n" 
	if [ -z "$checkmodifydatetimeadjtimex" ]
	then
        echo "Date & Time Modified Events - FAILED (Events where system date and/or time has been modified are not captured)"

	else
		echo "Date & Time Modified Events - PASSED (Events where system date and/or time has been modified are captured)"
	fi

fi

printf "\n\n"

# 6.2.1.7
echo -e "\e[4m6.2.1.7 : Record Events That Modify User/Group Information\e[0m\n"
checkmodifyusergroupinfo=`egrep '\/etc\/group' /etc/audit/audit.rules`

if [ -z "$checkmodifyusergroupinfo" ]
then
        echo "Group Configuration - FAILED (Group is not configured)"

else
        echo "Group Configuration - PASSED (Group is already configured)"
fi

printf "\n"

checkmodifyuserpasswdinfo=`egrep '\/etc\/passwd' /etc/audit/audit.rules`

if [ -z "$checkmodifyuserpasswdinfo" ]
then
        echo "Password Configuration - FAILED (Password is not configured)"

else
        echo "Password Configuration - PASSED (Password is configured)"
fi

printf "\n"

checkmodifyusergshadowinfo=`egrep '\/etc\/gshadow' /etc/audit/audit.rules`

if [ -z "$checkmodifyusergshadowinfo" ]
then
        echo "GShadow Configuration - FAILED (GShadow is not configured)"

else
        echo "GShadow Configuration - PASSED (GShadow is configured)"
fi

printf "\n"

# 6.2.1.8
checkmodifyusershadowinfo=`egrep '\/etc\/shadow' /etc/audit/audit.rules`

if [ -z "$checkmodifyusershadowinfo" ]
then
        echo "Shadow Configuration - FAILED (Shadow is not configured)"

else
        echo "7Shadow Configuration - PASSED (Shadow is configured)"
fi

printf "\n"

checkmodifyuseropasswdinfo=`egrep '\/etc\/security\/opasswd' /etc/audit/audit.rules`

if [ -z "$checkmodifyuseropasswdinfo" ]
then
        echo "OPasswd Configuration- FAILED (OPassword not configured)"

else
        echo "OPasswd Configuration - PASSED (OPassword is configured)"
fi

printf "\n\n"

# 6.2.1.8
echo -e "\e[4m6.2.1.8 : Record Events That Modify the System's Network Environment\e[0m\n"
checksystem=`uname -m | grep "64"`
checkmodifynetworkenvironmentname=`egrep 'sethostname|setdomainname' /etc/audit/audit.rules`

if [ -z "$checksystem" ]
then
	echo "It is a 32-bit system."
	printf "\n"
	if [ -z "$checkmodifynetworkenvironmentname" ]
	then
        	echo "Modify the System's Network Environment Events - FAILED (Sethostname and setdomainname is not configured)"

	else
		echo "Modify the System's Network Environment Events - PASSED (Sethostname and setdomainname is configured)"
	fi

else
	echo "It is a 64-bit system."
	printf "\n"
	if [ -z "$checkmodifynetworkenvironmentname" ]
	then
        echo "Modify the System's Network Environment Events - FAILED (Sethostname and setdomainname is not configured)"

	else
		echo "Modify the System's Network Environment Events - PASSED (Sethostname and setdomainname is configured)"
	fi

fi

printf "\n"

checkmodifynetworkenvironmentissue=`egrep '\/etc\/issue' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmentissue" ]
then
    echo "Modify the System's Network Environment Events - FAILED (/etc/issue is not configured)"

else
    echo "Modify the System's Network Environment Events - PASSED (/etc/issue is configured)"
fi

printf "\n"

checkmodifynetworkenvironmenthosts=`egrep '\/etc\/hosts' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmenthosts" ]
then
    echo "Modify the System's Network Environment Events - FAILED (/etc/hosts is not configured)"

else
     echo "Modify the System's Network Environment Events - PASSED (/etc/hosts is configured)"
fi

printf "\n"

checkmodifynetworkenvironmentnetwork=`egrep '\/etc\/sysconfig\/network' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmentnetwork" ]
then
    echo "Modify the System's Network Environment Events - FAILED (/etc/sysconfig/network is not configured)"

else
    echo "Modify the System's Network Environment Events - PASSED (/etc/sysconfig/network is configured)"
fi

printf "\n\n"
# 6.2.1.9
echo -e "\e[4m6.2.1.9 : Record Events That Modify the System's Mandatory Access Controls\e[0m\n"
checkmodifymandatoryaccesscontrol=`grep \/etc\/selinux /etc/audit/audit.rules`

if [ -z "$checkmodifymandatoryaccesscontrol" ]
then
	echo "Modify the System's Mandatory Access Controls Events - FAILED (Recording of modified system's mandatory access controls events is not configured)"

else
	echo "Modify the System's Mandatory Access Controls Events - PASSED (Recording of modified system's mandatory access controls events is configured)"
fi

printf "\n\n"

# Force exit
read -n 1 -s -r -p "Press any key to exit!"
kill -9 $PPID

#! /bin/bash

#6.2.1.10
chklogins=`grep logins /etc/audit/audit.rules`
loginfail=`grep "\-w /var/log/faillog -p wa -k logins" /etc/audit/audit.rules`
loginlast=`grep "\-w /var/log/lastlog -p wa -k logins" /etc/audit/audit.rules`
logintally=`grep "\-w /var/log/tallylog -p wa -k logins" /etc/audit/audit.rules`

if [ -z "$loginfail" -o -z "$loginlast" -o -z "$logintally" ]
then
        echo "FAILED - Login and logout events not recorded."
else
        echo "PASSED - Login and logout events recorded."
fi

#6.2.1.11
chksession=`egrep 'wtmp|btmp|utmp' /etc/audit/audit.rules`
sessionwtmp=`egrep "\-w /var/log/wtmp -p wa -k session" /etc/audit/audit.rules`
sessionbtmp=`egrep "\-w /var/log/btmp -p wa -k session" /etc/audit/audit.rules`
sessionutmp=`egrep "\-w /var/run/utmp -p wa -k session" /etc/audit/audit.rules`

if [ -z "$sessionwtmp" -o -z "$sessionbtmp" -o -z "sessionutmp" ]
then
        echo "FAILED - Session initiation information not collected."
else
        echo "PASSED - Session initiation information is collected."
fi

#6.2.1.12
chkpermission64=`grep perm_mod /etc/audit/audit.rules`
permission1=`grep "\-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`
permission2=`grep "\-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F
auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`
permission3=`grep "\-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S|chown -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`
permission4=`grep "\-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S|chown -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`
permission5=`grep "\-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -Fauid!=4294967295 -k perm_mod" /etc/audit/audit.rules`
permission6=`grep "\-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S
 fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F
auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

if [ -z "$permission1" -o -z "$permission2" -o -z permission3 -o -z permission4 -o -z permission5 -o -z permission6 ]
then
        echo "FAILED - Permission modifications not recorded."

else
        echo "PASSED - Permission modification are recorded."
fi

#6.2.1.13
chkaccess=`grep access /etc/audit/audit.rules`
access1=`grep "\-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`
access2=`grep "\-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`
access3=`grep "\-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`
access4=`grep "\-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`
access5=`grep "\-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`
access6=`grep "\-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

if [ -z "$access1" -o -z "$access2" -o -z "$access3" -o -z "$access4" -o -z "$access5" -o -z "$access6" ]
then
        echo "FAILED - Unsuccesful attempts to access files."

else
        echo "PASSED - Successful attempts to access files."
fi

#6.2.1.14 Collect Use of Privileged Commands
find / -xdev \( -perm -4000 -o -perm -2000 \)  -type f | awk '{print "-a always, exit-F path=" $1 " -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged" }' > /tmp/1.log

checkprivilege=`cat /tmp/1.log`
cat /etc/audit/audit.rules | grep -- "$checkprivilege" > /tmp/2.log

checkprivilegenotinfile=`grep -F -x -v -f /tmp/2.log /tmp/1.log`

if [ -n "$checkprivilegenotinfile" ]
then
	echo "FAILED - Privileged Commands not in audit"
else
	echo "PASSED - Privileged Commands in audit"
fi

rm /tmp/1.log
rm /tmp/2.log 

#6.2.1.15 Collect Successful File System Mounts
bit64mountb64=`grep "\-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" /etc/audit/audit.rules`
bit64mountb32=`grep "\-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" /etc/audit/audit.rules`
bit32mountb32=`grep "\-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" /etc/audit/audit.rules`

if [ -z "$bit64mountb64" -o -z "$bit64mountb32" -o -z "$bit32mountb32" ]
then
	echo "FAILED - To determine filesystem mounts" 
else
	echo "PASSED - To determine filesystem mounts"
fi

#6.2.1.16 Collect File Delection Events by User
bit64delb64=`grep "\-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" /etc/audit/audit.rules`
bit64delb32=`grep "\-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" /etc/audit/audit.rules`
bit32delb32=`grep "\-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" /etc/audit/audit.rules`

if [ -z "$bit64delb64" -o -z "$bit64delb32" -o -z "$bit32delb32" ]
then
	echo "FAILED - To determine the file delection event by user"
else
	echo "PASSED - To determine the file delection event by user"
fi

#6.2.1.17 Collect Changes to System Administration Scope
chkscope=`grep scope /etc/audit/audit.rules`
sudoers='-w /etc/sudoers -p wa -k scope'

if [ -z "$chkscope" -o "$chkscope" != "$sudoers" ]
then
	echo "FAILED - To unauthorize change to scope of system administrator activity"
else
	echo "PASSED - To unauthorize change to scope of system administrator activity"
fi

#6.2.1.18 
chkadminrules=`grep actions /etc/audit/audit.rules`
adminrules='-w /var/log/sudo.log -p wa -k actions'

if [ -z "$chkadminrules" -o "$chkadminrules" != "$adminrules" ]
then 
	echo "FAILED - Administrator activity not recorded"
else
	echo "PASSED - Administrator activity recorded"
fi

#6.2.1.19
chkmod1=`grep "\-w /sbin/insmod -p x -k modules" /etc/audit/audit.rules`
chkmod2=`grep "\-w /sbin/rmmod -p x -k modules" /etc/audit/audit.rules`
chkmod3=`grep "\-w /sbin/modprobe -p x -k modules" /etc/audit/audit.rules`
chkmod4=`grep "\-a always,exit -F arch=b64 -S init_module -S delete_module -k modules" /etc/audit/audit.rules`

if [ -z "$chkmod1" -o -z "$chkmod2" -o -z "$chkmod3" -o -z "$chkmod4" ]
then
	echo "FAILED - Kernel module not recorded"
else
	echo "PASSED - Kernel module recorded"
fi

#6.2.1.20
chkimmute=`grep "^-e 2" /etc/audit/audit.rules`
immute='-e 2'

if [ -z "$chkimmute" -o "$chkimmute" != "$immute" ]
then
	echo "FAILED - Audit configuration is not immutable"
else
	echo "PASSED - Audit configuration immutable"
fi

#6.2.1.21
chkrotate1=`grep "/var/log/messages" /etc/logrotate.d/syslog`
chkrotate2=`grep "/var/log/secure" /etc/logrotate.d/syslog`
chkrotate3=`grep "/var/log/maillog" /etc/logrotate.d/syslog`
chkrotate4=`grep "/var/log/spooler" /etc/logrotate.d/syslog`
chkrotate5=`grep "/var/log/boot.log" /etc/logrotate.d/syslog`
chkrotate6=`grep "/var/log/cron" /etc/logrotate.d/syslog`

if [ -z "chkrotate1" -o -z "$chkrotate2" -o -z "$chkrotate3" -o -z "$chkrotate4" -o -z "$chkrotate5" -o -z "$chkrotate6" ]
then
	echo "FAILED - System logs not rotated"
else
	echo "PASSED - System logs recorded"
fi

#!/bin/bash
echo "7.1 Set Password Expiration Days"

value=$(cat /etc/login.defs | grep "^PASS_MAX_DAYS" | awk '{ print $2 }')

standard=90 

if [ ! $value = $standard ]; then
  echo "Audit status: FAILED!"
elif [ $value = $standard ]; then
  echo "Audit status: PASSED!"
else
  echo "ERROR: FATAL ERROR, CONTACT SYSTEM ADMINISTRATOR!"
fi
#########################################################################
echo "7.2 Set Password Change Minimum Number of Days"
value=$(cat /etc/login.defs | grep "^PASS_MIN_DAYS" | awk '{ print $2 }')

standard=7 

if [ ! $value = $standard ]; then
	echo "Audit status: FAILED!"
elif [ $value = $standard ]; then
	echo "Audit status: PASSED!"
else
	echo ERROR: "FATAL ERROR, CONTACT SYSTEM ADMINISTRATOR!"
fi
#########################################################################
echo "7.3 Set Password Expiring Warning Days"
value=$(cat /etc/login.defs | grep "^PASS_WARN_AGE" | awk '{ print $2 }')

standard=7 

if [ ! $value = $standard ]; then
	echo "Audit status: FAILED!"
elif [ $value = $standard ]; then
	echo "Audit status: PASSED!"
else
	echo ERROR: "FATAL ERROR, CONTACT SYSTEM ADMINISTRATOR!"
fi
#########################################################################
#7.4 Disable System Accounts

echo "7.4 Disable System Accounts"

current=$(egrep -v "^\+" /etc/passwd | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<1000 && $7!="/sbin/nologin" && $7!="/bin/false") { print $1 }')

if [ -z "$current" ]; then
	echo "Audit status: PASSED!"
elif [ ! -z "$current" ]; then
	echo "Audit status: FAILED!"
else
	echo "FATAL ERROR. PLEASE CONTACT YOUR SYSTEM ADMINISTRATOR!"
fi
#########################################################################
echo "7.5 Set Default Group for root Account"

current=$(grep "^root:" /etc/passwd | cut -f4 -d:)

if [ "$current" == 0 ]; then
        echo "Audit status: PASSED!"
else
        echo "Audit status: FAILED!"
fi
#########################################################################
echo "7.6 Set Default umask for Users"

current=$(egrep -h "\s+umask ([0-7]{3})" /etc/bashrc /etc/profile | awk '{print $2}')

counter=0

for line in ${current}
do
	if [ "${line}" != "077" ] 
	then
       		((counter++))	
	fi
done

if [ ${counter} == 0 ]
then 
	echo "Audit status: PASSED!"
else     
	echo "Audit status: FAILED!"
fi
#########################################################################
echo "7.7 Lock Inactive User Accounts"

current=$(useradd -D | grep INACTIVE | awk -F= '{print $2}')

if [ "${current}" -le 30 ] && [ "${current}" -gt 0 ]
then
        echo "Audit status: PASSED!"
else
        echo "Audit status: FAILED!"
fi
#########################################################################
echo "7.8 Ensure Password Fields Are Not Empty"
current=$(cat /etc/shadow | awk -F: '($2 == "") { print $1 }')

if [ "$current" = "" ];then
	echo "Audit status: PASSED!"
else
	echo "Audit status: FAILED!" 
fi
#########################################################################
echo "7.9 Verify No Legacy "+" Entries Exist in /etc/passwd, /etc/shadow and /etc/group files"

passwd=$(grep '^+:' /etc/passwd) 
shadow=$(grep '^+:' /etc/shadow)
group=$(grep '^+:' /etc/group)

if [ "$passwd" == "" ]  && [ "$shadow" == "" ] && [ "$group" == "" ];then
	echo "Audit Status: PASSED!"
else
	echo "Audit Status: FAILED!"
fi
#########################################################################
echo "7.10 Verify No UID 0 Accounts Exist Other Than Root"

current=$(/bin/cat /etc/passwd | /bin/awk -F: '($3 ==0) { print $1 }')

if [ "$current" = "root" ];then
	echo "Audit status: PASSED!"
else
	echo "Audit status: FAILED!"
fi
#########################################################################
echo "7.11 Ensure root PATH Integrity"

check=0

#Check for Empty Directory in PATH (::)
if [ "`echo $PATH | grep ::`" != "" ]
then
	#echo "Empty Directory in PATH (::)"
	((check++))
fi

#Check for Trailing : in PATH
if [ "`echo $PATH | grep :$`" != "" ]
then
	#echo "Trailing : in PATH"
	((check++))
fi

p=`echo $PATH | sed -e 's/::/:/' -e 's/:$//' -e 's/:/ /g'`
set -- $p
while [ "$1" != "" ]
do
	#Check if PATH contains .
        if [ "$1" = "." ]
        then
		#echo "PATH contains ."
		((check++))
		shift
		continue
        fi
	
	#Check if PATH entry is a directory
        if [ -d $1 ]
        then
                dirperm=`ls -ldH $1 | cut -f1 -d" "`
                #Check if Group Write permission is set on directory
		if [ `echo $dirperm | cut -c6` != "-" ]
                then
			#echo "Group Write permission set on directory $1"
			((check++))
                fi
		#Check if Other Write permission is set on directory
                if [ `echo $dirperm | cut -c9` != "-" ]
		then
			#echo "Other Write permission set on directory $1"
			((check++))
                fi
		
		#Check if PATH entry is owned by root
                dirown=`ls -ldH $1 | awk '{print $3}'`
                if [ "$dirown" != "root" ]
                then
                       #echo $1 is not owned by root
			((check++))
                fi
        else
		#echo $1 is not a directory
		((check++))
        fi
	shift
done

#echo ${check}
if [ ${check} == 0 ]
then
	echo "Audit status: PASSED!"
elif [ ${check} != 0 ]
then
	echo "Audit status: FAILED!"
else
	echo "FATAL ERROR. PLEASE CONTACT YOUR SYSTEM ADMINISTRATOR!"
fi
#########################################################################

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"
bold=$(tput bold)
normal=$(tput sgr0)

####################################### 7.12 #######################################

echo "------------------------------------------------------------------------------------------"
echo ' '
echo "${bold}7.12 Check Permissions on User Home Directories${normal}"
echo ' '
intUserAcc="$(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }')"

if [ -z "$intUserAcc" ]
then
        echo "There is no interactive user account."
        echo ' '
else
        /bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }' | while read -r line; do

                echo "Checking user home directory $line"
                permission="$(ls -ld $line)"
                echo " Permission is ${permission:0:10}"
                ## check 6th field ##
                if [ ${permission:5:1} == *"w"* ]
                then
                        echo -e "${RED} 6th field of permission is w ${NC}"
                else
                        echo -e "${GREEN} 6th field of permission is '-' ${NC}"
                fi

                ## check 8th field ##
                if [ ${permission:7:1} == "-" ]
                then
                        echo -e "${GREEN} 8th field of permission is '-' ${NC}"
                else
                        echo -e "${RED} 8th field of permission is not '-' ${NC}"
 fi

                ## check 9th field ##
                if [ ${permission:8:1} == "-" ]
                then
                        echo -e "${GREEN} 9th field of permission is '-' ${NC}"
                else
                        echo -e "${RED} 9th field of permission is not '-' ${NC}"
                fi

                ## check 10th field ##
                if [ ${permission:9:1} == "-" ]
                then
                        echo -e "${GREEN} 10th field of permission is '-' ${NC}"
                else
                        echo -e "${RED} 10th field of permission is not '-' ${NC}"
                fi
                echo " "
        done
fi

####################################### 7.13 #######################################

echo "------------------------------------------------------------------------------------------"
echo ' '
echo "${bold}7.13 Check User Dot File Permissions${normal}"
echo ' '

intUserAcc="$(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }')"

if [ -z "$intUserAcc" ]
then
        echo "There is no interactive user account."
        echo ' '
else
        /bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }' | while read -r line; do

                echo "Checking hidden files in user home directory $line"
                cd $line
                hiddenfiles="$(echo .*)"

                if [ -z "$hiddenfiles" ]
                then
echo " There is no hidden files"
                else
                        for file in ${hiddenfiles[*]}
                        do
                                permission="$(stat -c %A $file)"
                                echo " Checking hidden file $file"
                                echo "  Permission is $permission"

                                ## check 6th field ##
                                if [ ${permission:5:1} == *"w"* ]
                                then
                                        echo -e " ${RED} 6th field of permission is 'w' ${NC}"
                                else
                                        echo -e " ${GREEN} 6th field of permission is not 'w' ${NC}"
                                fi

                                ## check 9th field ##
                                if [ ${permission:8:1} == *"w"* ]
                                then
                                        echo -e " ${RED} 9th field of permission is 'w' ${NC}"
                                else
                                        echo -e " ${GREEN} 9th field of permission is not 'w' ${NC}"
                                fi
 echo ' '
                        done
                fi
        done
fi

####################################### 7.14 #######################################

echo "------------------------------------------------------------------------------------------"
echo ' '
echo "${bold}7.14 Check Existence of and Permissions on User .netrc Files${normal}"
echo ' '
intUserAcc="$(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }')"

if [ -z "$intUserAcc" ]
then
        echo " There is no interactive user account."
        echo ' '
else
        /bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }' | while read -r line; do
 echo "Checking user home directory $line"
                permission="$(ls -al $line | grep .netrc)"
                if  [ -z "$permission" ]
                then
                        echo " There is no .netrc file"
                        echo ' '
                else
                        ls -al $line | grep .netrc | while read -r netrc; do
                                echo " $netrc"

                                ## check 5th field ##
                                if [ ${netrc:4:6} == "------" ]
                                then
                                        echo -e " ${GREEN} 5th-10th field of permission is '------' ${NC}"
                                else
                                        echo -e " ${RED} 5th-10th field of permission is not '------' ${NC}"
                                fi

                                echo ' '
                        done
                fi
        done
fi

#################################### 7.15 ####################################

echo "------------------------------------------------------------------------------------------"
echo ' '
echo "${bold}7.15 Check for Presence of User .rhosts Files${normal}"
echo ' '

intUserAcc="$(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }')"

if [ -z "$intUserAcc" ]
then
        echo "There is no interactive user account."
        echo ' '
else
        /bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }' | while read -r line; do
                echo "Checking user home directory $line"
                rhostsfile="$(ls -al $line | grep .rhosts)"

 if  [ -z "$rhostsfile" ]
                then
                        echo " There is no .rhosts file"
                        echo ' '
                else
                        ls -al $line | grep .rhosts | while read -r rhosts; do
                                for file in $rhosts
                                do
                                        if [[ $file = *".rhosts"* ]]
                                        then
                                                echo " Checking .rhosts file $file"
                                                #check if file created user matches directory user
                                                filecreateduser=$(stat -c %U $line/$file)
                                                if [[ $filecreateduser = *"$line"* ]]
                                                then
                                                       echo -e "${GREEN} $file created user is the same user in the directory${NC}"

 echo ' '
                                                else
                                                        echo -e "${RED} $file created user is not the same in the directory. This file should be deleted! ${NC}"

 echo ' '
                                                fi
                                        fi
                                done                    
                        done
                fi
        done
fi

echo "------------------------------------------------------------------------------------------"
echo ' '
echo "${bold}End of verification.${normal}"
echo ' '

#!/bin/bash
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"
bold=$(tput bold)
normal=$(tput sgr0)

####################################### 7.16 ######################################

echo "------------------------------------------------------------------------------------------"
echo ' '
echo "${bold}7.16 Check Groups in /etc/passwd${normal}"
echo ' '

for i in $(cut -s -d: -f4 /etc/passwd | sort -u); do
	grep -q -P "^.*?:x:$i:" /etc/group
	if [ $? -ne 0 ]
	then
		echo -e "${RED}Group $i is referenced by /etc/passwd but does not exist in /etc/group${NC}"
	else
		echo -e "${GREEN}Group $i is referenced by /etc/passwd and exist in /etc/group${NC}"
	fi
done

####################################### 7.17 ######################################

echo "------------------------------------------------------------------------------------------"
echo ' '
echo "${bold}7.17 Check That Users Are Assigned Valid Home Directories && Home Directory Ownership is Correct${normal}"
echo ' '

cat /etc/passwd | awk -F: '{ print $1,$3,$6 }' | while read user uid dir; do

	#checking validity of  user assigned home directories
	if [ $uid -ge 500 -a ! -d"$dir" -a $user != "nfsnobody" ]
	then
		echo -e "${RED}The home directory $dir of user $user does not exist.${NC}"
		
	else
		echo -e "${GREEN}The home directory $dir of user $user exist.${NC}"
	fi

	#checking user home directory ownership
	if [ $uid -ge 500 -a -d"$dir" -a $user != "nfsnobody" ]
	then
		owner=$(stat -L -c "%U" "$dir")
		if [ "$owner" != "$user" ]
		then
			echo -e "${RED}The home directory ($dir) of user $user is owned by $owner.${NC}"
		else

			echo -e "${GREEN}Then home directory ($dir) of user $user is owned by $owner.${NC}"
		fi
	fi
		
	
done

####################################### 7.18 ######################################

echo "------------------------------------------------------------------------------------------"
echo ' '
echo "${bold}7.18 Check for Duplicate UIDs ${normal}"
echo ' ' 

/bin/cat /etc/passwd | /bin/cut -f3 -d":" | /bin/sort -n | /usr/bin/uniq -c | while read x; do
	[ -z "${x}" ] && break
	set - $x
	if [ $1 -gt 1 ]
	then
		users=`/bin/gawk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | /user/bin/xargs`
		echo -e "${RED}Duplicate UID $2: ${users}${NC}"
	else
		echo -e "${GREEN}There is no duplicate UID $2 ${NC}" 
	fi

done

####################################### 7.19 ######################################

echo "------------------------------------------------------------------------------------------"
echo ' '
echo "${bold}7.19 Check for Duplicate GIDs ${normal}"
echo ' '

/bin/cat /etc/group | /bin/cut -f3 -d"." | /bin/sort -n | /usr/bin/uniq -c | while read x; do
	[ -z "${x}" ] && break
	set - $x
	if [ $1 -gt 1 ]
	then
		grp=`/bin/gawk -F: '($3 == n) { print $1 }' n=$2 /etc/group | xargs`
		echo -e "${RED}Duplicate GID $2: $grp$.{NC}"
	else
		echo -e "${GREEN}There is no duplicated GID $2 ${NC}"
	fi
done

#!/bin/bash

#7.20 - Check that reserved UIDs are assigned to only system accounts

echo "7.20 Check that reserved UIDs are assigned to only system accounts."

systemaccount=(root bin daemon adm lp sync shutdown halt mail news uucp operator games gopher ftp nobody nscd vcsa rpc mailnull smmsp pcap ntp dbus avahi sshd rpcuser nfsnobody haldaemon avahi-autoipd distcache apache oprofile webalizer dovecot squid named xfs gdm sabayon usbmuxd rtkit abrt saslauth pulse postfix tcpdump systemd-network tss radvd [51]=qemu)

nameCounter=0
systemNameFile="/etc/passwd"
while IFS=: read -r f1 f2 f3 f4 f5 f6 f7
do
	if [[ $f3 -lt 500 ]]
	then
		for i in ${systemaccount[*]}
		do
			if [[ $f1 == $i ]]
			then
				nameCounter=$((nameCounter+1))
			else
				nameCounter=$((nameCounter+0))
			fi
		done

		if [[ $nameCounter < 1 ]]
		then
			echo "User '$f1' is not a system account but has a reserved UID of $f3."
		fi
		nameCounter=0
	fi
done <"$systemNameFile"



#7.21 - Duplicate User Names

echo ""

echo "7.21 Check for duplicate user names."

cat /etc/passwd | cut -f1 -d":" | /bin/sort -n | /usr/bin/uniq -c |
while read x ; do
[ -z "${x}" ] && break
set - $x
if [ $1 -gt 1 ]; then
uids=`/bin/gawk -F: '($1 == n) { print $3 }' n=$2 /etc/passwd | xargs`
echo "There are $1 duplicate user name titled '$2' found in the system and its respective UIDs are ${uids}."
fi
done


#7.22 - Duplicate Group Names

echo ""

echo "7.22 Check for duplicate group names."

cat /etc/group | cut -f1 -d":" | /bin/sort -n | /usr/bin/uniq -c | 
while read x ; do
[ -z "${x}" ] && break
set - $x
if [ $1 -gt 1 ]; then
gids=`/bin/gawk -F: '($1 == n) { print $3 }' n=$2 /etc/group | xargs`
echo "There are $1 duplicate group name titled '$2' found in the system and its respective UIDs are ${gids}."
fi
done


#7.23 - Check for presence of user .forward files

echo ""

echo "7.23 Check for presence of user ./forward files."

for dir in `/bin/cat /etc/passwd | /bin/awk -F: '{ print $6 }'`; do
if [ ! -h "$dir/.forward" -a -f "$dir/.forward" ]; then 
echo ".forward file titled '$dir/.forward' found in the system."
fi
done

echo "8.1 Set Warning Banner for Standard Login Services"

current=$(cat /etc/motd)

standard="WARNING: UNAUTHORIZED USERS WILL BE PROSECUTED!"

if [ "$current" == "$standard" ]; then
        echo "Audit status: PASSED!"
else
        echo "Audit status: FAILED!"
fi
#########################################################################

echo "8.2 Remove OS Information from Login Warning Banners"

current1=$(egrep '(\\v|\\r|\\m|\\s)' /etc/issue)
current2=$(egrep '(\\v|\\r|\\m|\\s)' /etc/motd)
current3=$(egrep '(\\v|\\r|\\m|\\s)' /etc/issue.net)

string1="\\v"
string2="\\r"
string3="\\m"
string4="\\s"

if [[ $current1 =~ $string1 || $current1 =~ $string2 || $current1 = ~$string3 || $current1 =~ $string4 ]]; then
        echo "Audit status: FAILED! [OS Information found in /etc/issue]"
else
        echo "/etc/issue has no issues. Continuing with verification"
fi

if [[ $current2 =~ $string1 || $current2 =~ $string2 || $current2 = ~$string3 || $current2 =~ $string4 ]]; then
        echo "Audit status: FAILED! [OS Information found in /etc/motd]"
else
        echo "/etc/motd has no issues. Continuing with verification"
fi

if [[ $current3 =~ $string1 || $current3 =~ $string2 || $current3 = ~$string3 || $current4 =~ $string4 ]]; then
        echo "Audit status: FAILED! [OS Information found in /etc/issue.net]"
else
        echo "/etc/issue.net has no issues. Continuing with verification"
fi



#!/bin/bash

#Check whether Anacron Daemon is enabled or not
if rpm -q cronie-anacron
then
	echo "Anacron Daemon has been installed."
else
	echo "Please ensure that you have Anacron Daemon has been installed."
fi

#Check if Crond Daemon is enabled
checkCronDaemon=$(systemctl is-enabled crond)
if [[ $checkCronDaemon = "enabled" ]]
then
	echo "Crond Daemon has been enabled."
else
	echo "Please ensure that you have enabled crond Daemon."
fi

#Check if the correct permissions is configured for /etc/anacrontab
anacrontabFile="/etc/anacrontab"
if [ -e "$anacrontabFile" ]
then
	echo "The Anacrontab file ($anacrontabFile) exists."
	
	anacrontabPerm=$(stat -c "%a" "$anacrontabFile")
	anacrontabRegex="^[0-7]00$"
	if [[ $anacrontabPerm =~ $anacrontabRegex ]]
	then
		echo "Permissions has been set correctly for $anacrontabFile."
	else
		echo "Ensure that the permissions has been set correctly for $anacrontabFile."
	fi

	anacrontabOwn=$(stat -c "%U" "$anacrontabFile")
	if [ $anacrontabOwn = "root" ]
	then
		echo "Owner of the file ($anacrontabFile): $anacrontabOwn"
	else
		echo "Owner of the file ($anacrontabFile): $anacrontabOwn"
	fi

	anacrontabGrp=$(stat -c "%G" "$anacrontabFile")
	if [ $anacrontabGrp = "root" ]
	then
		echo "Group owner of the file ($anacrontabFile): $anacrontabGrp"
	else
		echo "Group owner of the file ($anacrontabFile): $anacrontabGrp. Please ensure that the group owner is root instead."
	fi
else
	echo "The Anacrontab file does not exist. Please ensure that you have Anacron Daemon installed."
fi

#Check if the correct permissions has been configured for /etc/crontab
crontabFile="/etc/crontab"
if [ -e "$crontabFile" ]
then
	crontabPerm=$(stat -c "%a" "$crontabFile")
	crontabRegex="^[0-7]00$"
	if [[ $crontabPerm =~ $crontabRegex ]]
	then
		echo "Permissions has been set correctly for $crontabFile."
	else
		echo "Ensure that the permissions has been set correctly for $crontabFile."
	fi

	crontabOwn=$(stat -c "%U" "$crontabFile")
	if [ $crontabOwn = "root" ]
	then
		echo "Owner of the file ($crontabFile): $crontabOwn"
	else
		echo "Owner of the file ($crontabFile): $crontabOwn. Please ensure that the owner of the file is root instead."
	fi

	crontabGrp=$(stat -c "%G" "$crontabFile")
	if [ $crontabGrp = "root" ]
	then
		echo "Group owner of the file ($crontabFile): $crontabGrp"
	else
		echo "Group owner of the file ($crontabFIle): $crontabGrp. Please ensure that the group owner of the file is root instead."
	fi

else
	echo "The crontab file ($crontabFile) does not exist."
fi

#Check if the correct permissions has been set for /etc/cron.XXXX
checkCronHDWMPerm(){
	local cronHDWMType=$1
	local cronHDWMFile="/etc/cron.$cronHDWMType"

	if [ -e "$cronHDWMFile" ]
	then
		local cronHDWMPerm=$(stat -c "%a" "$cronHDWMFile")
		local cronHDWMRegex="^[0-7]00$"
		if [[ $cronHDWMPerm =~ $cronHDWMRegex ]]
		then
			echo "Permissions has been set correctly for $cronHDWMFile."
		else
			echo "Ensure that the permissions has been set correctly for $cronHDWMFile."
		fi

		local cronHDWMOwn="$(stat -c "%U" "$cronHDWMFile")"
		if [ $cronHDWMOwn = "root" ]
		then
			echo "Owner of the file ($cronHDWMFile): $cronHDWMOwn"
		else
			echo "Owner of the file ($cronHDWMFile): $cronHDWMOwn. Please ensure that the owner of the file is root instead."
		fi

		local cronHDWMGrp="$(stat -c "%G" "$cronHDWMFile")"
		if [ $cronHDWMGrp = "root" ]
		then
			echo "Group Owner of the file ($cronHDWMFile): $cronHDWMGrp"
		else
			echo "Group Owner of the file ($cronHDWMFile): $cronHDWMGrp. Please ensure that the group owner of the file is root instead."
		fi
	else
		echo "File ($cronHDWMFile) does not exist."
	fi	
}

checkCronHDWMPerm "hourly"
checkCronHDWMPerm "daily"
checkCronHDWMPerm "weekly"
checkCronHDWMPerm "monthly"

#Check if the permissions has been set correctly for /etc/cron.d
cronDFile="/etc/cron.d"
if [ -e "$cronDFile" ]
then
	echo "The cron.d file ($cronDFile) exists."
	cronDPerm=$(stat -c "%a" "$cronDFile")
	cronDRegex="^[0-7]00$"
	if [[ $cronDPerm =~ $cronDRegex ]]
	then
		echo "Permissions has been set correctly for $cronDFile."
	else
		echo "Ensure that the permissions has been set correctly for $cronDFile."
	fi

	cronDOwn=$(stat -c "%U" "$cronDFile")
	if [ $cronDOwn = "root" ]
	then
		echo "Owner of the file ($cronDFile): $cronDOwn"
	else
		echo "Owner of the file ($cronDFile): $cronDOwn. Please ensure that the owner of the file is root instead."
	fi

	cronDGrp=$(stat -c "%G" "$cronDFile")
	if [ $cronDGrp = "root" ]
	then
		echo "Group owner of the file ($cronDFile): $cronDGrp"
	else
		echo "Group owner of the file ($cronDFile): $cronDGrp. Please ensure that the group owner of the file is root instead."
	fi
else
	echo "The cron.d file ($cronDFile) does not exist."
fi

#Check if /etc/at.deny is deleted and that a /etc/at.allow exists and check the permissions of the /etc/at.allow file
atDenyFile="/etc/at.deny"
if [ -e "$atDenyFile" ]
then
	echo "Please ensure that the file $atDenyFile is deleted."
else
	echo "$atDenyFile is deleted as recommended."
fi

atAllowFile="/etc/at.allow"
if [ -e "$atAllowFile" ]
then
        atAllowPerm=$(stat -c "%a" "$atAllowFile")
        atAllowRegex="^[0-7]00$"
        if [[ $atAllowPerm =~ $atAllowRegex ]]
        then
            	echo "Permissions has been set correctly for $atAllowFile."
        else
            	echo "Ensure that the permissions has been set correctly for $atAllowFile."
        fi

	atAllowOwn=$(stat -c "%U" "$atAllowFile")
        if [ $atAllowOwn = "root" ]
        then
            	echo "Owner of the file ($atAllowFile): $atAllowOwn"
        else
            	echo "Owner of the file ($atAllowFile): $atAllowOwn. Please ensure that the owner of the file is root instead."
        fi

	atAllowGrp=$(stat -c "%G" "$atAllowFile")
	if [ $atAllowGrp = "root" ]
	then
		echo "Group owner of the file ($atAllowFile): $atAllowGrp"
	else
		echo "Group owner of the file ($atAllowFile): $atAllowGrp. Please ensure that the group owner of the file is root instead."
	fi
else
	echo "Please ensure that a $atAllowFile is created for security purposes."
fi

#Check if /etc/cron.deny is deleted and that a /etc/cron.allow exists and check the permissions of the /etc/cron.allow file
cronDenyFile="/etc/cron.deny"
if [ -e "$cronDenyFile" ]
then
        echo "Please ensure that the file $cronDenyFile is deleted."
else
	echo "$cronDenyFile is deleted as recommended."
fi

cronAllowFile="/etc/cron.allow"
if [ -e "$cronAllowFile" ]
then
    	cronAllowPerm=$(stat -c "%a" "$cronAllowFile")
       	cronAllowRegex="^[0-7]00$"
        if [[ $cronAllowPerm =~ $cronAllowRegex ]]
        then
               	echo "Permissions has been set correctly for $cronAllowFile."
        else
               	echo "Ensure that the permissions has been set correctly for $cronAllowFile."
       	fi

       	cronAllowOwn=$(stat -c "%U" "$cronAllowFile")
        if [ $cronAllowOwn = "root" ]
        then
                echo "Owner of the file ($cronAllowFile): $cronAllowOwn"
        else
               	echo "Owner of the file ($atAllowFile): $cronAllowOwn. Please ensure that the owner of the file is root instead."
    	fi

    	cronAllowGrp=$(stat -c "%G" "$cronAllowFile")
       	if [ $cronAllowGrp = "root" ]
        then
            	echo "Group owner of the file ($cronAllowFile): $cronAllowGrp"
        else
            	echo "Group owner of the file ($cronAllowFile): $cronAllowGrp. Please ensure that the group owner of the file is root instead."
        fi
else
    	echo "Please ensure that a $cronAllowFile is created for security purposes."
fi

#!/bin/bash

#10.1 verification 
chksshprotocol=`grep "^Protocol 2" /etc/ssh/sshd_config`

if [ "$chksshprotocol" == "Protocol 2" ]
then
	echo "SSH (Protocol) - Pass"
else
	echo "SSH (Protocol) - Fail"
fi

#10.2 verification
chksshloglevel=`grep "^LogLevel INFO" /etc/ssh/sshd_config`

if [ "$chksshloglevel" == "LogLevel INFO" ]
then
	echo "SSH (LogLevel) - Pass"
else
	echo "SSH (LogLevel) - Fail"
fi

#10.3 verification 
deterusergroupownership=`/bin/ls -l /etc/ssh/sshd_config | grep "root root" | grep "\-rw-------"`

if [ -n "deterusergroupownership" ] #-n means not null, -z means null
then
	echo "Ownership (User & Group)- Pass"
else
	echo "Ownership (User & Group)- Fail"
fi

#10.4 verification 
chkx11forwarding=`grep "^X11Forwarding no" /etc/ssh/sshd_config`

if [ "$chkx11forwarding" == "X11Forwarding no" ]
then
	echo "SSH (X11Forwarding no) - Pass"
else
	echo "SSH (X11Forwarding no) - Fail"
fi

#10.5 verification
maxauthtries=`grep "^MaxAuthTries 4" /etc/ssh/sshd_config`

if [ "$maxauthtries" == "MaxAuthTries 4" ]
then
	echo "SSH (MaxAuthTries 4) - Pass"
else
	echo "SSH (MaxAuthTries 4) - Fail"
fi

#10.6 verification
ignorerhosts=`grep "^IgnoreRhosts yes" /etc/ssh/sshd_config`

if [ "$ignorerhosts" == "IgnoreRhosts yes" ]
then
	echo "SSH (IgnoreRhosts yes) - Pass"
else
	echo "SSH (IgnoreRhosts yes) - Fail"
fi

#10.7 verification
hostbasedauthentication=`grep "^HostbasedAuthentication no" /etc/ssh/sshd_config`

if [ "$hostbasedauthentication" == "HostbasedAuthentication no" ]
then
	echo "SSH (HostbasedAuthentication no) - Pass"
else
	echo "SSH (HostbasedAuthentication no) - Fail"
fi


#10.8 verification
chksshrootlogin=`grep "^PermitRootLogin" /etc/ssh/sshd_config`

if [ "$chksshrootlogin" == "PermitRootLogin no" ]
then
	echo "SSH (Permit Root Login) - Pass"
else
	echo "SSH (Permit Root Login) - Fail"
fi

#10.9 verification
chksshemptypswd=`grep "^PermitEmptyPasswords" /etc/ssh/sshd_config`

if [ "$chksshemptypswd" == "PermitEmptyPasswords no" ]
then
	echo "SSH (Permit Empty Passwords) - Pass"
else
	echo "SSH (Permit Empty Passwords) - Fail"
fi

#10.10 verification
chksshcipher=`grep "Ciphers" /etc/ssh/sshd_config`

if [ "$chksshcipher" == "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" ]
then
	echo "SSH (Cipher) - Pass"
else
	echo "SSH (Cipher) - Fail"
fi

#10.11 verification
chksshcai=`grep "^ClientAliveInterval" /etc/ssh/sshd_config`
chksshcacm=`grep "^ClientAliveCountMax" /etc/ssh/sshd_config`

if [ "$chksshcai" == "ClientAliveInterval 300" ]
then
	echo "SSH (ClientAliveInterval) - Pass"
else
	echo "SSH (ClientAliveInterval) - Fail"
fi

if [ "$chksshcacm" == "ClientAliveCountMax 0" ]
then
	echo "SSH (ClientAliveCountMax) - Pass"
else
	echo "SSH (ClientAliveCountMax) - Fail"
fi

#10.12 verification		*NOTE: Manually created users and groups as question was not very specific*
chksshalwusrs=`grep "^AllowUsers" /etc/ssh/sshd_config`
chksshalwgrps=`grep "^AllowGroups" /etc/ssh/sshd_config`
chksshdnyusrs=`grep "^DenyUsers" /etc/ssh/sshd_config`
chksshdnygrps=`grep "^DenyGroups" /etc/ssh/sshd_config`

if [ -z "$chksshalwusrs" -o "$chksshalwusrs" == "AllowUsers[[:space:]]" ]
then
	echo "SSH (AllowUsers) - Fail"
else
	echo "SSH (AllowUsers) - Pass"
fi

if [ -z "$chksshalwgrps" -o "$chksshalwgrps" == "AllowGroups[[:space:]]" ]
then
	echo "SSH (AllowGroups) - Fail"
else
	echo "SSH (AllowGroups) - Pass"
fi

if [ -z "$chksshdnyusrs" -o "$chksshdnyusrs" == "DenyUsers[[:space:]]" ]
then
	echo "SSH (DenyUsers) - Fail"
else
	echo "SSH (DenyUsers) - Pass"
fi

if [ -z "$chksshdnygrps" -o "$chksshdnygrps" == "DenyGroups[[:space:]]" ]
then
	echo "SSH (DenyGroups) - Fail"
else	
	echo "SSH (DenyGroups) - Pass"
fi

#10.13 verification
chksshbanner=`grep "Banner" /etc/ssh/sshd_config | awk '{ print $2 }'`

if [ "$chksshbanner" == "/etc/issue.net" -o "$chksshbanner" == "/etc/issue" ]
then
	echo "SSH (Banner) - Pass"
else
	echo "SSH (Banner) - Fail"
fi#!/bin/bash
#11.1
checkPassAlgo=$(authconfig --test | grep hashing | grep sha512)
checkPassRegex=".*sha512"
if [[ $checkPassAlgo =~ $checkPassRegex ]]
then
	echo "The password hashing algorithm is set to SHA-512 as recommended."
else
	echo "Please ensure that the password hashing algorithm is set to SHA-512 as recommended."
fi 



#11.2
pampwconf=$(grep pam_pwquality.so /etc/pam.d/system-auth)
correctpampwconf="password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type="
if [[ $pampwconf == $correctpampwconf ]]
then
echo "Recommended settings is already configured."
else
echo "Please configure the settings again."
fi

minlen=$(grep "minlen" /etc/security/pwquality.conf)
dcredit=$(grep "dcredit" /etc/security/pwquality.conf)
ucredit=$(grep "ucredit" /etc/security/pwquality.conf)
ocredit=$(grep "ocredit" /etc/security/pwquality.conf)
lcredit=$(grep "lcredit" /etc/security/pwquality.conf)
correctminlen="# minlen = 14"
correctdcredit="# dcredit = -1"
correctucredit="# ucredit = -1"
correctocredit="# ocredit = -1"
correctlcredit="# lcredit = -1"

if [[ $minlen == $correctminlen && $dcredit == $correctdcredit && $ucredit == $correctucredit && $ocredit == $correctocredit && $lcredit == $correctlcredit ]]
then
echo "Recommended settings is already configured."
else
echo "Please configure the settings again."
fi




#11.3
faillockpassword=$(grep "pam_faillock" /etc/pam.d/password-auth)
faillocksystem=$(grep "pam_faillock" /etc/pam.d/system-auth)

read -d '' correctpamauth << "BLOCK" 
auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900
auth        [default=die] pam_faillock.so authfail audit deny=5
auth        sufficient    pam_faillock.so authsucc audit deny=5
account     required      pam_faillock.so
BLOCK

if [[ $faillocksystem == "$correctpamauth" && $faillockpassword == "$correctpamauth" ]]
then
echo "Recommended settings is already configured."
else
echo "1Please configure the settings again."
fi




#11.4
pamlimitpw=$(grep "remember" /etc/pam.d/system-auth)
if [[ $pamlimitpw == *"remember=5"* ]]
then 
echo "Recommended settings is already configured."
else
echo "Please configure the settings again."
fi



#11.5
systemConsole="/etc/securetty"
systemConsoleCounter=0
while read -r line; do
	if [ -n "$line" ]
	then
		[[ "$line" =~ ^#.*$ ]] && continue
		if [ "$line" == "vc/1" ] || [ "$line" == "tty1" ]
		then
			systemConsoleCounter=$((systemConsoleCounter+1))
		else
			systemConsoleCounter=$((systemConsoleCounter+1))
		fi
	fi
done < "$systemConsole"

if [ $systemConsoleCounter != 2 ]
then
	echo "Please configure the settings again."
else
	echo "Recommended settings is already configured."
fi




#11.6
pamsu=$(grep pam_wheel.so /etc/pam.d/su | grep required)
if [[ $pamsu =~ ^#auth.*required ]]
then
echo "Please configure the settings again."
else
echo "Recommended settings is already configured."
fi

pamwheel=$(grep wheel /etc/group)
if [[ $pamwheel =~ ^wheel.*root ]]
then
echo "Recommended settings is already configured."
else
echo "Please configure the settings again."
fi

