@echo off
title ASA Localhost :8080
echo ============================================================
echo  Adventure Safari Africa - local server
echo  KEEP THIS WINDOW OPEN while you browse the site.
echo  Closing this window stops the server.
echo ============================================================
echo.
echo Giving the server 8 seconds to warm up, then opening your browser...
timeout /t 8 /nobreak >nul
start http://localhost:8080/
echo.
echo If the browser says "refused to connect", wait 10 seconds and refresh once.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve.ps1"
echo.
echo Server stopped. Press any key to close this window.
pause >nul
