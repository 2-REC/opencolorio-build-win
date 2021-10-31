# Find OpenImageIO

When using OpenImageIO version 2.3 or higher, the file "FindOpenImageIO.cmake" needs to be modified in order to use both "OpenImageIO" and "OpenImageIO_Util" libraries.
The file is located in:
```
OpenColorIO
+---share
    +---cmake
        +---modules
            +---FindOpenImageIO.cmake
```

Newer versions of the file (such as the file from the [master branch](https://github.com/AcademySoftwareFoundation/OpenColorIO/blob/master/share/cmake/modules/FindOpenImageIO.cmake)) contain the required changes, and could be used to replace the current file (beware however if changes have been made that could break the current version build).

The provided "OpenColorIO-2.0.2__OIIO-2.3-Fix.zip" file contains the modified files. It can be extracted to overwrite files in the OCIO source directory.


## Changes

### OpenImageIO_Util

1. After the line looking for the "OpenImageIO" library:
```
find_library ( OPENIMAGEIO_LIBRARY ...
```
Add the command to look for the "OpenImageIO_Util" library:
```
find_library ( OPENIMAGEIO_UTIL_LIBRARY
               NAMES OpenImageIO_Util${OIIO_LIBNAME_SUFFIX}
               HINTS ${OPENIMAGEIO_ROOT_DIR}
               PATH_SUFFIXES lib64 lib )
```


2. After the code block adding the "OpenImageIO" library:
```
if (NOT TARGET OpenImageIO::OpenImageIO)
    ...
endif()
```
Add the code block adding the "OpenImageIO_Util" library:
```
# Starting with OIIO v2.3, some utility classes are now only declared in OpenImageIO_Util
# (and not in both libraries like in older versions).
if (${OPENIMAGEIO_VERSION} VERSION_GREATER_EQUAL "2.3" AND NOT TARGET OpenImageIO::OpenImageIO_Util)
    add_library(OpenImageIO::OpenImageIO_Util UNKNOWN IMPORTED)
    set_target_properties(OpenImageIO::OpenImageIO_Util PROPERTIES
        IMPORTED_LOCATION "${OPENIMAGEIO_UTIL_LIBRARY}")
    target_link_libraries(OpenImageIO::OpenImageIO INTERFACE OpenImageIO::OpenImageIO_Util)
endif ()
```


### Oiiotool

It seems that "oiiotool" is not used anymore by the OCIO build process (?).

Remove the code block adding the "oiiotool" executable:
```
if (NOT TARGET OpenImageIO::oiiotool AND EXISTS "${OIIOTOOL_BIN}")
    add_executable(OpenImageIO::oiiotool IMPORTED)
    set_target_properties(OpenImageIO::oiiotool PROPERTIES
        IMPORTED_LOCATION "${OIIOTOOL_BIN}")
endif ()
```

### C++14

Starting with OIIO v2.3, OIIO needs to compile at least in C++14.

Add the code block checking that the C++ compiler will use at least C++14:
```
# Starting with OIIO v2.3, OIIO needs to compile at least in C++14.
if (${OPENIMAGEIO_VERSION} VERSION_GREATER_EQUAL "2.3" AND ${CMAKE_CXX_STANDARD} LESS_EQUAL 11)
    set(OpenImageIO_FOUND OFF)
    message(WARNING "Need C++14 or higher to compile with OpenImageIO ${OPENIMAGEIO_VERSION}.")
endif ()
```

