####################################################################################################################
# Script: Users Must Change Password On Next Logon
# Auteur: Damien Boissier
# Versie: 5.1
####################################################################################################################

$IgnoredUsers=@(
    'dbois',
    'administrateur',
    'infopro',
    'DefaultAccount',
    'Invité',
    'WDAGUtilityAccount')

$UselessUsers=@(
    'administrateur',
    'Invité',
    'test')

#----------------------------------------------
#Active change password on next logon and disable unless user
#----------------------------------------------

$EnableUser = 512
$DisableUser = 2

#Get user info
function getUser ($Name, $ComputerName) {
    $user = [ADSI]"WinNT://$env:ComputerName/$Name,user"
    $user
}

#Set user option
function setUser ($UserObj) {
    $UserObj.SetInfo()
}

#Get users list.
$ListUsers=Get-LocalUser | Where-Object {$_.Name -notIn $IgnoredUsers -and $_.Name -notIn $UselessUsers}
$ListUsersToDisable=Get-LocalUser | Where-Object {$_.Name -In $UselessUsers}

#Foreach user set for change password.
Foreach ($User in $ListUsers) {
    Write-Host "Set 'Change Password on next logon' for " $User " : " -NoNewline
    $UserReg = getUser -Name $User
    $UserReg.PasswordExpired = 1
    $UserReg.SetInfo()
    if ($?) {Write-Host "OK" -ForegroundColor Green} else {Write-Host "Failed" -ForegroundColor Red}
}

#Foreach useless user disabled it.
Foreach ($User in $ListUsersToDisable) {
    Write-Host "Disable " $User " : " -NoNewline
    Disable-LocalUser -Name $User
    if ($?) {Write-Host "OK" -ForegroundColor Green} else {Write-Host "Failed" -ForegroundColor Red}
}