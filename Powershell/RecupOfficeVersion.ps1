# Editeur : Damien Boissier
Param(
[string]$customfield="Custom1"
)

$x32 = ${env:ProgramFiles(x86)} + "\Microsoft Office"
$x64 = $env:ProgramFiles + "\Microsoft Office"
$OK = $true

#Test presence office
if (Test-Path -Path $x32) {$Excel32 = Get-ChildItem -Recurse -Path $x32 -Filter "EXCEL.EXE"}
if (Test-Path -Path $x64) {$Excel64 = Get-ChildItem -Recurse -Path $x64 -Filter "EXCEL.EXE"}
if ($Excel32) {$Excel = $Excel32}
if ($Excel64) {$Excel = $Excel64}
if ($Excel32 -and $Excel64) {"Error: x32 and x64 installation found." ; $Excel32.Fullname ; $Excel64.Fullname ; $OK = $false}
if ($Excel.Count -gt 1) {"Error: More than one Excel.exe found." ; $Excel.Fullname ; $OK = $false}
if ($Excel.Count -eq 0) {"Error: Excel.exe not found." ; $OK = $false}

if ($OK) {
   $DisplayVersion = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -Name "DisplayVersion" -ErrorAction SilentlyContinue | Where-Object {$_.DisplayVersion -eq $Excel.VersionInfo.ProductVersion -and $_.PSChildName -notlike "{*}"}
   $Office = Get-ItemProperty -Path $DisplayVersion.PSPath
   #$Office | ForEach-Object {"Product: " + $_.DisplayName + $(if ($_.InstallLocation -eq $x32) {", 32 Bit"} else {", 64 Bit"})  + ", Productversion: " + $_.PSChildName + ", Build: " + $_.DisplayVersion}
   $Test = $Office | ForEach-Object {$_.DisplayName}
   $xXX = $Office | ForEach-Object {$(if ($_.InstallLocation -eq $x32) {"32 Bit"} else {"64 Bit"})}
}

if ($OK -and -not ($Test -like "*2019*")) {
#Recuperation version office <= 2016
$version = Get-WmiObject win32_product -ComputerName $env:computername | where{$_.Name -like "*Office*"} | select Version
$version = ($version[0]).version
$versionSub = $version.Substring(0,2)
switch ($versionSub)
{
    16 {$ver = "Office 2016"}
    #exemple avec build : 16 {$ver = "Office 2016 - Build $version"}
    15 {$ver = "Office 2013"}
    14 {$ver = "Office 2010"}
    12 {$ver = "Office 2007"}
    11 {$ver = "Office 2003"}
    Default {$ver = "Non Connu"}
}
$VerOffice = $ver
}
else {$VerOffice = "Office 2019"}

"$env:computername has version $VerOffice, $xXX"
Set-ItemProperty -Path HKLM:\SOFTWARE\CentraStage\ -Name $customfield -Value "$VerOffice, $xXX" | Out-Null