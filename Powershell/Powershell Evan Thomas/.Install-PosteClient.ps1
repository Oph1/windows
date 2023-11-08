#Requires -RunAsAdministrator
Clear-Host
Set-PSDebug -Strict
#Supression des variables "fantomes" (en particulie variable contenant les checkbox) en cas de multiple execution du script.
Remove-Variable * -ErrorAction SilentlyContinue

#Ajout des class utiles
Add-Type -AssemblyName System.Windows.Forms

###########################
#Déclaration des clients/application
###########################
$listClient = new-object 'System.Collections.Generic.List[string]'
$listAppliClient = new-object 'System.Collections.Generic.List[string]'
#Liste des applis dispo

$listClient.Add('Agriservice')                      ; $listAppliClient.Add('agent,7zip,acrobatreader,googlechrome,libreoffice,vlc,java,firefoxesr') ; $listTokenAgentClient.Add('2f46c9da-753a-4698-b33e-7bb682c63161')
$listClient.Add('Association Espace')               ; $listAppliClient.Add('agent,7zip,acrobatreader') ; $listTokenAgentClient.Add('e66f6db8-006c-4cfd-96e3-b388b192e597')
$listClient.Add('Bonneau')                          ; $listAppliClient.Add('agent,7zip,acrobatreader') ; $listTokenAgentClient.Add('6316b87a-4894-4f12-881b-c0552f04fa6d')
$listClient.Add('C2E')                              ; $listAppliClient.Add('agent,7zip') ; $listTokenAgentClient.Add('6968cd11-5f6d-4b86-a603-9860423f95ea')
$listClient.Add('CCPG')                             ; $listAppliClient.Add()
$listClient.Add('CCPG Sortie Inventaire')           ; $listAppliClient.Add()
$listClient.Add('CCPNL')                            ; $listAppliClient.Add()
$listClient.Add('CCPNL - Maison France Service')    ; $listAppliClient.Add()
$listClient.Add('CPSD')                             ; $listAppliClient.Add()
$listClient.Add('Dauvilliers')                      ; $listAppliClient.Add() 
$listClient.Add('Dupré/Prévautat')                  ; $listAppliClient.Add() 
$listClient.Add('ECBG')                             ; $listAppliClient.Add() 
$listClient.Add('ECJA')                             ; $listAppliClient.Add() 
$listClient.Add('Espace Conduite')                  ; $listAppliClient.Add() 
$listClient.Add('Eurobougie')                       ; $listAppliClient.Add() 
$listClient.Add('Fortier')                          ; $listAppliClient.Add() 
$listClient.Add('GDS')                              ; $listAppliClient.Add() 
$listClient.Add('Gobois')                           ; $listAppliClient.Add() 
$listClient.Add('Golf Augerville')                  ; $listAppliClient.Add() 
$listClient.Add('ImmoA2')                           ; $listAppliClient.Add()
$listClient.Add('Inkern')                           ; $listAppliClient.Add() 
$listClient.Add('JPB Emballage')                    ; $listAppliClient.Add() 
$listClient.Add('Kansa')                            ; $listAppliClient.Add()
$listClient.Add('Lavindus 45')                      ; $listAppliClient.Add() 
$listClient.Add('LC2S')                             ; $listAppliClient.Add() 
$listClient.Add('Le Diamant Bleu')                  ; $listAppliClient.Add() 
$listClient.Add('Le Malesherbois')                  ; $listAppliClient.Add()
$listClient.Add('Maire de Bromeilles')              ; $listAppliClient.Add() 
$listClient.Add('Mairie de Dadonville')             ; $listAppliClient.Add() 
$listClient.Add('Mairie de Ladon')                  ; $listAppliClient.Add() 
$listClient.Add('Mairie de Pithiviers')             ; $listAppliClient.Add() 
$listClient.Add('Mairie de Sermaise')               ; $listAppliClient.Add()       
$listClient.Add('Matignon')                         ; $listAppliClient.Add() 
$listClient.Add('MSPL')                             ; $listAppliClient.Add() 
$listClient.Add('MVBatiment')                       ; $listAppliClient.Add() 
$listClient.Add('Panirecord')                       ; $listAppliClient.Add() 
$listClient.Add('Penicaud')                         ; $listAppliClient.Add() 
$listClient.Add('PlanetePaye')                      ; $listAppliClient.Add() 
$listClient.Add('PoletPeinture')                    ; $listAppliClient.Add() 
$listClient.Add('Pougat')                           ; $listAppliClient.Add() 
$listClient.Add('PPE')                              ; $listAppliClient.Add() 
$listClient.Add('Roullet')                          ; $listAppliClient.Add() 
$listClient.Add('Sabatte')                          ; $listAppliClient.Add() 
$listClient.Add('SICTOM-Chateauneuf')               ; $listAppliClient.Add() 
$listClient.Add('Sodispra')                         ; $listAppliClient.Add() 
$listClient.Add('Somater Andeville')                ; $listAppliClient.Add() 
$listClient.Add('Somater Belgique')                 ; $listAppliClient.Add() 
$listClient.Add('Somater Boulogne')                 ; $listAppliClient.Add() 
$listClient.Add('Somater Coutras')                  ; $listAppliClient.Add() 
$listClient.Add('Somater en atelier')               ; $listAppliClient.Add() 
$listClient.Add('Somater Frévent')                  ; $listAppliClient.Add() 
$listClient.Add('Somater Hautot')                   ; $listAppliClient.Add() 
$listClient.Add('Somater Lisses')                   ; $listAppliClient.Add()
$listClient.Add('Somater Marolles')                 ; $listAppliClient.Add() 
$listClient.Add('Somater Mortagnes')                ; $listAppliClient.Add() 
$listClient.Add('Somater PC Machine')               ; $listAppliClient.Add() 
$listClient.Add('Somater Savigny')                  ; $listAppliClient.Add()
$listClient.Add('Somater Theix')                    ; $listAppliClient.Add() 
$listClient.Add('StyleBois')                        ; $listAppliClient.Add()
$listClient.Add('Tetraaudit')                       ; $listAppliClient.Add()

