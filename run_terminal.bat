@echo off
REM Directly launches the Terminal evaluation window with pause
start "SmartFlow Grid - Review 1 Terminal Demo" cmd /k "python "%~dp0scripts\run_review1_demo.py" && echo. && echo Demonstration Finished. Press any key to close window... && pause > nul"
