# =======================================================
# NAME: RebootServerDevice.ps1
# AUTHOR: Boissier Damien, Infopro45
# DATE: 17/06/2022
#
# KEYWORDS: Windows Server, Restart , Stop
# VERSION 1.0
# /MM/YYYY added help to the functions
# COMMENTS: Desription des traitements
#
#Requires -Version 3.0
# =======================================================

$serverDelay = "$ENV:serverDelay" #Retardement de l'execution pour les serveur non Hyper-V en seconde
$hypervDelay = "$ENV:hypervDelay" #Retardement de l'execution pour les serveur Hyper-V en seconde
$stopServer = "$ENV:stopServer"   #Executer un arret au lieu de redemarer
$forceHyperv = "$ENV:forceHyperv" #Forcer l'execution si des VMs sont toujours "Executer" après une tentative d'arrêt

function Launch-Reboot {
    msg * "Info : Le serveur va effectuer un redémarage de maintenance dans 60 secondes."
    Start-Sleep -Seconds 60
    Restart-Computer -Force
}

function Launch-Stop {
    msg * "Info : Le serveur va s'arrêter dans 60 secondes."
    Start-Sleep -Seconds 60
    Stop-Computer -Force
}

function Launch {
    if ($stopServer -eq $true){Launch-Stop} else {Launch-Reboot}
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

function Launch-StartProdVm {
    foreach ($vm in Get-VM) {
    if ($vm.AutomaticStartAction -eq "Start") {
        write-host -NoNewline "Demarrage "$vm.Name" : "; Start-VM -Name $vm.Name; if($?) {write-host "OK"}}}
}

# Get the Hyper-V feature and store it in $hyperv
$hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

# Check if Hyper-V is already enabled.
if($hyperv.State -eq "Enabled") {
    Write-Host "Hyper-V is enabled."
    Start-Sleep -Seconds $hypervDelay
    Write-Host "Arrêt des VMs :" ; Stop-VM -Name *
    if ($(Check-HypervCanReboot) -eq $true) {Launch}
    elseif ($forceHyperv -eq $true) {Launch}
    else {Write-Host "Echec de la procedure, une VM doit être bloqué dans un état :" ; Launch-StartProdVm; exit 10}
} else {
    Write-Host "Hyper-V is disabled."
    Start-Sleep -Seconds $serverDelay
    Launch
}