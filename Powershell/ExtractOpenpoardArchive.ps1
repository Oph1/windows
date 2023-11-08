if(Test-Path "C:\Program Files\OpenBoard\library") {
    Expand-Archive -LiteralPath .\Openboard.zip -DestinationPath "C:\Program Files\OpenBoard\library" -Force
    }
elseif (Test-Path "C:\Program Files (x86)\OpenBoard\library") {
    Expand-Archive -LiteralPath .\Openboard.zip -DestinationPath "C:\Program Files (x86)\OpenBoard\library" -Force
    }
else {exit 20;Write-Host "Erreur : Le repertoire du programme OpenBoard n'existe pas !"}