      SUBROUTINE DFBIN (PASKEY,ARRAY,LNOTBK)
      IMPLICIT NONE
C----------
C  **DFBIN--CR   DATE OF LAST REVISION:  05/30/13
C----------
C
C  KEYWORD PROCESSOR FOR DOUGLAS-FIR BEETLE MODEL.
C
C  CALLED BY :
C     INITRE  [PROGNOSIS]
C
C  CALLS :
C     ERRGRO  (SUBROUTINE)   [PROGNOSIS]
C     FNDKEY  (SUBROUTINE)   [PROGNOSIS]
C     KEYRDR  (SUBROUTINE)   [PROGNOSIS]
C     DFBNSD  (ENTRY POINT)  [DFB (DFBRAN)]
C     OPNEW   (SUBROUTINE)   [PROGNOSIS]
C
C  ENTRY POINTS :
C     DFBKEY
C
C  PARAMETERS :
C     ARRAY  - ARRAY THAT HOLDS THE FIELDS READ IN WITH THE KEYWORD.
C     LNOTBK - LOGICAL ARRAY THAT HOLDS THE 'NOT BLANK' FLAGS FOR THE
C              FIELDS READ IN WITH THE KEYWORD.
C     PASKEY - THE KEYWORD READ IN BEFORE CALL TO THIS SUBROUTINE.
C
C  LOCAL VARIABLES :
C     I      - COUNTER INDEX.
C     IDT    - DATE THAT REGIONAL OUTBREAK IS SCHEDULED.
C     ISIZE  - THE SIZE OF THE KEYWORD TABLE.
C     KARD   - ARRAY THAT HOLDS THE CHARACTER REPRESENTATION OF THE
C              FIELDS READ IN WITH THE KEYWORD.
C     KEYWRD - KEYWORD READ IN.
C     KODE   - ERROR KODE RETURNED FROM KEYRDR, FNDKEY, AND OPNEW.
C     NUMBR  - HOLDS THE POSITION OF THE KEYWORD IN THE TABLE.
C     PNAME  - HOLDS THE NAME OF THE POST PROCESSOR OUTPUT FILE.
C     PRMS   - HOLDS PARAMETERS TO BE SENT TO THE EVENT MONITOR.
C     TABLE  - ARRAY THAT HOLDS THE TABLE OF DFB KEYWORDS.
C
C  COMMON BLOCK VARIABLES USED :
C     DBEVNT - (DFBCOM)  OUTPUT
C     DEBUIN - (DFBCOM)  OUTPUT
C     EPIPRB - (DFBCOM)  OUTPUT
C     EXPCTD - (DFBCOM)  OUTPUT
C     EXSTDV - (DFBCOM)  OUTPUT
C     IDBSCH - (DFBCOM)  OUTPUT
C     IDFBYR - (DFBCOM)  OUTPUT
C     IFVSSP - (DFBCOM)  OUTPUT
C     ILENTH - (DFBCOM)  OUTPUT
C     IPAST  - (DFBCOM)  OUTPUT
C     IREAD  - (CONTRL)  INPUT
C     IRECNT - (CONTRL)  OUTPUT
C     ISMETH - (DFBCOM)  OUTPUT
C     IWAIT  - (DFBCOM)  OUTPUT
C     IYOUT  - (DFBCOM)  OUTPUT
C     JODFB  - (DFBCOM)  OUTPUT
C     JODFBX - (DFBCOM)  OUTPUT
C     JOSTND - (CONTRL)  INPUT
C     KODTYP - (PLOT)    INPUT
C     LBAMOD - (DFBCOM)  OUTPUT
C     LDFBON - (DFBCOM)  OUTPUT
C     LEPI   - (DFBCOM)  OUTPUT
C     LINPRG - (DFBCOM)  OUTPUT
C     LINV   - (DFBCOM)  OUTPUT
C     MINDEN - (DFBCOM)  OUTPUT
C     ORSEED - (DFBCOM)  OUTPUT
C     PREKLL - (DFBCOM)  OUTPUT
C     PRPWIN - (DFBCOM)  OUTPUT
C
C Revision History:
C   26-SEP-2002 Lance R. David (FHTET)
C     Date of previous revision was 12/14/95.
C     Corrected error in WINDTHR keyword processing. The LNOTBK, PRMS and ARRAYS
C     index numbers were misaligned for fields 2 and 3.
C   10-NOV-2003 - Lance R. David (FHTET)
C     Added LFLAG to KEYRDR call statement argument list.
C
C---------------------------------
C
COMMONS
C
      INCLUDE 'PRGPRM.F77'

      INCLUDE 'CONTRL.F77'

      INCLUDE 'PLOT.F77'

      INCLUDE 'DFBCOM.F77'
