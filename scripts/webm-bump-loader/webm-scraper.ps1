# Create directory for files to be downloaded into
$bumpDir = $args[1] 


if(-not (Test-Path($bumpDir))) {
    New-Item -Path $bumpDir   -ItemType directory
    Write-Host "Directory has been created." -ForegroundColor Green
}



# change this to download from another page, other than the chan
$srcrpattern = '((i.4cdn.org|static.bumpworthy.com)([/|.|\w|\s|-])*\.(?:webm|mp4))' 
# default
$skip = $false

# Main - Invoking the web request, making first contact with the site.
Write-Host "Attempting to call website." -ForegroundColor Green

if($args[2] -eq "singlePage"){  #Page Retrieval single 4chan thread
$page=Invoke-WebRequest -Uri $args[0] 
} 
elseif ($args[2]-eq "bumpworthy") {  #Page Retrieval crawl through of www.bumpworthy.com
$count= 3
[Net.ServicePointManager]::SecurityProtocol = "Tls12, Tls11, Tls, Ssl3"
[System.Collections.ArrayList] $page = @()
$page.GetType()

if(-not (Test-Path("$bumpDir\scrapedLinksList.txt"))) {
    New-Item -itemType File -Path "$bumpDir\scrapedLinksList.txt"
    $count = 100
    }

For ($i=([IO.File]::ReadAllLines("$bumpDir\scrapedLinksList.txt")).length; $i -le ([IO.File]::ReadAllLines("$bumpDir\scrapedLinksList.txt")).length+$count; $i++) {
  
    $webDir = "$($args[0])$($i)"
    $pageTemp = Invoke-WebRequest -Uri $webDir 
   
    if(-not ($pageTemp -match 'A vast repository of Adult Swim bumps dating back to 2001, including audio and video downloads, live streaming, and musical artist information for each bump.')){
    $page.Add($pageTemp)
       
    }

    }
    
}


$src = ([regex]$srcrpattern).Matches($page) | ForEach-Object { 
    $_.Groups[1].Value
    
}


$scrapedLinks = [IO.File]::ReadAllText("$bumpDir\scrapedLinksList.txt")

if ($args[2]-eq "bumpworthy") {
@($src).foreach({

   if(-not $skip){
    if(-not ($scrapedLinks -match $_)) {
        $_ | Out-File -Append -FilePath  "$bumpDir\scrapedLinksList.txt"
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

