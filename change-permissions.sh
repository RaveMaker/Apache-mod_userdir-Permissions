#!/bin/bash

#Load settings.cfg
if [ -f settings.cfg ] ; then
    echo "Loading settings..."
        source settings.cfg
else
    echo "ERROR: Create settings.cfg (from settings.cfg.example)"
    exit
fi;

#Check if shell is interactive
#Add to crontab first row CRONJOB="1" 
if [ ! -z "$CRONJOB" ]; then
        #Define Colors
        red=""
        green=""
        nocolor=""
else
        #Define Colors
        red='\e[0;31m'
        green='\e[0;32m'
        nocolor='\e[0m'
fi

#Show Help
if [ "$1" = "--help" -o "$1" = "-h" -o "$1" = "-help" ] ; then
	echo ""
	echo "Change permissions command help:"
	echo ""
	echo "[ -g|-G ] - Select group"
	echo "[ -u|-U ] - Select user"
	echo ""
	echo "[ -h|-help|--help ] -  Shows help"
	echo ""
	echo "Example: ./change-permissions.sh -g mygroup -u myuser"
	exit
fi

#Check if cron is still running
if [ -a $logfile ] ; then
	echo ""
	echo -e "${red}Script Is Running! check $logfile${nocolor}"
	echo ""
	exit ;
fi

#Check Syntax
if ([ "$1" = "-u" -o "$1" = "-U" ] && [ "$2" = "-g" -o "$2" = "-G" -o -z "$2" ]); then 
	echo "Check syntax - run with -h/-help/--help for help"
	exit
fi
if ([ "$1" = "-g" -o "$1" = "-G" ] && [ "$2" = "-u" -o "$2" = "-U" -o -z "$2" ]); then 
	echo "Check syntax - run with -h/-help/--help for help"
	exit
fi
if ([ "$2" = "-u" -o "$2" = "-U" ] && [ "$3" = "-g" -o "$3" = "-G" -o -z "$3" ]); then 
	echo "Check syntax - run with -h/-help/--help for help"
	exit
fi
if ([ "$2" = "-g" -o "$2" = "-G" ] && [ "$3" = "-u" -o "$3" = "-U" -o -z "$3" ]); then 
	echo "Check syntax - run with -h/-help/--help for help"
	exit
fi
if ([ "$3" = "-u" -o "$3" = "-U" ] && [ "$4" = "-g" -o "$4" = "-G" -o -z "$4" ]); then 
	echo "Check syntax - run with -h/-help/--help for help"
	exit
fi
if ([ "$3" = "-g" -o "$3" = "-G" ] && [ "$4" = "-u" -o "$4" = "-U" -o -z "$4" ]); then 
	echo "Check syntax - run with -h/-help/--help for help"
	exit
fi

#Check Parameters
if [ "$1" = "-u" -o "$1" = "-U" ] ; then 
	user=$2
elif [ "$1" = "-g" -o "$1" = "-G" ] ; then
	group=$2
fi
if [ "$3" = "-u" -o "$3" = "-U" ] ; then 
	user=$4
elif [ "$3" = "-g" -o "$3" = "-G" ] ; then
	group=$4
fi

