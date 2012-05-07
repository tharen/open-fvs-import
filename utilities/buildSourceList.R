
# utility commands that aid in building sourceList files for open-fvs
# using the Fort Collins production code builds as raw information.

#===== I ran this by cut/paste these commands into a cygwin window on the PC. The directory was preset to 
#  /cygdrive/z/ncrookston/fvs/ftcollins/trunk/bin   (where I have an up-to-date copy of the Ft Collins repository.
# cleanObj is this: 
# curdir=`pwd`
# cd ..
# rm `find  | grep "\.obj$"`
# cd $curdir
#
# ./cleanObj; make FVSak  > FVSak.makeout  ; R  --verboxe --no-save --args FVSak   < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R
# ./cleanObj; make FVSbmc > FVSbmc.makeout ; R  --verboxe --no-save --args FVSbmc  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVScac > FVScac.makeout ; R  --verboxe --no-save --args FVScac  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVScic > FVScic.makeout ; R  --verboxe --no-save --args FVScic  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVScrc > FVScrc.makeout ; R  --verboxe --no-save --args FVScrc  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVScs  > FVScs.makeout  ; R  --verboxe --no-save --args FVScs   < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSecc > FVSecc.makeout ; R  --verboxe --no-save --args FVSecc  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSemc > FVSemc.makeout ; R  --verboxe --no-save --args FVSemc  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSiec > FVSiec.makeout ; R  --verboxe --no-save --args FVSiec  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSktc > FVSktc.makeout ; R  --verboxe --no-save --args FVSktc  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSls  > FVSls.makeout  ; R  --verboxe --no-save --args FVSls   < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSncc > FVSncc.makeout ; R  --verboxe --no-save --args FVSncc  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSne  > FVSne.makeout  ; R  --verboxe --no-save --args FVSne   < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSpnc > FVSpnc.makeout ; R  --verboxe --no-save --args FVSpnc  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSsn  > FVSsn.makeout  ; R  --verboxe --no-save --args FVSsn   < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSsoc > FVSsoc.makeout ; R  --verboxe --no-save --args FVSsoc  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSttc > FVSttc.makeout ; R  --verboxe --no-save --args FVSttc  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSutc > FVSutc.makeout ; R  --verboxe --no-save --args FVSutc  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSwcc > FVSwcc.makeout ; R  --verboxe --no-save --args FVSwcc  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     
# ./cleanObj; make FVSwsc > FVSwsc.makeout ; R  --verboxe --no-save --args FVSwsc  < z:/ncrookston/fvs/open-fvs/utilities/buildSourceList.R                                                     


# Set the working directory to the fvsbin from Ft Collins. This is only run
# on windows, here is mine:

setwd("Z:\\ncrookston\\fvs\\ftcollins\\trunk\\bin")

# DEFINE pgm from the command line....

  pgm = commandArgs(trailingOnly=TRUE)[1]
