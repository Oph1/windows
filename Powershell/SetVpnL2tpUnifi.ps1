# =======================================================
# NAME: SetVpnL2tpUnifi.ps1
# AUTHOR: Boissier Damien, Infopro45
# DATE: 18/05/2022
#
# KEYWORDS: VPN, L2TP , Unifi
# VERSION 1.0
# /MM/YYYY added help to the functions
# COMMENTS: Desription des traitements
#
#Requires -Version 4.0
# =======================================================

# VPN Settings / parameters
$Settings = @{
    Name                  = "VPN Infopro"
    ServerAddress         = "vpn.infopro45.fr"
    L2tpPsk	              = "7T8WJCwT2wS5M79TKifel3uAtghCbOH7"
    TunnelType 		      = "L2TP" 
    EncryptionLevel       = "Optional" 
    AuthenticationMethod  = "MSChapv2"
    Force	          	  = $true 
    RememberCredential    = $true 
    SplitTunneling        = $false
    AllUserConnection	  = $true
    #DnsSuffix             = "DnsSuffix"
    UseWinLogonCredential = $false
}

<#$Settings = @{
    Name                  = "$ENV:VPNName"
    ServerAddress         = "$ENV:ServerAddress"
    L2tpPsk	              = "$ENV:L2tpPsk"
    TunnelType 		      = "$ENV:TunnelType" 
    EncryptionLevel       = "$ENV:EncryptionLevel" 
    AuthenticationMethod  = "$ENV:AuthenticationMethod"
    Force	          	  = $ENV:Force 
    RememberCredential    = $ENV:RememberCredential
    SplitTunneling        = $ENV:SplitTunneling
    AllUserConnection	  = $ENV:AllUserConnection
    DnsSuffix             = "$ENV:DnsSuffix"
    UseWinLogonCredential = $ENV:UseWinLogonCredential
}#>

# VPN User Credentials
$UserSettings = @{
    connectionname        = "VPN Infopro"
    username              = "virginie.wion"
    password              = "!XDGce^W^5o*" 
    domain                = ""
}

<#$UserSettings = @{
    connectionname        = "$ENV:VPNName"
    username              = "$ENV:VPNUserName"
    password              = "$ENV:VPNUserPass" 
}#>

# Create VPN Connection
$VPN = Get-VPNconnection -name $($Settings.Name) -AllUserConnection
if (!$VPN) {
    Add-VPNconnection @Settings -verbose
}
else {
    Set-VpnConnection @settings -Verbose
}

# Checks if user credentials are set, otherwise ends script.
# Sets script bypass policy, installs NuGet + credentials helper module.
# Finds current user and creates a scheduled task that runs once on next login, then deletes itself. 
if (!"$($UserSettings.username)") { break } 
else {
Set-ExecutionPolicy Bypass -Scope Process
Install-PackageProvider -Name NuGet -Force
Install-Module -Name VPNCredentialsHelper -Force

# Finds current user and creates a scheduled task that runs once on next login, then deletes itself. 
$ENV:Confirm = '$false'
$current_user = (Get-CimInstance –ClassName Win32_ComputerSystem | Select-Object -expand UserName)
$action1 = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-WindowStyle Hidden Import-Module VPNCredentialsHelper; Set-VpnConnectionUserNamePassword @UserSettings"
$delete = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-WindowStyle Hidden Unregister-ScheduledTask -TaskName VPNSetup -TaskPath \ -Confirm:$ENV:confirm"
$trigger1 = New-ScheduledTaskTrigger -AtLogOn -User $current_user
$task = New-ScheduledTask -Action $action1,$delete -Trigger $trigger1 
Register-ScheduledTask -Action $action1,$delete -Trigger $trigger1 -User $current_user -Description "Add VPN Credentials" -TaskName 'VPNSetup' -RunLevel Highest
$ScheduledTaskSettings1 = New-ScheduledTaskSettingsSet –AllowStartIfOnBatteries –DontStopIfGoingOnBatteries -Hidden
Set-ScheduledTask -TaskName 'VPNSetup' -TaskPath \ -Settings $ScheduledTaskSettings1

# Set VPN Profile to Private
$action2 = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "Set-NetConnectionProfile -InterfaceAlias '$($UserSettings.connectionname)' -NetworkCategory Private"
$delete2 = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-WindowStyle Hidden Unregister-ScheduledTask -TaskName 'SetVPNProfile' -TaskPath \ -Confirm:$ENV:confirm"
$CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
$trigger2 = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
$trigger2.Subscription = 
@"
<QueryList><Query Id="0" Path="System"><Select Path="System">*[System[Provider[@Name='Rasman'] and EventID=20267]]</Select></Query></QueryList>
"@
Register-ScheduledTask -Action $action2,$delete2 -Trigger $trigger2 -TaskName "SetVPNProfile" -Description 'Set VPN Profile to Private' -User 'System' -Force 
$ScheduledTaskSettings2 = New-ScheduledTaskSettingsSet –AllowStartIfOnBatteries –DontStopIfGoingOnBatteries -Hidden
Set-ScheduledTask -TaskName 'SetVPNProfile' -TaskPath \ -Settings $ScheduledTaskSettings2
}