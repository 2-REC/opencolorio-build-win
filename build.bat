@echo off
setlocal enabledelayedexpansion

REM - TODO: find way to automate (dir with lib name (parent dir) in it?
set LIB_DIR=OpenColorIO-2.0.2

set BUILD_TYPE=Release
set ARCH=x64

REM set OIIO_PATH=%USERPROFILE%/Documents/OCIO/deps/oiio

set BUILD_APPS=ON
REM set BUILD_APPS=OFF

REM set WARNING_AS_ERROR=ON
set WARNING_AS_ERROR=OFF


set OCIO_BUILD_PYTHON=1


set LIB_PATH=%cd%
set LIB_SRC_PATH=%LIB_PATH%/%LIB_DIR%
set BUILD_PATH=%LIB_PATH%\build
set INSTALL_PATH=%LIB_PATH%/install


REM - TODO: problem using same path for Python 32|64 bits!
if "%PYTHON_PATH%" == "" (
    set PYTHON_PATH=%USERPROFILE%\AppData\Local\Programs\Python\Python37
)
REM - TODO: check that Python is installed... (should detect install location)


:: Set default dependencies paths if not set
if "%DEPS_PATH%" == "" (
    set DEPS_PATH=%LIB_PATH%/deps
)
if "%GLUT_PATH%" == "" (
    set GLUT_PATH=%DEPS_PATH%/glut
)
if "%GLEW_PATH%" == "" (
    set GLEW_PATH=%DEPS_PATH%/glew
)
if "%THIRD_PARTY_PATH%" == "" (
    set THIRD_PARTY_PATH=%DEPS_PATH%/thirdparty
)


:: Set default build configuration Release|64 (if not set)
if not "%ARCH%" == "Win32" (
    set ARCH=x64
)
if not "%BUILD_TYPE%" == "Debug" (
    set BUILD_TYPE=Release
)


:: Check input paths
if "%LIB_DIR%" == "" (
    echo 'LIB_DIR' is not set!
    pause
    exit /b
)
if not exist "%LIB_SRC_PATH%" (
    echo ERROR: %LIB_SRC_PATH% does not exist!
    echo Make sure 'LIB_SRC_PATH' is set correctly to OpenColorIO source directory.
    exit /b
)
if not exist "%GLUT_PATH%" (
    echo ERROR: %GLUT_PATH% does not exist
    echo Make sure 'GLUT_PATH' is set correctly to FreeGLUT library path.
    exit /b
)
if not exist "%GLEW_PATH%" (
    echo ERROR: %GLEW_PATH% does not exist
    echo Make sure 'GLEW_PATH' is set correctly to GLEW library path.
    exit /b
)

if not exist "%THIRD_PARTY_PATH%" (
    echo Third party directory '%THIRD_PARTY_PATH%' not found, building external libraries.
    set "THIRD_PARTY_PATH="
)



REM - TODO: If exists, should delete it
if not exist %BUILD_PATH% (
    mkdir %BUILD_PATH%
)
cd %BUILD_PATH%


:: Safety to make sure another version of Python is not detected/used
set PATH=%PYTHON_PATH%;%PATH%


:: Initialise Windows build environment
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
call "%VCVARS_PATH%\%VCVARS%"



set "BUILD_OPTIONS="

set BUILD_OPTIONS=%BUILD_OPTIONS% -DOCIO_INSTALL_EXT_PACKAGES=MISSING
set BUILD_OPTIONS=%BUILD_OPTIONS% -DBUILD_SHARED_LIBS=ON
set BUILD_OPTIONS=%BUILD_OPTIONS% -DOCIO_BUILD_APPS=%BUILD_APPS% -DOCIO_BUILD_DOCS=OFF
set BUILD_OPTIONS=%BUILD_OPTIONS% -DOCIO_BUILD_TESTS=ON -DOCIO_BUILD_GPU_TESTS=OFF
set BUILD_OPTIONS=%BUILD_OPTIONS% -DOCIO_USE_SSE=ON
set BUILD_OPTIONS=%BUILD_OPTIONS% -DOCIO_WARNING_AS_ERROR=%WARNING_AS_ERROR%

set BUILD_OPTIONS=%BUILD_OPTIONS% -DOCIO_BUILD_PYTHON=%OCIO_BUILD_PYTHON%
if "%OCIO_BUILD_PYTHON%" == "1" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DPython_INCLUDE_DIR="%PYTHON_PATH%/include"
    REM - TODO: problem when using Python debug symbols+binaries
    REM if "%BUILD_TYPE%" == "Debug" (
        REM set BUILD_OPTIONS=!BUILD_OPTIONS! -DPython_LIBRARY="%PYTHON_PATH%/libs/python37_d.lib" -DPython_EXECUTABLE="%PYTHON_PATH%/python_d.exe"
    REM ) else (
        REM set BUILD_OPTIONS=!BUILD_OPTIONS! -DPython_LIBRARY="%PYTHON_PATH%/libs/python37.lib" -DPython_EXECUTABLE="%PYTHON_PATH%/python.exe"
    REM )
    set BUILD_OPTIONS=!BUILD_OPTIONS! -DPython_LIBRARY="%PYTHON_PATH%/libs/python37.lib" -DPython_EXECUTABLE="%PYTHON_PATH%/python.exe"
)

set BUILD_OPTIONS=%BUILD_OPTIONS% -DOCIO_BUILD_JAVA=OFF

set BUILD_OPTIONS=%BUILD_OPTIONS% -DGLEW_ROOT="%GLEW_PATH%/%ARCH%/Release"
set BUILD_OPTIONS=%BUILD_OPTIONS% -DGLUT_ROOT="%GLUT_PATH%/%ARCH%/%BUILD_TYPE%" -DGLUT_INCLUDE_DIR="%GLUT_PATH%/%ARCH%/%BUILD_TYPE%/include"

if not "%THIRD_PARTY_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DCMAKE_PREFIX_PATH="%THIRD_PARTY_PATH%/%ARCH%/%BUILD_TYPE%"
)

if not "%OIIO_PATH%" == "" (
    set BUILD_OPTIONS=%BUILD_OPTIONS% -DOpenImageIO_ROOT="%OIIO_PATH%/%ARCH%/%BUILD_TYPE%"
)

echo Build options: %BUILD_OPTIONS:\=/%


:: Configure the build
echo.
echo Configure
cmake -G "Visual Studio 16 2019" -A %ARCH% ^
  -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_PATH%/%ARCH%/%BUILD_TYPE%" ^
  %BUILD_OPTIONS:\=/% ^
  "%LIB_SRC_PATH%"


:: Build the libraries
echo.
echo Build
cmake --build . --target install --config %BUILD_TYPE% --verbose


pause
exit /b
