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
CMAKE_SOURCE_DIR = C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVSktc_CmakeDir

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVSktc_CmakeDir

# Utility rule file for dbstypedefs.

# Include the progress variables for this target.
include CMakeFiles/dbstypedefs.dir/progress.make

CMakeFiles/dbstypedefs:
	.\mkdbsTypeDefs.exe

dbstypedefs: CMakeFiles/dbstypedefs
dbstypedefs: CMakeFiles/dbstypedefs.dir/build.make
.PHONY : dbstypedefs

# Rule to build all files generated by this target.
CMakeFiles/dbstypedefs.dir/build: dbstypedefs
.PHONY : CMakeFiles/dbstypedefs.dir/build

CMakeFiles/dbstypedefs.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles\dbstypedefs.dir\cmake_clean.cmake
.PHONY : CMakeFiles/dbstypedefs.dir/clean

CMakeFiles/dbstypedefs.dir/depend:
	$(CMAKE_COMMAND) -E cmake_depends "MinGW Makefiles" C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVSktc_CmakeDir C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVSktc_CmakeDir C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVSktc_CmakeDir C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVSktc_CmakeDir C:\MinGW\msys\1.0\home\pradtke\Source\trunk\bin\FVSktc_CmakeDir\CMakeFiles\dbstypedefs.dir\DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/dbstypedefs.dir/depend

