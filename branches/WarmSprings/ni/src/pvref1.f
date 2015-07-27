      SUBROUTINE PVREF1 (KARD2,ARRAY2,I1,I2,LPVCOD,LPVREF)
C----------
C  **PVREF1--NI   DATE OF LAST REVISION: 02/04/11
C----------
C
C     MAPS PV/REFERENCE CODES INTO A FVS HABITAT/ECOCLASS CODE
C     CALLED FROM **HABTYP** WHEN REFTMP IS GREATER THAN ZERO
C
C     INPUT VARIABLES
C     KARD2          - FIELD 2 OF STDINFO KEYWORD
C     ARRAY2         - FIELD 2 OF STDINFO (REAL CONTERPART TO KARD2)
C     CPVREF         - FIELD 7 OF STDINFO KEYWORD
C                    - CARRIED IN PLOT.F77
C
C     RETURN VARIABLES
C     KARD2          - MAPPED FVS HABITAT/ECOCLASS CODE
C
C     INTERNAL VARIABLES
C     PVCODE,PVREF   - ARRAYS OF PV CODE/REFERENCE CODE COMBINATIONS
C                      FROM FSVEG DATA BASE
C     HABPVR         - FVS HABITAT/ECOCLASS CODE CORRESPONDING TO
C                      PV CODE/REFERENCE CODE COMBINATION
      IMPLICIT NONE
COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
      INCLUDE 'PLOT.F77'
C
C  DECLARATIONS
C
      REAL         ARRAY2
      INTEGER      I,I1,I2,NCODES
      PARAMETER    (NCODES=702)
      CHARACTER*10 PVREF(NCODES),PVCODE(NCODES),KARD2,KARD2T
      CHARACTER*10 HABPVR(NCODES)
      LOGICAL      LPVCOD,LPVREF
