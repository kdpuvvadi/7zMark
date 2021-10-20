param($type="7z")

$method = "-t$($type)"
Write-Output "Starting"
$7ztime = Measure-Command -Expression { 7z a -mmt -mx9 $method test.$($type) .\$($Folder)\ | Out-Default } 

$duration =$7ztime | select-object -Expand TotalMinutes 

if($?) {Write-Output "Completed"}

Write-Output "Operation took $duration minutes"
Write-Output "Deleting Out file"
remove-item test.$($type) -Force -Confirm:$false

$cleanup = Read-Host -Prompt "Delete setup files?[y/n]"
if ( $cleanup -match "[yY]" ) { 
    remove-item ./temp/  -Force -Recurse -Confirm:$false
}
else {
    exit 0
}