Secure linux homedir permissions
================================================

Secure homedir for linux users including support for Apache mod_userdir.

Set permissions and ownership to users/groups/all homedir. 

homedir tree style:
```
/home/group/user
```

Apache userdir tree style (folder name configured in settings.cfg):
```
/home/group/user/WWW
```

### Installation

1. Clone this script from github or copy the files manually to your prefered directory.

2. Create settings.cfg from settings.cfg.example and change:

```
myname=change-permissions
homedir=/u
workdir=/scripts
excludeusersarray=("expired" "Expired" "MOVED" "Moved" ".snapshot" "TrashCan")
foldersarray=("Desktop" "My Documents" "My Documents/My Music" "My Documents/My Videos" "My Documents/My Pictures" "Downloads" "Favorites")
wwwfolder="WWW"
tmp="$workdir/tmp"
log="$workdir/log"
```

Author: [RaveMaker][RaveMaker].

[RaveMaker]: http://ravemaker.net
