#!/bin/bash

# -------------------------------------------------------------
# Don't forget to create settings.cfg and updated your settings
# -------------------------------------------------------------

# Load settings.cfg
if [ -f settings.cfg ]; then
  echo "Loading settings..."
  . settings.cfg
else
  echo "ERROR: Create settings.cfg (from settings.cfg.example)"
  exit
fi

# Define vars
all="false"
mydate="$(date +%Y-%m-%d-%H-%M-%S)"
logfile="$tmp/$myname.run"
finallogfile="$log/$myname-$mydate.log"

# Define Colors
red='\e[0;31m'
green='\e[0;32m'
nocolor='\e[0m'

# Check Parameters
if [[ "$#" -eq "0" || ("$#" -eq "1" && "$1" == "1") ]]; then
  echo "Check syntax - run with -h/--help for help"
  echo "$1"
  exit
fi
while test $# -gt 0; do
  case "$1" in
  -[Aa][Ll][Ll])
    if [ -z "$group" ] && [ -z "$user" ]; then
      all="true"
    else
      all="false"
    fi
    ;;
  -[Uu])
    all="false"
    shift
    user=$1
    ;;
  -[Gg])
    all="false"
    shift
    group=$1
    ;;
  1)
    # Define no colors for a cleaner mail report
    echo "Generate simple report"
    red=""
    green=""
    nocolor=""
    ;;
  -[Hh] | *)
    echo ""
    echo "Change permissions command help:"
    echo ""
    echo "[ -g ] - Group name"
    echo "[ -u ] - User name"
    echo ""
    echo "[ -all ] - Change all permissions"
    echo ""
    echo "[ -h ] -  Shows help"
    echo ""
    echo "Example: ./$myname.sh -g mygroup -u myuser"
    echo "Example: ./$myname.sh -all"
    exit
    ;;
  esac
  shift
done

# Final param check
if [ "$all" == "false" ] && [ -z "$group" ] && [ -z "$user" ]; then
  echo "Check syntax - run command with -h for help"
  echo "$1"
  exit
fi

# Check if script is still running
if [ -a "$logfile" ]; then
  echo ""
  echo -e "${red}Script Is Running! check $logfile${nocolor}"
  echo ""
  exit
fi

# Create user personal folders
function create-folders() {
  ## now loop through the above array
  for currentfolder in "${foldersarray[@]}"; do
    echo -e "Creating folder: ${red}$currentfolder${nocolor}"
    mkdir -p "$currentfolder"
  done
  echo -e "Creating folder: ${red}$wwwfolder${nocolor}"
  mkdir -p "$wwwfolder"
}

# checks if an item is in an array
# accepts item and array, returns 0 or 1
function element-in() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Change user permissions
function change-permissions() {
  if ! element-in "$user" "${excludeusersarray[@]}"; then
    if [ ! -d "$homedir/$group/$user" ]; then
      echo -e "User ${red}$user${nocolor} not found!"
      if [ ! -d "$homedir/$group" ]; then
        echo -e "Group ${red}$group${nocolor} not found!"
      fi
      return
    fi
    echo -e "${green}==========================================================${nocolor}"
    echo
    echo -e "Change ${red}$user${nocolor} @ ${red}$group${nocolor} Permissions"
    echo -e "1: Change ${red}$user${nocolor} folder Ownership"
    cd "$homedir/$group/$user/" || return
    if ! chown "$user:$group" . -R >/dev/null; then
      echo "Error: chown $user:$group $homedir/$group/$user/ -R" >>"$logfile"
    fi

    echo -e "2: Change ${red}$user${nocolor} folder Permissions"
    chmod 711 . >/dev/null

    create-folders

    cd "$homedir/$group/$user/" || return
    for dir in *; do
      if [ -d "$dir" ] && [ "$dir" != "$wwwfolder" ]; then
        chmod 700 "$homedir/$group/$user/$dir" >/dev/null
        find "$dir/" -type d -print -exec chmod 700 "{}" \; >/dev/null
        find "$dir/" -type f -print -exec chmod 600 "{}" \; >/dev/null
      elif [ -f "$dir" ] && [ "$dir" != "$wwwfolder" ]; then
        chmod 600 "$dir" >/dev/null
      fi
    done

    if [ -d "$wwwfolder/" ]; then
      echo -e "3: Change ${red}$user $wwwfolder${nocolor} folder Permissions"
      chmod 755 "$wwwfolder/" >/dev/null
      find "$wwwfolder/" -type d -print -exec chmod 755 "{}" \; >/dev/null
      find "$wwwfolder/" -type f -print -exec chmod 644 "{}" \; >/dev/null
    fi
    echo
  fi
}

function clear-logs-and-exit() {
  # Clear color codes and move log file
  sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" "$logfile" >"$finallogfile"
  rm -f "$logfile"
  exit
}

function change-group-permissions() {
  if [ ! -d "$homedir/$group/" ]; then
    echo -e "Group ${red}$group${nocolor} not found!"
    return
  fi
  cd "$homedir/$group/" || return
  for user in *; do
    change-permissions
  done
}

function change-user-permissions() {
  userfound=1
  cd "$homedir/" || return
  for group in *; do
    cd "$homedir/$group/" || return
    for readuser in *; do
      if [ "$user" == "$readuser" ]; then
        change-permissions
        userfound=0
      fi
    done
  done
  if [ "$userfound" == 1 ]; then
    echo -e "User ${red}$user${nocolor} not found!"
  fi
  echo
}

function change-all-permissions() {
  echo "Changing all users permissions"
  cd "$homedir/" || return
  for group in *; do
    echo -e "Change ${red}$group${nocolor} Permissions"
    echo
    cd "$homedir/$group/" || return
    for user in *; do
      change-permissions
    done
  done
}

# Start logging
(
  cd "$workdir/" || clear-logs-and-exit
  echo -e "Starting permissions update process... ${red}$mydate${nocolor}"
  # specified user and group
  if [ -n "$user" ] && [ -n "$group" ]; then
    change-permissions
  # specified group only
  elif [ -z "$user" ] && [ -n "$group" ]; then
    change-group-permissions
  # specified user only
  elif [ -n "$user" ] && [ -z "$group" ]; then
    change-user-permissions
  # run on all users
  elif [ "$all" == "true" ] && [ -z "$user" ] && [ -z "$group" ]; then
    change-all-permissions
  fi
  echo -e "======================================"
  echo -e "|               ${green}All Done${nocolor}             |"
  echo -e "======================================"
  echo ""
) 2>&1 | tee -a "$logfile"

clear-logs-and-exit
