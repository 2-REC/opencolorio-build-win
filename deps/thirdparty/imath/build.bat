@echo off

set BUILD_TYPE=Release
set ARCH=x64

set IMATH_PATH=%USERPROFILE%\Documents\imath

set IMATH_SRC_PATH=%IMATH_PATH%\Imath-3.1.2
set BUILD_PATH=%IMATH_PATH%\build
set INSTALL_PATH=%IMATH_PATH%\install



echo Build path: %BUILD_PATH%
if not exist %BUILD_PATH% (
    mkdir %BUILD_PATH%
)
cd %BUILD_PATH%


:: Set default build configuration Release|64 (if not set)
if not "%ARCH%" == "Win32" (
    set ARCH=x64
)
if not "%BUILD_TYPE%" == "Debug" (
    set BUILD_TYPE=Release
)


REM - TODO: get path from input argument
if "%VCVARS_PATH%" == "" (
    set VCVARS_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build"
)
:: ~Hack to remove quotes (will be added later)
set VCVARS_PATH=%VCVARS_PATH:"=%

if "%ARCH%" == "x64" (
    set VCVARS=vcvars64.bat
) else (
    set VCVARS=vcvars32.bat
)


:: Initialise VC environment
call "%VCVARS_PATH%\%VCVARS%"


echo.
echo Configure
cmake -G "Visual Studio 16 2019" -A %ARCH% ^
 -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
 -DCMAKE_INSTALL_PREFIX="%INSTALL_PATH%" ^
 "%IMATH_SRC_PATH%"

REM - TODO: add check for error

echo.
echo Build
cmake --build . --target install --config %BUILD_TYPE%

pause
exit /b