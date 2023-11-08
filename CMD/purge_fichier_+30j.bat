@echo off 
cls 
rem VARIABLES / CONSTANTES : 
rem ------------------------------------------------------------ 
rem Cette variable définie le dossier qu'il faut purger : 
set chemin="Y:\." 
rem Cette variable définie le nombre de jour que doivent être garder les fichiers: 
set jours=31
rem ------------------------------------------------------------

rem La commande si dessous va nettoyer les vieux fichiers du repertoire ciblé 
forfiles /p %chemin% /s /d -%jours% /m *.* /c "cmd /c del @FILE"

rem La commande suivante va supprimer les repertoires vides
for /R %chemin% /D %%x in ("*") do (rd "%%x") 