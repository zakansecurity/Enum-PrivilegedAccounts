# Enum-PrivilegedAccounts

This Powershell module automates the enumeration of Local Accounts/Groups on a set of Windows machines. It could filters a privileged accounts too.

This version uses WMI technology. The next version will include CIM and ADSI technologies.

## Functions

Test-Targets : Pings a list of machines, in order to create a list of available targets.
   
    param ($ListServer, $OutputFileUP, $OutputFileDOWN)


Get-LocalGroupsWMI : Lists local groups.
    
    param ($ListServer, $OutputCSV)

Get-LocalAccountsWMI : Lists local Accounts.
    
    param ($ListServer, $OutputCSV)

Get-PrivilegedAccountsWMI : Lists Privilived Accounts. The list of privileged groups is given on the parameter.
    
    param ($ListServer, $ListPrivilegedGroup, $OutputCSV)

## Prerequisites

Enabling PowerShell Remoting :
    
    Enable-PSRemoting –force
    
Make sure the WinRM service is setup to start automatically :
  
    # Set start mode to automatic
        Set-Service WinRM -StartMode Automatic
 
    # Verify start mode and state - it should be running
        Get-WmiObject -Class win32_service | Where-Object {$_.name -like "WinRM"}

Set all remote hosts to trusted. Note: You may want to unset this later :
      
      # Trust all hosts
        Set-Item WSMan:localhost\client\trustedhosts -value *
 
      # Verify trusted hosts configuration
        Get-Item WSMan:\localhost\Client\TrustedHosts
        
 Import the module :
      
      PS D:\Security\PowerShell> Import-Module .\Enum-PrivAccount.psd1
      
 ## Examples 
 
 ### Ping the servers :
PS D:\Security\PowerShell> Test-Targets -ListServer .\server.txt -OutputFileUP srvup.txt -OutputFileDOWN srvdown.txt
 
    [+] The Host 192.168.1.13 is up.
    PS D:\Security\PowerShell> ls


    Répertoire : D:\Security\PowerShell


    Mode                LastWriteTime     Length Name
    ----                -------------     ------ ----
    -a---        19/01/2017     16:02       5558 Enum-PrivAccount.psd1
    -a---        19/01/2017     15:58       7780 Enum-PrivAccount.psm1
    -a---        19/01/2017     13:43         58 server.txt
    -a---        19/01/2017     16:33         90 srvdown.txt
    -a---        19/01/2017     16:33         30 srvup.txt

PS D:\Security\PowerShell> cat .\srvup.txt
  
    192.168.1.13
    
PS D:\Security\PowerShell> cat .\srvdown.txt
    
    192.168.1.19
    192.168.1.133
    192.168.1.132
PS D:\Security\PowerShell>

### List of Local groups :
PS D:\Security\PowerShell> Get-LocalGroupsWMI -ListServer .\srvup.txt -OutputCSV localgroups.csv
    
    [+] Fetching Groups on 192.168.1.13.
    [+] The list of Groups is saved in localgroups.csv
    
PS D:\Security\PowerShell> cat .\localgroups.csv
    
    192.168.1.13;Administrateurs
    192.168.1.13;HomeUsers
    192.168.1.13;IIS_IUSRS
    192.168.1.13;Invités
    192.168.1.13;SQLServer2005SQLBrowserUser$KNASUS
    192.168.1.13;SQLServerMSSQLServerADHelperUser$KNASUS
    192.168.1.13;SQLServerMSSQLUser$knasus$SQLEXPRESS
    192.168.1.13;SQLServerSQLAgentUser$KNASUS$SQLEXPRESS
    192.168.1.13;Utilisateurs

### List of local Accounts :
PS D:\Security\PowerShell> Get-LocalAccountsWMI -ListServer .\srvup.txt -OutputCSV localaccounts.csv
    
    [+] Fetching Accounts on 192.168.1.13.
    [+] The list of Accounts is saved in localaccounts.csv

PS D:\Security\PowerShell> cat .\localaccounts.csv
    
    Administrateurs;Administrateur
    Administrateurs;kb
    IIS_IUSRS;IUSR
    Invités;Invité
    Utilisateurs;INTERACTIF
    Utilisateurs;Utilisateurs authentifiés
    HomeUsers;HomeGroupUser$
    HomeUsers;kb
    HomeUsers;UpdatusUser
    HomeUsers;WMPNetworkSvc
    HomeUsers;kbekkouche@outlook.fr
    HomeUsers;openpgsvc
    SQLServer2005SQLBrowserUser$KNASUS;SQLBrowser
    SQLServerMSSQLServerADHelperUser$KNASUS;SERVICE RÉSEAU
    SQLServerMSSQLServerADHelperUser$KNASUS;Système
    SQLServerMSSQLUser$knasus$SQLEXPRESS;MSSQL$SQLEXPRESS
    SQLServerSQLAgentUser$KNASUS$SQLEXPRESS;SQLAgent$SQLEXPRESS

### List Privilged Accounts regarding the given privileged groups list :

PS D:\Security\PowerShell> cat .\privilegedgroups.txt
Administrateurs

PS D:\Security\PowerShell> Get-PrivilegedAccountsWMI -ListServer .\srvup.txt -ListPrivilegedGroup .\privilegedgroups.txt -OutputCSV privilegedaccounts.csv

    [+] Fetching Privileged Accounts on 192.168.1.13.
    [+] The list of Privileged Accounts is saved in privilegedaccounts.csv

PS D:\Security\PowerShell> cat .\privilegedaccounts.csv
    
    Administrateurs;Administrateur
    Administrateurs;kb
    PS D:\Security\PowerShell>











      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      

    
    
    
