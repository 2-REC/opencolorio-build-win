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
