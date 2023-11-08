REM <start>
 @echo off
 if not exist c:\temp\. mkdir c:\temp
 REM Export the Uninstall registry keys
 start /wait "" REGEDIT /E c:\temp\registry.tmp HKEY_LOCAL_MACHINE\SOFTWARE\microsoft\windows\currentversion\uninstall
 REM Filter only the {} keys that Java might be in
 type c:\temp\registry.tmp | find /i "{" | find /i "}]" > c:\temp\uninstall.tmp
 type c:\temp\registry.tmp | find /i "JRE 1" >> c:\temp\uninstall.tmp
 
 REM Run the Vbscript that uses this file to find Java Sun entries to uninstall
 cscript "java-uninstaller.vbs"
 REM <end>