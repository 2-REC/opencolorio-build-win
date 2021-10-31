# Python Debug Libraries

When building OpenColorIO debug libraries, there is an issue if the Python debug libraries are installed.

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


## Fix

(TODO: Solve this issue, as currently don't know how to build in debug mode if the Python debug libraries are installed.
=> Could be related to missing
<UseDebugLibraries>true</UseDebugLibraries>
in the generated "build\pybind11_install.vcxproj" and "build\src\bindings\python\PyOpenColorIO.vcxproj"?
! - See if "undef _DEBUG" trick can be applied here
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


