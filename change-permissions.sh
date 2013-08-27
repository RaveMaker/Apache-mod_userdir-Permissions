#!/bin/bash

# Set permissions of Users and Groups in this format: 'home\group\username'
#
# by RaveMaker - http://ravemaker.net

# Load settings
if [ -f settings.cfg ] ; then
    echo "Loading settings..."
    source settings.cfg
else
    echo "ERROR: Create settings.cfg (from settings.cfg.example)"
    exit
fi;

workdir=`pwd`
logfile=$workdir/tmp/change-permissions.run
finallogfile=$workdir/log/change-permissions-$(date +%y%m%d)

(
echo "******************************************************"
echo "* Starting permissions update process..." $(date +%y%m%d) "*"
echo "******************************************************"

for group in `ls $homedir/`;
do
	echo "Change $group Permissions"
	echo
	for i in `ls $homedir/$group/`;
	do 
	if [ $i != "expired" -a $i != "Expired" -a $i != "MOVED" -a $i != ".snapshot" -a $i != "TrashCan" ]  ; 
	then 
		echo User Name - $i 
		echo
		echo 1: Change $i folder Permissions
		cd $homedir/$group/$i/
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
		chown $i:$group $homedir/$group/$i/ -R
		echo
		if [ -d $homedir/$group/$i/WWW/ ] ; then
			echo 3: Change $i WWW/ folder Permissions 
			chmod 755 /$homedir/$group/$i/WWW/ -R
			find $homedir/$group/$i/WWW/ -type d -print -exec chmod 755 "{}" \;
			find $homedir/$group/$i/WWW/ -type f -name '*.cgi' -print -exec chmod 755 "{}" \;
			find $homedir/$group/$i/WWW/ -type f ! -name '*.cgi' -print -exec chmod 644 "{}" \;
			echo
		fi
	fi
	done
	echo
	echo "Done !!"
done
) 2>&1 | tee -a $logfile

mv $logfile $finallogfile
