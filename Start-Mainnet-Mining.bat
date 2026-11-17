@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title Opacra Miner (Mainnet)

rem Check if mainnet address is saved
if exist mainnet-address.txt goto check

:ask
set "ADDR="
set /p "ADDR=Paste your Opacra wallet address (starts with Pa) and press Enter: "
> mainnet-address.txt echo(!ADDR!

:check
findstr /r /x "P[0-9A-Za-z]*" mainnet-address.txt >nul || (del mainnet-address.txt & echo Invalid Opacra mainnet address. Addresses start with Pa. & goto ask)
set "ADDR="
set /p "ADDR=" < mainnet-address.txt

echo =======================================================
echo Opacra CPU Miner (RandomOPCA / rx/opca) - Mainnet
echo Mining to: !ADDR!
echo Node daemon: 127.0.0.1:29961
echo Note: Ensure your Opacra node daemon (opacrad) is running!
echo =======================================================

if exist "%~dp0bin\xmrig.exe" (
    "%~dp0bin\xmrig.exe" -o 127.0.0.1:29961 --daemon -a rx/opca --coin opacra -u "!ADDR!"
) else if exist "%~dp0xmrig.exe" (
    "%~dp0xmrig.exe" -o 127.0.0.1:29961 --daemon -a rx/opca --coin opacra -u "!ADDR!"
) else if exist "%~dp0bin\xmrig" (
    echo Native xmrig.exe not found; executing compiled miner via WSL...
    wsl bash -c "'%~dp0bin/xmrig' -o 127.0.0.1:29961 --daemon -a rx/opca --coin opacra -u '!ADDR!'"
) else (
    echo Error: No miner binary found. Please run build.sh (via WSL) or build.bat first.
)

pause