C
C  DATA STATEMENTS
C
      DATA (HABPVR(I),I=   1,  60)/
     &'10        ','10        ','10        ','10        ',
     &'10        ','10        ','10        ','10        ',
     &'10        ','10        ','10        ','10        ',
     &'10        ','10        ','10        ','10        ',
     &'10        ','10        ','10        ','10        ',
     &'10        ','100       ','100       ','100       ',
     &'100       ','110       ','110       ','110       ',
     &'110       ','110       ','130       ','130       ',
     &'130       ','130       ','140       ','140       ',
     &'140       ','140       ','140       ','140       ',
     &'140       ','140       ','140       ','140       ',
     &'170       ','160       ','160       ','160       ',
     &'160       ','160       ','160       ','160       ',
     &'160       ','160       ','170       ','170       ',
     &'170       ','170       ','170       ','170       '/
      DATA (HABPVR(I),I=  61, 120)/
     &'170       ','170       ','170       ','170       ',
     &'180       ','180       ','180       ','180       ',
     &'180       ','180       ','180       ','180       ',
     &'180       ','190       ','190       ','190       ',
     &'200       ','200       ','200       ','200       ',
     &'210       ','210       ','210       ','210       ',
     &'220       ','220       ','220       ','220       ',
     &'230       ','230       ','230       ','250       ',
     &'250       ','250       ','250       ','260       ',
     &'260       ','260       ','260       ','260       ',
     &'260       ','260       ','260       ','260       ',
     &'260       ','260       ','260       ','260       ',
     &'260       ','280       ','280       ','280       ',
     &'280       ','280       ','280       ','280       ',
     &'280       ','280       ','280       ','280       '/
      DATA (HABPVR(I),I= 121, 180)/
     &'280       ','280       ','290       ','290       ',
     &'290       ','290       ','290       ','290       ',
     &'290       ','290       ','290       ','290       ',
     &'290       ','290       ','310       ','310       ',
     &'310       ','310       ','310       ','310       ',
     &'310       ','310       ','310       ','310       ',
     &'310       ','310       ','310       ','320       ',
     &'320       ','320       ','320       ','320       ',
     &'320       ','320       ','320       ','320       ',
     &'320       ','320       ','320       ','320       ',
     &'320       ','320       ','320       ','320       ',
     &'320       ','320       ','330       ','330       ',
     &'330       ','330       ','340       ','340       ',
     &'340       ','340       ','350       ','350       ',
     &'350       ','360       ','360       ','360       '/
      DATA (HABPVR(I),I= 181, 240)/
     &'360       ','360       ','360       ','370       ',
     &'370       ','370       ','380       ','380       ',
     &'380       ','400       ','400       ','400       ',
     &'410       ','410       ','410       ','420       ',
     &'420       ','420       ','420       ','420       ',
     &'420       ','420       ','420       ','420       ',
     &'430       ','430       ','430       ','440       ',
     &'440       ','440       ','450       ','450       ',
     &'450       ','460       ','460       ','460       ',
     &'460       ','460       ','460       ','460       ',
     &'460       ','460       ','470       ','470       ',
     &'470       ','480       ','480       ','480       ',
     &'500       ','500       ','500       ','500       ',
     &'501       ','501       ','501       ','501       ',
     &'502       ','502       ','502       ','502       '/
      DATA (HABPVR(I),I= 241, 300)/
     &'505       ','505       ','505       ','506       ',
     &'506       ','506       ','506       ','506       ',
     &'506       ','506       ','506       ','506       ',
     &'510       ','510       ','510       ','510       ',
     &'510       ','510       ','510       ','510       ',
     &'510       ','510       ','515       ','515       ',
     &'515       ','516       ','516       ','516       ',
     &'516       ','516       ','516       ','516       ',
     &'516       ','516       ','516       ','516       ',
     &'516       ','520       ','520       ','520       ',
     &'520       ','520       ','520       ','520       ',
     &'520       ','520       ','520       ','520       ',
     &'520       ','520       ','520       ','520       ',
     &'520       ','520       ','520       ','520       ',
     &'520       ','520       ','520       ','520       '/
      DATA (HABPVR(I),I= 301, 360)/
     &'520       ','529       ','529       ','529       ',
     &'530       ','530       ','530       ','530       ',
     &'530       ','530       ','530       ','530       ',
     &'530       ','530       ','530       ','530       ',
     &'530       ','530       ','530       ','530       ',
     &'530       ','530       ','530       ','530       ',
     &'530       ','540       ','540       ','540       ',
     &'540       ','540       ','540       ','540       ',
     &'540       ','545       ','545       ','545       ',
     &'545       ','545       ','545       ','545       ',
     &'545       ','545       ','545       ','545       ',
     &'545       ','545       ','550       ','550       ',
     &'550       ','550       ','555       ','555       ',
     &'555       ','560       ','560       ','560       ',
     &'565       ','565       ','565       ','570       '/
      DATA (HABPVR(I),I= 361, 420)/
     &'570       ','570       ','570       ','570       ',
     &'570       ','570       ','570       ','570       ',
     &'570       ','570       ','570       ','570       ',
     &'570       ','570       ','570       ','570       ',
     &'570       ','575       ','575       ','575       ',
     &'575       ','575       ','575       ','575       ',
     &'575       ','575       ','575       ','575       ',
     &'575       ','579       ','579       ','579       ',
     &'590       ','590       ','590       ','590       ',
     &'590       ','590       ','590       ','590       ',
     &'590       ','590       ','590       ','590       ',
     &'600       ','600       ','600       ','600       ',
     &'610       ','610       ','610       ','620       ',
     &'620       ','620       ','620       ','620       ',
     &'620       ','620       ','620       ','620       '/
      DATA (HABPVR(I),I= 421, 480)/
     &'620       ','620       ','620       ','620       ',
     &'620       ','620       ','620       ','620       ',
     &'620       ','620       ','620       ','620       ',
     &'620       ','630       ','630       ','630       ',
     &'635       ','635       ','635       ','635       ',
     &'635       ','635       ','635       ','635       ',
     &'635       ','640       ','640       ','640       ',
     &'640       ','650       ','650       ','650       ',
     &'650       ','650       ','650       ','650       ',
     &'650       ','650       ','650       ','650       ',
     &'650       ','650       ','650       ','650       ',
     &'650       ','650       ','650       ','650       ',
     &'650       ','650       ','660       ','660       ',
     &'660       ','660       ','660       ','660       ',
     &'660       ','660       ','660       ','660       '/
      DATA (HABPVR(I),I= 481, 540)/
     &'660       ','660       ','670       ','670       ',
     &'670       ','670       ','670       ','670       ',
     &'670       ','670       ','670       ','670       ',
     &'670       ','670       ','670       ','670       ',
     &'670       ','670       ','675       ','675       ',
     &'675       ','675       ','675       ','675       ',
     &'675       ','675       ','675       ','680       ',
     &'680       ','680       ','680       ','680       ',
     &'680       ','680       ','680       ','680       ',
     &'680       ','685       ','685       ','685       ',
     &'685       ','685       ','685       ','685       ',
     &'690       ','690       ','690       ','690       ',
     &'690       ','690       ','690       ','690       ',
     &'690       ','690       ','690       ','690       ',
     &'690       ','690       ','690       ','690       '/
      DATA (HABPVR(I),I= 541, 600)/
     &'690       ','690       ','700       ','700       ',
     &'700       ','701       ','710       ','710       ',
     &'710       ','710       ','710       ','710       ',
     &'710       ','710       ','710       ','710       ',
     &'710       ','710       ','710       ','720       ',
     &'720       ','720       ','720       ','730       ',
     &'730       ','730       ','730       ','730       ',
     &'730       ','730       ','730       ','730       ',
     &'730       ','730       ','730       ','730       ',
     &'740       ','740       ','740       ','750       ',
     &'750       ','750       ','750       ','770       ',
     &'770       ','770       ','780       ','780       ',
     &'780       ','790       ','790       ','790       ',
     &'790       ','790       ','790       ','790       ',
     &'790       ','790       ','800       ','800       '/
      DATA (HABPVR(I),I= 601, 660)/
     &'800       ','810       ','810       ','810       ',
     &'820       ','820       ','820       ','830       ',
     &'830       ','830       ','830       ','830       ',
     &'830       ','830       ','830       ','830       ',
     &'830       ','840       ','840       ','840       ',
     &'840       ','840       ','840       ','840       ',
     &'840       ','840       ','840       ','850       ',
     &'850       ','850       ','850       ','860       ',
     &'860       ','860       ','860       ','870       ',
     &'870       ','870       ','890       ','890       ',
     &'890       ','900       ','900       ','900       ',
     &'900       ','910       ','910       ','910       ',
     &'920       ','920       ','920       ','920       ',
     &'925       ','925       ','925       ','930       ',
     &'930       ','930       ','940       ','940       '/
      DATA (HABPVR(I),I= 661, NCODES)/
     &'940       ','940       ','950       ','950       ',
     &'950       ','CAG112    ','CCF221    ','CCF222    ',
     &'CCS211    ','CCS311    ','CDG123    ','CDG131    ',
     &'CDG311    ','CDS632    ','CDS633    ','CDS715    ',
     &'CDS716    ','CDS813    ','CDS814    ','CEF111    ',
     &'CEF211    ','CEF421    ','CEF422    ','CEF423    ',
     &'CEG311    ','CEM211    ','CES210    ','CES211    ',
     &'CES313    ','CES412    ','CES422    ','CHF311    ',
     &'CHF312    ','CHF422    ','CHF521    ','CHS411    ',
     &'CHS711    ','CLS521    ','CWS214    ','CWS421    ',
     &'CWS422    ','CWS821    '/
      DATA (PVCODE(I),I=   1,  60)/
     &'000       ','000       ','010       ','10        ',
     &'010       ','040       ','040       ','050       ',
     &'050       ','051       ','051       ','052       ',
     &'052       ','070       ','070       ','090       ',
     &'091       ','092       ','093       ','094       ',
     &'095       ','100       ','100       ','100       ',
     &'100       ','110       ','110       ','110       ',
     &'120       ','120       ','130       ','130       ',
     &'130       ','130       ','140       ','140       ',
     &'140       ','140       ','141       ','141       ',
     &'141       ','142       ','142       ','142       ',
     &'150       ','160       ','160       ','160       ',
     &'161       ','161       ','161       ','162       ',
     &'162       ','162       ','170       ','170       ',
     &'170       ','170       ','171       ','171       '/
      DATA (PVCODE(I),I=  61, 120)/
     &'171       ','172       ','172       ','172       ',
     &'180       ','180       ','180       ','181       ',
     &'181       ','181       ','182       ','182       ',
     &'182       ','190       ','190       ','190       ',
     &'200       ','200       ','200       ','200       ',
     &'210       ','210       ','210       ','210       ',
     &'220       ','220       ','220       ','220       ',
     &'230       ','230       ','230       ','250       ',
     &'250       ','250       ','250       ','260       ',
     &'260       ','260       ','260       ','261       ',
     &'261       ','261       ','261       ','262       ',
     &'262       ','262       ','263       ','263       ',
     &'263       ','280       ','280       ','280       ',
     &'280       ','281       ','281       ','281       ',
     &'282       ','282       ','282       ','283       '/
      DATA (PVCODE(I),I= 121, 180)/
     &'283       ','283       ','290       ','290       ',
     &'290       ','291       ','291       ','291       ',
     &'292       ','292       ','292       ','293       ',
     &'293       ','293       ','310       ','310       ',
     &'310       ','310       ','311       ','311       ',
     &'311       ','312       ','312       ','312       ',
     &'313       ','313       ','313       ','320       ',
     &'320       ','320       ','320       ','321       ',
     &'321       ','321       ','322       ','322       ',
     &'322       ','322       ','323       ','323       ',
     &'323       ','323       ','324       ','324       ',
     &'324       ','325       ','330       ','330       ',
     &'330       ','330       ','340       ','340       ',
     &'340       ','340       ','350       ','350       ',
     &'350       ','360       ','360       ','360       '/
      DATA (PVCODE(I),I= 181, 240)/
     &'365       ','365       ','365       ','370       ',
     &'370       ','370       ','380       ','380       ',
     &'380       ','400       ','400       ','400       ',
     &'410       ','410       ','410       ','420       ',
     &'420       ','420       ','421       ','421       ',
     &'421       ','422       ','422       ','422       ',
     &'430       ','430       ','430       ','440       ',
     &'440       ','440       ','450       ','450       ',
     &'450       ','460       ','460       ','460       ',
     &'461       ','461       ','461       ','462       ',
     &'462       ','462       ','470       ','470       ',
     &'470       ','480       ','480       ','480       ',
     &'500       ','500       ','500       ','500       ',
     &'501       ','501       ','501       ','501       ',
     &'502       ','502       ','502       ','502       '/
      DATA (PVCODE(I),I= 241, 300)/
     &'505       ','505       ','505       ','506       ',
     &'506       ','506       ','507       ','507       ',
     &'507       ','508       ','508       ','508       ',
     &'510       ','510       ','510       ','510       ',
     &'511       ','511       ','511       ','512       ',
     &'512       ','512       ','515       ','515       ',
     &'515       ','516       ','516       ','516       ',
     &'517       ','517       ','517       ','518       ',
     &'518       ','518       ','519       ','519       ',
     &'519       ','520       ','520       ','520       ',
     &'520       ','521       ','521       ','521       ',
     &'521       ','522       ','522       ','522       ',
     &'523       ','523       ','523       ','523       ',
     &'524       ','524       ','524       ','525       ',
     &'525       ','525       ','526       ','526       '/
      DATA (PVCODE(I),I= 301, 360)/
     &'526       ','529       ','529       ','529       ',
     &'530       ','530       ','530       ','530       ',
     &'531       ','531       ','531       ','531       ',
     &'532       ','532       ','532       ','533       ',
     &'533       ','533       ','533       ','534       ',
     &'534       ','534       ','535       ','535       ',
     &'535       ','540       ','540       ','540       ',
     &'541       ','541       ','541       ','542       ',
     &'542       ','542       ','545       ','545       ',
     &'545       ','546       ','546       ','546       ',
     &'547       ','547       ','547       ','548       ',
     &'548       ','548       ','550       ','550       ',
     &'550       ','550       ','555       ','555       ',
     &'555       ','560       ','560       ','560       ',
     &'565       ','565       ','565       ','570       '/
      DATA (PVCODE(I),I= 361, 420)/
     &'570       ','570       ','570       ','571       ',
     &'571       ','571       ','571       ','572       ',
     &'572       ','572       ','572       ','573       ',
     &'573       ','573       ','574       ','574       ',
     &'574       ','575       ','575       ','575       ',
     &'576       ','576       ','576       ','577       ',
     &'577       ','577       ','578       ','578       ',
     &'578       ','579       ','579       ','579       ',
     &'590       ','590       ','590       ','590       ',
     &'591       ','591       ','591       ','591       ',
     &'592       ','592       ','592       ','592       ',
     &'600       ','600       ','600       ','600       ',
     &'610       ','610       ','610       ','620       ',
     &'620       ','620       ','620       ','621       ',
     &'621       ','621       ','621       ','622       '/
      DATA (PVCODE(I),I= 421, 480)/
     &'622       ','622       ','623       ','623       ',
     &'623       ','624       ','624       ','624       ',
     &'624       ','625       ','625       ','625       ',
     &'625       ','630       ','630       ','630       ',
     &'635       ','635       ','635       ','636       ',
     &'636       ','636       ','637       ','637       ',
     &'637       ','640       ','640       ','640       ',
     &'640       ','650       ','650       ','650       ',
     &'650       ','651       ','651       ','651       ',
     &'651       ','652       ','652       ','652       ',
     &'653       ','653       ','653       ','654       ',
     &'654       ','654       ','654       ','655       ',
     &'655       ','655       ','660       ','660       ',
     &'660       ','661       ','661       ','661       ',
     &'662       ','662       ','662       ','663       '/
      DATA (PVCODE(I),I= 481, 540)/
     &'663       ','663       ','670       ','670       ',
     &'670       ','670       ','671       ','671       ',
     &'671       ','672       ','672       ','672       ',
     &'673       ','673       ','673       ','674       ',
     &'674       ','674       ','675       ','675       ',
     &'675       ','676       ','676       ','676       ',
     &'677       ','677       ','677       ','680       ',
     &'680       ','680       ','680       ','681       ',
     &'681       ','681       ','682       ','682       ',
     &'682       ','685       ','685       ','685       ',
     &'686       ','686       ','686       ','687       ',
     &'690       ','690       ','690       ','690       ',
     &'691       ','691       ','691       ','691       ',
     &'692       ','692       ','692       ','692       ',
     &'693       ','693       ','693       ','694       '/
      DATA (PVCODE(I),I= 541, 600)/
     &'694       ','694       ','700       ','700       ',
     &'700       ','701       ','710       ','710       ',
     &'710       ','710       ','711       ','711       ',
     &'711       ','712       ','712       ','712       ',
     &'713       ','713       ','713       ','720       ',
     &'720       ','720       ','720       ','730       ',
     &'730       ','730       ','730       ','731       ',
     &'731       ','731       ','732       ','732       ',
     &'732       ','733       ','733       ','733       ',
     &'740       ','740       ','740       ','750       ',
     &'750       ','750       ','750       ','770       ',
     &'770       ','770       ','780       ','780       ',
     &'780       ','790       ','790       ','790       ',
     &'791       ','791       ','791       ','792       ',
     &'792       ','792       ','800       ','800       '/
      DATA (PVCODE(I),I= 601, 660)/
     &'800       ','810       ','810       ','810       ',
     &'820       ','820       ','820       ','830       ',
     &'830       ','830       ','830       ','831       ',
     &'831       ','831       ','832       ','832       ',
     &'832       ','840       ','840       ','840       ',
     &'840       ','841       ','841       ','841       ',
     &'842       ','842       ','842       ','850       ',
     &'850       ','850       ','850       ','860       ',
     &'860       ','860       ','860       ','870       ',
     &'870       ','870       ','890       ','890       ',
     &'890       ','900       ','900       ','900       ',
     &'900       ','910       ','910       ','910       ',
     &'920       ','920       ','920       ','920       ',
     &'925       ','925       ','925       ','930       ',
     &'930       ','930       ','940       ','940       '/
      DATA (PVCODE(I),I= 661, NCODES)/
     &'940       ','940       ','950       ','950       ',
     &'950       ','CAG112    ','CCF221    ','CCF222    ',
     &'CCS211    ','CCS311    ','CDG123    ','CDG131    ',
     &'CDG311    ','CDS632    ','CDS633    ','CDS715    ',
     &'CDS716    ','CDS813    ','CDS814    ','CEF111    ',
     &'CEF211    ','CEF421    ','CEF422    ','CEF423    ',
     &'CEG311    ','CEM211    ','CES210    ','CES211    ',
     &'CES313    ','CES412    ','CES422    ','CHF311    ',
     &'CHF312    ','CHF422    ','CHF521    ','CHS411    ',
     &'CHS711    ','CLS521    ','CWS214    ','CWS421    ',
     &'CWS422    ','CWS821    '/
      DATA (PVREF(I),I=   1,  60)/
     &'101       ','111       ','101       ','110       ',
     &'199       ','101       ','111       ','101       ',
     &'111       ','101       ','111       ','101       ',
     &'111       ','101       ','111       ','199       ',
     &'199       ','199       ','199       ','199       ',
     &'199       ','101       ','110       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'111       ','199       ','101       ','110       ',
     &'111       ','199       ','101       ','110       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','110       ',
     &'111       ','199       ','101       ','111       '/
      DATA (PVREF(I),I=  61, 120)/
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','101       ','110       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       '/
      DATA (PVREF(I),I= 121, 180)/
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','110       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','110       ',
     &'111       ','199       ','101       ','110       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','199       ','101       ','110       ',
     &'111       ','199       ','101       ','110       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','111       ','199       '/
      DATA (PVREF(I),I= 181, 240)/
     &'101       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       '/
      DATA (PVREF(I),I= 241, 300)/
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','101       ','110       ','111       ',
     &'199       ','101       ','110       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','110       ','111       '/
      DATA (PVREF(I),I= 301, 360)/
     &'199       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','101       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','101       '/
      DATA (PVREF(I),I= 361, 420)/
     &'110       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       '/
      DATA (PVREF(I),I= 421, 480)/
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','110       ','111       ',
     &'199       ','101       ','110       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','101       ','110       ','111       ',
     &'199       ','101       ','110       ','111       ',
     &'199       ','101       ','110       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       '/
      DATA (PVREF(I),I= 481, 540)/
     &'111       ','199       ','101       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','110       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','110       '/
      DATA (PVREF(I),I= 541, 600)/
     &'111       ','199       ','101       ','111       ',
     &'199       ','110       ','101       ','110       ',
     &'111       ','199       ','110       ','111       ',
     &'199       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','111       '/
      DATA (PVREF(I),I= 601, 660)/
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','110       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       ',
     &'110       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','111       ',
     &'199       ','101       ','110       ','111       ',
     &'199       ','101       ','111       ','199       ',
     &'101       ','110       ','111       ','199       ',
     &'110       ','111       ','199       ','101       ',
     &'111       ','199       ','101       ','110       '/
      DATA (PVREF(I),I= 661, NCODES)/
     &'111       ','199       ','101       ','111       ',
     &'199       ','627       ','627       ','627       ',
     &'627       ','627       ','627       ','627       ',
     &'627       ','627       ','627       ','627       ',
     &'627       ','627       ','627       ','627       ',
     &'627       ','627       ','627       ','627       ',
     &'627       ','627       ','627       ','627       ',
     &'627       ','627       ','627       ','627       ',
     &'627       ','627       ','627       ','627       ',
     &'627       ','627       ','627       ','627       ',
     &'627       ','627       '/
