
# $Id: makefile 1665 2016-02-01 21:32:22Z nickcrookston $

all : iet01 iet02 iet03 iedb compress calibStats econdb firedb climdb \
 ffe_svs climate climatePutGet maxActs 

iet01 : 
	@echo Test iet01, basic functionality
	rm -f iet01_Out.db 
	-$(WINE) ../../bin/qFVSie --keywordfile=iet01.key
	grep -v "\-999" iet01.sum      > iet01.tmp
	grep -v "\-999" iet01.sum.save > iet01.tmp.save
	-diff -w iet01.tmp iet01.tmp.save
	rm iet01.tmp iet01.tmp.save
	-sqlite3 iet01_Out.db < iet01_Out_sqlite.sql > iet01_db_dump.txt
	-diff -w iet01_db_dump.txt iet01_db_dump.txt.save
	@echo Test iet01 ended
	
iet02 : 
	@echo Test iet02, test use of stop/restart, same as iet01.
	rm -f iet01_Out.db 
	-$(WINE) ../../bin/qFVSie --keywordfile=iet01.key --stoppoint=2,2040,iet02.stop
	-$(WINE) ../../bin/qFVSie --restart=iet02.stop
	grep -v "\-999" iet01.sum      > iet01.tmp
	grep -v "\-999" iet01.sum.save > iet01.tmp.save
	-diff -w iet01.tmp iet01.tmp.save
	rm iet01.tmp iet01.tmp.save
	-sqlite3 iet01_Out.db < iet01_Out_sqlite.sql > iet02_db_dump.txt
	-diff -w iet02_db_dump.txt iet02_db_dump.txt.save
	@echo Test iet02 ended
	
iet03 : 
	@echo Test iet03, simple test of ffe with stop/restart
	-$(WINE) ../../bin/qFVSie --keywordfile=iet03.key --stoppoint=1,2003,iet03.stop
	-$(WINE) ../../bin/qFVSie --restart=iet03.stop
	grep -v "\-999" iet03.sum      > iet03.tmp
	grep -v "\-999" iet03.sum.save > iet03.tmp.save
	-diff -w iet03.tmp iet03.tmp.save
	rm iet03.tmp iet03.tmp.save
	@echo Test iet03 ended
	
iedb : 	
	@echo Test ie database read and write
	rm -f FVSieOut.db
	-$(WINE) ../../bin/qFVSie --keywordfile=ie.key 
	-sqlite3 FVSieOut.db < sqliteTestFVSieOut.sql > ie.db_dump.txt
	-diff -w ie.db_dump.txt ie.db_dump.txt.save
	@echo Test ie ended

compress : 	
	@echo Test ie compres
	-$(WINE) ../../bin/qFVSie --keywordfile=compress.key 
	-diff -w compress.out compress.out.save
	@echo Compress test ended

calibStats : 	
	@echo Test FVS_CalibStats read and write
	rm -f calibStats.db
	-$(WINE) ../../bin/qFVSie --keywordfile=calibStats.key 
	-sqlite3 calibStats.db ".header on" "select StandID,TreeSize,SpeciesFVS,NumTrees,round(ScaleFactor,3),round(StdErrRatio,2) from FVS_CalibStats" > calibStats_dump.txt
	-diff -w calibStats_dump.txt calibStats_dump.txt.save
	@echo Test calibStats ended

econdb :
	@echo Test econ database read and write
	rm -f TestDataBase.db
	-$(WINE) ../../bin/qFVSie --keywordfile=TestDataBase.key 
	-sqlite3 TestDataBase.db "select Year,SpeciesPlants,Total_Value from FVS_EconHarvestValue;" > TestDataBase.dump
	-sqlite3 TestDataBase.db "select round(pnv,1),Mrch_BoardFoot_Volume from FVS_EconSummary;" >> TestDataBase.dump	
	-diff -w TestDataBase.dump TestDataBase.dump.save
	@echo Test calibStats ended
		 
firedb : 
	@echo fireTest database read and write
	rm -f FVSieFireOutput.db
	-$(WINE) ../../bin/qFVSie --keywordfile=fireTest.key 
	-sqlite3 FVSieFireOutput.db < sqliteTestFireOut.sql > fireTest.db_dump.txt
	-diff -w fireTest.db_dump.txt fireTest.db_dump.txt.save
	@echo fireTest ended
	
climdb : 
	@echo climate database read and write
	rm -f ClimOut.db
	-$(WINE) ../../bin/qFVSie --keywordfile=Clim.key  
	-sqlite3 ClimOut.db "Select SpeciesFVS,Count(SpeciesFVS) from FVS_Climate group by SpeciesFVS;" > Clim.db.txt 
	-diff -w Clim.db.txt Clim.db.txt.save

ffe_svs :
	@echo ffe_svs: Test FFE with SVS and stop/restart
	-$(WINE) ../../bin/qFVSie --keywordfile=ffe_svs.key --stoppoint=1,2003,ffe_svs.stop
	-$(WINE) ../../bin/qFVSie --restart=ffe_svs.stop
	-diff -w ffe_svs_007.svs ffe_svs_007.svs.save
	-diff -w ffe_svs_index.svs ffe_svs_index.svs.save
	rm ffe_svs_*.svs ffe_svs_*.grd
	@echo Test ffe_svs ended
	

climate :
	@echo Test Climate-FVS 
	-$(WINE) ../../bin/qFVSie --keywordfile=climate.key
	grep -v "\-999" climate.sum      > climate.tmp
	grep -v "\-999" climate.sum.save > climate.tmp.save
	-diff -w climate.tmp climate.tmp.save
	rm climate.tmp climate.tmp.save
	@echo Test Climate-FVS ended
	
climatePutGet :
	@echo Test Climate-FVS with PutGet
	-$(WINE) ../../bin/qFVSie --keywordfile=climate.key --stoppoint=1,2040,climate.stop
	-$(WINE) ../../bin/qFVSie --restart=climate.stop
	grep -v "\-999" climate.sum      > climate.tmp
	grep -v "\-999" climate.sum.save > climate.tmp.save
	-diff -w climate.tmp climate.tmp.save
	rm climate.tmp climate.tmp.save
	@echo Test Climate-FVS with PutGet ended

maxActs :
	@echo Test having many compute statements
	-$(WINE) ../../bin/qFVSie --keywordfile=maxActs.key
	@echo This grep command should not find the string
	grep "OPTION/ACTIVITY STORAGE AREA IS FULL" maxActs.out 
	rm maxActs.out 
	@echo Test having many compute statements ended

ccadj :
	@echo Test THINcc with a ccadj keyword
	-$(WINE) ../../bin/qFVSie --keywordfile=ccadj.key
	grep -v "\-999" ccadj.sum      > ccadj.tmp
	grep -v "\-999" ccadj.sum.save > ccadj.tmp.save
	-diff -w ccadj.tmp ccadj.tmp.save
	rm ccadj.tmp ccadj.tmp.save
	@echo Test THINcc with a ccadj keyword ended
	