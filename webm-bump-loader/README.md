#  Description [wsg] / bumpworthy.com loader
This script streams or downloads all webm/mp4 files found in [wsg] bumps from  [recent-bump-thread](https://github.com/SimonPhoenix96/random/tree/main/bump-links) repo or [bumpworthy.com](bumpworthy.com) depending on what you like.
I modified wm4's [autoload](https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua) script to add downloaded/streamed webms inbetween episodes of  the generated episode playlist.

Playlist will we generated in the background while the webms are downloaded/links for stream scraped. there is also an offline mode option, which will use locally availible webms.

# Installation
copy the .lua & .ps1 file to your scripts folder (usually "~/.config/mpv/scripts/" or "%APPDATA%\mpv\scripts" in Windows).

# Usage (Default settings should work if wanting to stream off the ancient mongolian pottery forum)

Change following variables in webm-autoloader.lua to your liking:

**bumpworthy** 
change this to true if u want adult swim bumps instead

**onlineMode** 
change this to false if u just want to use availible files in webmDir

**streamMode** 
streaming mode streams bumps instead of downloading them directly, if online mode false then itll use availible links automatically generated in webmDir\streamLinks.txt

**bumpCount** 
defines ammount of webms to be played after episode finishes || default is 3

**webmDir** 
defines where to save webm files || default location is %HOMEDRIVE%\\%HOMEPATH%\\Videos\\bumps aka. C:\Users\simonphoenix96\Videos\bumps

**WARNING** 
If on Windows and you want to download from a different page you must also change the regex pattern in webm-scraper.ps1 on linux you'll have to replace i.4cdn.org in the wget command with something else 
