param(
        $type="7z",
        $setupclean="n"
    )

if( "7z","zip" -NotContains $type ) { Throw "$type is not valid method" }
if( "y","Y","n","N" -notcontains $setupclean ) { Throw "$setupclean is not valid input" }

$Folder = "temp"
$method = "-t$($type)"
Write-Output "Starting"

function startBenchMark {
    $7ztime = Measure-Command -Expression { 7z a -mmt -mx9 $method test.$($type) .\$($Folder) | Out-Default } | select-object -Expand TotalMinutes 
    Write-Output "Time for completion $($7ztime.ToString("###.####")) Minutes"
}

$getSize = (Get-ChildItem .\temp\ | Measure-Object -Property Length -Sum ).Sum / 1048576
$sizeofDir = $getSize.ToString("###.##")

$startBench = Read-Host -Prompt "Size of dump is $($sizeofDir)Mib, Start Benchmark ?[y/n]"
if ($startBench -match "[yY]") {startBenchMark}

if ( $setupclean -match "[yY]" ) { 
    Write-Output "Cleaning up"
    remove-item test.$($type) -Force -Confirm:$false
    remove-item ./temp/  -Force -Recurse -Confirm:$false
}
else {
    exit 0
}