#  Description
This script streams or downloads all webm files found in recent-bump-thread (https://github.com/SimonPhoenix96/recent-bump-thread).
I modified https://github.com/wm4 autoload (https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua) script to add downloaded/streamed webms inbetween episodes of  the generated episode playlist.

Playlist will we generated in the background while the webms are downloaded/links for stream scraped. there is also an offline mode option, which will use locally availible webms.


# Usage (Default settings should work if wanting to stream off the ancient mongolian pottery forum)

Change following variables in webm-autoloader.lua to your liking:

**onlineMode** 
change this to false if u just want to use availible files in webmDir

**onlineMode** 
streaming mode streams bumps instead of downloading them directly, if online mode false then itll use availible links automatically generated in webmDir\streamLinks.txt

**bumpCount** 
defines ammount of webms to be played after episode finishes || default is 3

**webmDir** 
defines where to save webm files || default location is %HOMEDRIVE%\\%HOMEPATH%\\Videos\\bumps aka. C:\Users\simonphoenix96\Videos\bumps

**WARNING** 
If on Windows and you want to download from a different page you must also change the regex pattern in webm-scraper.ps1 on linux you'll have to replace i.4cdn.org in the wget command with something else 
