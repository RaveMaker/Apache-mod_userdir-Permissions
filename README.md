Change folder permissions for Apache mod_userdir
================================================

Change folder permissions for Apache mod_userdir (assuming NIS)

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
