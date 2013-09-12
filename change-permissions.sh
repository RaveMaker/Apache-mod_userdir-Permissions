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

WorkDir=`pwd`
LogFile=$WorkDir/tmp/change-permissions.run
FinalLogFile=$WorkDir/log/change-permissions-$(date +%y%m%d)

(
echo "******************************************************"
echo "* Starting permissions update process..." $(date +%y%m%d) "*"
echo "******************************************************"

for Group in `ls $HomeDir/`;
do
	echo "Change $Group Permissions"
	echo
	for User in `ls $HomeDir/$Group/`;
	do 
	if [ $User != "expired" -a $User != "Expired" -a $User != "MOVED" -a $User != ".snapshot" -a $User != "TrashCan" ]  ; 
	then 
		echo "-----------------"
		echo
		echo User Name - $User 
		echo
		echo 1: Change $User folder Permissions
		cd $HomeDir/$Group/$User/
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
		echo 2: Change $User folder Ownership
		chown $User:$Group $HomeDir/$Group/$User/ -R
		echo
		if [ -d $HomeDir/$Group/$User/WWW/ ] ; then
			echo 3: Change $User WWW/ folder Permissions 
			chmod 755 /$HomeDir/$Group/$User/WWW/ -R
			find $HomeDir/$Group/$User/WWW/ -type d -print -exec chmod 755 "{}" \;
			find $HomeDir/$Group/$User/WWW/ -type f -name '*.cgi' -print -exec chmod 755 "{}" \;
			find $HomeDir/$Group/$User/WWW/ -type f ! -name '*.cgi' -print -exec chmod 644 "{}" \;
			echo
		fi
	fi
	done
	echo
	echo "Done !!"
done
) 2>&1 | tee -a $LogFile

mv $LogFile $FinalLogFile
