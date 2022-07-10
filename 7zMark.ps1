param(
        $type="7z",
        $setupclean="n",
        $fileCount=50000, 
        $lines=100000
    )

if( "7z","zip" -NotContains $type ) { Throw "$type is not valid method" }
if( "y","Y","n","N" -notcontains $setupclean ) { Throw "$setupclean is not valid input" }

$Folder = "$env:TEMP\temp"
$method = "-t$($type)"
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

function startBenchMark {
    $7ztime = Measure-Command -Expression { 7z a -mmt -mx9 $method test.$($type) $($Folder) | Out-Default } | select-object -Expand TotalSeconds 
    Write-Output "Time for completion $($7ztime.ToString("####")) Seconds"
}

function setup {
    $dumpStart = Read-Host -Prompt "Test data is not present. Create?[y/n]"
    if ($dumpStart -match "[yY]") {
        createFolder
        if(!$?){ Throw Write-Output "Something went wrong" }
        Start-Sleep -Milliseconds 1500
        createTextFile
        if(!$?){ Throw Write-Output "Something went wrong" }
        Start-Sleep -Milliseconds 1500
        createdump
        if(!$?){ Throw Write-Output "Something went wrong" }
    }
}

$dumpExist = Test-Path $Folder
if(!$dumpExist) {
    setup
}

$getSize = (Get-ChildItem .\temp\ | Measure-Object -Property Length -Sum ).Sum / 1048576
$sizeofDir = $getSize.ToString("###.##")

$startBench = Read-Host -Prompt "Size of test data is $($sizeofDir)Mb, Start Benchmark ?[y/n]"
if ($startBench -match "[yY]") {
    startBenchMark
    if(!$?){ Throw Write-Output "Something went wrong" }
    }

if ( $setupclean -match "[yY]" ) { 
    Write-Output "Cleaning up"
    remove-item test.$($type) -Force -Confirm:$false
    remove-item ./temp/  -Force -Recurse -Confirm:$false
}
else {
    exit 0
}