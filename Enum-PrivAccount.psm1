<#
    Author: Kader BEKKOUCHE.
    WebSite: www.zakansecurity.com
    Version: 1.0


#>

<#=================================================================================================#>

function Log {
    
    param (
        
        [Parameter (Mandatory = $True)] $Color,
        [Parameter (Mandatory = $True)] $Msg
    )

    switch ($color) {
            
        "green" { Write-Host "[+] " -NoNewline -ForegroundColor Green }
        "red"   { Write-Host "[-] " -NoNewline -ForegroundColor Red}
        "blue"  { Write-Host "[/] " -NoNewline -ForegroundColor Blue }
        default { Write-Host "[*] " -NoNewline }
    }

    Write-Host $msg

}

<#=================================================================================================#>
function Test-Targets {
    
        param ($ListServer, $OutputFileUP, $OutputFileDOWN)

        if ( $ListServer -eq $null ) {
            
            Log -Color "red" -Msg "ERROR, There isn't any target machine specified ! Check Options !"
        }

        if ($OutputFileUP -eq $null) { $OutputFileUP = "MachinesUP.txt" }
        if ($OutputFileDOWN -eq $null) { $OutputFileDOWN = "MachinesDOWN.txt" }

        if ( Test-Path $OutputFileUP ) { Remove-Item $OutputFileUP -Confirm }
        if ( Test-Path $OutputFileDOWN ) { Remove-Item $OutputFileDOWN -Confirm }

        if ( Test-Path $ListServer) {

            $NBLines = (Get-Content $ListServer | Measure-Object -Line).Lines
            $Count = 0
        

            Get-Content $ListServer | Foreach-Object { 
            
                $Target = $_ 
                if (Test-Connection -ComputerName $Target -Quiet) { 
                    $Target | Out-File -FilePath $OutputFileUP -Append 
                    Log "green" "The Host $Target is up."
                }
                else { $Target | Out-File -FilePath $OutputFileDOWN -Append }

                $Count++
                Write-Progress -Activity "Gathering Information" -status "Pinging Hosts..." -percentComplete ($Count / $NBLines * 100)

            }

        } else {  Log -Color "red" -Msg "ERROR, The list of server $ListServer is not found !" }

}

<#=================================================================================================#>
function Get-LocalGroupsWMI {
    
    param ($ListServer, $OutputCSV)

    if ( $ListServer -eq $null ) { Log -Color "red" -Msg "ERROR, There isn't any target machine specified ! Check Options !" }
    
    if ($OutputCSV -eq $null) { $OutputCSV = "Machines_Local_Groups.csv" }
    if ( Test-Path $OutputCSV ) { Remove-Item $OutputCSV -Confirm }
    if ( Test-Path "temp.csv" ) { Remove-Item "temp.csv" }

    if ( Test-Path $ListServer) {

        $NBLines = (Get-Content $ListServer | Measure-Object -Line).Lines
        $Count = 0

        
        Get-Content $ListServer | ForEach-Object { 
            
            $Target = $_ 

            Log "green" "Fetching Groups on $Target."
            
            $Groups = Get-WmiObject -Class Win32_GroupUser -ComputerName $Target
            $Groups = $Groups |% { $_.groupcomponent  -match ".+Domain\=(.+)\,Name\=(.+)$" > $null; $matches[2].trim('"') }
            $Groups = $Groups | Select-Object -Unique

            $Groups | ForEach-Object { $Group = $_; echo "$Target;$Group" >> temp.csv } 

            $Count++
            Write-Progress -Activity "Gathering Information" -status "Getting Groups..." -percentComplete ($Count / $NBLines * 100)

        }

        Get-Content temp.csv | sort -Unique > $OutputCSV

        Log "green" "The list of Groups is saved in $OutputCSV"

    } else {  Log -Color "red" -Msg "ERROR, The list of server $ListServer is not found !" }

}
<#=================================================================================================#>
function Get-LocalAccountsWMI {
    
    param ($ListServer, $OutputCSV)

    if ( $ListServer -eq $null ) { Log -Color "red" -Msg "ERROR, There isn't any target machine specified ! Check Options !" }
    
    if ($OutputCSV -eq $null) { $OutputCSV = "Machines_Local_Accounts.csv" }
    if ( Test-Path $OutputCSV ) { Remove-Item $OutputCSV -Confirm }
    
    if ( Test-Path $ListServer) {

        $NBLines = (Get-Content $ListServer | Measure-Object -Line).Lines
        $Count = 0

        
        Get-Content $ListServer | ForEach-Object { 
            
            $Target = $_ 

            Log "green" "Fetching Accounts on $Target."
            
            $Groups = Get-WmiObject -Class Win32_GroupUser -ComputerName $Target
            $Groups = $Groups |? { $_.groupcomponent  -like '*' }
            $Groups = $Groups | Select-Object -Unique
            $Groups |% {
                $_.partcomponent –match ".+Domain\=(.+)\,Name\=(.+)$" > $null
                $Account = $matches[2].trim('"') 
                $_.groupcomponent  -match ".+Domain\=(.+)\,Name\=(.+)$" > $null
                $Group = $matches[2].trim('"'); 

                echo "$Group;$Account" >> $OutputCSV

            }

            $Count++
            Write-Progress -Activity "Gathering Information" -status "Getting Accountss..." -percentComplete ($Count / $NBLines * 100)

        }

        Log "green" "The list of Accounts is saved in $OutputCSV"

    } else {  Log -Color "red" -Msg "ERROR, The list of server $ListServer is not found !" }
}
<#=================================================================================================#>
function Get-PrivilegedAccountsWMI {
    
    param ($ListServer, $ListPrivilegedGroup, $OutputCSV)

    if ( $ListServer -eq $null -or $ListPrivilegedGroup -eq $null ) { Log -Color "red" -Msg "ERROR, There isn't any target machine specified ! Check Options !" }
    
    if ($OutputCSV -eq $null) { $OutputCSV = "Machines_Privileged_Accounts.csv" }

    if ( Test-Path $OutputCSV ) { Remove-Item $OutputCSV -Confirm }
    
    if ( (Test-Path $ListServer) -and (Test-Path $ListPrivilegedGroup) ) {

        $NBLines = (Get-Content $ListServer | Measure-Object -Line).Lines
        $Count = 0

        
        Get-Content $ListServer | ForEach-Object { 
            
            $Target = $_ 

            Log "green" "Fetching Privileged Accounts on $Target."
            
            $Groups = Get-WmiObject -Class Win32_GroupUser -ComputerName $Target

            Get-Content $ListPrivilegedGroup | ForEach-Object {
            
                $PrivGroup = $_

                $Groups = $Groups |? { $_.groupcomponent  -like "*$PrivGroup*" }
                $Groups = $Groups | Select-Object -Unique

                    $Groups |% {
                    $_.partcomponent –match ".+Domain\=(.+)\,Name\=(.+)$" > $null
                    $User = $matches[2].trim('"') 
                    $_.groupcomponent  -match ".+Domain\=(.+)\,Name\=(.+)$" > $null
                    $Group = $matches[2].trim('"'); 

                    echo "$Group;$User" >> $OutputCSV

                }
            }

            $Count++
            Write-Progress -Activity "Gathering Information" -status "Getting Userss..." -percentComplete ($Count / $NBLines * 100)

            Log "green" "The list of Privileged Accounts is saved in $OutputCSV"

        }

    } else {  Log -Color "red" -Msg "ERROR, At least one of you're giving lists doesn't exist : $ListServer, $ListPrivilegedGroup !" }
}
<#=================================================================================================#>

Export-ModuleMember -Function *-*

<#=================================================================================================#>
