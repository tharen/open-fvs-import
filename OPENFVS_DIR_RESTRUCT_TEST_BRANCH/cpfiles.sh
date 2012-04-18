################################################################################
## this script merges builds a single directory for building 
## the FVSpn variant with the ORGANON extension.

## open the file, read each line, and execute a copy command
VARIANT=pnc
BUILD_DIR=FVS${VARIANT}_buildDir/
##SRC_FILES=FVS${VARIANT}_sourceList-DS6.txt
SRC_FILES=FVS${VARIANT}_sourceList-MinGW32.txt

##SRC_FILES=FVS${VARIANT}_sourceList_local_dbs.txt

## wipe out the existing build directory
rm -fr $BUILD_DIR
mkdir $BUILD_DIR

## copy the FVS source files.
file_list=`cut -f1 $SRC_FILES | awk '{printf "%s\n", $1}'`
for f in $file_list
do
    cp -v $f $BUILD_DIR/
done

## cd to the build dir, compile, and link it.
# cd $BUILD_DIR
# gcc -c *.c 
# gfortran -c *.f
# gfortran -o FVS${VARIANT} *.o

