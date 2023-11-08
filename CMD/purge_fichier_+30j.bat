@echo off 
cls 
rem VARIABLES / CONSTANTES : 
rem ------------------------------------------------------------ 
rem Cette variable d�finie le dossier qu'il faut purger : 
set chemin="Y:\." 
rem Cette variable d�finie le nombre de jour que doivent �tre garder les fichiers: 
set jours=31
rem ------------------------------------------------------------

rem La commande si dessous va nettoyer les vieux fichiers du repertoire cibl� 
forfiles /p %chemin% /s /d -%jours% /m *.* /c "cmd /c del @FILE"

rem La commande suivante va supprimer les repertoires vides
for /R %chemin% /D %%x in ("*") do (rd "%%x") 