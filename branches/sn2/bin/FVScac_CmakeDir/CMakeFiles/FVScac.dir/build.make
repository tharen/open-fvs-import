# CMAKE generated file: DO NOT EDIT!
# Generated by "MinGW Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Produce verbose output by default.
VERBOSE = 1

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

SHELL = cmd.exe

# The CMake executable.
CMAKE_COMMAND = "C:\Program Files (x86)\CMake 2.8\bin\cmake.exe"

# The command to remove a file.
RM = "C:\Program Files (x86)\CMake 2.8\bin\cmake.exe" -E remove -f

# Escaping for special characters.
EQUALS = =

# The program to use to edit the cache.
CMAKE_EDIT_COMMAND = "C:\Program Files (x86)\CMake 2.8\bin\cmake-gui.exe"

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVScac_CmakeDir

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVScac_CmakeDir

# Include any dependencies generated for this target.
include CMakeFiles/FVScac.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/FVScac.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/FVScac.dir/flags.make

CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj: CMakeFiles/FVScac.dir/flags.make
CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj: CMakeFiles/FVScac.dir/includes_Fortran.rsp
CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj: C:/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f
	$(CMAKE_COMMAND) -E cmake_progress_report C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVScac_CmakeDir\CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building Fortran object CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj"
	C:\strawberry\c\bin\gfortran.exe  $(Fortran_DEFINES) $(Fortran_FLAGS) -c C:\MinGW\msys\1.0\home\pradtke\Source\trunk\base\src\main.f -o CMakeFiles\FVScac.dir\C_\MinGW\msys\1.0\home\pradtke\Source\trunk\base\src\main.f.obj

CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj.requires:
.PHONY : CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj.requires

CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj.provides: CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj.requires
	$(MAKE) -f CMakeFiles\FVScac.dir\build.make CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj.provides.build
.PHONY : CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj.provides

CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj.provides.build: CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj

# Object files for target FVScac
FVScac_OBJECTS = \
"CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj"

# External object files for target FVScac
FVScac_EXTERNAL_OBJECTS =

FVScac.exe: CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj
FVScac.exe: CMakeFiles/FVScac.dir/build.make
FVScac.exe: libFVS_cac.dll.a
FVScac.exe: libFVSsql.dll.a
FVScac.exe: libFVSfofem.dll.a
FVScac.exe: CMakeFiles/FVScac.dir/objects1.rsp
FVScac.exe: CMakeFiles/FVScac.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking Fortran executable FVScac.exe"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles\FVScac.dir\link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/FVScac.dir/build: FVScac.exe
.PHONY : CMakeFiles/FVScac.dir/build

CMakeFiles/FVScac.dir/requires: CMakeFiles/FVScac.dir/C_/MinGW/msys/1.0/home/pradtke/Source/trunk/base/src/main.f.obj.requires
.PHONY : CMakeFiles/FVScac.dir/requires

CMakeFiles/FVScac.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles\FVScac.dir\cmake_clean.cmake
.PHONY : CMakeFiles/FVScac.dir/clean

CMakeFiles/FVScac.dir/depend:
	$(CMAKE_COMMAND) -E cmake_depends "MinGW Makefiles" C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVScac_CmakeDir C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVScac_CmakeDir C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVScac_CmakeDir C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVScac_CmakeDir C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVScac_CmakeDir\CMakeFiles\FVScac.dir\DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/FVScac.dir/depend

