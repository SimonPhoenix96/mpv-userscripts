# TODO: functionize everything
# Page to get bumps from 4chan/bumpworthy
[string]$webPage = $args[0]

# Create directory for files to be downloaded into
[string]$bumpDir = $args[1]

# Check streamMode 
[string]$streamMode = $args[2]

# LEGACY Get bumpworthy.com links randomly
[bool]$randomMode = $False

# LEGACY get bump thread url
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


# LEGACY change this to download from another page, other than the chan
[string]$srcrpattern = '((ii.yuki.la|i.4cdn.org|static.bumpworthy.com)([/|.|\w|\s|-])*\.(?:webm|mp4))' 

# LEGACYdefault
[bool]$skip = $false

# LEGACY default bumpworthy download count cut in half for true value, as bumpworthy has these links doubly on their page
[int]$linkCount= 100

# create downloadedLinks.txt
if(-not (Test-Path("$bumpDir\downloadedLinks.txt"))) {
    New-Item "$bumpDir\downloadedLinks.txt" -ItemType file
    Write-Host "downloadedLinks has been created." -ForegroundColor Green
    $linkCount = 200
}

function get-github-links{
    param (
        [Parameter(Mandatory=$true)][String[]]$webPage
    )

    # function local variables
    [System.Collections.ArrayList]$links = @()
    
    if($webPage -eq "4chan"){ 
        $local_links = (join-path -path $bumpDir -childpath "wsg-links.txt")
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SimonPhoenix96/random/main/bump-links/wsg/wsg-links.txt" -OutFile $local_links
        $links = Get-Content -Path $local_links
        Remove-Item $local_links
    }elseif($webPage -eq "bumpworthy"){
        $local_links = (join-path -path $bumpDir -childpath "bumpworthy-links.txt")
        $links = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SimonPhoenix96/random/main/bump-links/bumpworthy/bumpworthy-links.txt" -OutFile $local_links
        $links = Get-Content -Path $local_links
        Remove-Item $local_links
    }

    return $links

}

# LEGACY
function get-webm-links {
    
    param (
        [Parameter(Mandatory=$true)][String[]]$webPage
    )

    # function local variables
    [System.Collections.ArrayList]$links = @() 
    [Int]$addedCount = 0
    
    # read available links 
    if (-not $streamMode){
        $availableLinks = [IO.File]::ReadAllText("$bumpDir\downloadedLinks.txt")
    }else{
        $availableLinks = "$($bumpDir)/streamLinks.txt"
    }

    Write-Host "Attempting to call website." -ForegroundColor Green

    if($webPage -eq "4chan"){  #Page Retrieval single 4chan/yuki thread
        $page=Invoke-WebRequest -Uri $bumpThreadUrl 
        ([regex]$srcrpattern).Matches($page) | ForEach-Object { 
                    
            Write-Host "Valid Link $($_.Groups[1].Value)" -ForegroundColor Green
            Write-Host 'append link to $links' 
            # cast return value of Add() to void, as these indexes get included when returning the links array
            [void]$links.Add($_.Groups[1].Value)
        
        }
    }

    elseif ($webPage -eq "bumpworthy") {  #Page Retrieval crawl through of www.bumpworthy.com

    [Net.ServicePointManager]::SecurityProtocol = "Tls12, Tls11, Tls, Ssl3"
    [System.Collections.ArrayList] $page = @()
    $page.GetType()
    
    if($randomMode){
        write-host "randomMode true : links will be found randomly" -ForegroundColor Yellow
    }else{
        $iterator = 4000
    }

    $skippedPages = 0
    
    while ($addedCount -le $linkCount -or $skippedPages -le 300) {

        if($randomMode){$iterator = Get-Random -Minimum 1 -Maximum 9000}
        
        $webDir = "$($bumpThreadUrl)$($iterator)"
        if ($availableLinks -match $webDir){
            Write-Host 'Skipping file, already added in $linksPath' -ForegroundColor Yellow
            $iterator += 1
            $skippedPages += 1
            continue
        } 
        else {
            
            $pageTemp = Invoke-WebRequest -Uri $webDir 
            
            if(-not ($pageTemp -match 'A vast repository of Adult Swim bumps dating back to 2001, including audio and video downloads, live streaming, and musical artist information for each bump.')){
                Write-Host 'Valid Page' -ForegroundColor Green
                
                ([regex]$srcrpattern).Matches($pageTemp) | ForEach-Object { 
                    
                    Write-Host "Valid Link $($_.Groups[1].Value)" -ForegroundColor Green
                    Write-Host 'append link to $links' 

                    # cast return value of Add() to void, as these indexes get included when returning the links array
                    [void]$links.Add($_.Groups[1].Value)
                    $addedCount++
                }
            }
            else{
                Write-Host 'Not a valid bumpworthy.com page' -ForegroundColor Yellow
                $iterator += 1
                $skippedPages += 1

                continue
            }
            
            
        }

        $iterator += 1

    }
}
   
    # adding this to 4chan and bumpworthy condition on top as bumpworthy needs special treatment
    # $links = ([regex]$srcrpattern).Matches($page) | ForEach-Object { 
    #     $_.Groups[1].Value
    # }
    # write-host $links
    
    if($skippedPages -gt 3000){

        write-host "Too many skipped bump files, probably best to turn off randomMode in the top of this file located at: Split-Path -parent $($PSCommandPath) or if you think all the links have been added to streamlink turn off onlineMode in webm-autoloader.lua" -ForegroundColor Red
        Write-Host "Press any key to continue ....."  -ForegroundColor Red
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } 

    return $links
    
}

function get-webms {
    
    param (
        [Parameter(Mandatory=$true)][String[]]$links
    )
    
    # read links in downloadedLinks 
    $downloadedLinks = [IO.File]::ReadAllText("$bumpDir\downloadedLinks.txt")

    # clean up links as they contain everyline doubly
    $downloadedLinks = $downloadedLinks | sort | get-unique 
    [boolean]$successfulyDownloadedWebms = $False

    # randomize links
    $links = $links | Sort-Object {Get-Random} | get-unique
    
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
        Write-Host "$linksPath has been created." -ForegroundColor Green
    }
    # read links in downloadedLinks 
    $downloadedLinks = [IO.File]::ReadAllText("$linksPath")

    # clean up links as they contain everyline doubly
    $links = $links | Sort-Object {Get-Random} | get-unique 


    # TODO: if all files already downloaded, get files from previous thread
    @($links).foreach({
        
        if ($downloadedLinks -match $_ -or $_ -match "System.Collections.ArrayList"){
            Write-Host 'Skipping file, already added to $linksPath' -ForegroundColor Yellow
        } 
        else {
            Write-Host 'append streamLink to $linksPath' 
            # add https:// to front of everyline as mpv requires this to be able to stream
            Write-Host "$($_)"
            "$($_)" | Out-File -Encoding UTF8 -Append -FilePath  "$linksPath"
        }
    })



}






# MAIN

# Step 1  - Invoking the web request, get link

# # LEGACY [System.Collections.ArrayList]$links = get-webm-links -webPage $webPage
[System.Collections.ArrayList]$links = get-github-links -webPage $webPage


# # Step 2 - Download webms, skip if file already exists 
# #        - if $downloadedWebms return false then download previous thread files
# # OR     - stream webms if streaming option chosen

if ($streamMode -eq $False){
    get-webms -links $links
}
else {

    write-links-file -links $links -linksPath "$($bumpDir)/streamLinks.txt"
}



# /MAIN