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
$computers = Get-ADComputer -Filter {OperatingSystem -Like "*Windows 7*" -or OperatingSystem -Like "*Windows 8*" -or OperatingSystem -Like "*Windows 8.1*" -or OperatingSystem -Like "*Windows 10*"} |FT Name
Write-Host "Computers found:" -ForegroundColor Yellow

Write-Host $computers

foreach ($computer in $computers) {

  Write-Host "For computer:" $Computer -ForegroundColor Yellow
  Write-Host "CPU:"
  
  $cpu = Get-WmiObject Win32_Processor  -computername $computer | Select name
  
  Write-Host $cpu

  }#end foreach
