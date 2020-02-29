#  Description
This Script scrapes all webm files from a given web page, and uses https://github.com/wm4 
autoload (https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua) script to add downloaded webms inbetween episodes in playlist

Playlist will we generated once all webms are downloaded, or if you dont want to wait on windows once the download window is forcefully exited
# Usage (Default settings should work if wanting to download off the ancient pottery forum)
Change following variables in webm-autoloader.lua if you want

**WARNING** 
If on Windows and you want to download from a different page you must also change the regex pattern in webm-scraper.ps1 on linux you'll have to replace i.4cdn.org in the wget command with something else 

**webPage** 
in downloadWebms function defines, where it'll download webms from || default is that chinese basket weaving forum, chinese dissidents use to communicate with eachother 

**webmCount** 
defines ammount of webms to be played after episode finishes || default is 3

**webmDir** 
defines where to save webm files || default location is mpv script folder

# External/Modified Scripts: 	    
wm4 (https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua)