#Change permissions
function set-permissions
{
	if [ $user != "expired" -a $user != "Expired" -a $user != "MOVED" -a $user != ".snapshot" -a $user != "TrashCan" -a $user != "Moved" ] ;
	then
		echo -e "${green}=================================================${nocolor}"
		echo
		echo -e "Change ${red}$group${nocolor} Permissions"
		echo
		echo -e "User Name - ${red}$user${nocolor}"
		echo
		cd "$homedir/$group/$user/"
		echo -n "Changed to folder: "
		echo `pwd`
		echo
		echo -e "1: Change ${red}$user${nocolor} folder Permissions"
		chmod 711 "$homedir/$group/$user/" ; 1> /dev/null
		if [ ! -d "$homedir/$group/$user/Desktop/" ] ; then
			echo -e "Creating folder: ${red}Desktop${nocolor}"
			mkdir "$homedir/$group/$user/Desktop"
		fi
		if [ ! -d "$homedir/$group/$user/My Documents/" ] ; then
			echo -e "Creating folder: ${red}My Documents${nocolor}"
			mkdir "$homedir/$group/$user/My Documents"
		fi
		if [ ! -d "$homedir/$group/$user/Downloads/" ] ; then
			echo -e "Creating folder: ${red}Downloads${nocolor}"
			mkdir "$homedir/$group/$user/Downloads"
		fi
		if [ ! -d "$homedir/$group/$user/Favorites/" ] ; then
			echo -e "Creating folder: ${red}Favorites${nocolor}"
			mkdir "$homedir/$group/$user/Favorites"
		fi
		cd "My Documents"
		if [ ! -d "$homedir/$group/$user/My Documents/My Music/" ] ; then
			echo -e "Creating folder: ${red}My Music${nocolor}"
			mkdir "$homedir/$group/$user/My Documents/My Music"
		fi
		if [ ! -d "$homedir/$group/$user/My Documents/My Videos/" ] ; then
			echo -e "Creating folder: ${red}My Videos${nocolor}"
			mkdir "$homedir/$group/$user/My Documents/My Videos"
		fi
		if [ ! -d "$homedir/$group/$user/My Documents/My Pictures/" ] ; then
			echo -e "Creating folder: ${red}My Pictures${nocolor}"
			mkdir "$homedir/$group/$user/My Documents/My Pictures"
		fi
		if [ ! -d "$homedir/$group/$user/WWW/" ] ; then
			echo -e "Creating folder: ${red}WWW${nocolor}"
			mkdir "$homedir/$group/$user/WWW"
		fi
		for dir in `ls -a $homedir/$group/$user/` ; do
			if [ -d "$homedir/$group/$user/$dir" -a "$dir" != "ownCloud" -a "$dir" != "WWW" -a "$dir" != ".snapshot" -a "$dir" != "." -a "$dir" != ".." ] ;
			then
				chmod 700 "$homedir/$group/$user/$dir" ; 1> /dev/null
				find "$homedir/$group/$user/$dir/" -type d -print -exec chmod 700 "{}" \; 1> /dev/null
				find "$homedir/$group/$user/$dir/" -type f -print -exec chmod 600 "{}" \; 1> /dev/null
			elif [ -f "$homedir/$group/$user/$dir" -a "$dir" != "ownCloud" -a "$dir" != "WWW" -a "$dir" != ".snapshot" -a "$dir" != "." -a "$dir" != ".." ] ;
			then
				chmod 600 "$homedir/$group/$user/$dir" ; 1> /dev/null
			fi
		done
		echo
		echo -e "2: Change ${red}$user${nocolor} folder Ownership"
		chown "$user:$group" "$homedir/$group/$user/" -R ;  1> /dev/null
		echo
		if [ -d "$homedir/$group/$user/WWW/" ] ; then
			echo -e "3: Change ${red}$user WWW${nocolor} folder Permissions"
			chmod 755 "$homedir/$group/$user/WWW/" ; 1> /dev/null
			find "$homedir/$group/$user/WWW/" -type d -print -exec chmod 755 "{}" \; 1> /dev/null
			find "$homedir/$group/$user/WWW/" -type f -print -exec chmod 644 "{}" \; 1> /dev/null
			echo
		fi
		if [ -d "$homedir/$group/$user/ownCloud/" ] ; then
			echo -e "4: Change $user ${red}ownCloud${nocolor} folder Permissions"
			chown "$user:apache" "$homedir/$group/$user/ownCloud/" -R ; 1> /dev/null
			chmod 770 "$homedir/$group/$user/ownCloud/" ; 1> /dev/null
			find "$homedir/$group/$user/ownCloud/" -type d -print -exec chmod 770 "{}" \; 1> /dev/null
			find "$homedir/$group/$user/ownCloud/" -type f -print -exec chmod 660 "{}" \; 1> /dev/null
			echo
		fi
	fi
}

#Start logging
(
cd $workdir/
echo
echo -e "Starting permissions update process... ${red}$(date +%d-%m-%Y)${nocolor}"
if [ ! -z "$user" -a ! -z "$group" ] ; then
	set-permissions
elif [ -z "$user" -a ! -z "$group" ] ; then
	for user in `ls $homedir/$group/` ; do
		set-permissions
	done
elif [ ! -z "$user" -a -z "$group" ] ; then
	for group in `ls $homedir/` ; do
		for readuser in `ls $homedir/$group/` ; do
			if [ $user = $readuser ] ; then
				set-permissions
			fi
		done
	done
else
	for group in `ls $homedir/` ; do
		echo -e "Change ${red}$group${nocolor} Permissions"
		echo
		for user in `ls $homedir/$group/` ; do
			set-permissions
		done
	done
fi
echo -e "${green}=================================================${nocolor}"
echo ""
echo -e "======================================"
echo -e "|               ${green}All Done${nocolor}             |"
echo -e "======================================"
echo ""
) 2>&1 | tee -a $logfile

#Move log file
mv $logfile $finallogfile.log
