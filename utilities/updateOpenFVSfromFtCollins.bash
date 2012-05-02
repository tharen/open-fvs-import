#!/bin/bash

# This .bash script provides files compare the FtColins sources to the open-fvs
# sources and to suggest which files from Ft Collins are needed to update
# the open-fvs repository. 

# The files assueme that you are starting in a directory that contains the ftcollins
# sources and the open-fvs sources.

cd ftcollins
find * -type f |  grep -v ".svn" |  grep -v ".doc" | grep -v "/bin/" | \
       grep -v "/dbs/"  > ../ftc.list
cd ../open-fvs
find * -type f |  grep -v "OPENFVS_DIR_" | grep -v ".svn" |  grep -v ".doc" | \
      grep -v "wiki/" | grep -v "rFVS/" | grep -v "/dbs/" |  grep -v "utilities" | \
      grep -v "mod$" | grep -v "/tests/" | grep -v "/bin/" > ../opn.list
cd ..

# files to add from ft collins to open-fvs
diff ftc.list opn.list | grep "^<" > ftc.newfiles
diff ftc.list opn.list | grep "^>" > opn.newfiles

rm -f copyNewCmds addNewCmds
cut -d\< -f2 ftc.newfiles |
( 
  while read line
  do
    echo cp ftcollins/$line open-fvs/$line >> copyNewCmds
    echo svn add $line >> addNewCmds
  done
)

cat ftc.list opn.list | sort | uniq -D | uniq > both.list

rm -f alldiff.report diff.report copycmds
cat both.list | 
( 
  while read line
  do
    diff -w ftcollins/$line  open-fvs/$line > /dev/null
    rc=$?
    if [ $rc -gt 0 ] 
    then
      echo diff -w ftcollins/$line  open-fvs/$line >> alldiff.report
      diff -w ftcollins/$line  open-fvs/$line >> alldiff.report
      fn=`echo $line | rev | cut -f1 -d/ | rev`
      grep ^$fn open-fvs/utilities/defermentList > /dev/null
      if [ $? -gt 0 ]
      then
        echo diff -w ftcollins/$line  open-fvs/$line >> diff.report
        diff -w ftcollins/$line  open-fvs/$line >> diff.report
        echo cp ftcollins/$line  open-fvs/$line >> copycmds
      fi
    fi
  done
  diff -w ftcollins/trunk/bin/makefile open-fvs/trunk/bin/oldmakefile > /dev/null
  rc=$?
  if [ $rc -gt 0 ] 
  then
    echo diff -w ftcollins/trunk/bin/makefile open-fvs/trunk/bin/oldmakefile >> diff.report
    diff -w ftcollins/trunk/bin/makefile open-fvs/trunk/bin/oldmakefile >> diff.report
    echo cp ftcollins/trunk/bin/makefile open-fvs/trunk/bin/oldmakefile >> copycmds
  fi
)





