@ECHO off
CLS
ECHO Date format = %date%

REM Breaking down the format 
FOR /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set datetime=%%G
ECHO dd = %datetime:~6,2%
ECHO mth = %datetime:~4,2% 
ECHO yyyy = %datetime:~0,4%
ECHO/
ECHO Time format = %time%
ECHO hh = %time:~0,2%
ECHO mm = %time:~3,2%
ECHO ss = %time:~6,2%
ECHO/

REM Format date/time
SET Timestamp=%date:~6,8%%date:~3,2%%date:~0,2%%time:~0,2%%time:~3,2%%time:~6,2%
ECHO New Format 2: %Timestamp%
ECHO/
REM Building a timestamp from variables
SET "dd=%datetime:~6,2%"
SET "mth=%datetime:~4,2%"
SET "yyyy=%datetime:~0,4%"
SET "Date=%yyyy%%mth%%dd%"
ECHO Built Date from variables: %Date%

SET "Date=%yyyy%%mth%%dd%"
SET "DateTime=%Date%-%time:~0,2%%time:~3,2%%time:~6,2%"
echo "Heure lancement : %DateTime%

ECHO/

robocopy "\\Nassodispra\commun" "D:\Shares\Commun" /TBD /FFT /DCOPY:DAT /COPY:DAT /PURGE /ZB /NP /S /R:12 /W:5 /LOG:log\robocopy_mir_commun_%DateTime%.log /XD "\\Nassodispra\commun\#recycle\"

PAUSE