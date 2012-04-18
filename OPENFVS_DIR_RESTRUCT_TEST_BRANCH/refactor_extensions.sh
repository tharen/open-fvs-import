################################################################################
# this script iterates over the extensions.csv file and reoganises 
# the directory structure so that newbies can more easily ingest 
# the simulator structure.

## not all exentions will fit the pattern.
## some extensions have variant specific files/structures.
## this file handles the cases where the extension is a simple extensions.

## clim is not in this category.
EXTENSIONS_FILE=simple_extensions.csv

## copy the FVS source files.
file_list=`cut -f1 $EXTENSIONS_FILE | awk '{printf "%s\n", $1}'`
for f in $file_list
do
    ##cp -v $f $BUILD_DIR/
    ##svn mv $f src/variants/$f/obj/makefile src/variants/$f/
    ##echo "svn mv src/variants/$f/obj/makefile src/variants/$f/"
    ##svn mv src/variants/$f/obj/makefile src/variants/$f/
    ## svn rm src/variants/$f/obj

    ##echo "svn mv src/extensions/$f/$f/obj/makefile src/extensions/$f/makefile"
    ##echo "svn rm src/extensions/$f/$f/obj"

    
    ## don't mess with the src. nope. mess with src.
    echo "svn mv src/extensions/$f/$f/src src/extensions/$f/"
    echo "svn rm src/extensions/$f/$f"


done

## needed to hack out some svn issues.
## svn resolve -R --accept=working extensions


## these are for the extensions.
## /Users/hamannjd/Documents/open-fvs/OPENFVS_DIR_RESTRUCT_TEST_BRANCH/src/extensions/bgc/bgc/obj




