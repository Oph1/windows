#Script for configure proxy setting

<#
$ProxyServer = "proxy-ecoles.ac-orleans-tours.fr:3128"
$ProxyBypassList = "192.168.2.3;192.168.2.4;192.168.2.5;192.168.2.72;<local>"
$TurnProxyOnOff = "On"
$ProxyPerMachine = $False
#/#>


#Get Datto Variable
param ([string]$ProxyServer = "proxy-ecoles.ac-orleans-tours.fr:3128",
       [string]$ProxyBypassList = "<local>",
       [string]$TurnProxyOnOff = "Off",
       [boolean]$ProxyPerMachine = $False)

if ([Environment]::GetEnvironmentVariable("ProxyServeur", "Process")) {
    $ProxyServeur = [Environment]::GetEnvironmentVariable("ProxyServeur", "Process")
}
if ([Environment]::GetEnvironmentVariable("ProxyBypassList", "Process")) {
    $ProxyBypassList = [Environment]::GetEnvironmentVariable("ProxyBypassList", "Process")
}
if ([Environment]::GetEnvironmentVariable("TurnProxyOnOff", "Process")) {
    $TurnProxyOnOff = [Environment]::GetEnvironmentVariable("TurnProxyOnOff", "Process")
}
if ([Environment]::GetEnvironmentVariable("ProxyPerMachine", "Process")) {
    $ProxyPerMachine = [Environment]::GetEnvironmentVariable("ProxyPerMachine", "Process")
}
 
#Example: Set-InternetProxy "mproxy:3128" "*.mysite.com;<local>"
function Set-InternetProxy($ProxyPerMachine, $TurnProxyOnOff, $proxy, $bypassUrls) {
    if ($TurnProxyOnOff -eq "Off") { $ProxyEnabled = '01'; $ProxyEnable = 0 } Else { $ProxyEnabled = '11'; $ProxyEnable = 1 }
 
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings"
    $proxyBytes = [system.Text.Encoding]::ASCII.GetBytes($proxy)
    $bypassBytes = [system.Text.Encoding]::ASCII.GetBytes($bypassUrls)
    $defaultConnectionSettings = [byte[]]@(@(70, 0, 0, 0, 0, 0, 0, 0, $ProxyEnabled, 0, 0, 0, $proxyBytes.Length, 0, 0, 0) + $proxyBytes + @($bypassBytes.Length, 0, 0, 0) + $bypassBytes + @(1..36 | % { 0 }))
                        
    if ($ProxyPerMachine -eq $True) { #ProxySettingsPerMachine         
 
        New-ItemProperty -Path $regPath -Name 'ProxySettingsPerUser' -Value 0 -PropertyType DWORD -Force #-ErrorAction SilentlyContinue
 
        #Set the proxy settings per Machine
        SetProxySettingsPerMachine $Proxy $ProxyEnable $defaultConnectionSettings
                        
        #As we are using the per machine proxy settings clear the user settings, tidy up.
        #This is done for all profiles found on the host as well as the default profile.
        ClearProxySettingPerUser
 
    }
    Elseif ($ProxyPerMachine -eq $False) { #ProxySettingsPerUser
        New-ItemProperty -Path $regPath -Name 'ProxySettingsPerUser' -Value 1 -PropertyType DWORD -Force #-ErrorAction SilentlyContinue
        #write-Host "we  get here"
 
        #Set the proxy settings per user (this is done for all profiles found on the host as well as the default profile)
        SetProxySettingsPerUser $Proxy $ProxyEnable $defaultConnectionSettings
             
        #As we are using the per user proxy settings clear the machine settings, tidy up.
        ClearProxySettingsPerMachine
 
    }          
}
 