############################
#Fin déclaration
############################

###########################
#Script install Appli
###########################

function Install-Appli ([string]$appli) {
    switch ($appli, $client) {
        "Chocolatey" {
            Write-host "Installation Chocolatey : " -NoNewline
            if (-not(powershell choco -v)) {
                $result = Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) #*> $null 
            }
            else {$result = "installed"}
            if ($result = "installed") {Write-host "already installed" -ForegroundColor Green}
            elseif ($result = "installed") {Write-host "ok" -ForegroundColor Green}
            else {Write-host "failed" -ForegroundColor Red}
        }
        "agent" {
            Write-host "Installation agent : " -NoNewline
            $Platform="merlot"
            $SiteID=$client
            <# 
            Datto RMM Agent deploy by MS Azure Intune 
            Designed and written by Jon North, Datto, March 2020 
            Download the Agent installer, run it, wait for it to finish, delete it 
            #> 
            # First check if Agent is installed and instantly exit if so
            <#If (Get-Service CagService -ErrorAction SilentlyContinue) {Write-Output "Datto RMM Agent already installed on this device" ; exit} 
            # Download the Agent
            $AgentURL="https://$Platform.centrastage.net/csm/profile/downloadAgent/$SiteID" 
            $DownloadStart=Get-Date 
            Write-Output "Starting Agent download at $(Get-Date -Format HH:mm) from $AgentURL"
            try {[Net.ServicePointManager]::SecurityProtocol=[Enum]::ToObject([Net.SecurityProtocolType],3072)}
            catch {Write-Output "Cannot download Agent due to invalid security protocol. The`r`nfollowing security protocols are installed and available:`r`n$([enum]::GetNames([Net.SecurityProtocolType]))`r`nAgent download requires at least TLS 1.2 to succeed.`r`nPlease install TLS 1.2 and rerun the script." ; exit 1}
            try {(New-Object System.Net.WebClient).DownloadFile($AgentURL, "$env:TEMP\DRMMSetup.exe")} 
            catch {$host.ui.WriteErrorLine("Agent installer download failed. Exit message:`r`n$_") ; exit 1} 
            Write-Output "Agent download completed in $((Get-Date).Subtract($DownloadStart).Seconds) seconds`r`n`r`n" 
            # Install the Agent
            $InstallStart=Get-Date 
            Write-Output "Starting Agent install to target site at $(Get-Date -Format HH:mm)..." 
            & "$env:TEMP\DRMMSetup.exe" | Out-Null 
            Write-Output "Agent install completed at $(Get-Date -Format HH:mm) in $((Get-Date).Subtract($InstallStart).Seconds) seconds."
            Remove-Item "$env:TEMP\DRMMSetup.exe" -Force
            Exit
            if ($result) {Write-host "ok" -ForegroundColor Green} else {Write-host "failed" -ForegroundColor Red}#>
            Write-Host "Intall agent""merlot" $client
        }
        "7zip" {
            Write-host "Installation 7zip : " -NoNewline
            powershell choco install 7zip --upgrade --force -y
            if ($result) {Write-host "ok" -ForegroundColor Green} else {Write-host "failed" -ForegroundColor Red}
        }
        "acrobatreader" {
            Write-host "Installation AcrobatReader : " -NoNewline
            powershell choco install adobereader --upgrade --force -y
            if ($result) {Write-host "ok" -ForegroundColor Green} else {Write-host "failed" -ForegroundColor Red}
        }
        "libreoffice" {
            Write-host "Installation LibreOffice : " -NoNewline
            powershell choco install libreoffice-still --upgrade --force -y
            if ($result) {Write-host "ok" -ForegroundColor Green} else {Write-host "failed" -ForegroundColor Red}
        }
        "googlechrome" {
            Write-host "Installation GoogleChrome : " -NoNewline
            powershell choco install choco install googlechrome --upgrade --force -y
            if ($result) {Write-host "ok" -ForegroundColor Green} else {Write-host "failed" -ForegroundColor Red}
        }
        "vlc" {
            Write-host "Installation VLC : " -NoNewline
            powershell choco install choco install vlc --upgrade --force -y
            if ($result) {Write-host "ok" -ForegroundColor Green} else {Write-host "failed" -ForegroundColor Red}
        }
        "java" {
            Write-host "Installation VLC : " -NoNewline
            powershell choco install choco install javaruntime --upgrade --force -y
            if ($result) {Write-host "ok" -ForegroundColor Green} else {Write-host "failed" -ForegroundColor Red}
        }
        "firefoxesr" {
            Write-host "Installation VLC : " -NoNewline
            powershell choco install choco install firefoxesr --upgrade --force -y
            if ($result) {Write-host "ok" -ForegroundColor Green} else {Write-host "failed" -ForegroundColor Red}
        }
    }
} 

