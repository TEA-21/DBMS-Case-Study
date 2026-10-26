@echo off
REM Directly launches the Web-based Municipal Operations Console
cd /d "%~dp0web"
npm run dev
