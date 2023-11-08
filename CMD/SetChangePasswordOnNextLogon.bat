@echo off & setlocal
rem ################################################################################################################
rem Script: Users Must Change Password On Next Logon
rem Auteur: Damien Boissier
rem Versie: batsh
rem ################################################################################################################
set "IgnoredUsers=dbois administrateur infopro DefaultAccount Invité WDAGUtilityAccount

for /f "tokens=* skip=1" %%a in ('wmic UserAccount get Name') do (
	set "b=%%a"
	echo 
    if not "%%a"=="" (
		if not "%%a"==dbois (
		echo. %%a
        )
		)
		rem net user "test" /logonpasswordchg:yes
	)
)


