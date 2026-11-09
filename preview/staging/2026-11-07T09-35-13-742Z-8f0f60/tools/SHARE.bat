@echo off
title ASA Share Link
echo ============================================================
echo  Adventure Safari Africa - public share link
echo  KEEP THIS WINDOW OPEN while people visit your link.
echo  Closing this window takes the link offline.
echo ============================================================
echo.
echo [1/2] Starting local server...
start "ASA Localhost :8080" powershell -NoProfile -NoExit -ExecutionPolicy Bypass -File "%~dp0serve.ps1"
echo [2/2] Opening public tunnel (takes ~15 seconds)...
"%~dp0cloudflared.exe" tunnel --url http://localhost:8080
pause
