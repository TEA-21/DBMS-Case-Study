@echo off
REM ============================================================================
REM SmartFlow Grid: Master Evaluation Demonstration Launcher
REM Run this script or double-click it in Windows Explorer.
REM It pops up the evaluation window to showcase to the professor!
REM ============================================================================

title SmartFlow Grid - Evaluation Demonstration
color 0A

echo ================================================================================
echo   SMARTFLOW GRID: REVIEW 1 EVALUATION DEMONSTRATION LAUNCHER
echo ================================================================================
echo.
echo   Select how you would like to showcase the project to your professor:
echo.
echo   [1] GUI Showcase Window (Recommended - Visual Tables, SQL Explorer, ER Diagram)
echo   [2] Terminal Showcase Window (Command-line execution trace with live pause)
echo.
set /p choice="Enter choice [1 or 2, default is 1]: "

if "%choice%"=="2" goto RUN_TERMINAL

:RUN_GUI
echo.
echo Launching GUI Showcase Window...
start "" python "%~dp0scripts\review_1_showcase.py"
exit

:RUN_TERMINAL
echo.
echo Launching Terminal Demonstration Window...
start "SmartFlow Grid - Review 1 Terminal Demo" cmd /k "python "%~dp0scripts\run_review1_demo.py" && echo. && echo Press any key to close this window... && pause > nul"
exit
