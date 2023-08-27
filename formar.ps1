# SCRIPT FOR AUTO FORMATTING A DISK

#check if the script is running with admin privilages
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if(-not $isAdmin){
    #run as administartor
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    
}

$disks = Get-Disk 
Write-Host("`n`n")
for($i=0; $i -lt $disks.Length; $i+=1){

    $size = $disks[$i].AllocatedSize
    
    for($j=0; $j -lt 3; $j += 1){
        $size /= 1000
    }
    $size = [Math]::Floor($size)

    Write-Host("`n`n $i - "+$disks[$i].FriendlyName+" | "+$size+" GB")

    #showing the partitions as well 

    $part = Get-Partition -DiskNumber $i
    $len = $part.Count
    if($len -gt 0){
        Write-Host("`n`n     -------- $len partitions --------`n")
        for($j=0; $j -lt $len; $j+=1){

            $size = $part[$j].Size
            Write-Host("     $j - $size bytes")
        }
    }
}

#user choses the number of the disk
$choise = Read-Host("`n choose disk")
$choise = [int]$choise

$disk = Get-Disk $choise | Clear-Disk -RemoveData

$fsType = Read-Host("`n file system type (fat), (exfat), (ntfs) etc`n Default is (exFAT) ")

if($fsType.ToLower() -eq "exfat"){
    $fsType = "exFAT"
}elseif ($fsType.ToLower() -eq "ntfs") {
    $fsType = "NTFS"
}else{
  
    $fsType = "exFAT"
  
}

Write-Host("`n DISK CLEANED! ")
$driveLetter = Read-Host("`n drive Letter ")

$driveLetter = $driveLetter.ToUpper()

$driveName = Read-Host("`n drive name ")

# formatting first
# creating the primary partuition
# assigning the drive letter
# assigning the label to the drive
$newPartition = New-Partition -DiskNumber $choise -UseMaximumSize -IsActive -DriveLetter $driveLetter | Format-Volume -FileSystem $fsType -NewFileSystemLabel $driveName