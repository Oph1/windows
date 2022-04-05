####################################################################################################################
# Script: Setup Windows 10 machine and up
# Auteur: 
# Versie: 1.0
# Function Check-PendingReboot: https://stackoverflow.com/questions/47867949/how-can-i-check-for-a-pending-reboot
####################################################################################################################

#-------------------------------------------------------------------------------------------------------------------
# Question avant lancement
#-------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------
# Update Windows
#-------------------------------------------------------------------------------------------------------------------
# Function to check pending reboot.
function Check-PendingReboot {
    if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return $true }
    if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return $true }
    if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return $true }
    try { 
        $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
        $status = $util.DetermineIfRebootPending()
        if (($status -ne $null) -and $status.RebootPending) {
            return $true
        }
    }
    catch { }

    return $false
}

# Change Execution Policy for this process to run the script.
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force

# Install the required packages.
Install-PackageProvider -Name NuGet -Force > $null
Install-Module -Name PSWindowsUpdate -Force > $null

# Import the required module.
Import-Module PSWindowsUpdate

# Look for all updates, download, install and don't reboot yet.
Get-WindowsUpdate -AcceptAll -Download -Install -IgnoreReboot

# Check if a pending reboot is found, notify users if that is the case. If none found just close the session.
$reboot = Check-PendingReboot

if($reboot -eq $true){
   write-host("Pending reboot found. Reboot..")
   cmd /c "msg * "Windows update has finished downloading and needs to reboot to install the required updates. Rebooting in 5 minutes..""
   #cmd /c "Shutdown /r /f /t 300"
   #Exit
   
}else {
   write-host("No Pending reboot. Shutting down PowerShell..")
   #Exit
}

#-------------------------------------------------------------------------------------------------------------------
# Check Infopro User
#-------------------------------------------------------------------------------------------------------------------
#Clear-Host
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

#User to search for
$USERNAME = "infopro"

#Declare LocalUser Object
$ObjLocalUser = $null

try {
    Write-Verbose "Searching for $($USERNAME) in LocalUser DataBase"
    $ObjLocalUser = Get-LocalUser $USERNAME
    Write-Verbose "User $($USERNAME) was found"
}
catch [Microsoft.PowerShell.Commands.UserNotFoundException] {
    "User $($USERNAME) was not found" | Write-Warning
}
catch {
    "An unspecifed error occured" | Write-Error
    Exit # Stop Powershell! 
}

#Create the user if it was not found (Example)
if (!$ObjLocalUser) {
    Write-Verbose "Creating User $($USERNAME)" #(Example)
    $Password = Read-Host -AsSecureString
    New-LocalUser "infopro" -Password $Password -FullName "Infopro" -Description "Compte administrateur infopro"
}

#-------------------------------------------------------------------------------------------------------------------
# Install logiciel with chocolatey
#-------------------------------------------------------------------------------------------------------------------
#Check if chocolatey is installed
$ChocoPackages = 'googlechrome', 'firefoxesr', '7zip', 'adobereader', 'microsoft-edge', 'vlc'

#Fouction to install chocolatey
function InstallChoco() {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
 }

#Fouction to install chocolatey packages
function InstallChocoPackages ($ChocoPackages) {
    ForEach ($PackageName in $ChocoPackages)
    {
        $localprograms = choco list --localonly
        program1 = "googlechrome"

        If(Test-Path -Path "$env:ProgramData\Chocolatey") {
            if ($localprograms1 -like "*$PackageName*") {
                choco upgrade $program1
                }
            else {
                choco install $program1 -y
                }
        }
        choco install $PackageName -y
    }
}

#Check if chocolatey is installed and install packages
If(Test-Path -Path "$env:ProgramData\Chocolatey") {
    InstallChocoPackages $ChocoPackages
}
Else {
    InstallChoco
    InstallChocoPackages $ChocoPackages
}