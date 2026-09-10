@echo off
setlocal

set SOURCE_DIR=%~dp0src
set DEST_DIR=%USERPROFILE%\AutoHotkey

if not exist "%DEST_DIR%" (
    mkdir "%DEST_DIR%"
)

echo Copying *.ahk files to %DEST_DIR%
for %%F in ("%SOURCE_DIR%\*.ahk") do (
    echo   Copying %%~nxF
    copy /Y "%%~fF" "%DEST_DIR%\" >nul
)
echo.

echo Copying *.toml files to %DEST_DIR% (skip if already exists)
for %%F in ("%SOURCE_DIR%\*.toml") do (
    if not exist "%DEST_DIR%\%%~nxF" (
        echo   Copying %%~nxF
        copy /Y "%%~fF" "%DEST_DIR%\" >nul
    ) else (
        echo   Skipping %%~nxF ^(already exists^)
    )
)
echo.

echo Removing *.ahk files that do not exist in source
pushd "%DEST_DIR%"
for %%G in (*.ahk) do (
    if not exist "%SOURCE_DIR%\%%~nxG" (
        echo   Removing "%%~nxG"
        del /Q "%%~nxG"
    )
)
popd
echo.

endlocal
echo Done
pause
