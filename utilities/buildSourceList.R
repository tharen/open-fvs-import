
# utility commands that aid in building sourceList files for open-fvs
# using the Fort Collins production code builds as raw information.

#=============  This script is not to be run as a single set. There
#=============  are parts that must be run from R and some steps that
#=============  are run from a cygwin command line.


# Set the working directory to the fvsbin on your system. This is only run
# on windows, here is mine:

setwd("C:/fvs/trunk/bin")
baseWD = getwd()

# Start with a clean (no object files) set of code from Ft Collins
# These commands will clean out all the .obj files.
setwd("..")
allfiles=dir(all.files=TRUE, recursive=TRUE)
obj=grep ("\\.obj$",allfiles)
if (length(obj)>0) 
{
  obj=allfiles[obj]
  lapply(obj,unlink)
}  

# set variables that specify which FVS program and variant will be processed
pgm="FVSiec"; var="/ie/"

pgm="FVScrc"; var="/cr/"

#=============  FROM cygwin.
# Run make: make FVSiec > FVSiec.makeout
# Run make: make FVScrc > FVScrc.makeout
#=============

# The following code can be cup and pasted into R as a set

# You'll need to edit the resulting file to add in files used in open-fvs and not Ft Collins
# plus the fofem gcc routines.

setwd("bin")
all = scan(paste(pgm,"makeout",sep="."),what="character",sep="\n",quiet=TRUE)
allout=vector("list")

map = scan(paste(pgm,"map",sep="."),what="character",sep="\n",quiet=TRUE)
map = map[(grep("Lib:Object",map)+1):length(map)]
map = map[1:(grep(".dll",map)[1]-1)]
map = lapply(map,function (x) 
  {
    x = unlist(strsplit(x," "))
    x = x[length(x)]
   })
map=unlist(unique(map))
map=gsub(".obj",".f",map,fixed = TRUE)
   
for (line in all)
{
  tag = grep ("Entering",line)
  if (length(tag) > 0) 
  {
    curdir=strsplit(line,"`")[[1]][2]
    curdir=sub("'","",curdir)
    dirparts=unlist(strsplit(curdir,"/"))
    dirparts=dirparts[4:length(dirparts)]
    next
  }
  tag = substr(line,1,4)
  if (tag == "LF95") 
  {
    src=unlist(strsplit(gsub("\t","",line)," "))
    include=NULL
    for (inc in 1:length(src)) if (src[inc] == "-i") { include=src[inc+1]; break }
    if (!is.null(include))
    {
      include=gsub("\\","",include,fixed=TRUE)
      inc=unlist(strsplit(include,";"))
      for (ii in 1:length(inc)) inc[ii] = if (substr(inc[ii],1,2) == "./") substring(inc[ii],3) else inc[ii]
      for (ii in 1:length(inc)) inc[ii] = if (substr(inc[ii],1,2) == "./") substring(inc[ii],3) else inc[ii]
      incp=inc
      for (ii in 1:length(incp))
      {
        incparts=unlist(strsplit(incp[ii],"/"))            
        i=0
        for (sp in incparts) if (sp == "..") i=i+1
        incp[ii] = paste(c("",dirparts[1:(length(dirparts)-i)],
          incparts[(i+1):length(incparts)]),collapse="/")
      }
    }

    src=src[length(src)]
    if (substr(src,1,2) == "./") src = substring(src,3)
    if (substr(src,1,2) != "..") next
    srcparts=unlist(strsplit(src,"/"))
  } else next
  i=0
  for (sp in srcparts) if (sp == "..") i=i+1
  fn = srcparts[length(srcparts)]  
  fnused = grep(fn,map,fixed=TRUE)
  if (length(fnused) == 0) 
  {
     cat ("compiled but not used=",fn,"\n"); flush.console()
     mod = grep("_mod",fn,fixed=TRUE)
     myo = grep("myopen",fn,fixed=TRUE)
     if (length(mod)+length(myo) == 0) next
     cat ("kept anyway=",fn,"\n"); flush.console()
  }

  filename = paste(c("",dirparts[1:(length(dirparts)-i)],
          srcparts[(i+1):length(srcparts)]),collapse="/")
  if (!file.exists(filename)) break
  # cat (filename,"\n"); flush.console()
  allout=append(allout,filename)
  sf = scan(filename,what="character",sep="\n",quiet=TRUE)
  includes = grep ("include",sf,ignore.case=TRUE)
  if (length(includes) == 0) next 
  sf = gsub(" ","",sf[includes],fixed=TRUE)
  for (inc in sf)
  {
    up = toupper(inc) 
    if (substring(up,1,7) != "INCLUDE") break
    up = sub("INCLUDE","",up,fixed = TRUE)
    up = gsub("'","",up,fixed = TRUE)
    up = gsub('"',"",up,fixed = TRUE)
    for (i in 1:length(incp)) 
    {
      incfile = paste(incp[i],up,sep="/")
      if (file.exists(incfile)) 
      { 
        # cat (incfile,"\n"); flush.console()
        allout=append(allout,incfile)
        break
      }
    }
  }
}
allout=unique(allout)
allout=sort(unlist(allout))
allout=gsub("/fvs/trunk","..",allout,fixed = TRUE)
svn=grep ("INCLUDESVN.F",allout)
if (length(svn) > 0) allout[svn]=sub("INCLUDESVN.F","incudeSVN.f",allout[svn],fixed = TRUE)
myo=grep ("myopen_pc.f",allout)
if (length(myo) > 0) allout[myo]=sub("_pc","",allout[svn],fixed = TRUE)

