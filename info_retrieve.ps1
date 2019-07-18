<#
Author: Stefanos Chatzakis
Version: 0.1
Company: Fourlis Group
Created on 17/07/2019
#>

<#
The purpose of this script is to access the active directory computers and
retrieve information regarding the operating system as well as hardware parts.
#>

Write-Host "Starting script!"

#Hash map for RAM type
$MemoryTypeMap = @{
  "0" = 'Unknown'
  "1" = 'Other'
  "2" = 'DRAM'
  "3" = 'Synchronous DRAM'
  "4" = 'Cache DRAM'
  "5" = 'EDO'
  "6" = 'EDRAM'
  "7" = 'VRAM'
  "8" = 'SRAM'
  "9" = 'RAM'
  "10" = 'ROM'
  "11" = 'Flash'
  "12" = 'EEPROM'
  "13" = 'FEPROM'
  "14" = 'EPROM'
  "15" = 'CDRAM'
  "16" = '3DRAM'
  "17" = 'SDRAM'
  "18" = 'SGRAM'
  "19" = 'RDRAM'
  "20" = 'DDR'
  "21" = 'DDR2'
  "22" = 'DDR2 FB-DIMM'
  "24" = 'DDR3'
  "25" = 'FBD2'
}

#prompt the admin for option.
$Readhost = Read-Host "Type (1(single directory)/2(active directory)/3(cancel))"

if($ReadHost -eq "1") {
  #Verifies that the active directory is enabled and enables it.
  if(!(Get-Module activedirectory)){
    Write-Host "Host does not have activedirectory module installed, installing"
    Import-Module activedirectory
    Clear-Host
  }#end if

  $CompName = Read-Host  "Enter computer name:"
  if ($CompName -Like "FH*") {
    #This retriece the cpu and print it
    Write-Host "For computer:" $CompName -ForegroundColor Yellow
    Write-Host "CPU:"
    $cpu = Get-WmiObject Win32_Processor  -computername $CompName | Select name
    Write-Host $cpu

    #Hard drive
    $drives = Get-WmiObject win32_diskdrive | Where-Object{$_.mediatype -eq "HDD" -or $_.mediatype -eq "SSD"} | ForEach-Object -Process {$_.DeviceID} |Format-Table Name, MediaType
    Write-Host "Hard Drives:"
    Write-Host $drives

    #Memory
    $memory = Get-WmiObject Win32_PhysicalMemory |Select @{Label = 'Type';Expression = {$MemoryTypeMap["$($_.MemoryType)"]}}
    Write-Host "Memory:"
    Write-Host $memory
  }#end if
}#end if

elseif ($Readhost -eq "2") {
  $computers = Get-ADComputer -Filter {OperatingSystem -Like "*Windows 7*" -or OperatingSystem -Like "*Windows 8*" -or OperatingSystem -Like "*Windows 8.1*" -or OperatingSystem -Like "*Windows 10*"} |FT Name
  Write-Host "Computers found:" -ForegroundColor Yellow

  Write-Host $computers

  foreach ($computer in $computers) {
    #Verifies that the active directory is enabled and enables it.
    if(!(Get-Module activedirectory)){
      Write-Host "Host does not have activedirectory module installed,
        installing"
      Import-Module activedirectory
      Clear-Host
    }#end if
    
    Write-Host "For computer:" $Computer -ForegroundColor Yellow
    Write-Host "CPU:"
    cpu = Get-WmiObject Win32_Processor  -computername $computer | select name
    Write-Host $cpu

    #Hard drive
    Get-WmiObject win32_diskdrive | Where-Object{$_.mediatype -eq "HDD" -or $_.mediatype -eq "SSD"} | ForEach-Object -Process {$_.DeviceID} |Format-Table Name, MediaType
    #Write-Host "Hard Drives:"
    Write-Host $drives

    #Memory
    $memory = Get-WmiObject Win32_PhysicalMemory |Select @{Label = 'Type';Expression = {$MemoryTypeMap["$($_.MemoryType)"]}}
    Write-Host "Memory:"
    Write-Host $memory
  }#end foreach
}#end elseif
