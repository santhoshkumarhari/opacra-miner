@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title Opacra Miner - Mainnet

rem Check if mainnet address is saved
if exist mainnet-address.txt goto check

:ask
set "ADDR="
set /p "ADDR=Paste your Opacra wallet address (starts with Pa) and press Enter: "
> mainnet-address.txt echo(!ADDR!

:check
findstr /r /x "P[0-9A-Za-z]*" mainnet-address.txt >nul
if errorlevel 1 (
    del mainnet-address.txt 2>nul
    echo Invalid Opacra mainnet address. Addresses start with Pa.
    goto ask
)
set "ADDR="
set /p "ADDR=" < mainnet-address.txt

echo =======================================================
echo Opacra CPU Miner (RandomOPCA / rx/opca) - Mainnet
echo Mining to: !ADDR!
echo Node daemon: 127.0.0.1:29961
echo Note: Ensure your Opacra node daemon (opacrad) is running!
echo =======================================================

if exist "%~dp0bin\xmrig.exe" goto run_win_bin
if exist "%~dp0xmrig.exe" goto run_win_root
if exist "%~dp0bin\xmrig" goto run_wsl
goto no_binary

:run_win_bin
"%~dp0bin\xmrig.exe" -o 127.0.0.1:29961 --daemon -a rx/opca --coin opacra -u "!ADDR!"
goto done

:run_win_root
"%~dp0xmrig.exe" -o 127.0.0.1:29961 --daemon -a rx/opca --coin opacra -u "!ADDR!"
goto done

:run_wsl
for /f "delims=" %%i in ('wsl wslpath -u "%~dp0bin\xmrig"') do (
    wsl %%i -o 127.0.0.1:29961 --daemon -a rx/opca --coin opacra -u "!ADDR!"
)
goto done

:no_binary
echo Error: No miner binary found.
echo Please run build.sh through WSL or build xmrig.exe for Windows.
goto done

:done
pause
