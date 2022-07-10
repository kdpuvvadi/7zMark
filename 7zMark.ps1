param(
        $type="7z",
        $setupclean="n",
        $fileCount=5000, 
        $lines=1000
    )

if( "7z","zip" -NotContains $type ) { Throw "$type is not valid method" }
if( "y","Y","n","N" -notcontains $setupclean ) { Throw "$setupclean is not valid input" }

$Folder = "temp"
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

function startBenchMark {
    $7ztime = Measure-Command -Expression { 7z a -mmt -mx9 $method test.$($type) .\$($Folder) | Out-Default } | select-object -Expand TotalMinutes 
    Write-Output "Time for completion $($7ztime.ToString("###.####")) Minutes"
}

function setup {
    $dumpStart = Read-Host -Prompt "Test Dump is not present. Press Y/y to create?[y/n]"
    if ($dumpStart -match "[yY]") {
        # $NoLines = Read-Host -Prompt "Select Number of lines:"
        # $NoFiles = Read-Host -Prompt "Enter number of files:"
        Invoke-Expression "./setup.ps1 -fileCount $fileCount -lines $lines"
        if(!$?){ Throw Write-Output "Something went wrong" }
    }
}

$dumpExist = Test-Path $Folder
if(!$dumpExist) {
    setup
}

#Check 7z installion status
. ./setup.ps1


$getSize = (Get-ChildItem .\temp\ | Measure-Object -Property Length -Sum ).Sum / 1048576
$sizeofDir = $getSize.ToString("###.##")

$startBench = Read-Host -Prompt "Size of dump is $($sizeofDir)Mb, Start Benchmark ?[y/n]"
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