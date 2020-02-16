#Step 1 - Invoking the web request, making first contact with the site.
Write-Host "Attempting to call website." -ForegroundColor Green
$page=Invoke-WebRequest -Uri "https://boards.4channel.org/wsg/thread/3201021" # <-- put [wsg] bump thread link here 

#Step 2 - Create directory for files to be downloaded into
$wsgDir = "C:\Users\$env:USERNAME\Videos\wsgBumps" # set this to desired directory
New-Item -Path $wsgDir   -ItemType directory
Write-Host "Directory has been created." -ForegroundColor Green

#Step 3 - List all webms from page and download them into newly created directory
$srcrpattern = '((i.4cdn.org)([/|.|\w|\s|-])*\.(?:webm))'
$src = ([regex]$srcrpattern ).Matches($page) |  ForEach-Object { $_.Groups[1].Value }

#Step 4 - Download webms, skip if file already exists
@($src).foreach({
$fileName = $_ | Split-Path -Leaf
if (Test-Path("$wsgDir/$fileName")){
Write-Host 'Skipping file, already downloaded' -ForegroundColor Yellow
return
}
else 
{
Write-Host "Downloading image file $fileName"
Invoke-WebRequest -Uri $_ -OutFile "$wsgDir/$fileName"
Write-Host 'Image download complete'
}
})