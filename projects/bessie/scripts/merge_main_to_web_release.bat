@echo off
setlocal

REM --- Configuration ---
REM !!! IMPORTANT: Replace these paths with the actual paths to your repositories !!!
set REPO_PATHS[0]="C:\path\to\your\flutter_frontend_repo"
set REPO_PATHS[1]="C:\path\to\your\ember_core_repo"
set REPO_PATHS[2]="C:\path\to\your\ember_fire_repo"
REM --- End Configuration ---

REM Function-like structure using labels and goto
:PROCESS_REPOS
for /L %%i in (0,1,2) do (
    call :PROCESS_SINGLE_REPO %%i
    REM Optional: Check error level if you want script to stop on failure
    REM if errorlevel 1 (
    REM    echo ERROR: Script stopped due to failure in repository.
    REM    goto :EOF
    REM )
)
goto :END_PROCESSING

:PROCESS_SINGLE_REPO
set INDEX=%1
call set REPO_PATH=%%REPO_PATHS[%INDEX%]%%

echo -----------------------------------------------------
echo Processing repository: %REPO_PATH%
echo -----------------------------------------------------

pushd %REPO_PATH%
if errorlevel 1 (
    echo ERROR: Failed to change directory to %REPO_PATH%
    exit /b 1
)

echo 1. Checking out main and pulling latest changes...
git checkout main
if errorlevel 1 ( echo ERROR: Failed 'git checkout main'. & popd & exit /b 1 )
git pull origin main
if errorlevel 1 ( echo ERROR: Failed 'git pull origin main'. & popd & exit /b 1 )

echo 2. Checking out release/web and pulling latest changes...
git checkout release/web
if errorlevel 1 ( echo ERROR: Failed 'git checkout release/web'. & popd & exit /b 1 )
git pull origin release/web
if errorlevel 1 ( echo ERROR: Failed 'git pull origin release/web'. & popd & exit /b 1 )

echo 3. Merging main into release/web...
git merge main
REM Batch doesn't have an easy way to check merge conflict status like bash's git diff --check
REM We'll rely on the user seeing git's output if there are conflicts.
REM The script continues regardless of merge conflicts.

echo 4. Checking out main again...
git checkout main
if errorlevel 1 ( echo ERROR: Failed final 'git checkout main'. & popd & exit /b 1 )

popd
echo Finished processing %REPO_PATH%
echo.
exit /b 0


:END_PROCESSING
echo =====================================================
echo All repositories processed.
echo NOTE: If any merges had conflicts, you need to resolve them manually.
echo =====================================================

endlocal
exit /b 0