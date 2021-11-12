@ECHO OFF
powershell.exe -Command "Set-Executionpolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
powershell.exe -Command "& '%~dpn0.ps1'”
