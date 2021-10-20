param([int32] $fileCount=1000, $lines=100)
$Folder = "temp"
New-Item -ItemType Directory $Folder -Force| out-null
$filename="file.txt"
$quickbrown
for ($x=1; $x -le $lines; $x++) { 
    Add-Content -Value  '$quickbrown `n' -Path $Folder\$($filename)
    Write-Progress -Activity "File Creation" -Status "addeding content" -PercentComplete (($x/$lines)*100)

}

for ($k=1; $k -le $fileCount; $k++) {
    
    Copy-Item $Folder\$($filename) -Destination $Folder\file$($k).txt
    Write-Progress -Activity "File copy" -Status "copying:" -PercentComplete (($k/$fileCount)*100)


}