###########################
#Fin Script install Appli
###########################

###########################
#Déclaration du formulaire1
###########################
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(300,400)
$form.StartPosition = 'CenterScreen'
$form.Topmost = $true

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(74,300)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'Selectionner'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(148,300)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Annuler'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Sélectionner une entreprise :'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.Height = 250
$form.Controls.Add($listBox)

#Generation de la liste des clients pour la listbox avec un trie alphabetic
$listClient | Sort-Object | % {
    [void] $listBox.Items.Add($_)
}

############################
#Fin déclaration formulaire1
############################

###########################
#Déclaration du formulaire2
###########################
$form2 = New-Object System.Windows.Forms.Form
$form2.Size = New-Object System.Drawing.Size(300,400)
$form2.StartPosition = 'CenterScreen'
$form2.Topmost = $true

$okButton2 = New-Object System.Windows.Forms.Button
$okButton2.Location = New-Object System.Drawing.Point(20,300)
$okButton2.Size = New-Object System.Drawing.Size(75,23)
$okButton2.Text = 'Selectionner'
$okButton2.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form2.AcceptButton = $okButton2
$form2.Controls.Add($okButton2)

$retourButton2 = New-Object System.Windows.Forms.Button
$retourButton2.Location = New-Object System.Drawing.Point(100,300)
$retourButton2.Size = New-Object System.Drawing.Size(75,23)
$retourButton2.Text = 'Retour'
$retourButton2.DialogResult = [System.Windows.Forms.DialogResult]::Retry
$form2.AcceptButton = $retourButton2
$form2.Controls.Add($retourButton2)