# pgm="FVSne"  
  var = paste("/",substr(pgm,4,5),"/",sep="")
  cat ("running, pgm=",pgm," var=",var,"\n"); flush.console()
  
  makeoutFile = paste(pgm,"makeout",sep=".")
  mapFile = paste(pgm,"map",sep=".")
  
  makeExists = file.exists(makeoutFile)
  mapExists  = file.exists(mapFile)
  
  cat ("\npgm=",pgm," var=",var," makeout=",makeoutFile," exists=", makeExists,
       "\nmap=",mapFile, " exists=",mapExists,"\n")
       
  if (! (makeExists & mapExists)) next
  
  cat ("processing ",pgm,"\n"); flush.console()
  
  all = scan(makeoutFile,what="character",sep="\n",quiet=TRUE)

  linkfirst=grep(pgm,all)[1]
  linkList = NULL
  for (linkL in linkfirst:length(all))
  {
    linkLine = all[linkL]
    addToList = unlist(strsplit(linkLine,"..",fixed=TRUE))
    if (is.null(linkList)) addToList = addToList[-1]
    addToList = gsub(" ","",addToList)
    lastone = addToList[length(addToList)]
    fixLast = gsub("\\","",lastone,fixed=TRUE)
    addToList[length(addToList)] = fixLast
    linkList = c(linkList,addToList)
    if (fixLast == lastone) break
  }

  keep=unlist(lapply(linkList,nchar)) > 0
  linkList = linkList[keep]
  objSearches = grep ("*.obj",linkList,fixed=TRUE)
  if (length(objSearches)> 0)
  {
    for (linkL in linkList[objSearches])
    {
      toSearch = paste("..",gsub("/*.obj`","",linkL,fixed=TRUE),sep="")
      addToList = dir(toSearch,pattern="obj")
      if (length(addToList) > 0) 
      {
        addToList = paste(toSearch,"/",addToList,sep="")
        addToList = gsub("..","",addToList,fixed=TRUE)
        linkList = c(linkList,addToList)
      }
    }
    linkList = linkList[-objSearches]
  }
  linkList=gsub("`ls","",linkList)
  linkList=gsub("`","",linkList)
     
  
  map = scan(mapFile,what="character",sep="\n",quiet=TRUE)
  map = map[(grep("Lib:Object",map)+1):length(map)]
  map = map[1:(grep(".dll",map)[1]-1)]
  map = lapply(map,function (x) 
    {
      x = unlist(strsplit(x," "))
      x = x[length(x)]
     })
  map=unlist(unique(map))
  keep = unique(sort(unlist(lapply(map,function (x,linkList) grep(x,linkList), linkList))))
  linkList = linkList[keep]
    
  map=gsub(".obj",".f",map,fixed = TRUE)

  allout=vector("list")     
  for (line in all)
  {
    tag = grep ("Entering",line)
    if (length(tag) > 0) 
    {
      curdir=strsplit(line,"`")[[1]][2]
      curdir=sub("'","",curdir)
      dirparts=unlist(strsplit(curdir,"/"))
      trunk=grep("trunk",dirparts,fixed=TRUE)
      cdparts=dirparts[(trunk+1):length(dirparts)]
      compDir=paste("/",paste(cdparts,collapse="/"),"/",sep="")
      cat ("compDir = ",compDir,"\n"); flush.console()
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
    compOut = paste(compDir,srcparts[length(srcparts)],sep="")
    compOut = sub(".f",".obj",compOut,fixed=TRUE)
    fnused = grep(compOut,linkList,fixed=TRUE)
    if (length(fnused) == 0) 
    {
       fn = srcparts[length(srcparts)]  
  #     cat ("compiled but not used=",compOut,"\n"); flush.console()
       mod = grep("_mod",fn,fixed=TRUE)
       myo = grep("myopen",fn,fixed=TRUE)
       if (length(mod)+length(myo) == 0) next
  #     cat ("kept anyway=",fn,"\n"); flush.console()
    }
  
    filename = paste(c("",dirparts[1:(length(dirparts)-i)],
            srcparts[(i+1):length(srcparts)]),collapse="/") 
    filename = sub("//cygdrive/z","Z:",filename,fixed=TRUE)
#    cat (filename," exists=",file.exists(filename),"\n"); flush.console()
    if (!file.exists(filename)) next
    allout=append(allout,filename)
    sf = scan(filename,what="character",sep="\n",quiet=TRUE)
    includes = grep ("include",sf,ignore.case=TRUE)
    if (length(includes) == 0) next 
    sf = gsub(" ","",sf[includes],fixed=TRUE)
    verbose = length(grep("volum",compDir))>0
 
    for (inc in sf)
    {
      up = toupper(inc)
      if (verbose) cat (filename,"up = ",up,"\n")
      if (substring(up,1,7) != "INCLUDE") next
      up = sub("INCLUDE","",up,fixed = TRUE)
      up = gsub("'","",up,fixed = TRUE)
      up = gsub('"',"",up,fixed = TRUE)
      if (length(grep("!",up)) > 0) up = unlist(strsplit(up,"!"))[1]
      # search the "include search list"

      for (i in 0:length(incp)) 
      {
        if (i == 0)
        {
          incfile=unlist(strsplit(filename,"/"))
          incfile=paste(c(incfile[1:(length(incfile)-1)],up),collapse="/")
        }
        else
        {
          incfile = paste(incp[i],up,sep="/")
          incfile = sub("//cygdrive/z","Z:",incfile,fixed=TRUE)
        }
    #    cat (incfile," exists=",file.exists(incfile),"\n"); flush.console()
        # if the file is found, then add it and break.
        if (file.exists(incfile)) 
        {
          if (length(grep(incfile,unlist(allout))) == 0) allout=append(allout,incfile)
          break
        }
      }
    }
  }

  allout=sort(unlist(allout))
  allout=unique(allout)
  trimout = "Z:/ncrookston/fvs/ftcollins/trunk"
  allout=gsub(trimout,"..",allout,fixed = TRUE)
  cat ("trimout = ",trimout,"\n");flush.console()
  svn=grep ("INCLUDESVN.F",allout)
  if (length(svn) > 0) allout = allout[-svn]
  myo=grep ("myopen_pc.f",allout)
  if (length(myo) > 0) allout[myo]=sub("_pc","",allout[svn],fixed = TRUE)
  
  allout = sort(allout)
  allout = unique(allout)
  alloutSave = allout

  adds=c("../base/src/apisubs.f",
  "../base/src/cmdline.f",
  "../base/src/fvs.f",
  "../base/src/myopen.f",
  "../common/GLBLCNTL.F77",
  "../common/GGCOM.F77",
  "../common/ESHAP2.F77",
  "../common/ESCOM2.F77",
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
  "../pg/src/chget.f",
  "../pg/src/chput.f",
  "../pg/src/ecnget.f",
  "../pg/src/ecnput.f",
  "../pg/src/fmppget.f",
  "../pg/src/fmpphv.f",
  "../pg/src/fmppput.f",
  "../pg/src/getstd.f",
  "../pg/src/putgetsubs.f",
  "../pg/src/putstd.f",
  "../pg/src/stash.f")

  if (length(grep("excov.f",allout)) == 0) adds=c(adds,
     c("../pg/src/cvget.f","../pg/src/cvput.f"))
     
  if (length(grep("exmist.f",allout))== 0) adds=c(adds, 
     c("../mistoe/src/MISCOM.F77","../mistoe/src/misact.f",
       "../mistoe/src/msppgt.f","../mistoe/src/mspppt.f"))
  
  allout = unique(sort(c(allout,adds)))

  outfile=paste(pgm,"sourceList.txt",sep="_")
  cat("output file=",outfile,"\n"); flush.console()
  write.table(allout,file=outfile,quote=FALSE,row.names=FALSE,col.names=FALSE)

q()
