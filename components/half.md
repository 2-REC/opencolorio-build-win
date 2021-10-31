# Half

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
* Build the "Imath" library(*) and move the files to the OCIO third party directory (if not using a common directory, the "Half" location needs to be specified to the OCIO build configuration).
  Both debug and release are built at the same time.
  ! - Both debug+release libraries must be present when building, regardless of the build type!
  The required files are in the following directories:
  * bin
  * include/Imath
  * lib
  * lib/cmake

By doing so, the library will not be built automatically and conflicts will be avoided when using OIIO.

These changes can e found in ["Half Fix"](fixes/half_fix).

(*) Building the Imath library is straightforward and doesn't require anything specific.
A build script and the source for "Imath" version 3.1.2 can be found in [deps/thirdparty/imath](TODO: add link).


### Half Include Directory

Using the "Imath" library instead of the "Half" library causes an issue when building the "ociodisplay" and "ociolutimages" tools.
(TODO: other tools impacted?)

In order to fix this issue, the include directory should be added to the OCIO configuration option, using the "Half_INCLUDE_DIR" option:
```
-DHalf_INCLUDE_DIR="%THIRD_PARTY_PATH%/%ARCH%/%BUILD_TYPE%/include"
```
