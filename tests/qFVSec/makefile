
all : ect01 ect02

ect01 : 
	@echo Test ect01, basic functionality 
	-$(WINE) ../../bin/qFVSec --keywordfile=ect01.key
	grep -v "\-999" ect01.sum      > ect01.tmp
	grep -v "\-999" ect01.sum.save > ect01.tmp.save
	-diff -w ect01.tmp ect01.tmp.save
	rm ect01.tmp ect01.tmp.save
	@echo Test ect01 ended
	
ect02 : 
	@echo Test ect02, stop/restart, output should match ect01
	-$(WINE) ../../bin/qFVSec --keywordfile=ect01.key --stoppoint=2,2040,ect.stop
	-$(WINE) ../../bin/qFVSec --restart=ect.stop
	grep -v "\-999" ect01.sum      > ect01.tmp
	grep -v "\-999" ect01.sum.save > ect01.tmp.save
	-diff -w ect01.tmp ect01.tmp.save
	rm ect01.tmp ect01.tmp.save
	@echo Test ect02 ended
		 
 
 