C
COMMONS
C
      INTEGER IDT, KODE, ISIZE, I, NUMBR
      INTEGER KEY

      CHARACTER*8 PASKEY, TABLE(20), KEYWRD
      CHARACTER*10 KARD(7)
      CHARACTER*80 PNAME

      LOGICAL LNOTBK(7),LKECHO

      REAL ARRAY(7), PRMS(5)

      DATA ISIZE /20/

      DATA TABLE /
     &     'END','CUROUTBK','DEBUG','DFBECHO','MANSTART','RANSTART',
     &     'RANNSEED','RANSCHED','MANSCHED','WINDTHR','STOPROB',
     &     'NODEBUG','MORTDIS',' ','OLENGTH','EXYRMORT',4*' ' /

C
C     IFVSSP CAN BE MODIFIED FOR DIFFERENT VARIANTS OF FVS SO
C     THAT SPECIES MATCH BETWEEN FVS AND THE DOUGLAS-FIR BEETLE
C     MODEL.
C
C     FOR CENTRAL ROCKIES VARIANT (CR) SET THE SPECIES MAPPING
C     ARRAY IFVSSP BASED ON THE MODEL TYPE.  IN THE OTHER
C     VARIANTS OF FVS IFVSSP IS SET IN THE VARIANT DEPENDENT
C     SUBROUTINE DFBLKD.
C

      WRITE (JOSTND,5) KODTYP
    5 FORMAT(/8X,'   CENTRAL ROCKIES MODEL TYPE ',I1,' IS BEING USED ',
     &       'FOR THE DOUGLAS-FIR BEETLE MODEL.')

      IF (KODTYP .EQ. 1) THEN
C
C        SOUTHWEST MIXED CONIFER MODEL TYPE.
C
         IFVSSP(1)  =  1
         IFVSSP(2)  = 17
         IFVSSP(3)  =  3
         IFVSSP(4)  = 13
         IFVSSP(5)  = 18
         IFVSSP(6)  = 19
         IFVSSP(7)  = 20
         IFVSSP(8)  =  8
         IFVSSP(9)  =  9
         IFVSSP(10) = 10
         IFVSSP(11) = 33

      ELSEIF (KODTYP .EQ. 2) THEN
C
C        SOUTHWEST PONDEROSA PINE MODEL TYPE.
C
         IFVSSP(1)  =  1
         IFVSSP(2)  = 17
         IFVSSP(3)  =  3
         IFVSSP(4)  = 13
         IFVSSP(5)  = 18
         IFVSSP(6)  = 19
         IFVSSP(7)  = 20
         IFVSSP(8)  = 18
         IFVSSP(9)  = 33
         IFVSSP(10) = 10
         IFVSSP(11) = 26

      ELSEIF (KODTYP .EQ. 3) THEN
C
C        BLACK HILLS PONDEROSA PINE MODEL TYPE.
C
         IFVSSP(1)  = 24
         IFVSSP(2)  = 17
         IFVSSP(3)  =  3
         IFVSSP(4)  = 30
         IFVSSP(5)  = 18
         IFVSSP(6)  = 19
         IFVSSP(7)  =  7
         IFVSSP(8)  = 25
         IFVSSP(9)  = 30
         IFVSSP(10) = 10
         IFVSSP(11) = 26

      ELSEIF (KODTYP .EQ. 4) THEN
C
C        SPRUCE-FIR MODEL TYPE.
C
         IFVSSP(1)  = 30
         IFVSSP(2)  = 17
         IFVSSP(3)  =  3
         IFVSSP(4)  = 30
         IFVSSP(5)  = 18
         IFVSSP(6)  = 19
         IFVSSP(7)  =  7
         IFVSSP(8)  =  8
         IFVSSP(9)  =  9
         IFVSSP(10) = 30
         IFVSSP(11) = 30

      ELSEIF (KODTYP .EQ. 5) THEN
