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
