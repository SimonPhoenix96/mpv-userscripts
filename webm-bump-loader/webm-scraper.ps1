


# TODO: functionize everything
# Page to get bumps from 4chan/bumpworthy
[string]$webPage = $args[0]

# Create directory for files to be downloaded into
[string]$bumpDir = $args[1]

# Check streamMode 
[string]$streamMode = $args[2]

# get bump thread url
if($webPage -eq "4chan") {
    # get bump thread from my github
    $bumpThreadUrl = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SimonPhoenix96/recent-bump-thread/main/recent-bump-threads.json" | convertfrom-json | select  -expandproperty threads | Get-Random | select -expandproperty url 
}
elseif ($webPage -eq "bumpworthy") {
    $bumpThreadUrl = "https://www.bumpworthy.com/bumps/"
}

# create bump directory 
if(-not (Test-Path($bumpDir))) {
    New-Item -Path $bumpDir -ItemType directory
    Write-Host "Directory has been created." -ForegroundColor Green
}


# change this to download from another page, other than the chan
[string]$srcrpattern = '((ii.yuki.la|i.4cdn.org|static.bumpworthy.com)([/|.|\w|\s|-])*\.(?:webm|mp4))' 

# default
[bool]$skip = $false

# default bumpworthy download count
[int]$count= 3 

# create downloadedLinks.txt
if(-not (Test-Path("$bumpDir\downloadedLinks.txt"))) {
    New-Item "$bumpDir\downloadedLinks.txt" -ItemType file
    Write-Host "downloadedLinks has been created." -ForegroundColor Green
    $count = 50
}

function get-webm-links {
    
    param (
        [Parameter(Mandatory=$true)][String[]]$webPage
    )

    Write-Host "Attempting to call website." -ForegroundColor Green

    if($webPage -eq "4chan"){  #Page Retrieval single 4chan thread
    $page=Invoke-WebRequest -Uri $bumpThreadUrl 
    }

    elseif ($webPage -eq "bumpworthy") {  #Page Retrieval crawl through of www.bumpworthy.com


    [Net.ServicePointManager]::SecurityProtocol = "Tls12, Tls11, Tls, Ssl3"
    [System.Collections.ArrayList] $page = @()
    $page.GetType()

    For ($i=([IO.File]::ReadAllLines("$bumpDir\downloadedLinks.txt")).length; $i -le ([IO.File]::ReadAllLines("$bumpDir\downloadedLinks.txt")).length+$count; $i++) {
    
        $webDir = "$($bumpThreadUrl)$($i)"
        $pageTemp = Invoke-WebRequest -Uri $webDir 
    
        if(-not ($pageTemp -match 'A vast repository of Adult Swim bumps dating back to 2001, including audio and video downloads, live streaming, and musical artist information for each bump.')){
        $page.Add($pageTemp)
        
        }

        }
        
    }
    
    $links = ([regex]$srcrpattern).Matches($page) | ForEach-Object { 
        $_.Groups[1].Value
    }

    return $links
}

function get-webms {
    
    param (
        [Parameter(Mandatory=$true)][String[]]$links
    )
    
    # read links in downloadedLinks 
    $downloadedLinks = [IO.File]::ReadAllText("$bumpDir\downloadedLinks.txt")

    [boolean]$successfulyDownloadedWebms = $False

    
    # TODO: if all files already downloaded, get files from previous thread
    @($links).foreach({
        
        if ($downloadedLinks -match $_){
            Write-Host 'Skipping file, already downloaded' -ForegroundColor Yellow
        } 
        else {
            $fileName = $_ | Split-Path -Leaf
            Write-Host "Downloading image file $fileName"
            Invoke-WebRequest -Uri $_ -OutFile "$bumpDir\$fileName"
            Write-Host 'File download complete append to downloadedLinks.txt' 
            $_ | Out-File -Encoding UTF8 -Append -FilePath  "$bumpDir\downloadedLinks.txt"
            $successfulyDownloadedWebms = $True
        }
    })
    
    return $successfulyDownloadedWebms
}

function write-links-file {
    
    param (
        [Parameter(Mandatory=$true)][String[]]$links,
        [Parameter(Mandatory=$true)][String[]]$linksPath
    )

    # create streamLinks.txt if doesnt exist yet
    if(-not (Test-Path("$linksPath"))) {
        New-Item "$linksPath" -ItemType file
        Write-Host "streamLinks has been created." -ForegroundColor Green
    }
    # read links in downloadedLinks 
    $downloadedLinks = [IO.File]::ReadAllText("$linksPath")

    # clean up links as they contain everyline doubly
    $links = $links | sort | get-unique 


    # TODO: if all files already downloaded, get files from previous thread
    @($links).foreach({
        
        if ($downloadedLinks -match $_){
            Write-Host 'Skipping file, already added to streamLinks.txt' -ForegroundColor Yellow
        } 
        else {
            Write-Host 'append streamLink to streamLinks.txt' 
            "https://$($_)" | Out-File -Encoding UTF8 -Append -FilePath  "$linksPath"
        }
    })

    # TODO add https:// to front of everyline as mpv requires this to be able to stream


}






# MAIN
# Step 1  - Invoking the web request, get link

$links = (get-webm-links -webPage $webPage)


# Step 2 - Download webms, skip if file already exists 
#        - if $downloadedWebms return false then download previous thread files
# OR     - stream webms if streaming option chosen

if ($streamMode -eq $False){
    $successfulyDownloadedWebms = (get-webms -links $links) 
}
else {

    write-links-file -links $links -linksPath "$($bumpDir)/streamLinks.txt"
}
# /MAIN














# OLD PROBABLY (bumpworthy) - Compare with links in downloadedLinks, if exists skip link else write to scrapedLink
# if($webPage -eq "bumpworthy") {
#     @($links).foreach({

#     if(-not $skip){
#         if(-not ($downloadedLinks -match $_)) {
#             $_ | Out-File -Append -FilePath  "$bumpDir\downloadedLinks.txt"
#         }
#         $skip = $true
#     } elseif ($skip){ $skip = $false}
#     })
# }