param([int32] $fileCount=1000, $lines=100)


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