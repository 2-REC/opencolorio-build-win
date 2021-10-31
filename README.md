# OpenColorIO Windows Build

_"[OpenColorIO](https://opencolorio.org/) (OCIO) is a complete color management solution geared towards motion picture production with an emphasis on visual effects and computer animation. OCIO provides a straightforward and consistent user experience across all supporting applications while allowing for sophisticated back-end configuration options suitable for high-end production usage."_

This repositroy aims at helping build [OpenColorIO library](https://github.com/AcademySoftwareFoundation/OpenColorIO) from source in Windows.

Building OCIO can be confusing, as it has a few dependencies, one of them being OpenImageIO (OIIO), which itself depends on OpenColorIO.


The build process described here is based on the [OpenColorIO documentation](https://github.com/AcademySoftwareFoundation/OpenColorIO/blob/master/docs/quick_start/installation.rst#windows-build).

The software and library versions used in the process try to follow the [VFX Reference Platform](https://vfxplatform.com/).
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


Aternatively, OCIO can be built without Python by setting the configure option:
```batch
-DOCIO_BUILD_PYTHON=0
```
The Python bindings will not be built.


### Python Debug Libraries

(TODO: CHECK IF CORRECT)
There is an issue in debug mode if the Python debug libraries are installed.

More information can be found in ["Python Debug"](components/python_debug.md).


## GPU Rendering

OCIO can be compiled with or without GPU rendering options.

For GPU rendering support, GLEW and GLUT are required.

(TODO: Add more info/details - impact on libraries?
No gl:
=> "GPU rendering disabled"
- ociochecklut.exe
  => different size...
- oglapphelpers.lib
  => not compiled
)

Information on the 2 libraries can be found in ["GLEW"](components/glew.md) and ["GLUT"](components/glut.md) respectively.


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

! - The "Half" library should not be built automatically by the process. See ["Half"](#half).

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

Since OpenEXR 2.4, structural changes have been made regarding the "IlmBase" libraries, creating conflicts in OpenColorIO when building with OpenImageIO.

To avoid conflicts, the "Half" library should be buit separately instead of automatically by the OCIO build process.
See ["Half"](components/half.md) for details.


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

Information on how to build OpenImageIO can be found in the ["openimageio-build-win"](https://github.com/2-REC-inwork/windows-build-openimageio) repository.
(TODO: CHANGE LINK WHEN NOT IN "IN-WORK" ANYMORE)

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


If using OIIO version 2.3 or higher with OCIO version 2.0.x, linking errors will occur.
An example of such error is:
```
main.obj : error LNK2019: unresolved external symbol "__declspec(dllimport) public: __cdecl OpenImageIO_v2_3::TypeDesc::TypeDesc(enum OpenImageIO_v2_3::TypeDesc::BASETYPE,enum OpenImageIO_v2_3::TypeDesc::AGGREGATE,enum OpenImageIO_v2_3::TypeDesc::VECSEMANTICS,int)"
 (__imp_??0TypeDesc@OpenImageIO_v2_3@@QEAA@W4BASETYPE@01@W4AGGREGATE@01@W4VECSEMANTICS@01@H@Z)
 referenced in function main [OCIO\build\src\apps\ocioconvert\ocioconvert.vcxproj]
```
Changes have been done in OIIO, where some functions are now in an additional library "OpenImageIO_Util", which also needs to be linked.

To fix this, changes are required in the way OCIO finds OIIO in "FindOpenImageIO.cmake".
The changes have been done in more recent of OCIO, the file can be obtained from a [newer version](https://github.com/AcademySoftwareFoundation/OpenColorIO/blob/master/share/cmake/modules/FindOpenImageIO.cmake) and replace the older one.

The changes can also be found in ["OIIO 2.3 Find Fix"](fixes/oiio-2.3_find_fix).


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
