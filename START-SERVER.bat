@echo off
REM Double-click this. First run installs everything; later runs just start the server.
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
pause
