
# Page to get bumps from 4chan/bumpworthy
$webPage = $args[0]

# Create directory for files to be downloaded into
$bumpDir = $args[1] 

if($webPage -eq "4chan") {
# get bump thread from my github
$bumpThreadUrl = Invoke-WebRequest -Uri https://raw.githubusercontent.com/SimonPhoenix96/recent-bump-thread/main/recent-bump-thread.txt | select content -ExpandProperty content
}

# create bump directory 
if(-not (Test-Path($bumpDir))) {
    New-Item -Path $bumpDir -ItemType directory
    Write-Host "Directory has been created." -ForegroundColor Green
}




# change this to download from another page, other than the chan
$srcrpattern = '((i.4cdn.org|static.bumpworthy.com)([/|.|\w|\s|-])*\.(?:webm|mp4))' 
# default
$skip = $false

# Main - Invoking the web request, making first contact with the site.
Write-Host "Attempting to call website." -ForegroundColor Green

if($args[0] -eq "4chan"){  #Page Retrieval single 4chan thread
$page=Invoke-WebRequest -Uri $bumpThreadUrl 
} 
elseif ($args[0] -eq "bumpworthy") {  #Page Retrieval crawl through of www.bumpworthy.com
$count= 3
[Net.ServicePointManager]::SecurityProtocol = "Tls12, Tls11, Tls, Ssl3"
[System.Collections.ArrayList] $page = @()
$page.GetType()

if(-not (Test-Path("$bumpDir\scrapedLinks.txt"))) {
    New-Item -itemType File -Path "$bumpDir\scrapedLinks.txt"
    $count = 100
    }

For ($i=([IO.File]::ReadAllLines("$bumpDir\scrapedLinks.txt")).length; $i -le ([IO.File]::ReadAllLines("$bumpDir\scrapedLinks.txt")).length+$count; $i++) {
  
    $webDir = "$($bumpThreadUrl)$($i)"
    $pageTemp = Invoke-WebRequest -Uri $webDir 
   
    if(-not ($pageTemp -match 'A vast repository of Adult Swim bumps dating back to 2001, including audio and video downloads, live streaming, and musical artist information for each bump.')){
    $page.Add($pageTemp)
       
    }

    }
    
}


$src = ([regex]$srcrpattern).Matches($page) | ForEach-Object { 
    $_.Groups[1].Value
    
}


if ($args[0] -eq "bumpworthy") {
# create scrapedLinks.txt for bumpworthy, as files get downloaded at random
if(-not (Test-Path("$bumpDir\scrapedLinks.txt"))) {
    New-Item "$bumpDir\scrapedLinks.txt" -ItemType file
    Write-Host "Directory has been created." -ForegroundColor Green
}
$scrapedLinks = [IO.File]::ReadAllText("$bumpDir\scrapedLinks.txt")
@($src).foreach({

   if(-not $skip){
    if(-not ($scrapedLinks -match $_)) {
        $_ | Out-File -Append -FilePath  "$bumpDir\scrapedLinks.txt"
    }
    $skip = $true
   } elseif ($skip){ $skip = $false}
})
}

#Step 4 - Download webms, skip if file already exists
@($src).foreach({
  
$fileName = $_ | Split-Path -Leaf
if (Test-Path("$bumpDir\$fileName")){
Write-Host 'Skipping file, already downloaded' -ForegroundColor Yellow
return
}
else 
{
Write-Host "Downloading image file $fileName"
Invoke-WebRequest -Uri $_ -OutFile "$bumpDir\$fileName"
Write-Host 'Image download complete'
}

})