C
C        LODGEPOLE PINE MODEL TYPE.
C
         IFVSSP(1)  = 30
         IFVSSP(2)  = 17
         IFVSSP(3)  =  3
         IFVSSP(4)  = 30
         IFVSSP(5)  = 18
         IFVSSP(6)  = 19
         IFVSSP(7)  =  7
         IFVSSP(8)  =  8
         IFVSSP(9)  =  9
         IFVSSP(10) = 10
         IFVSSP(11) = 30

      ELSE
         WRITE (JOSTND,8)
    8    FORMAT (/'******** ERROR !!!   MODEL TYPE HAS NOT BEEN ',
     &           'SELECTED.  STDINFO KEYWORD IS REQUIRED BEFORE ',
     &           'DOUGLAS-FIR BEETLE KEYWORDS.')

         STOP 20

      ENDIF

      KEYWRD = PASKEY

   10 CONTINUE
C
C     GET THE NEXT KEYWORD.
C
      CALL KEYRDR (IREAD,JOSTND,DEBUIN,KEYWRD,LNOTBK,
     &             ARRAY,IRECNT,KODE,KARD,LFLAG,LKECHO)

C
C     RETURN KODES: 0=NO ERROR, 1=COLUMN 1 BLANK OR ANOTHER ERROR,
C                   2=EOF, LESS THAN ZERO...USE OF PARMS STATEMENT IS
C                   PRESENT.
C
      IF (KODE .NE. 0) THEN
         IF (KODE .EQ. 2) CALL ERRGRO(.FALSE.,2)
         CALL ERRGRO (.TRUE.,6)
         GOTO 10
      ENDIF

C
C     FIND THE KEYWORD IN THE KEYWORD TABLE.
C
      CALL FNDKEY (NUMBR,KEYWRD,TABLE,ISIZE,KODE,DEBUIN,JOSTND)
C
C     RETURN KODES 0=NO ERROR,1=KEYWORD NOT FOUND,2=MISSPELLING.
C
      IF (KODE .NE. 0) THEN
         IF (KODE .EQ. 1) CALL ERRGRO (.FALSE.,1)
         CALL ERRGRO (.TRUE.,5)
      ENDIF

C
C     SET FLAG. "DFB MODEL IS BEING USED"
C
      LDFBON  = .TRUE.

C
C     PROCESS OPTIONS
C
      GOTO  (1000,1200,1300,1400,1500,1600,1700,1800,1900,2000
     &      ,2100,2200,2300,2400,2500,2600),  NUMBR

 1000 CONTINUE
C
C  ====================  OPTION NUMBER 1  -- END  ===================
C
      WRITE (JOSTND,1010) KEYWRD
 1010 FORMAT (/A8,'   END OF DOUGLAS-FIR BEETLE OPTIONS.')

      RETURN

 1200 CONTINUE
C
C  ====================  OPTION NUMBER 2  -- CUROUTBK  ==============
C
      IF (LNOTBK(1)) THEN
C
C        OUTBREAK IN PROGRESS.
C
         IYOUT  = IFIX(ARRAY(1))
         LINPRG = .TRUE.

         IF (LNOTBK(2)) THEN
C
C           USER ENTERED THE MORTALITY FROM DFB.
C
            PREKLL = ARRAY(2)
            WRITE (JOSTND,1210) KEYWRD, IYOUT, IFIX(PREKLL)
 1210       FORMAT (/A8,'   YEAR IN OUTBREAK IS ',I2,'.',2X,I3,
     &             ' TREES/ACRE HAVE BEEN KILLED.')
         ELSE
C
C           THE MORTALITY FROM DFB WILL COME FROM THE TREE LIST.
C
            LINV = .TRUE.
            WRITE (JOSTND,1220) KEYWRD, IYOUT
 1220       FORMAT (/A8,'   YEAR IN OUTBREAK IS ',I2,'.  NUMBER ',
     &              'OF TREES/ACRE KILLED IS READ FROM TREE LIST.')
         ENDIF

      ENDIF

      GOTO 10

 1300 CONTINUE
C
C  ====================  OPTION NUMBER 3  -- DEBUG  =================
C
      WRITE (JOSTND,1310) KEYWRD
 1310 FORMAT (/A8,'   DOUGLAS-FIR BEETLE DEBUG ACTIVATED.')
      JODFB = JOSTND
      DEBUIN = .TRUE.
      GOTO 10

 1400 CONTINUE
C
C  ====================  OPTION NUMBER 4 -- DFBECHO  ===============
C

C
C     SET JODFBX TO THE UNIT NUMBER FOR THE POST PROCESSOR OUTPUT.
C
      JODFBX = 21

