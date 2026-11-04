@echo off
title Auto Start Node 2 & Node 3 di VirtualBox VM
powershell -ExecutionPolicy Bypass -File "%~dp0start_vms_automatically.ps1"
pause
