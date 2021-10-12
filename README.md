# OpenColorIO Windows Build

_"[OpenColorIO](https://opencolorio.org/) (OCIO) is a complete color management solution geared towards motion picture production with an emphasis on visual effects and computer animation. OCIO provides a straightforward and consistent user experience across all supporting applications while allowing for sophisticated back-end configuration options suitable for high-end production usage."_

This repositroy aims at helping build [OpenColorIO library](https://github.com/AcademySoftwareFoundation/OpenColorIO) from source in Windows.

Building OCIO can be confusing, as it has a few dependencies, one of them being OpenImageIO (OIIO), which itself depends on OpenColorIO.


The build process described here is based on the [OpenColorIO documentation](https://github.com/AcademySoftwareFoundation/OpenColorIO/blob/master/docs/quick_start/installation.rst#windows-build).

The versions of software and library used in the process try to follow the [VFX Reference Platform](https://vfxplatform.com/).
CY2021 will be used as the annual reference.

The process is thus aimed at version 2.0.x of the OpenColorIO library. Later versions might require changes, but the main process should remain the same.


----

# Build Environment

The software used for the build are the following:
* Windows 10 64bits
* Visual Studio 2019 (Community Edition) (MSVC142)
* Windows 10 SDK v10 (10.0.19041)
* Python 3.7.9

Third party libraries used by OCIO can be built during the build process, requiring the following:
* Git: ("Git for Windows")[https://git-scm.com/download/win] can be used
* Internet access: in order to allow Git to access the libraries source repositories

More information about third part libraries is provided in [THIRD PARTY LIBRARIES](TODO: link).


----

# Components

## OpenColorIO

OpenColorIO can be downloaded from its [Github repository](https://github.com/AcademySoftwareFoundation/OpenColorIO).

Version [2.0.2](https://github.com/AcademySoftwareFoundation/OpenColorIO/releases/tag/v2.0.2) is used here.

Once downloaded, extract the archive to the desired location, and rename the directory to 'OpenColorIO'.
From this point, the location of the extracted archive (the parent directory) will be referred to as 'OCIO_PATH'.

For example, the location can be:
```
%USERPROFILE%\Documents\OCIO
```
Which will contain the 'OpenColorIO' directory.


## Python

The build process will try to find an installed version of Python.
If more than 1 version is installed on the system, the version to be used by the build process should be specified to avoid any conflict.

The following configuration options can be used:
```batch
-DPython_LIBRARY="%PYTHON_PATH%\libs\python37.lib" ^
-DPython_INCLUDE_DIR="%PYTHON_PATH%\include" ^
-DPython_EXECUTABLE="%PYTHON_PATH%\python.exe" ^
```
Where 'PYTHON_PATH' is the Python install location (not to be confused with the 'PYTHONPATH' variable used by Python).

Additionally, the location of the executable should be added to the PATH environment variable to avoid any conflict:
```batch
set PATH=%PYTHON_PATH%;%PATH%
```

Version [3.7.9](https://www.python.org/downloads/release/python-379/) is used here.


### Python Debug Libraries

There seems to be an issue in debug mode if the Python debug libraries are installed.
Related [issue](https://github.com/AcademySoftwareFoundation/OpenColorIO/issues/592):
"When compiling in debug mode, python27_d.lib is expected but that's usually not installed by default, and there is no need to debug Python. The idea is to compile in debug mode but still using the release Python library."


If Python is installed with the debugging symbols and binaries, the OCIO build process will automatically try to use the debug libraries.
This can be seen in the link command of 'PyOpenColorIO', where one of the linked item is the Python debug library:
```
Link:
  ... "%PYTHON_PATH%\libs\python37_d.lib" ...
```
Even by specifying the use of the non debug library and executable, the process will still use the debug library:
```batch
-DPython_LIBRARY="%PYTHON_PATH%\libs\python37.lib"
-DPython_EXECUTABLE="%PYTHON_PATH%\python.exe"
```

This should not be an issue (it actually is the normal behaviour as the build is in debug mode), however the build process will fail with the following error:
```
LINK : fatal error LNK1104: cannot open file 'python37.lib' [...\OCIO\build\src\bindings\python\PyOpenColorIO.vcxproj]
```

Even by specifying the use of the Python debug libraries, the problem remains:
```batch
-DPython_LIBRARY="%PYTHON_PATH%\libs\python37_d.lib"
-DPython_EXECUTABLE="%PYTHON_PATH%\python_d.exe"
```
(TODO: Solve this issue, as currently don't know how to build in debug mode if the Python debug libraries are installed.
=> Could be related to missing
<UseDebugLibraries>true</UseDebugLibraries>
in the generated "build\pybind11_install.vcxproj" and "build\src\bindings\python\PyOpenColorIO.vcxproj"?
)
A temporary "fix" (hack) to make the build even if the Python debug libraries are installed (but will be ignored):
* Run "build.bat"
  => Configure + build until the error.
    (Initial fail build is required, if not doing it the VS build will fail)
* Edit "PyOpenColorIO" project properties in:
  ...\build\src\bindings\python\PyOpenColorIO.vcxproj
  In
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x64'">
    ...
    <Link>
      <AdditionalDependencies>C:\Users\2-REC\AppData\Local\Programs\Python\Python37\libs\python37_d.lib;..\..\OpenColorIO\Debug\OpenColorIO_2_0.lib;kernel32.lib;user32.lib;gdi32.lib;winspool.lib;shell32.lib;ole32.lib;oleaut32.lib;uuid.lib;comdlg32.lib;advapi32.lib</AdditionalDependencies>
  Replace "python37_d.lib" by "python37.lib".
* Open the solution "OpenColorIO.sln" in VS2019
  * Build the solution (ALL_BUILD)
    => Build should be OK (19 projects).
  * Build the install solution (INSTALL)
    => Binaries+libraries+includes will be copied to "install".
! - Third party libraries are built in "build/ext/dist". The directory should be copied/saved for later use.



OCIO can be built without Python by setting the configure option:
```batch
-DOCIO_BUILD_PYTHON=0
```
The Python bindings will not be built.


## GPU Rendering

OCIO can be compiled with or without GPU rendering options.

For GPU rendering support, GLEW and GLUT are required.

(TODO: find more info/details - impact on libraries?
No gl:
=> "GPU rendering disabled"
- ociochecklut.exe
  => different size...
- OpenColorIOoglapphelpers.lib
  => not compiled
)


### GLEW

_"The [OpenGL Extension Wrangler Library](http://glew.sourceforge.net/) is a cross-platform open-source C/C++ extension loading library (wrapper)."_

Version 2.1.0 is used here.
[Windows binaries](https://sourceforge.net/projects/glew/files/glew/2.1.0/glew-2.1.0-win32.zip/download) are available for the latest version, so the build process will be skipped here.
(TODO: should add the build process for other/later versions - as well as debug configurations)

Once downloaded, extract the archive to '%OCIO_PATH%/deps' and rename the directory to 'glew'.
The directory will now be referred to as 'GLEW_PATH':
```batch
set GLEW_PATH=%OCIO_PATH%\deps\glew
```

To simplify the configuration options, the files should be reorganised as follows:
* The 'include' directory kept as is
* The libraries from the desired configuration moved to the 'lib' directory (for example from the 'lib\Release\x64' directory)
* The other files can be deleted

The resulting file hierarchy should be:
```
glew
  include
    GL
      eglew.h
      glew.h
      glxew.h
      wglew.h
  lib
    glew32.lib
    glew32s.lib
```

The path to GLEW needs to be added to the configuration options:
```batch
-DGLEW_ROOT="%GLEW_PATH%"
```


### GLUT

_"[freeglut](http://freeglut.sourceforge.net/) is a free-software/open-source alternative to the OpenGL Utility Toolkit (GLUT) library.
[...] GLUT (and hence freeglut) takes care of all the system-specific chores required for creating windows, initializing OpenGL contexts, and handling input events, to allow for trully portable OpenGL programs."_

[Windows binaries](https://www.transmissionzero.co.uk/software/freeglut-devel/) are available, but not for the latest version.
It is thus preferable to build the libraries from the latest source.

The stable version [3.2.1](http://prdownloads.sourceforge.net/freeglut/freeglut-3.2.1.tar.gz?download) is used here.


A simple build script is provided in [deps/glut](TODO: link).
The script will build the library in an "install" directory.

The directory should have the following file organisation:
```
glut
  bin
    freeglut.dll
  include
    GL
      freeglut.h
      freeglut_ext.h
      freeglut_std.h
      freeglut_ucall.h
      glut.h
  lib
    freeglut.lib (or 'freeglutd.lib' for debug)
    (+other library related files)
```

Additionally, the (provided) file 'glut.h' needs to be added to the 'include' directory.
If the file is missing, the following error will occur when building 'oglapphelpers':
```
...\src\libutils\oglapphelpers\oglapp.cpp(17,10): fatal error C1083: Cannot open include file: 'GL/glut.h': No such file or directory
 [...\build\src\libutils\oglapphelpers\oglapphelpers.vcxproj]
```

The directory can be moved to a 'glut' directory in the dependencies location ('%OCIO_PATH%\deps').
The directory will be referred to as 'GLUT_PATH':
```batch
set GLUT_PATH=%OCIO_PATH%\deps\glut
```

The directory then needs to be referenced in the OCIO build process configuration.
The location of the include directory is also required here, else the process will not find GLUT (is this a bug?):
```batch
-DGLUT_ROOT="%GLUT_PATH%"
-DGLUT_INCLUDE_DIR="%GLUT_PATH%\include"
```
(TODO: determine how to build with static libraries.
=> If using the static library 'freeglut_static.lib', it needs to be renamed as 'freeglut.lib' else the configuration process will not find it.
! - Solve issue with 'freeglut_static.lib' not found, even if using 'GLUT_glut_LIBRARY')
=> seems like should use the shared library, as have unresolved externals when using the static (+if building OCIO shared libs, expects to have 'bin' directory as well)
????
)


## Third Party Libraries

Third party libraries are used by OpenColorIO.

For OpenColorIO 2.0.x, the minimum required versions of each library are:
* expat 2.2.8
* yaml-cpp 0.6.3
* Half (OpenEXR) 2.4.0
* pystring 1.1.3
* lcms2 2.2
* pybind11 2.6.1
* OpenImageIO 2.1.9
  => If missing, the process skips building 'ociolutimage', 'ocioconvert', 'ociodisplay' and 'ocioperf'.


### Automatic Build

Except for OpenImageIO, if the libraries are not provided, the process will download the required files and build each library.

! - Since OpenEXR 2.4, structural changes have been made regarding the "IlmBase" libraries, creating conflicts in OCIO when building with OpenImageIO.
=> To avoid conflicts, the "Half" library should not be handled automatically by the process. See "Half" (TODO: link) for details.

To reduce building time when building the OCIO library, the third party libraries can be provided, avoiding having to build them.

Ideally, these libraries should be built along OCIO during the first build, and can then be reused during the rebuild process (when adding OpenImageIO support - see below (TODO: add link to OpenImageIO section)).

The libraries will be generated in the '%BUILD_TYPE%\ext\dist' subdirectory of the build directory, where 'BUILD_TYPE' is the build configuration type (Release|Debug).
(TODO: in build script, copy built libraries to install directory)
(TODO: list generated flies (headers and libs))


### Built Libraries

(TODO: rephrase)
If keeping the same file hierarchy as the build from OCIO (a common directory containing all the thirs party libraries), the location of the libraries can be specified with the single variable 'THIRD_PARTY_PATH'.
For example:
```batch
set THIRD_PARTY_PATH=%OCIO_PATH%\deps\thirdparty
```
The include files and libraries of each third party library should be found automatically by the build process.


Alternatively, the location of include files and libraries can be specified independently using build variables in the form of:
```
XXX_INCLUDE_DIR
XXX_LIBRARY
```
where 'XXX' is the name of the library.

Example of each variable with hardcoded paths:
```batch
expat_LIBRARY=%THIRD_PARTY_PATH%\libexpat\lib\%BUILD_TYPE%\expatMD.lib
expat_INCLUDE_DIR=%THIRD_PARTY_PATH%\libexpat\include
expat_STATIC_LIBRARY=ON

yaml-cpp_LIBRARY=%THIRD_PARTY_PATH%\yaml-cpp\lib\%BUILD_TYPE%\libyaml-cppmd.lib
yaml-cpp_INCLUDE_DIR=%THIRD_PARTY_PATH%\yaml-cpp\include
yaml-cpp_STATIC_LIBRARY=ON

Half_LIBRARY=%THIRD_PARTY_PATH%\openexr\Half\lib\%BUILD_TYPE%\Half-2_4.lib
Half_INCLUDE_DIR=%THIRD_PARTY_PATH%\openexr\Half\include
Half_STATIC_LIBRARY=ON

pystring_LIBRARY=%THIRD_PARTY_PATH%\pystring\lib\%BUILD_TYPE%\pystring.lib
pystring_INCLUDE_DIR=%THIRD_PARTY_PATH%\pystring\include
pystring_STATIC_LIBRARY=ON

lcms2_LIBRARY=%THIRD_PARTY_PATH%\Little-CMS\lib\%BUILD_TYPE%\lcms2.lib
lcms2_INCLUDE_DIR=%THIRD_PARTY_PATH%\Little-CMS\include
lcms2_STATIC_LIBRARY=ON

pybind11_INCLUDE_DIR=%THIRD_PARTY_PATH%\pybind11\include
```
(The variables 'XXX_STATIC_LIBRARY' specify that the static version of the library should be used)


(TODO: 'error' in git doc?
=> Generally had to specify both LIBRARY and INCLUDE_DIR variables
(Instead of ROOT, as it requires a specific directory structure for each library - easier to specify each one separately)
)

(Third party libraries seem to be the same when built with or without Python)


## Half

When building OCIO with OpenImageIO, some errors will occur (for example when building "ocioconvert"), due to conflicts between versions of the "Half" library.
(TODO: detail more precisely the issue - what library/version causes the exact issue)

From the [OpenEXR/Imath 2.x to 3.x Porting Guide](https://github.com/AcademySoftwareFoundation/Imath/blob/master/docs/PortingGuide2-3.md):
_"... with the 2.4 release (of "OpenEXR"), the "IlmBase" libraries are no longer distributed in a form that is readily separable from the rest of OpenEXR."_

To fix the OpenColorIO build, the [Imath library}(https://github.com/AcademySoftwareFoundation/Imath) should be used, instead of relying on OpenEXR.
Version [3.1.2](https://github.com/AcademySoftwareFoundation/Imath/releases/tag/v3.1.2) is used here.
(TODO: update to 3.1.3)

Additionally, the following steps are required before doing the build:
* Modify files referring to Ilmbase module and OpenEXR headers (14 files to modify), as detailed in this [archlinux mingw patch](https://aur.archlinux.org/cgit/aur.git/tree/opencolorio-openexr3.patch?h=mingw-w64-opencolorio-git)
  => Or look at "half_fix" directory (TODO: link).
* If present (for example from a previous build), remove OpenEXR files from third party builds
  * OpenEXR include directory
  * Half library
* Build the Imath library* and move the files to the OCIO third party directory (if not using a common directory, the "Half" location needs to be specified to the OCIO build configuration).
  Both debug and release are built at the same time.
  ! - Both debug+release libraries must be present when building, regardless of the build type!
  The required files are in the following directories:
  * bin
  * include/Imath
  * lib
  * lib/cmake

By doing so, the library will not be built automatically and conflicts will be avoided when using OIIO.

* Building the Imath library is straightforward and doesn't require anything specific.
(TODO: could add link/info with build script - link to OIIO? or other?)


### Half Include Directory

Using the "Imath" library instead of the "Half" library causes an issue when building the "ociodisplay" and "ociolutimages" tools.
(TODO: other tools impacted?)

In order to fix this issue, the include directory should be added to the OCIO configuration option, using the "Half_INCLUDE_DIR" option:
```
-DHalf_INCLUDE_DIR="%THIRD_PARTY_PATH%/%ARCH%/%BUILD_TYPE%/include"
```


## OpenImageIO

[OpenImageIO](https://sites.google.com/site/openimageio/home) (OIIO) is used by OpenColorIO, but is not built during the process.
The reason being that OpenImageIO also depends on OpenColorIO.

The two projects have a circular dependency which can make the build process difficult and confusing.

OIIO isn't required in order to build OCIO, but omitting it will disable some of its features and tools: building of 'ociolutimage', 'ocioconvert', 'ociodisplay' and 'ocioperf' will be skipped.


A way to solve the interdependency between the 2 libraries is to:
1. Build OpenColorIO without OpenImageIO
2. Build OpenImageIO with the built OpenColorIO
3. Rebuild OpenColorIO with the built OpenImageIO
(4. Rebuild OpenImageIO with the rebuilt OpenColorIO)

This seems like unnecessary work, but it will ensure that both libraries are built with support for the other.

Information on how to build OpenImageIO can be found in [openimageio-build-win](TODO: link!).

Once the OIIO library has been built, the location of the include files and libraries need to be specified to the configuration process:
```
-DOpenImageIO_ROOT=%OIIO_PATH%
```
where "OIIO_PATH" is the location of the OIIO library and includes.
(TODO: rephrase)


The debug variants of the OIIO libraries by default have a "_d" suffix.
When building OCIO in debug mode, this suffix should be specified in order for the build process to find the libraries (unless the libraries are renamed and the suffix removed).
A configuration option is available to specify this suffix:
```
-DOIIO_LIBNAME_SUFFIX=_d
```


If using OIIO version 2.3 or higher, linking errors will occur.
An example of such error is:
```
main.obj : error LNK2019: unresolved external symbol "__declspec(dllimport) public: __cdecl OpenImageIO_v2_3::TypeDesc::TypeDesc(enum OpenImageIO_v2_3::TypeDesc::BASETYPE,enum OpenImageIO_v2_3::TypeDesc::AGGREGATE,enum OpenImageIO_v2_3::TypeDesc::VECSEMANTICS,int)"
 (__imp_??0TypeDesc@OpenImageIO_v2_3@@QEAA@W4BASETYPE@01@W4AGGREGATE@01@W4VECSEMANTICS@01@H@Z)
 referenced in function main [OCIO\build\src\apps\ocioconvert\ocioconvert.vcxproj]
```
Changes have been done in OIIO, where some functions are now in an additional library "OpenImageIO_Util", which also needs to be linked.

To fix this, changes are required in the way OCIO finds OIIO in "FindOpenImageIO.cmake".
The changes have been done in more recent of OCIO, so the file can be obtained from a [newer version](https://github.com/AcademySoftwareFoundation/OpenColorIO/blob/master/share/cmake/modules/FindOpenImageIO.cmake) and replace the older one.
=> Or look at "oiio-2.3_find_fix" directory (TODO: link).


----

# Build

(TODO: rewrite)
Some variables need to be set, as well as locations of inputs/outputs:
* Build type ("Release"|"Debug") and architecture (32|64 bits) should be specified (by default release build in 64 bits).
* source path
* python
* deps
...
(TODO: explain expected paths, etc.)

A build script is provided, but the following can be used as reference or base.

For example, a build script could be:
TODO: 
- adapt to lates changes in "build.bat"
- convert code to terminal code (not for .bat)
    (to allow to copy paste directly in CMD instead of using .bat file)
    => remove all "useless" steps (like default values and tests), to make script as short as possible
+ make 2 parts
  1. without third party libs (full build)
  2. with third party libs (+add option to look for OpenImageIO or not)
```batch
(TODO: add script - "pure" command line, not .BAT)
```



Alternatively, the provided 'build.bat' file can be used.
Make sure to previously define the variables if not using default values.
TODO: show how to use .bat
=> set env vars before and call it in same cmd.
