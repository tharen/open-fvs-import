      SUBROUTINE SVKEY(KEYWRD,LNOTBK,ARRAY)
      IMPLICIT NONE
C----------
C  $Id: svkey.f 1004 2013-08-01 16:04:44Z rhavis@msn.com $
C----------
C
C     STAND VISUALIZATION GENERATION
C     N.L.CROOKSTON -- RMRS MOSCOW -- NOVEMBER 1998
C     D. ROBINSON   -- ESSA        -- MAY 2005
C     S.SCHAROSCH   -- Abacus      -- MAR 2008
C
C     PROCESS VISUALZATION KEYWORD.
C
C     ALL ARGUMENTS ARE INPUT, STD FROM INITRE
C
COMMONS

      INCLUDE 'PRGPRM.F77'

      INCLUDE 'CONTRL.F77'

      INCLUDE 'SVDATA.F77'

COMMONS

      LOGICAL LNOTBK(7),LOPEN
      REAL ARRAY(7)
      CHARACTER*8 KEYWRD
      CHARACTER*10 SUFFIX
      INTEGER KODE,ISTLNB

      IF (LNOTBK(1)) IPLGEM=IFIX(ARRAY(1))
      IF (IPLGEM.LT.0 .OR. IPLGEM.GT.3) IPLGEM=1

      IF (LNOTBK(2)) IGRID = INT(ARRAY(2))
      IF (IGRID.GT.256) IGRID=256
      IF (IGRID.LT.0) IGRID=0

      IF (LNOTBK(7)) JSVOUT = -1

      IF (LNOTBK(5)) ICOLIDX = INT(ARRAY(5))
      IF (ICOLIDX.GT.20) ICOLIDX=20

C     Allow negative color index to pass through.
C     Will be interpreted in SVGRND as a request for
C     a uniform ground surface of the indicated color.

C>>>      IF (ICOLIDX.LT.0) ICOLIDX=2

      WRITE (JOSTND,10) KEYWRD,IPLGEM,IGRID
   10 FORMAT (/A8,'   PRODUCE SVS-READY DATA'/T12,
     >  'PLOT GEOMETRY CODE = ',I2,
     >  ' (0=SQUARE, IGNORE POINTS; 1=SUBDIVIDED SQUARE; ',
     >    '2=ROUND, IGNORE POINTS; 3=SUBDIVIDED CIRCLE)'/T12,
     >  'GROUND FILE GRID RESOLUTION (ZERO IMPLIES NO GROUND FILE)= ',
     >  I3)
      IRPOLES=IFIX(ARRAY(3))
      IF (IRPOLES.GT.1) IRPOLES=1
      IF (IRPOLES.LT.0) IRPOLES=0
      IDPLOTS=IFIX(ARRAY(4))
      IF (IDPLOTS.GT.1) IDPLOTS=1
      IF (IDPLOTS.LT.0) IDPLOTS=0
      IMETRIC=IFIX(ARRAY(6))
      IF (IMETRIC.GT.1) IMETRIC=1
      IF (IMETRIC.LT.0) IMETRIC=0

      IF (IRPOLES.EQ.0) THEN
        WRITE (JOSTND,15) 'RANGE POLES ARE NOT DRAWN.'
      ELSE
        WRITE (JOSTND,15) 'RANGE POLES ARE DRAWN.'
      ENDIF
      IF (IDPLOTS.EQ.0) THEN
        WRITE (JOSTND,15) 'SUBPLOT BOUNDARIES ARE NOT DRAWN.'
      ELSE
        WRITE (JOSTND,15) 'SUBPLOT BOUNDARIES ARE DRAWN.'
      ENDIF
      IF (IMETRIC.EQ.0) THEN
        WRITE (JOSTND,15) 'OUTPUT DATA ARE IMPERIAL.'
      ELSE
        WRITE (JOSTND,15) 'OUTPUT DATA ARE METRIC.'
      ENDIF
      WRITE (JOSTND,16) ICOLIDX
      IF (LNOTBK(7)) JSVOUT = -1
      IF (JSVOUT .LT. 0) WRITE (JOSTND,15) 
     >   'SVS RUNS BUT NO OUTPUT FILES ARE PRODUCED.' 
   

   15 FORMAT (T12,A)
   16 FORMAT (T12,'COLOR INDEX= ',I4)

      IF (JSVOUT.LT.0) RETURN
      
      JSVOUT=90
      inquire(unit=JSVOUT,opened=LOPEN)
      if (.not.LOPEN) then
        SUFFIX='_index.svs'
        open(unit=JSVOUT,file=trim(KWDFIL)//SUFFIX,
     >       status="replace",err=19)
        GOTO 21
   19   CONTINUE
        WRITE (JOSTND,20) trim(KWDFIL)//SUFFIX
   20   FORMAT (/T12,'**** FILE OPEN ERROR FOR FILE: ',A)
        CALL RCDSET (2,.TRUE.)
        JSVOUT=0
        RETURN
   21   CONTINUE
        WRITE (JSVOUT,'(''#TREELISTINDEX'')')
      ENDIF
      RETURN
      END
