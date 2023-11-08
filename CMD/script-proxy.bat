REM Enable-Disable System Proxy in one file
@echo off
SET home_key="HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
FOR /F "tokens=3" %%L IN ('reg query %home_key% /v ProxyEnable' ) DO SET currentProxy=%%L
IF %currentProxy% == 0x1 goto turnoff
IF %currentProxy% == 0x0 goto turnon

:turnoff
reg add %home_key% /v ProxyEnable /t REG_DWORD /d 0 /f
SET proxy="Proxy disabled"
goto EOF

:turnon
reg add %home_key% /v ProxyEnable /t REG_DWORD /d 1 /f
SET proxy="Proxy enabled"
goto EOF

:EOF
REM Restart Internet Explorer to changes take efect
start /w /b iexplore.exe
timeout 2 /nobreak
taskkill /f /im iexplore.exe
echo %proxy%