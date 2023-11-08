@echo off
color 1E
cls

:MENU
echo.
echo ******************************
echo *** Robocopy Backup Script ***
echo ******************************
echo.
echo 1 - Run ROBO copie entre 20h00 et 06h00 #1
echo 2 - Run ROBO #2
echo 3 - Exit
echo.
echo ******************************
echo.
SET /P M=Type 1, 2 or 3 then press ENTER:
if not '%M%'=='' set M=%M:~0,1%
IF '%M%'=='1' GOTO 1
IF '%M%'=='2' GOTO 2
IF '%M%'=='3' GOTO 3
ECHO "%M%" is not valid, try again
ECHO.

goto MENU

:1
REM robocopy "\\172.17.99.2\Partage atelier" "E:\Documents\Partage atelier" /MIR /SEC /ETA /TEE /R:5 /LOG+:c:\journal.log
REM robocopy "\\172.17.99.2\Partage" "E:\Documents\Partage" /MIR /SEC /ETA /RH:2000-0700 /TEE /LOG+:c:\journal.log
goto MENU

:2
REM robocopy "\\172.17.99.2\Partage atelier" "E:\Documents\Partage atelier" /MIR /SEC /ETA /TEE /LOG+:c:\journal.log
REM robocopy "\\172.17.99.2\Partage" "E:\Documents\Partage" /MIR /SEC /ETA /TEE /LOG+:c:\journal.log
goto MENU

:3

pause
exit