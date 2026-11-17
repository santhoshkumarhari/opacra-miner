@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title Opacra Miner (Testnet)

rem Check if testnet address is saved
if exist testnet-address.txt goto check

:ask
set "ADDR="
set /p "ADDR=Paste your Opacra testnet wallet address (starts with Te) and press Enter: "
> testnet-address.txt echo(!ADDR!

:check
findstr /r /x "T[0-9A-Za-z]*" testnet-address.txt >nul || (del testnet-address.txt & echo Invalid Opacra testnet address. Addresses start with Te. & goto ask)
set "ADDR="
set /p "ADDR=" < testnet-address.txt

echo =======================================================
echo Opacra CPU Miner (RandomOPCA / rx/opca) - Testnet
echo Mining to: !ADDR!
echo Node daemon: 127.0.0.1:29971
echo Note: Ensure your Opacra testnet node daemon is running!
echo =======================================================

if exist "%~dp0bin\xmrig.exe" (
    "%~dp0bin\xmrig.exe" -o 127.0.0.1:29971 --daemon -a rx/opca --coin opacra -u "!ADDR!"
) else if exist "%~dp0xmrig.exe" (
    "%~dp0xmrig.exe" -o 127.0.0.1:29971 --daemon -a rx/opca --coin opacra -u "!ADDR!"
) else if exist "%~dp0bin\xmrig" (
    echo Native xmrig.exe not found; executing compiled miner via WSL...
    wsl bash -c "'%~dp0bin/xmrig' -o 127.0.0.1:29971 --daemon -a rx/opca --coin opacra -u '!ADDR!'"
) else (
    echo Error: No miner binary found. Please run build.sh (via WSL) or build.bat first.
)

pause
