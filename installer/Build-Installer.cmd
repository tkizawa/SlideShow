@echo off
pushd "%~dp0"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0Build-Installer.ps1"
if errorlevel 1 pause
popd
