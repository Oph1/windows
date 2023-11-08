# =======================================================
# NAME: ImportConfigToFilezilla.ps1
# AUTHOR: Boissier Damien, Infopro45
# DATE: 25/10/2023
#
# KEYWORDS: FileZilla, paramètre
# VERSION 1.0
# /MM/YYYY added help to the functions
# COMMENTS: Desription des traitements
#
#Requires -Version 4.0
# =======================================================

Clear
# Initialisation varibles
$UserFzConfigPath = "\AppData\Roaming\FileZilla\"
$UserFzConfigFile = "sitemanager.xml"


# Récupération du dernier utilisateur connecté
$LastLogUser = WmiObject -Class win32_computersystem | % Username
$LastLogUserAlone = $LastLogUser.Substring($LastLogUser.IndexOf("\")+1)
$UserFzConfigFilePath = "C:\Users\"+$LastLogUserAlone+$UserFzConfigPath+$UserFzConfigFile

# Test si fichier est present
if (Test-Path -Path $UserFzConfigFilePath -PathType Leaf) {
    # Backup du fichier de conf
    $Date=Get-Date -Format "yyyyMMdd"
    $UserFzConfigFilePathBkp = $UserFzConfigFilePath+"_"+$Date+".bkp"
    Copy-Item -Path $UserFzConfigFilePath -Destination $UserFzConfigFilePathBkp
}
else {
    if (Test-Path -Path ("C:\Users\"+$LastLogUserAlone+$UserFzConfigPath) -PathType Leaf) {}
    else {New-Item -Path ("C:\Users\"+$LastLogUserAlone+$UserFzConfigPath) -ItemType Directory}

    # Sauvegarde directe du fichier a importer et fin du script
    $File2 = [xml](Get-Content .\sitemanager.xml)
    $File2.Save($UserFzConfigFilePath)
    Exit
}

# Déclaration des fichiers a fusionner
$File1 = [xml](Get-Content $UserFzConfigFilePath)
$File2 = [xml](Get-Content .\sitemanager.xml)

# Fusion des fichiers
Foreach ($Node in $File2.DocumentElement.ChildNodes.ChildNodes) {
    $File1.FileZilla3.Servers.AppendChild($File1.ImportNode($Node, $true))
}

# Sauvegarde des donnes fusionne dans le fichier
$File1.Save($UserFzConfigFilePath)