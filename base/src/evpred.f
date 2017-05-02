      SUBROUTINE EVPRED
      IMPLICIT NONE
C----------
C  $Id: evpred.f 1640 2015-12-10 23:30:14Z rhavis $
C----------
C  THIS SUBROUTINE COMPUTES VALUES OF PRE-DEFINED EVENT MONITOR 
C  VARIABLES, WHERE THE COMPUTATION IS VERY INVOLVED.
C
C  THIS ROUTINE IS CALLED FROM **EVTSTV**.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C----------
      INTEGER I,ISPC,INDEX(MAXTRE),ISRTI
      REAL FINDX,TEMP,CCPCT,BASM,ADHW,DMAX,DSNMAX,D,SUMTPA,P
      REAL X1,X2,X3,X4,X5,SUMPIN,HTMAX
      LOGICAL DEBUG,LFIRE2
      CHARACTER VVER*7
C
C
C
      ENTRY FISHER (FINDX)
C----------
C  THIS ENTRY COMPUTES A VALUE FOR THE FISHER RESTING HABITAT
C  SUITABILITY
C
C  REF: ZIELINSKI, WILLIAM J.; TRUEX, RICHARD L.; DUNK, JEFFREY R.;
C       GAMAN, TOM. 2006. USING FOREST INVENTORY DATA TO ASSESS FISHER
C       RESTING HABITAT SUITABILITY IN CALIFORNIA. ECOLOGICAL
C       APPLICATIONS 16(3). PP 1010-1025.
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'FISHER',6,ICYC)
      IF(DEBUG)WRITE(JOSTND,10)ICYC
   10 FORMAT(' ENTERING SUBROUTINE EVPDEF, ENTRY FISHER, CYCLE =',I4)
C----------
C  INITIALIZE VARIABLES.
C----------
      TEMP = 0.
      FINDX = 0.
      BASM = 0.
      CCPCT = 0.
      ADHW = 0.
      DMAX = 0.
      DSNMAX = 0.
C----------
C  IF FIRE MODEL IS NOT ACTIVE, FOR SNAG PROCESSING, RETURN A ZERO.
C----------
      CALL FMATV(LFIRE2)
      IF(.NOT. LFIRE2)GO TO 500
C----------
C  THIS IS CURRENTLY ONLY ALLOWED IN THE CALIFORNIA VARIANTS AND
C  ONLY FOR R5 FORESTS (I.E. BASED ON R5 CROWN WIDTH EQNS).
C----------  
      CALL VARVER(VVER)
      IF(VVER(:2).EQ.'NC' .AND. IFOR.NE.4 .AND. IFOR.NE.5)THEN
        GO TO 20
      ELSEIF((VVER(:2).EQ.'CA'.OR.VVER(:2).EQ.'OC').AND.IFOR.LT.6)THEN
        GO TO 20
      ELSEIF(VVER(:2).EQ.'SO' .AND. (IFOR.GT.3 .AND. IFOR.LT.10))THEN
        GO TO 20
      ELSEIF(VVER(:2).EQ.'WS')THEN
        GO TO 20
      ELSE
        GO TO 500
      ENDIF
   20 CONTINUE
      IF(ITRN .LE. 0) GO TO 500
C----------
C  CANOPY COVER PERCENT IS ONLY FOR PREDOMINANT, DOMINANT, AND CODOMINENT
C  TREES. PROXY THIS BY TAKING ALL TREES WHICH ARE AT LEAST AS TALL AS
C  50% OF THE HEIGHT OF THE 90TH %-TILE TREE IN THE HEIGHT DISTRIBUTION
C
C  EXCLUDE TREES WITH CROWN RATIO LESS THAN 30% FROM THE CALCULATION. 
C  EXCLUDE TREES WITH DBH LT 1" FROM THE CALCULATION
C  FIRST SORT BY HT. NEXT LOOP THROUGH THE TREES AND COMPUTE PERCENT
C  CANOPY COVER.
C----------
      DO 25 I=1,MAXTRE
      IF(I .LE. ITRN)THEN
        INDEX(I)=I
      ELSE
        INDEX(I)=0
      ENDIF
   25 CONTINUE
      CALL RDPSRT(ITRN,HT,INDEX,.FALSE.)
      IF(DEBUG)WRITE(JOSTND,*)' INDEX = ',(INDEX(I),I=1,ITRN)
C
      SUMPIN = 0.
      HTMAX = 0.
      DO 30 I=1,ITRN
      ISRTI = INDEX(I)
      P = PROB(ISRTI)
      IF(DEBUG)WRITE(JOSTND,*)' IN FISHER CCPCT1, SUMPIN,ISRTI,P,HT,HTMA 
     &X,TPROB= ',SUMPIN,ISRTI,P,HT(ISRTI),HTMAX,TPROB
      IF(DBH(ISRTI) .LT. 1.) GOTO 30
      IF(ICR(ISRTI) .LT. 31) GOTO 30
      IF(HT(ISRTI) .GE. HTMAX)THEN
        CCPCT=CCPCT + P*CRWDTH(ISRTI)**2.0
        SUMPIN = SUMPIN + P
        IF(DEBUG)WRITE(JOSTND,*)' ISRTI,P,CRWDTH,CCPCT,SUMPIN= ',
     &  ISRTI,P,CRWDTH(ISRTI),CCPCT,SUMPIN  
      ENDIF
      IF(SUMPIN.GT.TPROB*0.10 .AND. HTMAX.EQ.0.)HTMAX = HT(ISRTI)*.50
   30 CONTINUE
      CCPCT = 100.0*CCPCT*0.785398/43560.
