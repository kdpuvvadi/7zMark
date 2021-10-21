param($type="7z")

if( "7z","zip" -NotContains $type ) { Throw "$type is not valid method" }

$Folder = "temp"
$method = "-t$($type)"
Write-Output "Starting"
$7ztime = Measure-Command -Expression { 7z a -mmt -mx9 $method test.$($type) .\$($Folder)\ | Out-Default } 

$duration =$7ztime | select-object -Expand TotalMinutes 

if($?) {Write-Output "Completed"}

Write-Output "Operation took $duration minutes"


$cleanup = Read-Host -Prompt "Delete setup files?[y/n]"
if ( $cleanup -match "[yY]" ) { 
    Write-Output "Cleaning up"
    remove-item test.$($type) -Force -Confirm:$false
    remove-item ./temp/  -Force -Recurse -Confirm:$false
}
else {
    exit 0
}