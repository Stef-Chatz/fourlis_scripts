<#
Author: Stefanos Chatzakis
Version: 1.2
Company: Fourlis Group
Created on 04/07/2019
#>

<#
The purpose of this script is to logoff disconnected users that have been in
that status for over an hour. It achieves this by first establishing a PSSession
(persistent connection) to the active direcotry or a specific server.
#>

#boolean to allow the admin to rerun the script when bolean changes to false.
$Repeat = $True

<# This while loop exists in order to be able to rerun the script without
re-executing it. #>
While($Repeat) {
  #Ask Admin for the Name of the server.
  Write-Host '=================================================='
  Write-Host 'Would you like to select the Active Directory or a
  specific server?' -ForegroundColor Yellow

  #prompt the admin for option.
  $Readhost = Read-Host "Type (1(single directory)/2(active directory)/3 (cancel))"

  #Crete an empty array to store names of failedServers.
  $failedServers = @()
  $DiscUsers = @()
  $newArray = @()

  #Execute if admin chose single directory.
  if($Readhost -match "1") {
    #Ask for specific Server
    $server = Read-Host -Prompt 'Enter Server/Computer name'

    #connection with the server was successful.
    Write-Host "$server is accessible, moving on"
    $failedServers += "none"

    #List current users operating on remote host.
    Invoke-Command -ComputerName $server -ScriptBlock {
      $sessions = query user /server:$server | select -skip 1
      foreach ($line in $sessions) {
        $line = -split $line;

        #Check for missing SessionName field/column
        if ($line.length -eq 8) {
          # Get current session state (column 4)
          $state = $line[3];

          # Get Session ID (column 3) and current idle time (column 5)
          $sessionid = $line[2];
          $idletime = $line[4];
        }#end if

        else {
          # Get current session state (column 3)
          $state = $line[2];

          # Get Session ID (column 2) and current idle time (column 4)
          $sessionid = $line[1];
          $idletime = $line[3];
        }#end else

        $line = -split $line;

        # If the session state is Disconnected
        if ($state -eq "Disc") {
          $line += $DiscUsers

          # Check if idle for more than 1 day (has a '+') and log off
          if ($idletime -like "*+*") {
            logoff $sessionid /server:$server /v
            # Check if idle for more than 1 hour (has a ':') and log off
          }#end if

          elseif ($idletime -like "*:*") {
            logoff $sessionid /server:$server /v
          }#end elseif
        }#end if
      }#end foreach
    }#end scriptBlock

    Write-Host "Failed Servers:" $failedServers -ForegroundColor Yellow
    $failedServers.Clear()

    if ($newArray.length -eq 0) {
      Write-Host "There were no disconnected users." -ForegroundColor Yellow
    }#end if
    else {
      $newArray.Clear()
    }#end else
  }#end if

  #If the admin chose active direcory.
  elseif($Readhost -match "2") {

    #Select only the computers running any version of Windows Server.
    #$servers = Get-ADComputer -Filter {OperatingSystem -Like "*Windows Server*"} -Properties OperatingSystem | Sort name | Format-Table name, OperatingSystem | out-string
    $servers = Get-ADComputer -Filter {OperatingSystem -Like "*Windows Server*"} | ForEach-Object {$_.Name}
    Write-host "Servers found: " -ForegroundColor Yellow

    Write-Host $servers

    #Double check before proceeding with logging off disconnected users.
    Write-host "Users that have disconnected from the above servers will be disconnected. (y/n):" -BackgroundColor DarkCyan
    $continueDisc = Read-Host

    if ($continueDisc -match "y") {

      foreach ($server in $servers) {
        #Establish connection with server
        Invoke-Command -ComputerName $server -ScriptBlock{

          if(-not($testSession)) {
            #connection with the server was unsuccessful.
            Write-Warning "$server is inaccessible, the script will continue running regardless."
            $failedServers += $server
            Write-Host "stopped here."
          }#end if

          else {
            #connection with the server was successful.
            Write-Host "$server is accessible, continuing."

            #List current users operating on remote host.
            $sessions = query user /server:$server | select -skip 1;
            Write-Host $sessions

            # Loop through each session/line returned
            foreach ($line in $sessions) {
              $line = -split $line;

              #Check for missing SessionName field/column
              if ($line.length -eq 8) {
                # Get current session state (column 4)
                $state = $line[3];

                # Get Session ID (column 3) and current idle time (column 5)
                $sessionid = $line[2];
                $idletime = $line[4];
              }#end if

              else {
                # Get current session state (column 3)
                $state = $line[2];

                # Get Session ID (column 2) and current idle time (column 4)
                $sessionid = $line[1];
                $idletime = $line[3];
              }#end else

              $line = -split $line;

              # If the session state is Disconnected
              if ($state -eq "Disc") {
                  $line += $DiscUsers
                  quser

                # Check if idle for more than 1 day (has a '+') and log off
                if ($idletime -like "*+*") {
                  logoff $sessionid /server:$server /v
                  # Check if idle for more than 1 hour (has a ':') and log off
                }#end if

                elseif ($idletime -like "*:*") {
                  logoff $sessionid /server:$server /v
                }#end elseif
              }#end if
            }#end foreach

            if($DiscUsers -eq 0) {
              Write-Host "none"
            }#end if
          }#end else

          if ($DiscUsers.length -eq 0) {
            Write-Host  "none" -ForegroundColor Yellow
          }#end if

          else {
            $DiscUsers = @()
          }#end else
        }#end invoke-command
      }#end foreach
    }#end if

    elseif($continueDisc -match "n") {
      break
    }#end elseif

    $string = $failedServers -join "-n"
    Write-Host "Failed servers:"
    Write-Host $string

    $failedServers.Clear()
  }#end elseif

  else {
    Write-Host "The script has now been terminated."
    break
  }#end else

  $rerun = Read-Host "Would you like to rerun the script? (y/n)"

  if ($rerun -match "n") {
    $Repeat = $False
  }#end if
}#end while
