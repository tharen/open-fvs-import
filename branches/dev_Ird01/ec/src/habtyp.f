      SUBROUTINE HABTYP (KARD2,ARRAY2)
      IMPLICIT NONE
C----------
C  **HABTYP--EC   DATE OF LAST REVISION:  05/02/12
C----------
C
C     TRANSLATES HABITAT TYPE  CODE INTO A SUBSCRIPT, ITYPE, AND IF
C     KODTYP IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
COMMONS
C----------
      INTEGER NPA
      PARAMETER (NPA=155)
      LOGICAL DEBUG
      LOGICAL LPVCOD,LPVREF,LPVXXX
      CHARACTER*10 KARD2
      CHARACTER*8 PCOML(NPA)
      INTEGER IHB,I
      REAL ARRAY2
C
C----------
      DATA (PCOML(I),I=1,75)/
C 1-25
     &'CAG112  ', 'CAS311  ', 'CCF211  ', 'CCF212  ', 'CCF221  ',
     &'CCF222  ', 'CCS211  ', 'CCS311  ', 'CDF411  ', 'CDG123  ',
     &'CDG131  ', 'CDG132  ', 'CDG134  ', 'CDG141  ', 'CDG311  ',
     &'CDG321  ', 'CDG322  ', 'CDG323  ', 'CDS231  ', 'CDS241  ',
     &'CDS411  ', 'CDS412  ', 'CDS631  ', 'CDS632  ', 'CDS633  ',
C 26-50
     &'CDS636  ', 'CDS637  ', 'CDS638  ', 'CDS639  ', 'CDS640  ',
     &'CDS653  ', 'CDS654  ', 'CDS655  ', 'CDS661  ', 'CDS662  ',
     &'CDS673  ', 'CDS674  ', 'CDS675  ', 'CDS715  ', 'CDS716  ',
     &'CDS811  ', 'CDS813  ', 'CDS814  ', 'CDS831  ', 'CDS832  ',
     &'CDS833  ', 'CEF111  ', 'CEF211  ', 'CEF222  ', 'CEF421  ',
C 51-75
     &'CEF422  ', 'CEF423  ', 'CEF424  ', 'CEG121  ', 'CEG310  ',
     &'CEG311  ', 'CEM211  ', 'CES111  ', 'CES113  ', 'CES210  ',
     &'CES211  ', 'CES213  ', 'CES312  ', 'CES313  ', 'CES342  ',
     &'CES412  ', 'CES413  ', 'CES422  ', 'CES423  ', 'CES424  ',
     &'CES425  ', 'CES426  ', 'CFF162  ', 'CFF254  ', 'CFS232  '/
      DATA (PCOML(I),I=76,150)/
C 76-100
     &'CFS233  ', 'CFS234  ', 'CFS542  ', 'CFS553  ', 'CFS556  ',
     &'CFS558  ', 'CFS621  ', 'CHC311  ', 'CHF223  ', 'CHF311  ',
     &'CHF312  ', 'CHF313  ', 'CHF422  ', 'CHF521  ', 'CHS142  ',
     &'CHS143  ', 'CHS144  ', 'CHS225  ', 'CHS226  ', 'CHS227  ',
     &'CHS411  ', 'CHS711  ', 'CLS521  ', 'CMF131  ', 'CMG221  ',
C 101-125
     &'CMS121  ', 'CMS122  ', 'CMS256  ', 'CMS257  ', 'CMS258  ',
     &'CMS259  ', 'CMS354  ', 'CMS355  ', 'CMS356  ', 'CPG141  ',
     &'CPG231  ', 'CPH211  ', 'CPH212  ', 'CPS241  ', 'CWC511  ',
     &'CWF321  ', 'CWF444  ', 'CWF521  ', 'CWF522  ', 'CWF523  ',
     &'CWF524  ', 'CWG121  ', 'CWG122  ', 'CWG123  ', 'CWG124  ',
