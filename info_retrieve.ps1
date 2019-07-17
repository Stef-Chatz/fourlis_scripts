<#
Author: Stefanos Chatzakis
Version: 1.2
Company: Fourlis Group
Created on 04/07/2019
#>

<#
The purpose of this script is to access the active directory computers and
retrieve information regarding the operating system as well as hardware parts.
#>

while($Repeat) {
  Write-Host "Starting script!"
  $servers = Get-ADComputer -Filter {OperatingSystem -Like "*Windows 7*" -or "*Windows 8*" -or "*Windows 8.1*" -or "*Windows 10*"} |ForEach-Object {$_.Name}
  Write-Host "Computers found:" -ForegroundColor Yellow

  Write-Host $servers

  foreach ($server in $servers) {
    Invoke-Command -ComputerName $server -ScriptBlock{
      Write-Host "The computer $server is using:"
      Get_WmiObject win32_processor -Name 
    }#end Invoke-Command
  }#end foreach
}#end while
