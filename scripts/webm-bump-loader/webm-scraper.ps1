#Step 1 - Invoking the web request, making first contact with the site.
Write-Host "Attempting to call website." -ForegroundColor Green
$page=Invoke-WebRequest -Uri $args[0]

#Step 2 - Create directory for files to be downloaded into
$webmDir = $args[1] 
New-Item -Path $webmDir   -ItemType directory
Write-Host "Directory has been created." -ForegroundColor Green

#Step 3 - List all webms from page and download them into newly created directory
$srcrpattern = '((i.4cdn.org)([/|.|\w|\s|-])*\.(?:webm))' # change this to download from another page, other than the chan
$src = ([regex]$srcrpattern ).Matches($page) |  ForEach-Object { $_.Groups[1].Value }

#Step 4 - Download webms, skip if file already exists
@($src).foreach({
$fileName = $_ | Split-Path -Leaf
if (Test-Path("$webmDir/$fileName")){
Write-Host 'Skipping file, already downloaded' -ForegroundColor Yellow
return
}
else 
{
Write-Host "Downloading image file $fileName"
Invoke-WebRequest -Uri $_ -OutFile "$webmDir/$fileName"
Write-Host 'Image download complete'
}
})
