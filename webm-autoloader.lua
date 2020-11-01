-- Author: 	    wm4 + simonphoenix96
--
-- Description: This Script scrapes all webm files from a given web page, and uses https://github.com/wm4
--              autoload (https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua) script to add downloaded webms inbetween episodes in playlist
--
-- Usage: 		webPage in downloadWebms function defines, where it'll download webms from
--				bumpCount defines ammount of webms to be played after episode finishes
--				webmDir defines where to save webm files || default location is mpv script folder
--
--
-- !!! change this to false if u just want to use availible files in webmDir
onlineMode = false
--
-- !!! change following link to page you want to download webms from
webPage = 'https://boards.4channel.org/wsg/thread/3352336' -- 'https://www.bumpworthy.com/bumps/' 
--
-- !!! change following variable to amount of desired webms to be between episodes
bumpCount = 3
--
-- !!! change this to desired webm save directory, on windows seperate path with double backslash, on linux with single forward slash  
--     Default: 0 || which means webmDir points the MPVs Script Folder
webmDir = 'F:\\Videos\\bumps\\'
--
-- downloads webms off single webPage currently only 4chan thread support
singlePage = true
-- bumpworthy.com support
bumpWorthy = false
--
function downloadWebms()

    -- sets default webmDir value
    if(webmDir == 0)
    then
    webmDir =  script_path() .. 'webmDir' 
    end

  -- check which OS this script is running on to decide which download function to use
  if package.config:sub(1,1) == "\\" 
  then
    if(bumpWorthy) then
    print('powershell.exe -file "' .. script_path() .. 'webm-scraper.ps1" "' .. webPage .. '" "' .. webmDir .. '" "bumpworthy"') 
    os.execute('powershell.exe -file "' .. script_path() .. 'webm-scraper.ps1" "https://www.bumpworthy.com/bumps/" "' .. webmDir .. '" "bumpworthy"')
    else
        print('powershell.exe -file "' .. script_path() .. 'webm-scraper.ps1" "' .. webPage .. '" "' .. webmDir .. '" "singlePage"') 
 	os.execute('powershell.exe -file "E:' .. 'webm-scraper.ps1" "' .. webPage .. '" "' .. webmDir .. '" "singlePage"') -- change regex pattern in webm-scraper.ps1 to website other than the chan
    end  
  else
    os.execute("wget -P " .. webmDir ..  " -nd -nc -r -l 1 -H -D i.4cdn.org -A webm " .. webPage)  -- change i.4cdn.org to wtv if you want to use different website, dont axe me
  end
  --

end
--
-- number of lines in a file
function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

-- see if the file exists
function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
  end

  -- TODO: search table for value
function has_value (tab, val)
    for index, value in ipairs(tab) do
      print("check if alreadyPLayedBumps contains: " .. value .. "index: " .. index)  
      if value == val then
      print( value  .. " contained in alreadyPLayedBumps") 
      return true
      end
    end
   return false
end
  -- wm4's modified function
function add_files_at(index, files)

  

    index = index - 1
    local oldcount = mp.get_property_number("playlist-count", 1)
  
    if #files <= 1 then
      playlistSize = 1
      print("playlistsize" .. playlistSize)
    else
      playlistSize = #files + (bumpCount  * #files)
      print("playlistsize" .. playlistSize)
    end
  
  
    
    for i = 1, playlistSize do
  
      
  
      -- random number
      math.randomseed(os.time() * os.time())
      j = math.random(#bumpFiles)
  
  
  
  
      local bumpFileCounter = 1
      -- add bumps tosimosi playlist
      while(bumpFileCounter <= bumpCount ) do
        
  
  
        if(has_value(alreadyPlayedBumpsLines, bumpFiles[j])) then
          print("removing: " .. bumpFiles[j] .. " from list.") 
            table.remove(bumpFiles, j)
            print("Current bumpFiles size == " .. #bumpFiles)
            print("going to continue mark")
            goto continue
          else


    print("adding " .. bumpFiles[j] .. " to playlist")
	mp.commandv("loadfile", bumpFiles[j], "append")
	bumpFileCounter = bumpFileCounter + 1
    print("removing: " .. bumpFiles[j] .. " from list.") 
    table.remove(bumpFiles, j)
    print("Current bumpFiles size == " .. #bumpFiles)
        -- appends played filename to the last line of alreadyPlayedBumps.txt
        print("adding " .. bumpFiles[j] .. " to alreadyPlayedBumps.txt")
        -- Opens a file in append mode

        writeFile = io.open("alreadyPlayedBumps.txt", "a")
        io.output(writeFile)
        io.write(bumpFiles[j] .. "\n" ) 
        -- closes the open file
        io.close(writeFile)
      end

      ::continue::


    end

	
    print("bumpFileCounter " .. bumpFileCounter)
    bumpFileCounter = 1
    


    print("adding " .. files[i] .. " to playlist")
    mp.commandv("loadfile", files[i], "append")
    mp.commandv("playlist-move", oldcount + i - bumpCount, index + i - bumpCount)

    end
end
--

-- get script path
function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end
--


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

	-- read wsg folders content aswell
    bumpFiles = utils.readdir(webmDir)

    -- filter
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

    local files = utils.readdir(dir, "files")
    if files == nil then
        msg.verbose("no other files in directory")
        return
    end

    -- randomize bumpFiles order of elements
    -- shuffle(bumpFiles)
    -- &
    -- append webmDir to bumpFiles for full path to file if using windows use double backslash
	if package.config:sub(1,1) == "\\" then
		for i = 1, #bumpFiles do
		bumpFiles[i] = webmDir .. "\\" .. bumpFiles[i]
		end
	else
		for i = 1, #bumpFiles do
		bumpFiles[i] = webmDir .. "/" .. bumpFiles[i]
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
-- remove alreadyPlayedBumps.txt when same amount as existing bump files as this would mean we've played them all 

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
alreadyPlayedBumpsLines = lines_from("alreadyPlayedBumps.txt")

print("Nr. of Bumps in bumpFolder: " .. #bumpFiles .. "Nr. of already played Bumps: " .. #alreadyPlayedBumpsLines)
if(#bumpFiles == #alreadyPlayedBumpsLines)
then
  os.remove ("alreadyPlayedBumps.txt")
end



    add_files_at(pl_current + 1, append[1])
    add_files_at(pl_current, append[-1])

end

if(onlineMode) then mp.register_event("start-file", downloadWebms) end

mp.register_event("start-file", find_and_add_entries)
