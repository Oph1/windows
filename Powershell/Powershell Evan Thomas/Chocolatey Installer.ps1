Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install googlechrome -y
choco install vlc --version=3.0.12
choco install libreoffice-fresh
choco install firefox
choco install 7zip
choco install adobereader  