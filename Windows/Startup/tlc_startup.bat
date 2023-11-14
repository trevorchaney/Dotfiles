@echo off
REM Trevor's startup batch file

if not exist %userprofile%\pars mkdir %userprofile%\pars
subst w: %userprofile%\pars
