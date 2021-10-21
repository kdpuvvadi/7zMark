param($type="7z")

if( "7z","zip" -NotContains $type ) { Throw "$type is not valid method" }

$Folder = "temp"
$method = "-t$($type)"
Write-Output "Starting"

function startBenchMark {
    param (
        $timeDuration
    )

    $7ztime = Measure-Command -Expression { 7z a -mmt -mx9 $method test.$($type) .\$($Folder)\ | Out-Default } | select-object -Expand TotalMinutes 
    if(!$?) {Throw Write-Output "Something Wentwrong" ; exit}
    return $7ztime
}

$startBench = Read-Host -Prompt "Start Benchmark ?[y/n]"
if ($startBench -match "[yY]") {startBenchMark($time); Write-Output "Time for completion $time "}

$cleanup = Read-Host -Prompt "Delete setup files?[y/n]"
if ( $cleanup -match "[yY]" ) { 
    Write-Output "Cleaning up"
    remove-item test.$($type) -Force -Confirm:$false
    remove-item ./temp/  -Force -Recurse -Confirm:$false
}
else {
    exit 0
}