C
C     READ IN THE FILE NAME FROM THE SUPPLEMENTAL RECORD.
C
      READ (IREAD,1410) PNAME
 1410 FORMAT (A)
      IF (PNAME .EQ. ' ') PNAME = 'DFBOUT'

C
C     TRY TO OPEN THE FILE.
C
      CALL MYOPEN (JODFBX, PNAME, 1, 133, 0, 1, 1, 0, KODE)

C
C     PRINT OUT KEYWORD MESSAGE BASED ON IF THE FILE OPENS OR NOT.
C
      IF (KODE .EQ. 1) THEN
         WRITE (JOSTND,1420) KEYWRD, PNAME
 1420    FORMAT (/A8,'   POST PROCESSOR OUTPUT FILE ',A80,/,
     &           11X,'WAS NOT OPENED DUE TO AN ERROR!!!!')
         JODFBX = 0
      ELSE
         WRITE (JOSTND,1430) KEYWRD, PNAME
 1430    FORMAT (/A8,'   POST PROCESSOR OUTPUT FILE ',A80,/,
     &           11X,'WAS OPENED.')
      ENDIF

      GOTO 10

 1500 CONTINUE
C
C  ====================  OPTION NUMBER 5  -- MANSTART  ==============
C
C
      ISMETH = 1
      WRITE (JOSTND,1510) KEYWRD
 1510 FORMAT (/A8,'   STAND IS INCLUDED IN ALL REGIONAL OUTBREAKS.')
      GOTO 10

 1600 CONTINUE
C
C  ====================  OPTION NUMBER 6  -- RANSTART  ==============
C
      ISMETH = 2
      WRITE (JOSTND,1610) KEYWRD
 1610 FORMAT (/A8,'   STAND INCLUSION IN REGIONAL OUTBREAKS IS ',
     &   'STOCHASTICALLY DETERMINED.')
      GOTO 10

 1700 CONTINUE
C
C  ====================  OPTION NUMBER 7 -- RANNSEED  ===============
C

      ORSEED = ARRAY(1)
      CALL DFBNSD (LNOTBK(1), ORSEED)
      WRITE (JOSTND,1710) KEYWRD, ORSEED
 1710 FORMAT (/A8,'   RANDOM SEED IS:',F10.0)
      GOTO 10

 1800 CONTINUE
C
C  ====================  OPTION NUMBER 8 -- RANSCHED  ===============
C
      IDBSCH = 2
      IF (LNOTBK(1)) IWAIT  = IFIX(ARRAY(1))
      IF (LNOTBK(2)) DBEVNT = ARRAY(2)
      IF (LNOTBK(3)) IPAST  = IFIX(ARRAY(3))

      WRITE (JOSTND,1810) KEYWRD, IWAIT, DBEVNT, IPAST
 1810 FORMAT (/A8,'   REGIONAL OUTBREAKS AUTOMATICALLY ',
     &   'SCHEDULED.',/T12,'MINIMUM WAITING PERIOD IS ',I5,
     &   ' YEARS; EVENT PROBABILITY IS ',F6.3,/T12,'LAST RECORDED ',
     &   'DOUGLAS-FIR BEETLE OUTBREAK WAS IN YEAR: ',I5)
      GOTO 10

 1900 CONTINUE
C
C  ====================  OPTION NUMBER 9 -- MANSCHED  ===============
C
      IDT = 1
      IF (LNOTBK(1)) IDT = IFIX(ARRAY(1))
      IDBSCH = 1

C
C     CALL OPTION PROCESSOR AND SCHEDULE REGIONAL OUTBREAK.
C
      CALL OPNEW (KODE,IDT,2209,0,PRMS)
      IF (KODE .GT. 0) GOTO 10

      WRITE (JOSTND,1910) KEYWRD, IDT
 1910 FORMAT (/A8,'   DATE/CYCLE= ',I5,'; REGIONAL OUTBREAKS ',
     &   'SCHEDULED BY USER.')

C
C     KEEP TRACK OF OUTBREAKS SCHEDULED BY DATE.
C
      IF (IDT .GT. 40) THEN
         IDFBYR(41) = IDFBYR(41) + 1
         I = IDFBYR(41)
         IDFBYR(I) = IDT
      ENDIF

      GOTO 10

 2000 CONTINUE
C
C  ====================  OPTION NUMBER 10 -- WINDTHR  ===============
C

      IDT = 1
      IF (LNOTBK(1)) IDT = INT(ARRAY(1))

      PRMS(1) = PRPWIN
      PRMS(2) = MINDEN
      IF (LNOTBK(2)) PRMS(1) = ARRAY(2)
      IF (LNOTBK(3)) PRMS(2) = ARRAY(3)

