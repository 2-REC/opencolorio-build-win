@echo off

set MAIN_PATH=%USERPROFILE%\Documents\glut

set ARCH=x64
set BUILD_TYPE=Release

set SRC_PATH=%MAIN_PATH%\freeglut-3.2.1
set BUILD_PATH=%MAIN_PATH%\build
set INSTALL_PATH=%MAIN_PATH%\install


echo Build path: %BUILD_PATH%
if not exist %BUILD_PATH% (
    mkdir %BUILD_PATH%
)
cd %BUILD_PATH%

if "%ARCH%" == "x64" (
    set VCVARS=vcvars64.bat
) else (
    set ARCH=Win32
    set VCVARS=vcvars32.bat
)
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\%VCVARS%"


echo.
echo Configure
cmake -G "Visual Studio 16 2019" -A %ARCH% ^
 -DCMAKE_INSTALL_PREFIX="%INSTALL_PATH%/%ARCH%/%BUILD_TYPE%" ^
 "%SRC_PATH%"

REM - TODO: add check for error

echo.
echo Build
cmake --build . --target install --config %BUILD_TYPE%

pause
exit /b