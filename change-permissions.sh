#!/bin/bash

workdir=/scripts
logfile=$workdir/tmp/change-permissions.run
finallogfile=$workdir/log/change-permissions-$(date +%y%m%d)

(
cd $workdir/
if [ -a $logfile ] ; then
	echo ""
	echo "Script Is Running! check " $logfile
	echo ""
	exit; 
fi
echo "******************************************************"
echo "* Starting permissions update process..." $(date +%y%m%d) "*"
echo "******************************************************"

for group in `ls /u/`;
do
	echo "Change $group Permissions"
	echo
	for i in `ls /u/$group/`;
	do 
	if [ $i != "expired" -a $i != "Expired" -a $i != "MOVED" -a $i != ".snapshot" -a $i != "TrashCan" ]  ; 
	then 
		echo User Name - $i 
		echo
		echo 1: Change $i folder Permissions
		cd /u/$group/$i/
		for dir in `ls --hide --escape WWW | egrep WWW`;  
		do
			if [ -d $dir ] ; 
			then
				chmod 711 $dir -R;
			else
				chmod 711 $dir;
			fi
		done
		echo
		echo 2: Change $i folder Ownership
		chown $i:$group /u/$group/$i/ -R
		echo
		if [ -d /u/$group/$i/WWW/ ] ; then
			echo 3: Change $i WWW/ folder Permissions 
			chmod 755 /u/$group/$i/WWW/ -R
			find /u/$group/$i/WWW/ -type d -print -exec chmod 755 "{}" \;
			find /u/$group/$i/WWW/ -type f -name '*.cgi' -print -exec chmod 755 "{}" \;
			find /u/$group/$i/WWW/ -type f ! -name '*.cgi' -print -exec chmod 644 "{}" \;
			echo
		fi
	fi
	done
	echo
	echo "Done !!"
done
) 2>&1 | tee -a $logfile

mv $logfile $finallogfile