C----------
C  MAP PV/REFERENCE CODES INTO A FVS HABITAT/ECOCLASS CODE
C  REMOVE DECIMAL FROM KARD2 IF PRESENT
C----------
      DO I= 10, 1, -1
        IF (KARD2(I:I) .EQ. '.') THEN
          KARD2=KARD2
          KARD2(I:)=' '    
          GO TO 10
        END IF
      END DO
   10 CONTINUE
      KODTYP=0
      KARD2T=KARD2
      KARD2='          '
C
      DO I=1,NCODES
      IF((ADJUSTL(PVCODE(I)).EQ.ADJUSTL(KARD2T)).AND.(ADJUSTL(PVREF(I))
     &   .EQ.ADJUSTL(CPVREF)))THEN
        IF(I2-I1.EQ.5)THEN
           KARD2=HABPVR(I)
           ARRAY2=0.
        ELSE
          READ(HABPVR(I),'(A4)') KARD2
          READ(HABPVR(I),'(F10.0)')ARRAY2
          READ(HABPVR(I),'(I4)')KODTYP
        ENDIF
        LPVCOD=.TRUE.
        LPVREF=.TRUE.
        EXIT
      ENDIF
      IF(ADJUSTL(PVCODE(I)).EQ.ADJUSTL(KARD2T))LPVCOD=.TRUE.
      IF(ADJUSTL(PVREF(I)).EQ.ADJUSTL(CPVREF))LPVREF=.TRUE.
      ENDDO
C
      RETURN
      END











