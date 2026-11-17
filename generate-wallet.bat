@echo off
cd /d "%~dp0"
python generate-wallet.py %*
pause