$cancelButton2 = New-Object System.Windows.Forms.Button
$cancelButton2.Location = New-Object System.Drawing.Point(180,300)
$cancelButton2.Size = New-Object System.Drawing.Size(75,23)
$cancelButton2.Text = 'Annuler'
$cancelButton2.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form2.CancelButton = $cancelButton2
$form2.Controls.Add($cancelButton2)

$label21 = New-Object System.Windows.Forms.Label
$label21.Location = New-Object System.Drawing.Point(10,20)
$label21.Size = New-Object System.Drawing.Size(280,15)
$label21.Text = "null"
$form2.Controls.Add($label21)

$label22 = New-Object System.Windows.Forms.Label
$label22.Location = New-Object System.Drawing.Point(10,40)
$label22.Size = New-Object System.Drawing.Size(280,15)
$label22.Text = "Sélection des logiciels a installer :"
$form2.Controls.Add($label22)

#Récupération de la liste complète des applications sans faire de doublon.
$listAppli = new-object 'System.Collections.Generic.List[string]'
for ($MonCompteur = 0; $MonCompteur -le $listAppliClient.Count-1; $MonCompteur++){
    $temp = $listAppliClient[$MonCompteur].Split(",")
    for ($MonCompteur2 = 0; $MonCompteur2 -le $temp.Count-1; $MonCompteur2++){
        if ([array]$listAppli -notcontains $temp[$MonCompteur2]) {
        $listAppli.Add($temp[$MonCompteur2])
        }
    }
}
$listAppli = $listAppli | Sort-Object
[array]$listAppli
#Tableau colonne pour mise en page des checkbox
$tabLayout = New-Object System.Windows.Forms.TableLayoutPanel
$tabLayout.AutoSize = $true
$tabLayout.Location = New-Object System.Drawing.Size(10,60)
$tabLayout.ColumnCount = 3
$tabLayout.RowCount = 1
$form2.Controls.Add($tabLayout)

#Création des checkbox pour chaque application
$listAppli | % {

    $checkBox = New-Object System.Windows.Forms.CheckBox
    $checkBox.Text = $_
    $checkBox.Name = "checkBox$_"
    $tabLayout.Controls.Add($checkBox)
    New-Variable -name checkBox$_ -Value $checkBox
}
############################
#Fin déclaration formulaire2
############################

###########################
#Appel des formulaires
###########################
#Demande Confirmation et bouclage si réponse est non
$result="Retry"
while ($result -ne "OK") {
    switch ($result) {
        "Retry" {
            #Appelle le formulaire et execution commande en fonction du retour bouton.
            switch ($form.ShowDialog()) {
                "OK" {$label21.Text = "Le client " + $listBox.SelectedItem + " a été choisi !"}
                "CANCEL" {Exit 10}
            }
            if ($listBox.SelectedItem -ne $null) 
                {
                Remove-Variable temp -ErrorAction SilentlyContinue
                $temp = $listAppliClient[[array]::IndexOf($listClient, $listBox.SelectedItem)].Split(",")

                #Rénitialisation de la valeur Checked des checkbox
                $listAppli | % {$((Get-Variable -name checkBox$_).Value).Checked = $false}

                #Activation des checkbox pour toutes les applications du client selectionne
                $temp | % {$((Get-Variable -name checkBox$_).Value).Checked = $true}
                $result=$form2.ShowDialog()
                }
        }
        "Cancel" {Exit 10}
    }
}
###########################
#Fin appel des formulaires
###########################

#$test = [array]::IndexOf($listClient, $listBox.SelectedItem)
#$test
#$listAppliClient[[array]::IndexOf($listClient, $listBox.SelectedItem)]

Install-Appli "Chocolatey"

$listAppli | % {
    if ($((Get-Variable -name checkBox$_).Value).Checked -eq $true) {
        Install-Appli $_ $listBox.SelectedItem
    }
}