function SetProxySettingsPerUser($Proxy, $ProxyEnable, $defaultConnectionSettings) {
     
    # Get each user profile SID and Path to the profile
    $UserProfiles = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | Where { $_.PSChildName -match "S-1-5-21-(\d+-?){4}$" } | Select-Object @{Name = "SID"; Expression = { $_.PSChildName } }, @{Name = "UserHive"; Expression = { "$($_.ProfileImagePath)\NTuser.dat" } }
 
    # We also grab the default user profile just in case the proxy settings have been changed in there, but they should not have been
    $DefaultProfile = "" | Select-Object SID, UserHive
    $DefaultProfile.SID = ".DEFAULT"
    $DefaultProfile.Userhive = "C:\Users\Public\NTuser.dat"
 
    #$UserProfiles += $DefaultProfile
 
    # Loop through each profile we found on the host
    Foreach ($UserProfile in $UserProfiles) {
        # Load ntuser.dat if it's not already loaded
        If (($ProfileAlreadyLoaded = Test-Path Registry::HKEY_USERS\$($UserProfile.SID)) -eq $false) {
            Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE LOAD HKU\$($UserProfile.SID) $($UserProfile.UserHive)" -Wait -WindowStyle Hidden
            Write-Host -ForegroundColor Cyan "Loading hive" $UserProfile.UserHive "for user profile SID:" $UserProfile.SID
        }
        Else {
            Write-Host -ForegroundColor Cyan "Hive already loaded" $UserProfile.UserHive "for user profile SID:" $UserProfile.SID
        }                    
                     
                     
        $registryPath = "Registry::HKEY_USERS\$($UserProfile.SID)\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
        #$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
        Set-ItemProperty -Path $registryPath -Name ProxyServer -Value $proxy
        Set-ItemProperty -Path $registryPath -Name ProxyEnable -Value $ProxyEnable
        Set-ItemProperty -Path "$registryPath\Connections" -Name DefaultConnectionSettings -Value $defaultConnectionSettings   
 
         
        # Unload NTuser.dat if it wasen't loaded to begin with.  
        If ($ProfileAlreadyLoaded -eq $false) {
            [gc]::Collect() #Ckean up any open handles to the registry to avoid getting an "Access Denied" error.
            Start-Sleep -Seconds 5 #Give it some time
            #Unoad the user profile, but only if we loaded it our selves manually.
            Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE UNLOAD HKU\$($UserProfile.SID)" -Wait -WindowStyle Hidden | Out-Null
            Write-Host -ForegroundColor Cyan "Unloading hive" $UserProfile.UserHive "for user profile SID:" $UserProfile.SID
        } 
    }
         
}    
     
function SetProxySettingsPerMachine ($Proxy, $ProxyEnable, $defaultConnectionSettings) {
 
    #Set the proxy settings per machine (this is done for both X64 and X86)
    $registryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    Set-ItemProperty -Path $registryPath -Name ProxyServer -Value $proxy
    Set-ItemProperty -Path $registryPath -Name ProxyEnable -Value $ProxyEnable
    Set-ItemProperty -Path "$registryPath\Connections" -Name DefaultConnectionSettings -Value $defaultConnectionSettings
             
    $registryPath = "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Internet Settings"
    Set-ItemProperty -Path $registryPath -Name ProxyServer -Value $proxy
    Set-ItemProperty -Path $registryPath -Name ProxyEnable -Value $ProxyEnable
    Set-ItemProperty -Path "$registryPath\Connections" -Name DefaultConnectionSettings -Value $defaultConnectionSettings
}
 
