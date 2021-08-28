#  Description [wsg] / bumpworthy.com loader 
This script streams or downloads all [wsg] or [bumpworthy.com](https://www.bumpworthy.com/) webm/mp4 files found in  [bump-links](https://github.com/SimonPhoenix96/random/tree/main/bump-links) repo depending on which option you set.

I modified wm4's [autoload](https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua) script to add downloaded/streamed webms inbetween episodes of  the generated episode playlist.

Playlist will we generated in the background while the webms are downloaded/links for stream scraped. there is also an offline mode option, which will use locally available webms.

If using streamMode, the script will get [bump-links](https://github.com/SimonPhoenix96/random/tree/main/bump-links) updates if the file hasnt been updated in 5 days.

# Installation ***WARNING: LINUX COMPATIBILTY BROKEN***
copy the .lua & .ps1 file to your scripts folder (usually `"~/.config/mpv/scripts/"` or if using Windows `%APPDATA%\mpv\scripts`)

# Usage (yuki.la seems to be down atm so i made the default bump source bumpworthy.com)

Change following variables in webm-autoloader.lua to your liking:

**`bumpWorthy`** 
change this to true if u want adult swim bumps instead

**`onlineMode`** 
change this to false if u just want to use available files in webmDir

**`streamMode`** 
streaming mode streams bumps instead of downloading them directly, if online mode false then itll use available links automatically generated in webmDir\streamLinks.txt

**`bumpCount`** 
defines ammount of webms to be played after episode finishes || default is 3

**`webmDir`** 
defines where to save webm files on windows seperate folders with `\\` default location is `%HOMEDRIVE%\\%HOMEPATH%\\Videos\\bumps` aka. `C:\\Users\\simonphoenix96\\Videos\\bumps`

# **Dev Info** 
If on Windows and you want to download from a different page you must also change the regex pattern in webm-scraper.ps1 on linux you'll have to replace i.4cdn.org in the wget command with something else 