C 126-150
     &'CWG125  ', 'CWS214  ', 'CWS221  ', 'CWS222  ', 'CWS223  ',
     &'CWS224  ', 'CWS225  ', 'CWS226  ', 'CWS331  ', 'CWS332  ',
     &'CWS335  ', 'CWS336  ', 'CWS337  ', 'CWS338  ', 'CWS421  ',
     &'CWS422  ', 'CWS531  ', 'CWS532  ', 'CWS533  ', 'CWS534  ',
     &'CWS535  ', 'CWS536  ', 'CWS537  ', 'CWS551  ', 'CWS552  '/
      DATA (PCOML(I),I=151,155)/
C 151-155
     &'CWS553  ', 'CWS554  ', 'CWS821  ', 'HQG111  ', 'HQS211  '/
C
      LPVREF=.FALSE.
      LPVCOD=.FALSE.
      LPVXXX=.FALSE.
C----------
C  IF REFERENCE CODE IS NON-ZERO THEN MAP PV CODE/REF. CODE TO
C  FVS HABITAT TYPE/ECOCLASS CODE. THEN PROCESS FVS CODE
C----------
      IF(CPVREF.NE.'          ') THEN
        CALL PVREF6(KARD2,ARRAY2,LPVCOD,LPVREF)
        ICL5=0
        IF((LPVCOD.AND.LPVREF).AND.
     &      (KARD2.EQ.'          '))THEN
          CALL ERRGRO(.TRUE.,34)
          ITYPE=114
          LPVXXX=.TRUE.
          GO TO 30
        ELSEIF((.NOT.LPVCOD).AND.(.NOT.LPVREF))THEN
          CALL ERRGRO(.TRUE.,33)
          CALL ERRGRO(.TRUE.,32)
          ITYPE=114
          LPVXXX=.TRUE.
          GO TO 30
        ELSEIF((.NOT.LPVREF).AND.LPVCOD)THEN
          CALL ERRGRO(.TRUE.,32)
          ITYPE=114
          LPVXXX=.TRUE.
          GO TO 30
        ELSEIF((.NOT.LPVCOD).AND.LPVREF)THEN
          CALL ERRGRO(.TRUE.,33)
          ITYPE=114
          LPVXXX=.TRUE.
          GO TO 30
        ENDIF
       ENDIF
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HABTYP',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,*)
     &'ENTERING HABTYP CYCLE,KODTYP,KODFOR,KARD2,ARRAY2= ',
     &ICYC,KODTYP,KODFOR,KARD2,ARRAY2
C----------
C  DECODE HABITAT TYPE/PLANT ASSOCIATION FIELD.
C----------
      CALL HBDECD (KODTYP,PCOML(1),NPA,ARRAY2,KARD2)
      IF(DEBUG)WRITE(JOSTND,*)'AFTER HAB DECODE,KODTYP= ',KODTYP
      IF (KODTYP .LE. 0) GO TO 20
C
      PCOM = PCOML(KODTYP)
      ITYPE=KODTYP
      IF(LSTART)WRITE(JOSTND,10) PCOM
   10 FORMAT(/,T12,'PLANT ASSOCIATION CODE USED IN THIS',
     &' PROJECTION IS ',A8)
      GO TO 40
C----------
C  NO MATCH WAS FOUND, TREAT IT AS A SEQUENCE NUMBER.
C----------
   20 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)'EXAMINING FOR INDEX, ARRAY2= ',ARRAY2
      IHB = IFIX(ARRAY2)
      IF(IHB.GT.0 .AND. IHB.LE.NPA)THEN
        KODTYP=IHB
        ITYPE=IHB
        PCOM = PCOML(KODTYP)
        GO TO 40
      ELSE
C----------
C  DEFAULT CONDITIONS --- PA = CPS241   SITE SPECIES=PP   SITE INDEX=75
C----------
        ITYPE=114
        GO TO 30
      ENDIF
C
   30 CONTINUE
      IF(.NOT.LPVXXX)CALL ERRGRO(.TRUE.,14)
      KODTYP=ITYPE
      PCOM = PCOML(KODTYP)
      IF(LSTART)WRITE(JOSTND,10) PCOM
C
   40 CONTINUE
      ICL5=KODTYP
      KARD2=PCOM
C
      IF(DEBUG)WRITE(JOSTND,*)'LEAVING HABTYP KODTYP,ITYPE,ICL5,KARD2',
     &' PCOM =',KODTYP,ITYPE,ICL5,KARD2,PCOM
C
      RETURN
      END