C----------
C  LOOP THROUGH TREES AND CALCULATE:
C  1) BASAL AREA IN SMALL TREES, 5-51 CENTIMETERS DBH 
C     (BASM: SQUARE METERS/HA)
C  2) PERCENT CROWN COVER OF DOMINANT AND CODOMINANT TREES
C     (CCPCT: PERCENT, ALLOW FOR OVERLAP)
C  3) ARITHMETIC AVERAGE DIAMETER OF ALL HARDWOODS
C     (ADHW: CENTIMETERS)
C  4) DIAMETER OF THE LARGEST LIVE TREE IN THE STAND 
C     (DMAX: CENTIMETERS)
C  5) DIAMETER OF THE LARGEST CONIFER SNAG IN THE STAND
C     (DSNMAX: CENTIMETERS)
C----------
      DO 90 I=1,ITRN
      ISPC = ISP(I)
      D = DBH(I)
      P = PROB(I)
      IF(D .GT. DMAX)DMAX=D
C
C     NOTE: IN THE DIAMETER SCREEN BELOW, WE ARE USING 5" AS THE LOWER 
C           LIMIT INSTEAD OF 5 CM (1.9685") TO BE CONSISTENT WITH THE
C           WAY ANDREW GRAY (PNW-FIA) SAYS IT NEEDS TO BE CALCULATED
C           WHICH IS CONTRARY TO THE PUBLICATION. THIS MAY NEED TO BE
C           CHANGED.
C     IF(D.GE.1.9685 .AND. D.LT.20.0787)THEN
C
      IF(D.GE.5.0 .AND. D.LT.20.0787)THEN
        BASM = BASM + 0.0054542*P*D*D
      ENDIF
      IF(VVER(:2).EQ.'WS' .AND. (ISPC.EQ.7 .OR. ISPC.EQ.11))THEN
        ADHW=ADHW + D*P
        SUMTPA=SUMTPA + P
      ELSEIF(VVER(:2).EQ.'NC' .AND. (ISPC.EQ.5 .OR. ISPC.EQ.7 .OR.
     &       ISPC.EQ.8 .OR. ISPC.EQ.11))THEN
        ADHW=ADHW + D*P
        SUMTPA=SUMTPA + P
      ELSEIF((VVER(:2).EQ.'CA'.OR.VVER(:2).EQ.'OC').AND.ISPC.GE.26)THEN
        ADHW=ADHW + D*P
        SUMTPA=SUMTPA + P
      ELSEIF(VVER(:2).EQ.'SO' .AND. ((ISPC.GE.21 .AND. ISPC.LE.31) .OR.
     &       ISPC.EQ.33))THEN
        ADHW=ADHW + D*P
        SUMTPA=SUMTPA + P
      ENDIF
   90 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)' IN FISHER DMAX,ADHS,SUMTPA,BASM,CCPCT= '
     &,DMAX,ADHW,SUMTPA,BASM,CCPCT 
C----------
C  CALCULATE:
C  5) DIAMETER OF THE LARGEST CONIFER SNAG IN THE STAND
C     (DSNMAX: CENTIMETERS)
C----------
      CALL FMEVMSN(DSNMAX)
      IF(DEBUG)WRITE(JOSTND,*)' IN FISHER DSNMAX= ',DSNMAX
C----------
C  CONVERT ENGLISH UNITS TO METRIC UNITS WHERE APPROPRIATE
C  PERCENT CROWN COVER SHOULD BE EQUIVALENT CALCULATED EITHER WAY
C  CALCULATE THE FISHER HABITAT SUITABILITY INDEX
C----------
      DMAX = DMAX*2.54
      DSNMAX = DSNMAX*2.54
      IF(SUMTPA .GT. 0.)THEN
        ADHW = (ADHW/SUMTPA)*2.54
      ELSE
        ADHW = 0.
      ENDIF
      BASM = BASM*0.2295643
      IF(DEBUG)WRITE(JOSTND,*)' IN FISHER, CCPCT,BASM,ADHW,DMAX,SLOPE,',
     &'DSNMAX= ',CCPCT,BASM,ADHW,DMAX,SLOPE,DSNMAX 
C
      IF(CCPCT .GT. 0.)THEN
        X1=ALOG10(CCPCT)
      ELSE
        X1 = 0.
      ENDIF
      IF(BASM .GT. 0.)THEN
        X2=ALOG10(BASM)
      ELSE
        X2 = 0.
      ENDIF
      IF(ADHW .GT. 0.)THEN
        X3=ALOG10(ADHW)
      ELSE
        X3 = 0.
      ENDIF
      IF(DMAX .GT. 0.)THEN
        X4=ALOG10(DMAX)
      ELSE
        X4 = 0.
      ENDIF
      IF(SLOPE .GT. 0.)THEN
        X5=ALOG10(SLOPE*100.)
      ELSE
        X5 = 0.
      ENDIF
C
      TEMP = -22.1217941 + 2.461062*X1 + 2.15615937*X2 + 0.47133361*X3
     & + 4.55271635*X4 + 2.16130549*X5 + 0.00793579*DSNMAX
      FINDX=EXP(TEMP)/(1+EXP(TEMP))
C
  500 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)' LEAVING FISHER, TEMP,FINDX= ',TEMP,FINDX
      RETURN
C
C
C
C      ENTRY NEXT
C      RETURN
C
C
C
C      ENTRY NEXT
C      RETURN
C
C
C
      END
