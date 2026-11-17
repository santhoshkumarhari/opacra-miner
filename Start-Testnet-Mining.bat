@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title Opacra Miner - Testnet

rem Check if testnet address is saved
if exist testnet-address.txt goto check

:ask
set "ADDR="
set /p "ADDR=Paste your Opacra testnet wallet address (starts with Te) and press Enter: "
> testnet-address.txt echo(!ADDR!

:check
findstr /r /x "T[0-9A-Za-z]*" testnet-address.txt >nul
if errorlevel 1 (
    del testnet-address.txt 2>nul
    echo Invalid Opacra testnet address. Addresses start with Te.
    goto ask
)
set "ADDR="
set /p "ADDR=" < testnet-address.txt

echo =======================================================
echo Opacra CPU Miner (RandomOPCA / rx/opca) - Testnet
echo Mining to: !ADDR!
echo Node daemon: 127.0.0.1:29971
echo Note: Ensure your Opacra testnet node daemon is running!
echo =======================================================

if exist "%~dp0bin\xmrig.exe" goto run_win_bin
if exist "%~dp0xmrig.exe" goto run_win_root
if exist "%~dp0bin\xmrig" goto run_wsl
goto no_binary

:run_win_bin
"%~dp0bin\xmrig.exe" -o 127.0.0.1:29971 --daemon -a rx/opca --coin opacra -u "!ADDR!"
goto done

:run_win_root
"%~dp0xmrig.exe" -o 127.0.0.1:29971 --daemon -a rx/opca --coin opacra -u "!ADDR!"
goto done

:run_wsl
for /f "delims=" %%i in ('wsl wslpath -u "%~dp0bin\xmrig"') do (
    wsl %%i -o 127.0.0.1:29971 --daemon -a rx/opca --coin opacra -u "!ADDR!"
)
goto done

:no_binary
echo Error: No miner binary found.
echo Please run build.sh through WSL or build xmrig.exe for Windows.
goto done

:done
pause