Function ClearProxySettingPerUser () {
    # Get each user profile SID and Path to the profile
    $UserProfiles = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | Where { $_.PSChildName -match "S-1-5-21-(\d+-?){4}$" } | Select-Object @{Name = "SID"; Expression = { $_.PSChildName } }, @{Name = "UserHive"; Expression = { "$($_.ProfileImagePath)\NTuser.dat" } }
 
    # We also grab the default user profile just in case the proxy settings have been changed in there, but they should not have been
    $DefaultProfile = "" | Select-Object SID, UserHive
    $DefaultProfile.SID = ".DEFAULT"
    $DefaultProfile.Userhive = "C:\Users\Public\NTuser.dat"
 
    $UserProfiles += $DefaultProfile
 
    # Loop through each profile we found on the host
    Foreach ($UserProfile in $UserProfiles) {
        # Load ntuser.dat if it's not already loaded
        If (($ProfileAlreadyLoaded = Test-Path Registry::HKEY_USERS\$($UserProfile.SID)) -eq $false) {
            Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE LOAD HKU\$($UserProfile.SID) $($UserProfile.UserHive)" -Wait -WindowStyle Hidden
            Write-Host -ForegroundColor Cyan "Loading hive" $UserProfile.UserHive "for user profile SID:" $UserProfile.SID
        }
        Else {
            Write-Host -ForegroundColor Cyan "Hive already loaded" $UserProfile.UserHive "for user profile SID:" $UserProfile.SID
        }
 
        #As you are using per machine setttings erase any proxy setting for the current user.
        $proxyBytes = [system.Text.Encoding]::ASCII.GetBytes('')
        $bypassBytes = [system.Text.Encoding]::ASCII.GetBytes('')
        $defaultConnectionSettings = [byte[]]@(@(70, 0, 0, 0, 0, 0, 0, 0, 01, 0, 0, 0, $proxyBytes.Length, 0, 0, 0) + $proxyBytes + @($bypassBytes.Length, 0, 0, 0) + $bypassBytes + @(1..36 | % { 0 }))
            
        $registryPath = "Registry::HKEY_USERS\$($UserProfile.SID)\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
        Set-ItemProperty -Path $registryPath -Name ProxyServer -Value ''
        Set-ItemProperty -Path $registryPath -Name ProxyEnable -Value 0
        Set-ItemProperty -Path "$registryPath\Connections" -Name DefaultConnectionSettings -Value $defaultConnectionSettings   
         
        # Unload NTuser.dat if it wasen't loaded to begin with.  
        If ($ProfileAlreadyLoaded -eq $false) {
            [gc]::Collect() #Clean up any open handles to the registry to avoid getting an "Access Denied" error.
            Start-Sleep -Seconds 2 #Give it some time
            #Unoad the user profile, but only if we loaded it our selves manually.
            Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE UNLOAD HKU\$($UserProfile.SID)" -Wait -WindowStyle Hidden | Out-Null
            Write-Host -ForegroundColor Cyan "Unloading hive" $UserProfile.UserHive "for user profile SID:" $UserProfile.SID
        } 
    }
}
     
Function ClearProxySettingsPerMachine () {
    #As you are using per user setttings erase any proxy setting per machine
    $proxyBytes = [system.Text.Encoding]::ASCII.GetBytes('')
    $bypassBytes = [system.Text.Encoding]::ASCII.GetBytes('')
    $defaultConnectionSettings = [byte[]]@(@(70, 0, 0, 0, 0, 0, 0, 0, 01, 0, 0, 0, $proxyBytes.Length, 0, 0, 0) + $proxyBytes + @($bypassBytes.Length, 0, 0, 0) + $bypassBytes + @(1..36 | % { 0 }))
             
    $registryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    Set-ItemProperty -Path $registryPath -Name ProxyServer -Value ''
    Set-ItemProperty -Path $registryPath -Name ProxyEnable -Value 0
    Set-ItemProperty -Path "$registryPath\Connections" -Name DefaultConnectionSettings -Value $defaultConnectionSettings
             
    $registryPath = "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Internet Settings"
    Set-ItemProperty -Path $registryPath -Name ProxyServer -Value ''
    Set-ItemProperty -Path $registryPath -Name ProxyEnable -Value 0
    Set-ItemProperty -Path "$registryPath\Connections" -Name DefaultConnectionSettings -Value $defaultConnectionSettings
}
 
 Set-InternetProxy $ProxyPerMachine $TurnProxyOnOff $ProxyServer $ProxyBypassList