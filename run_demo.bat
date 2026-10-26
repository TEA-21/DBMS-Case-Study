@echo off
REM ============================================================================
REM SmartFlow Grid: Enterprise Municipal Traffic Operations Console Launcher
REM Launches the live web-based Smart City traffic management center for professor demo!
REM ============================================================================

title SmartFlow Grid - Municipal Operations Console
color 0B

echo ================================================================================
echo   SMARTFLOW GRID: ENTERPRISE MUNICIPAL TRAFFIC OPERATIONS CENTER
echo ================================================================================
echo.
echo   Starting Node.js / Vite Municipal Server on http://localhost:3000 ...
echo   Browser will launch automatically once server is active.
echo.

cd /d "%~dp0web"
if not exist "node_modules\" (
    echo Installing dependencies...
    call npm install
)

npm run dev
