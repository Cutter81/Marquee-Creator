@echo off
setlocal EnableExtensions
 title Build Marquee Creator v1.3
cd /d "%~dp0"

set "SOURCE=%~dp0MarqueeCreatorLauncher-v1.3.cs"
set "ICON=%~dp0MarqueeCreator-RazorBlade.ico"
set "OUTPUT=%~dp0MarqueeCreator-v1.3.exe"
set "LOG=%~dp0Build-MarqueeCreator-v1.3.log"
set "CSC=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC%" set "CSC=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe"

 echo.
echo ============================================
echo   Marquee Creator v1.3 - EXE Builder
echo ============================================
echo.

if not exist "%SOURCE%" (
  echo ERROR: Source file not found:
  echo   "%SOURCE%"
  goto :fail
)
if not exist "%ICON%" (
  echo ERROR: Razor-blade icon not found:
  echo   "%ICON%"
  echo.
  echo Put MarqueeCreator-RazorBlade.ico beside this batch file.
  goto :fail
)
if not exist "%CSC%" (
  echo ERROR: The .NET Framework C# compiler could not be found.
  echo Checked Framework64 and Framework v4.0.30319.
  goto :fail
)

rem Check ImageMagick. If absent, attempt an automatic install through winget.
echo Checking for ImageMagick (magick.exe)...
where magick.exe >nul 2>&1
if not errorlevel 1 goto :imagemagick_ok

where winget.exe >nul 2>&1
if errorlevel 1 (
  echo ERROR: ImageMagick is not on PATH and winget is unavailable.
  echo Install ImageMagick from https://imagemagick.org/ and reopen this tool.
  goto :fail
)

echo ImageMagick was not found. Attempting installation with winget...
winget install --id ImageMagick.ImageMagick --exact --accept-package-agreements --accept-source-agreements
if errorlevel 1 (
  echo.
  echo ERROR: winget could not install ImageMagick automatically.
  echo Try this command in Terminal:
  echo   winget install --id ImageMagick.ImageMagick --exact
  goto :fail
)

rem Refresh PATH for this build process in case winget updated the environment.
where magick.exe >nul 2>&1
if errorlevel 1 (
  echo.
  echo WARNING: ImageMagick installed, but magick.exe is not visible on this PATH yet.
  echo The EXE can still be built; if the app cannot find ImageMagick later, sign out/in
  echo or add the ImageMagick installation folder to PATH.
) else (
  echo ImageMagick detected successfully.
)
goto :imagemagick_done

:imagemagick_ok
echo ImageMagick is already installed and available on PATH.
:imagemagick_done

rem Validate that the icon file is non-empty before invoking the compiler.
for %%F in ("%ICON%") do if %%~zF LEQ 0 (
  echo ERROR: The icon file is empty.
  goto :fail
)

 echo Source: "%SOURCE%"
echo Icon:   "%ICON%"
echo Output: "%OUTPUT%"
echo.
echo Compiling and embedding the icon automatically...

rem Remove a stale output first so an old EXE cannot be mistaken for a new build.
if exist "%OUTPUT%" del /q "%OUTPUT%"
if exist "%OUTPUT%" (
  echo ERROR: Could not remove the previous EXE. Close it if it is running and try again.
  goto :fail
)

"%CSC%" /nologo /target:winexe /platform:anycpu /optimize+ /reference:System.Windows.Forms.dll "/win32icon:%ICON%" "/out:%OUTPUT%" "%SOURCE%" > "%LOG%" 2>&1
set "BUILD_EXIT=%ERRORLEVEL%"
if not "%BUILD_EXIT%"=="0" (
  echo.
  echo BUILD FAILED. Compiler output:
  echo --------------------------------------------
  type "%LOG%"
  echo --------------------------------------------
  goto :fail
)
if not exist "%OUTPUT%" (
  echo ERROR: Compiler reported success but the EXE was not created.
  if exist "%LOG%" type "%LOG%"
  goto :fail
)
for %%F in ("%OUTPUT%") do if %%~zF LEQ 0 (
  echo ERROR: The generated EXE is empty.
  goto :fail
)

echo.
echo BUILD SUCCEEDED.
echo EXE: "%OUTPUT%"
echo Razor-blade icon embedded by the compiler.
echo Build log: "%LOG%"
echo.
echo Note: This confirms compilation completed; test the EXE on Windows.
pause
exit /b 0

:fail
echo.
echo Build did not complete successfully. No Windows security settings were changed.
echo If a compiler error is shown above, copy it back for diagnosis.
pause
exit /b 1
