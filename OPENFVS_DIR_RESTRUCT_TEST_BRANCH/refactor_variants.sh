# this script iterates over the VARIANTS.CSV file and reoganises 
# the directory structure so that newbies can more easily ingest 
# the simulator structure.



## ieeee! you need to get the data/script from your windows machine.


################################################################################
## this script merges builds a single directory for building 
## the FVSpn variant with the ORGANON extension.

## open the file, read each line, and execute a copy command
##VARIANT=pnc
##BUILD_DIR=FVS${VARIANT}_buildDir/
##SRC_FILES=FVS${VARIANT}_sourceList-DS6.txt
VARIANTS_FILE=variants.csv

##SRC_FILES=FVS${VARIANT}_sourceList_local_dbs.txt

## wipe out the existing build directory
##rm -fr $BUILD_DIR
##mkdir $BUILD_DIR

## copy the FVS source files.
file_list=`cut -f1 $VARIANTS_FILE | awk '{printf "%s\n", $1}'`
for f in $file_list
do
    ##cp -v $f $BUILD_DIR/
    ##svn mv $f src/variants/$f/obj/makefile src/variants/$f/
    ##echo "svn mv src/variants/$f/obj/makefile src/variants/$f/"
    ##svn mv src/variants/$f/obj/makefile src/variants/$f/
    svn rm src/variants/$f/obj
done

## needed to hack out some svn issues.
## svn resolve -R --accept=working variants



## cd to the build dir, compile, and link it.
# cd $BUILD_DIR
# gcc -c *.c 
# gfortran -c *.f
# gfortran -o FVS${VARIANT} *.o

## these are for the extensions.
## /Users/hamannjd/Documents/open-fvs/OPENFVS_DIR_RESTRUCT_TEST_BRANCH/src/extensions/bgc/bgc/obj




