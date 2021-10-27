param([int32] $fileCount=1000, $lines=100)
$Folder = "temp"

# Check 7Zip installed or not
function get7z {
    $is7z = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "7-Zip*"}
    if($null -eq $is7z.VersionMajor ) {
    Throw "7Zip is not installed on your PC"
    exit 1
    }
}

get7z

function createFolder {
    New-Item -ItemType Directory $Folder -Force | out-null
}

function createTextFile {
    New-Item -Path ./$Folder -Name "file.txt" -ItemType "file" -Value "The quick brown fox jumps over the lazy dog.`n" | out-null
    for ($x=1; $x -le $lines; $x++) { 
        Add-Content -Value 'The quick brown fox jumps over the lazy dog' -Path $Folder\file.txt
        Write-Progress -Activity "File Creation" -Status "addeding content" -PercentComplete (($x/$lines)*100)
    }
}
function createdump {
    for ($k=1; $k -le $fileCount; $k++) {
        Copy-Item $Folder\file.txt -Destination $Folder\file$($k).txt
        Write-Progress -Activity "File copy" -Status "copying:" -PercentComplete (($k/$fileCount)*100)
    }
    if($?) { Write-Output "Setup Completed"} else { Write-Error -Message "Error" -ErrorId 1}
}

function runOpr {
    createFolder
    Start-Sleep -Milliseconds 1500
    createTextFile
    Start-Sleep -Milliseconds 1500
    createdump
}


if (Test-Path -Path $Folder) {

    $folderexists = Read-Host -Prompt "Test dumt already exists, Continue to create dump files?[y/n]"
    if ( $folderexists -match "[yY]" ) { 

        remove-item $Folder  -Force -Recurse -Confirm:$false
        Start-Sleep -Milliseconds 1500
        runOpr
        
    }
    elseif ($folderexists -notmatch	 "[yY]") { exit 0 }
}
else { 
    runOpr
 }