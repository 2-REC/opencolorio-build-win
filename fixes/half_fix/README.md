# Imath/Half

The following files need to be modified in order to use the 'Imath' library instead of 'OpenEXR'.
```
OpenColorIO
+---share
|   +---cmake
|       +---modules
|           +---FindExtPackages.cmake
+---src
|   +---OpenColorIO
|   |   +---ops
|   |   |   +---range
|   |   |       +---RangeOp.cpp
|   |   +---transforms
|   |   |   +---builtins
|   |   |       +---ACES.cpp
|   |   |       +---OpHelpers.cpp
|   |   +---BitDepthUtils.h
|   |   +---CMakeLists.txt
|   |   +---MathUtils.h
|   +---apps
|   |   +---ocioconvert
|   |   |   +---CMakeLists.txt
|   |   |   +---main.cpp
|   |   +---ocioperf
|   |       +---CMakeLists.txt
|   |       +---main.cpp
|   +---libutils
|       +---oiiohelpers
|           +---CMakeLists.txt
|           +---oiiohelpers.cpp
+---tests
    +---cpu
        +---CMakeLists.txt
```

These changes come from a [Git patch](https://aur.archlinux.org/cgit/aur.git/tree/opencolorio-openexr3.patch?h=mingw-w64-opencolorio-git).

The provided "OpenColorIO-2.0.2__HalfFix.zip" file contains the modified files. It can be extracted to overwrite files in the OCIO source directory.


## share/cmake/modules/FindExtPackages.cmake

Replace:
```
find_package(Half 2.4.0 REQUIRED)
```
with:
```
find_package(Imath 3.0 REQUIRED)
```


## src/OpenColorIO/BitDepthUtils.h

Replace:
```
#include "OpenEXR/half.h"
```
with:
```
#include "Imath/half.h"
```


## src/OpenColorIO/CMakeLists.txt

Replace:
```
		IlmBase::Half
```
with:
```
		Imath::Imath
```


## src/OpenColorIO/MathUtils.h

Replace:
```
#include "OpenEXR/half.h"
```
with:
```
#include "Imath/half.h"
```


## src/OpenColorIO/ops/range/RangeOp.cpp

Replace:
```
#include "OpenEXR/half.h"
```
with:
```
#include "Imath/half.h"
```

## src/OpenColorIO/transforms/builtins/ACES.cpp

Replace:
```
#include "OpenEXR/half.h"
```
with:
```
#include "Imath/half.h"
```


## src/OpenColorIO/transforms/builtins/OpHelpers.cpp

Replace:
```
#include "OpenEXR/half.h"
```
with:
```
#include "Imath/half.h"
```


## src/apps/ocioconvert/CMakeLists.txt

Replace:
```
        IlmBase::Half
```
with:
```
        Imath::Imath
```


## src/apps/ocioconvert/main.cpp

Replace:
```
#include "OpenEXR/half.h"
```
with:
```
#include "Imath/half.h"
```


## src/apps/ocioperf/CMakeLists.txt

Replace:
```
        IlmBase::Half
```
with:
```
        Imath::Imath
```


## src/apps/ocioperf/main.cpp

Replace:
```
#include "OpenEXR/half.h"
```
with:
```
#include "Imath/half.h"
```


## src/libutils/oiiohelpers/CMakeLists.txt

Replace:
```
        IlmBase::Half
```
with:
```
        Imath::Imath
```


## src/libutils/oiiohelpers/oiiohelpers.cpp

Replace:
```
#include "OpenEXR/half.h"
```
with:
```
#include "Imath/half.h"
```


## tests/cpu/CMakeLists.txt

Replace:
```
            IlmBase::Half
```
with:
```
            Imath::Imath
```
