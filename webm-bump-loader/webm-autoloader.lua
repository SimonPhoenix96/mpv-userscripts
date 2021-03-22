-- Author: 	      wm4 + simonphoenix96
--
-- Description:   This Script scrapes all webm files from a given web page, and uses https://github.com/wm4
--                autoload (https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua) script to add downloaded webms inbetween episodes in playlist
--
-- Usage: 		   <bumpworthy> change this to true if u want adult swim bumps instead
--                <onlineMode> change this to false if u just want to use availible files in webmDir
--                <streamMode> streaming mode streams bumps instead of downloading them directly, if online mode false then itll use availible links automatically generated in webmDir\streamLinks.txt
--                <bumpCount> defines ammount of webms to be played after episode finishes || default is 3
--                <webmDir> defines where to save webm files || default location is %HOMEDRIVE%\%HOMEPATH%\Videos\bumps aka. C:\Users\simonphoenix96\Videos\bumps
--
--
onlineMode = true
--
streamMode = true
--
bumpCount = 3
--
bumpWorthy = true
--
webmDir = "%HOMEDRIVE%\\%HOMEPATH%\\Videos\\bumps"
--
--
--
--
--
--
-- !!! DONT change these !!!
-- set download folders
if(bumpWorthy) then
   webmDir = webmDir .. "\\bumpworthy"
else
   webmDir = webmDir .. "\\4chan"
end
--
--
alreadyPlayedBumpsPath = webmDir .. "\\alreadyPlayedBumps.txt"
--
streamLinksPath = webmDir .. "\\streamLinks.txt"
--  
ranDownloadedWebms = false
--
addedToPlayedBumps = 0
--
updateStreamlinks = true
--
--
--
--
--
--
--
function downloadWebms()
   if(ranDownloadedWebms == false) then
      -- sets default webmDir value if webmDir left empty
      if(webmDir == 0)
      then
         webmDir =  script_path() .. 'webmDir'
      end
      -- check which OS this script is running on to decide which download function to use
      if package.config:sub(1,1) == "\\"
      then
         -- Windows Version
         if(bumpWorthy) then
            -- print('powershell.exe  -file "' .. script_path() .. 'webm-scraper.ps1" "' .. "bumpworthy" .. '" "' .. webmDir .. '" ' .. tostring(streamMode))
            os.execute('powershell.exe -file "' .. script_path() .. 'webm-scraper.ps1" "bumpworthy" "' .. webmDir .. '" ' .. tostring(streamMode))
         else
            -- print('powershell.exe -file "' .. script_path() .. 'webm-scraper.ps1" "' .. "4chan" .. '" "' .. webmDir .. '" ' .. tostring(streamMode))
            -- -- print('if(((Get-Process mpv -ErrorAction SilentlyContinue) -eq $null)){powershell.exe -windowstyle hidden -file "' .. script_path() .. 'webm-scraper.ps1" "' .. "4chan" .. '" "' .. webmDir .. '" ' .. tostring(streamMode) .. "}" )
            -- os.execute('if(-not((Get-Process mpv -ErrorAction SilentlyContinue) -eq $null)){powershell.exe -windowstyle hidden -file "' .. script_path() .. 'webm-scraper.ps1" "' .. "4chan" .. '" "' .. webmDir .. '" ' .. tostring(streamMode) .. "}" ) -- change regex pattern in webm-scraper.ps1 to website other than the chan
            os.execute('powershell.exe -file "' .. script_path() .. 'webm-scraper.ps1" "' .. "4chan" .. '" "' .. webmDir .. '" ' .. tostring(streamMode))
         end
      else
         --Linux Version
         -- TODO: implement stream mode for linux version
         os.execute("wget -P " .. webmDir ..  " -nd -nc -r -l 1 -H -D i.4cdn.org -A webm " .. webPage)  -- change i.4cdn.org to wtv if you want to use different website, dont axe me
      end
      --
   end
   ranDownloadedWebms = true
end
--
--

-- get script path
function script_path()
   local script_path = debug.getinfo(1, "S").source
   -- -- print("debug_info " .. script_path:match("(.*/)"))
   return script_path:match("(.*/)")
end
--

