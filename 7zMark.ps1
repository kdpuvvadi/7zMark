param(
        $type="7z",
        $setupclean="n",
        $fileCount=20000, 
        $lines=10000
    )

if( "7z","zip" -NotContains $type ) { Throw "$type is not valid method" }
if( "y","Y","n","N" -notcontains $setupclean ) { Throw "$setupclean is not valid input" }

$Folder = "dump"
$method = "-t$($type)"
$outfile=$($Folder)+'.'+$($type)
Write-Output "Starting"

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
    New-Item -Path $Folder -Name "file.txt" -ItemType "file" -Value "The quick brown fox jumps over the lazy dog.`n" | out-null
    $totalLines = 0..[Int32]$lines
    $totalLines | ForEach-Object {
        Add-Content -Value 'The quick brown fox jumps over the lazy dog' -Path $Folder\file.txt
        Write-Progress -Activity "File Creation" -Status "addeding content.." -PercentComplete (($_/$lines)*100)
    }
}
function createdump {
    $totalFileCount=0..[int32]$filecount
    $totalFileCount | ForEach-Object {
        copy-item $Folder\file.txt -Destination $Folder\file$($_).txt
        Write-Progress -Activity "File Copy" -Status "Copying.." -PercentComplete (($_/$filecount)*100)
    }
}

function startBenchMark {
    $7ztime = (Measure-Command {
        $OriginalProgPref = $ProgressPreference
        $ProgressPreference = "SilentlyContinue"
        7z a -mmt -mx9 $method $outfile $($Folder)
        $ProgressPreference = $OriginalProgPref
    }).TotalSeconds
    Write-Host "Time for completion $7ztime Seconds"
}

function cleanOut { 
    # Deleting output archive if exists.
    if($(Test-Path $outfile)){
        Write-Host -NoNewline "Deleting $outfile" 
        remove-item $outfile -Force -Confirm:$false
        if($?){ Write-Host " Done" -ForegroundColor Green}
    }
    else {
        Write-Host -NoNewline "$outfile not found. "
        Write-Host "Exiting" -ForegroundColor Red
        exit 0
    }
}
function cleanDump {
    # Delete dump folder if exists
    if($(Test-Path $Folder)){
        Write-Host -NoNewline "Deleting $Folder" 
        remove-item $Folder -Force -Recurse -Confirm:$false
        if($?){ Write-Host " Done" -ForegroundColor Green }
    }  
    else {
        Write-Host -NoNewline "$Folder not found."
        Write-Host "Exiting" -ForegroundColor Red
        exit 0
    }
}

function setup {
    $dumpStart = Read-Host -Prompt "Test data is not present. Create?[y/n]"
    if ($dumpStart -match "[yY]") {
        createFolder
        if(!$?){ Throw Write-Output "Something went wrong" }
        Start-Sleep -Milliseconds 1500
        $timeForFile = (Measure-Command { createTextFile }).TotalSeconds
        if(!$?){ Throw Write-Output "Something went wrong" }
        Write-Host "Time for File Creation: $timeForFile Seconds"
        Start-Sleep -Milliseconds 1500
        $timeFordump = (Measure-Command { createdump }).TotalSeconds
        if(!$?){ Throw Write-Output "Something went wrong" }
        Write-Host "Time for dump Creation: $timeFordump Seconds"
    }
    elseif ($setupclean -match "[yY]") {
        Write-Output "Cleaning up"
        cleanOut
        cleanDump
    }
    else {
        Write-Host "Nothing to do. Exiting"
        exit 0
    }
}

$dumpExist = Test-Path $Folder
if(!$dumpExist) {
    setup
}

$getSize = (Get-ChildItem $Folder | Measure-Object -Property Length -Sum ).Sum / 1048576
$sizeofDir = $getSize.ToString("###.##")

$startBench = Read-Host -Prompt "Size of test data is $($sizeofDir)Mb, Start Benchmark?[y/n]"
if ($startBench -match "[yY]") {
    startBenchMark
    if(!$?){ Throw Write-Output "Something went wrong" }
}

if ( $setupclean -match "[yY]" ) { 
    Write-Output "Cleaning up"
    cleanDump
    cleanOut
}
else {
    exit 0
}