C
C     CALL OPTION PROCESSOR AND SCHEDULE WINDTHROW.
C
      CALL OPNEW (KODE,IDT,2210,2,PRMS)
      IF (KODE .GT. 0) GOTO 10

      WRITE (JOSTND,2010) KEYWRD, IDT, PRMS(1), PRMS(2)
 2010 FORMAT(/A8,'   WINDTHROW EVENT TO BE ATTEMPTED IN DATE/CYCLE=',
     &            I4,';   PROPORTION TO WINDTHROW =',F4.2,
     &          /T12,'MINIMUM ELIGIBLE STEMS FOR EVENT =',F7.0)
      GOTO 10

 2100 CONTINUE
C
C  ====================  OPTION NUMBER 11 -- STOPROB  ===============
C
      IF (ARRAY(1) .LT. 0.0 .OR. ARRAY(1) .GT. 1.0) GOTO 10

      IF (LNOTBK(1)) THEN
C
C        USER SET THE PROBABILITY OF THIS STAND BEING INCLUDED IN A
C        REGIONAL OUTBREAK.
C
         LEPI = .TRUE.
         EPIPRB = ARRAY(1)
         WRITE (JOSTND,2110) KEYWRD, EPIPRB
 2110    FORMAT (/A8,'   SPECIFIED OUTBREAK PROBABILITY = ',F11.3)
      ELSE
C
C        MODEL WILL CALCULATE PROBABILITY OF THIS STAND BEING INCLUDED
C        IN A REGIONAL OUTBREAK.
C
         WRITE (JOSTND,2120) KEYWRD
 2120    FORMAT (/A8,'   KEYWORD IGNORED!!!  PROBABILITY WILL BE '
     &           'CALCULATED.')
      ENDIF
      GOTO 10

 2200 CONTINUE
C
C  ====================  OPTION NUMBER 12 -- NODEBUG  ===============
C
      WRITE (JOSTND,2210) KEYWRD
 2210 FORMAT (/A8,'   TURN OFF DEBUG OUTPUT.')
      DEBUIN = .FALSE.
      GOTO 10

 2300 CONTINUE
C
C  ====================  OPTION NUMBER 13 -- MORTDIS  ===============
C
      LBAMOD = .TRUE.

      WRITE (JOSTND,2310) KEYWRD
 2310 FORMAT (/A8,'   THE BASAL AREA METHOD IS USED FOR THE ',
     &        'MORTALITY DISTRIBUTION.')

      GOTO 10

 2400 CONTINUE
C
C  ====================  OPTION NUMBER 14 --          ===============
C
      GOTO 10

 2500 CONTINUE
C
C  ====================  OPTION NUMBER 15 -- OLENGTH  ===============
C
      IF (ARRAY(1) .GE. 1.0 .AND. ARRAY(1) .LE. 10.0)
     &   ILENTH = IFIX (ARRAY(1))
      WRITE (JOSTND,2510) KEYWRD, ILENTH
 2510 FORMAT (/A8,'   LENGTH OF DFB OUTBREAK  = ',I4)
      GOTO 10

 2600 CONTINUE
C
C  ====================  OPTION NUMBER 16 -- EXYRMORT  ==============
C
      IF (LNOTBK(1)) EXPCTD = ARRAY(1)
      IF (LNOTBK(2)) EXSTDV = ARRAY(2)

      WRITE (JOSTND,2610) KEYWRD, EXPCTD, EXSTDV
 2610 FORMAT (/A8,'   AVERAGE NUMBER OF DOUGLAS-FIR TREES EXPECTED ',
     &       'TO BE KILLED BY THE DFB EACH YEAR OF AN OUTBREAK = ',
     &       F5.1,/,8X,'   STANDARD DEVIATION USED IN RANDOM ',
     &       'CALCULATION OF NUMBER THAT WILL BE KILLED = ',F5.1)
      GOTO 10



      ENTRY DFBKEY (KEY,PASKEY)
C
C     ENTRY POINT
C
C     PARAMETERS :
C        KEY    - POSITION OF KEYWORD IN TABLE (INPUT).
C        PASKEY - KEYWORD TO BE RETURNED (OUTPUT).
C
      PASKEY=TABLE(KEY)

      RETURN
      END