allout = unique(allout)

for (x in allout)
{
  px = unlist(strsplit(x,"/"))
  px = paste("/",px[length(px)],sep="")
  found = grep (px,allout,fixed = TRUE)
  if (length(found) > 1) 
  {
    cat (" x=",x," found ", found, " routines=", allout[found],"\n")
    for (ii in found)
    {
      keep=grep(var,allout[found],fixed = TRUE)
      if (length(keep) == 0) next
      cat (" keep=",allout[found[keep]],"\n")
      found=found[-keep]
      cat (" toss=",allout[found],"\n")
      allout = allout[-found]
    }
  } 
}

adds=c("../base/src/apisubs.f",
"../base/src/cmdline.f",
"../base/src/fvs.f",
"../base/src/myopen.f",
"../common/GLBLCNTL.F77",
"../common/PPDNCM.F77",
"../dbs/src/fvsSQL.c",
"../dbs/src/mkdbsTypeDefs.c",
"../dbs/src/dbsppget.f",
"../dbs/src/dbsppput.f",
"../dbs/src/dbspusget.f",
"../dbs/src/dbspusput.f",
"../fire/fofem/src/bur_bov.c",
"../fire/fofem/src/bur_bov.h",
"../fire/fofem/src/bur_brn.c",
"../fire/fofem/src/bur_brn.h",
"../fire/fofem/src/fm_fofem.c",
"../fire/fofem/src/fm_fofem.h",
"../fire/fofem/src/fof_ansi.h",
"../fire/fofem/src/fof_bcm.c",
"../fire/fofem/src/fof_bcm.h",
"../fire/fofem/src/fof_cct.h",
"../fire/fofem/src/fof_ci.c",
"../fire/fofem/src/fof_ci.h",
"../fire/fofem/src/fof_cm.c",
"../fire/fofem/src/fof_cm.h",
"../fire/fofem/src/fof_co.c",
"../fire/fofem/src/fof_co.h",
"../fire/fofem/src/fof_co2.h",
"../fire/fofem/src/fof_disp.h",
"../fire/fofem/src/fof_duf.c",
"../fire/fofem/src/fof_duf.h",
"../fire/fofem/src/fof_gen.h",
"../fire/fofem/src/fof_hsf.c",
"../fire/fofem/src/fof_hsf.h",
"../fire/fofem/src/fof_iss.h",
"../fire/fofem/src/fof_lem.c",
"../fire/fofem/src/fof_lem.h",
"../fire/fofem/src/fof_mrt.c",
"../fire/fofem/src/fof_mrt.h",
"../fire/fofem/src/fof_sd.c",
"../fire/fofem/src/fof_sd.h",
"../fire/fofem/src/fof_sd2.h",
"../fire/fofem/src/fof_se.c",
"../fire/fofem/src/fof_se.h",
"../fire/fofem/src/fof_se2.h",
"../fire/fofem/src/fof_sgv.c",
"../fire/fofem/src/fof_sgv.h",
"../fire/fofem/src/fof_sh.c",
"../fire/fofem/src/fof_sh.h",
"../fire/fofem/src/fof_sh2.h",
"../fire/fofem/src/fof_sha.c",
"../fire/fofem/src/fof_sha.h",
"../fire/fofem/src/fof_smt.h",
"../fire/fofem/src/fof_soi.c",
"../fire/fofem/src/fof_soi.h",
"../fire/fofem/src/fof_spp.h",
"../fire/fofem/src/fof_unix.c",
"../fire/fofem/src/fof_util.c",
"../fire/fofem/src/fof_util.h",
"../fire/fofem/src/win_ccwf.h",
"../mistoe/src/MISCOM.F77",
"../mistoe/src/misact.f",
"../mistoe/src/msppgt.f",
"../mistoe/src/mspppt.f",
"../pg/src/chget.f",
"../pg/src/chput.f",
"../pg/src/cvget.f",
"../pg/src/cvput.f",
"../pg/src/ecnget.f",
"../pg/src/ecnput.f",
"../pg/src/fmppget.f",
"../pg/src/fmpphv.f",
"../pg/src/fmppput.f",
"../pg/src/getstd.f",
"../pg/src/putgetsubs.f",
"../pg/src/putstd.f",
"../pg/src/stash.f")


allout=sort(c(allout,adds))

write.table(allout,file=paste(pgm,"sourceList.txt",sep="_"),quote=FALSE,row.names=FALSE,col.names=FALSE)

