# =======================================================
# NAME: RebootServerDevice.ps1
# AUTHOR: Boissier Damien, Infopro45
# DATE: 17/06/2022
#
# KEYWORDS: VPN, L2TP , Unifi
# VERSION 1.0
# /MM/YYYY added help to the functions
# COMMENTS: Desription des traitements
#
#Requires -Version 4.0
# =======================================================

$serverDelay = "$ENV:serverDelay"
$hypervDelay = "$ENV:hypervDelay"

function Lunch-Reboot {
    msg * "Info : Le serveur va effectuer un redémarage de maintenance dans 60 secondes."
    Start-Sleep -Seconds 60
    Restart-Computer -Force
}

function Check-HypervCanReboot {
    $statevm = Get-VM
    $hypervcanreboot = $true
    foreach ($state in $statevm.state)
    {
        if ($state -ne "Off") {$hypervcanreboot = $false}
    }
    return $hypervcanreboot
}

# Get the Hyper-V feature and store it in $hyperv
$hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

# Check if Hyper-V is already enabled.
if($hyperv.State -eq "Enabled") {
    Write-Host "Hyper-V is enabled."
    Start-Sleep -Seconds $hypervDelay
    Write-Host "Arrêt des VMs :" ; Stop-VM -Name *
    if ($(Check-HypervCanReboot) -eq $true) {Lunch-Reboot}
    else {Write-Host "Echec de la procedure, une VM doit être bloqué dans un état :" ; Start-VM -Name *; exit 10}
} else {
    Write-Host "Hyper-V is disabled."
    Start-Sleep -Seconds $serverDelay
    Lunch-Reboot
}