-- APB: number of lines in a file
function lines_from(file)
   if not file_exists(file) then return {} end
   lines = {}
   for line in io.lines(file) do
      lines[#lines + 1] = line
   end
   return lines
end

-- APB: see if the file exists
function file_exists(file)
   local f = io.open(file, "rb")
   if f then f:close() end
   return f ~= nil
end

-- APB: check if table contains value
function has_value (tab, val)
   for index, value in ipairs(tab) do
      -- print("comparing " .. value .. #value ..  ' ' .. val .. #val .. ' ' .. tostring(value == val) )
      if value == val then
         -- print("table has value " .. value ..  ' ' .. val )
         return true
      end
   end
   return false
end
--
-- APB
function shallowcopy(orig)
   local orig_type = type(orig)
   local copy
   if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in pairs(orig) do
         copy[orig_key] = orig_value
      end
   else -- number, string, boolean, etc
      copy = orig
   end
   return copy
end

function wait(seconds)
   local start = os.time()
   repeat until os.time() > start + seconds
end

-- wm4's modified function
function add_files_at(index, files)
   
   index = index  - 1
   
   local oldcount = mp.get_property_number("playlist-count", 1)
   -- -- print("number of episodes" .. #files)
   
   -- no bumps at end
   -- for i = 1, #files do
   for i = 1, (#files + 1) do
      
      bumpFileCounter = 1
      
      -- APB
      while(bumpFileCounter <= bumpCount ) do
         
         -- -- print('number of bump files xxx: '.. #bumpFiles)
         -- -- print("Current bumpFiles size == " .. #bumpFiles)
         -- -- print("bumpFilesCopy Size: " .. #bumpFilesCopy)
         math.randomseed(os.time() * os.time())
         j = math.random(#bumpFiles)
         -- remove carriage return symbol
         bumpFileWithoutNR = string.gsub(bumpFiles[j], "\r", " ")
         bumpFileWithoutNR = string.gsub(bumpFileWithoutNR, "%s+", "")
         -- -- print("no. bump already played? " .. #alreadyPlayedBumpsLines)
         -- -- print("bump already played? " .. tostring(has_value(alreadyPlayedBumpsLines, bumpFileWithoutNR)))
         if(has_value(alreadyPlayedBumpsLines, bumpFileWithoutNR)) then
            -- -- print("bump already played removing: " .. bumpFileWithoutNR .. " from list.")
            table.remove(bumpFiles, j)
            -- -- print("Current bumpFiles size == " .. #bumpFiles)
            -- -- print("going to continue mark")
            -- goto continue

         else


            -- add bump to playlist between episodes
            -- -- print("appending bump " .. bumpFileWithoutNR .. " to playlist")
            mp.commandv("loadfile",  bumpFileWithoutNR, "append")
            bumpFileCounter = bumpFileCounter + 1
            -- -- print("removing: " .. bumpFileWithoutNR .. " from list.")
            table.remove(bumpFiles, j)



         end

      end

      -- APB
      -- -- print("bumpFileCounter " .. bumpFileCounter)
      -- add episode to playlist between bumps
      if (i <= #files) then
         -- -- print("episodes added: " .. i)
         -- -- print("adding episode " .. files[i] .. " to playlist index: " .. index)
         mp.commandv("loadfile", files[i], "append")
      end 
      -- -- print("oldcount " .. oldcount)
      -- -- print("indschmex: " .. index)
      mp.commandv("playlist-move", oldcount + i - bumpCount, index + i - bumpCount)
      
   end

end

-- from here modified wm4 stuff
MAXENTRIES = 5000

local msg = require 'mp.msg'
local options = require 'mp.options'
local utils = require 'mp.utils'

o = {
   disabled = false,
   images = true,
   videos = true,
   audio = true,
   bump = false
}
options.read_options(o)

function Set (t)
   local set = {}
   for _, v in pairs(t) do set[v] = true end
   return set
end

function SetUnion (a,b)
   local res = {}
   for k in pairs(a) do res[k] = true end
   for k in pairs(b) do res[k] = true end
   return res
end

EXTENSIONS_VIDEO = Set {
   'mkv', 'avi', 'mp4', 'ogv', 'webm', 'rmvb', 'flv', 'wmv', 'mpeg', 'mpg', 'm4v', '3gp'
}

EXTENSIONS_AUDIO = Set {
   'mp3', 'wav', 'ogm', 'flac', 'm4a', 'wma', 'ogg', 'opus'
}

EXTENSIONS_IMAGES = Set {
   'jpg', 'jpeg', 'png', 'tif', 'tiff', 'gif', 'webp', 'svg', 'bmp'
}

EXTENSIONS = Set {}
if o.videos then EXTENSIONS = SetUnion(EXTENSIONS, EXTENSIONS_VIDEO) end
if o.audio then EXTENSIONS = SetUnion(EXTENSIONS, EXTENSIONS_AUDIO) end
if o.images then EXTENSIONS = SetUnion(EXTENSIONS, EXTENSIONS_IMAGES) end




function get_extension(path)
   match = string.match(path, "%.([^%.]+)$" )
   if match == nil then
      return "nomatch"
   else
      return match
   end
end

table.filter = function(t, iter)
   for i = #t, 1, -1 do
      if not iter(t[i]) then
         table.remove(t, i)
      end
   end
end



-- splitbynum and alnumcomp from alphanum.lua (C) Andre Bogus
-- Released under the MIT License
-- http://www.davekoelle.com/files/alphanum.lua

-- split a string into a table of number and string values
function splitbynum(s)
   local result = {}
   for x, y in (s or ""):gmatch("(%d*)(%D*)") do
      if x ~= "" then table.insert(result, tonumber(x)) end
      if y ~= "" then table.insert(result, y) end
   end
   return result
end

function clean_key(k)
k = (' '..k..' '):gsub("%s+", " "):sub(2, -2):lower()
return splitbynum(k)
end

-- compare two strings
function alnumcomp(x, y)
   local xt, yt = clean_key(x), clean_key(y)
   for i = 1, math.min(#xt, #yt) do
      local xe, ye = xt[i], yt[i]
      if type(xe) == "string" then ye = tostring(ye)
   elseif type(ye) == "string" then xe = tostring(xe) end
      if xe ~= ye then return xe < ye end
   end
   return #xt < #yt
end

local autoloaded = nil

function find_and_add_entries()
   local path = mp.get_property("path", "")
   local dir, filename = utils.split_path(path)
   msg.trace(("dir: %s, filename: %s"):format(dir, filename))
   if o.disabled then
      msg.verbose("stopping: autoload disabled")
      return
   elseif #dir == 0 then
      msg.verbose("stopping: not a local path")
      return
   end

   local pl_count = mp.get_property_number("playlist-count", 1)
   -- check if this is a manually made playlist
   if (pl_count > 1 and autoloaded == nil) or
   (pl_count == 1 and EXTENSIONS[string.lower(get_extension(filename))] == nil) then
      msg.verbose("stopping: manually made playlist")
      return
   else
      autoloaded = true
   end

   local pl = mp.get_property_native("playlist", {})
   local pl_current = mp.get_property_number("playlist-pos-1", 1)
   msg.trace(("playlist-pos-1: %s, playlist: %s"):format(pl_current,
   utils.to_string(pl)))


   -- read wsg folders content aswell, if streammode on readlines from streamLinks.txt
   bumpFiles = {}
   if (streamMode) then
      bumpFiles = lines_from(streamLinksPath)
   else
      bumpFiles = utils.readdir(webmDir)
         -- filter all non video files
      table.filter(bumpFiles, function (v, k)
         if string.match(v, "^%.") then
            return false
         end
         local ext = get_extension(v)
         if ext == nil then
            return false
         end
         return EXTENSIONS[string.lower(ext)]
      end)
   end
   

   --    -- go through bumpFiles
   -- for i = 1, #bumpFiles do
   --    -- print("file in bumpFiles: " .. bumpFiles[i])
   -- end

   -- wm4
   local files = utils.readdir(dir, "files")
   if files == nil then
      msg.verbose("no other files in directory")
      return
   end
   -- wm4
   table.filter(files, function (v, k)
   if string.match(v, "^%.") then
      return false
   end
   local ext = get_extension(v)
   if ext == nil then
      return false
   end
   return EXTENSIONS[string.lower(ext)]
   end)

   -- append webmDir to bumpFiles for full path to file if using windows use double backslash
   if (streamMode ~= true) then
      if package.config:sub(1,1) == "\\" then
         for i = 1, #bumpFiles do
            bumpFiles[i] = webmDir .. "\\" .. bumpFiles[i]
         end
      else
         for i = 1, #bumpFiles do
            bumpFiles[i] = webmDir .. "/" .. bumpFiles[i]
         end
      end
   end
   --

   table.sort(files, alnumcomp)

   if dir == "." then
      dir = ""
   end

   -- Find the current pl entry (dir+"/"+filename) in the sorted dir list
   local current
   for i = 1, #files do
      if files[i] == filename then
         current = i
         break
      end
   end
   if current == nil then
      return
   end

   msg.trace("current file position in files: "..current)

   local append = {[-1] = {}, [1] = {}}
   for direction = -1, 1, 2 do -- 2 iterations, with direction = -1 and +1
      for i = 1, MAXENTRIES do
         local file = files[current + i * direction]
         local pl_e = pl[pl_current + i * direction]
         if file == nil or file[1] == "." then
            break
         end

         local filepath = dir .. file
         if pl_e then
            -- If there's a playlist entry, and it's the same file, stop.
            msg.trace(pl_e.filename.." == "..filepath.." ?")
            if pl_e.filename == filepath then
               break
            end
         end

         if direction == -1 then
            if pl_current == 1 then -- never add additional entries in the middle
               msg.info("Prepending " .. file)
               table.insert(append[-1], 1, filepath)
            end
         else
            msg.info("Adding " .. file)
            table.insert(append[1], filepath)
         end
      end
   end

   -- get all lines from a file, returns an empty list/table if the file does not exist
   alreadyPlayedBumpsLines = lines_from(alreadyPlayedBumpsPath)

   -- APB
   numNeededBumpFiles = (#append[1] * bumpCount) + bumpCount
   -- print("number of bump files: " .. #bumpFiles .." needed bump files: " .. numNeededBumpFiles) 
   -- print("Nr. of Bumps in bumpFiles: " .. #bumpFiles .. "Nr. of already played Bumps: " .. #alreadyPlayedBumpsLines)
   if((#alreadyPlayedBumpsLines + numNeededBumpFiles > #bumpFiles ) == true)
   then
      -- print("reset already played bumps!")
      io.open(alreadyPlayedBumpsPath,"w"):close()
   end
   
   -- print("adding files onward from played file")
   add_files_at(pl_current + 1, append[1])
   -- print("adding files backward from played file")
   -- add_files_at(pl_current, append[-1]) 
   mp.unregister_event(find_and_add_entries)         

end




function file_check(file_name)
   local file_found=io.open(file_name, "r")      
   
   if file_found==nil then
     file_found=false
   else
     file_found=true
   end
   return file_found
 end

-- MAIN

-- print("streamlinks exists: " .. tostring(file_exists(streamLinksPath)))
if (file_exists(streamLinksPath) and streamMode) then
   local streamLinksUpdatedOn = io.popen( "dir /T:W " .. '"' .. streamLinksPath.. '"', "r" )
   streamLinksUpdatedOn = streamLinksUpdatedOn:read "*a"
   -- print("streamLinksUpdatedOn: " .. tostring(streamLinksUpdatedOn))
   m, d, y = string.match(streamLinksUpdatedOn, "(%d+)/(%d+)/(%d+)")
   local date = os.time{day=d, year=y, month=m}  
   -- print("da date: " .. date)
   daysfrom = math.floor(os.difftime(os.time(), date) / (24 * 60 * 60))
   -- print("has it been 5 days already since last streamlink.txt update: " .. daysfrom) 
   if (daysfrom < 5) then 
      updateStreamlinks = false
   end
end

-- print("updateStreamlinks: " .. tostring(updateStreamlinks))


if (onlineMode) then

   if (streamMode and updateStreamlinks) then
     -- print("streamMode and updateStreamlinks true")
      mp.register_event("start-file", downloadWebms)
   elseif (streamMode == false) then
     -- print("streamMode and updateStreamlinks false")
      mp.register_event("start-file", downloadWebms)
   end


      
end
   
mp.register_event("start-file", find_and_add_entries)

--  Event Loop
function loading_next_playlist_file()
   local current_playlist_pos = tonumber(mp.get_property('playlist-current-pos'))
   -- print ( "current playlist pos : " .. tostring(current_playlist_pos))
   if addedToPlayedBumps == bumpCount then
      -- print("resetting addedtoplayedbumps")
      addedToPlayedBumps = 0 
      resetAddedToPlayedBumps = true
   end
   
   if (current_playlist_pos >= 1  and addedToPlayedBumps ~= bumpCount and  resetAddedToPlayedBumps ~= true) then
      local current_playlist_filename =  mp.get_property('playlist/' .. current_playlist_pos.. '/filename')

      -- Opens a file in append mode
      if (streamMode) then 
         -- prevents when skipping fast through playlist in streamMode non bump files get added to alreadyplayedbumps
         if( string.sub(current_playlist_filename,1,4) == "http") then
         writeFile = io.open(alreadyPlayedBumpsPath, "a")
         io.output(writeFile)
         io.write(current_playlist_filename .. "\n" )
         -- closes the open file
         io.close(writeFile)
         addedToPlayedBumps = addedToPlayedBumps + 1
         -- print("addedtoplayedbumps " .. addedToPlayedBumps)
         end
      else
         writeFile = io.open(alreadyPlayedBumpsPath, "a")
         io.output(writeFile)
         io.write(current_playlist_filename .. "\n" )
         -- closes the open file
         io.close(writeFile)
         addedToPlayedBumps = addedToPlayedBumps + 1
         -- print("addedtoplayedbumps " .. addedToPlayedBumps)
      
      end
   end
   
   resetAddedToPlayedBumps = false


end

function loop_append_to_apb()
   -- mp.add_key_binding("ctrl+a", "loop_append_to_apb", loop_append_to_apb)
   -- print("loop_append_to_apb triggered")
   mp.register_event("file-loaded", loading_next_playlist_file)
end

local mp_event_loop = loop_append_to_apb()

