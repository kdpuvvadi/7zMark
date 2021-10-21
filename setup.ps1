param([int32] $fileCount=1000, $lines=100)
$Folder = "temp"

function createFolder {
    New-Item -ItemType Directory $Folder -Force| out-null
}

function createTextFile {
    $filename="file.txt"
    $quickbrown = "The quick brown fox jumps over the lazy dog"
    for ($x=1; $x -le $lines; $x++) { 
        Add-Content -Value  "$($quickbrown) `n" -Path $Folder\$($filename)
        Write-Progress -Activity "File Creation" -Status "addeding content" -PercentComplete (($x/$lines)*100)
    }
}
function createdump {
    for ($k=1; $k -le $fileCount; $k++) {
        Copy-Item $Folder\$($filename) -Destination $Folder\file$($k).txt
        Write-Progress -Activity "File copy" -Status "copying:" -PercentComplete (($k/$fileCount)*100)
    }
    if($?) { Write-Output "Setup Completed"} else { Write-Error -Message "Error" -ErrorId 1}
}

if (Test-Path -Path $Folder) {

    $folderexists = Read-Host -Prompt "Test dumt already exists, Continue to create dump files?[y/n]"
    if ( $folderexists -match "[yY]" ) { 

        remove-item $Folder  -Force -Recurse -Confirm:$false
        Start-Sleep -Milliseconds 1500
        createFolder
        Start-Sleep -Milliseconds 1500
        createTextFile
        Start-Sleep -Milliseconds 1500
        createdump
    }
    elseif ($folderexists -notmatch	 "[yY]") { exit 0 }
}
else { 
    Start-Sleep -Milliseconds 1500
    createFolder
    Start-Sleep -Milliseconds 1500
    createTextFile
    Start-Sleep -Milliseconds 1500
    createdump
 }