      SUBROUTINE CROWN
      IMPLICIT NONE
C----------
C AK $Id$
C----------
C  THIS ROUTINE IS CALLED FROM **CRATET** TO DUB
C  MISSING VALUES, AND BY **TREGRO** TO COMPUTE CHANGE DURING
C  REGULAR CYCLING.  ENTRY **CRCONS** IS CALLED BY **RCON** TO
C  LOAD MODEL CONSTANTS THAT ARE SITE DEPENDENT AND NEED ONLY
C  BE RESOLVED ONCE.  A CALL TO **DUBSCR** IS ISSUED TO DUB
C  CROWN RATIO FOR DEAD TREES.
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
      INCLUDE 'CRCOEF.F77'
C
C
COMMONS
C
C----------
C  VARIABLE DECLARATIONS:
C----------
C
      LOGICAL DEBUG
C
      INTEGER I,I1,I2,I3,IACTK,ICRI,IDATE,IDT,IG,IGRP,IGSP,IITRE,ISPC
      INTEGER ISPCC,IULIM,J1,JJ,NP,NTODO,IWHO
      INTEGER ISORT(MAXTRE),MYACTS(1)
C
      REAL CHG,CL,CR,CRLN,CRMAX,D,H,HD,HN,PDIFPY
      REAL RDEN,DBHLO,DBHHI,SDICS,SDICZ,A,B,X,B1,B2,B3,B4
      REAL CRNEW(MAXTRE),PRM(5),ZRD(MAXPLT),XMAX
      REAL BAPLT,TPAPLT,QMDPLT
C
C----------
C  DATA STATEMENTS:
C----------
      DATA MYACTS/81/
C----------
C  SPECIES ORDER:
C  1   2   3   4   5   6   7   8   9   10  11  12
C  SF  AF  YC  TA  WS  LS  BE  SS  LP  RC  WH  MH
C
C  13  14  15  16  17  18  19  20  21  22  23
C  OS  AD  RA  PB  AB  BA  AS  CW  WI  SU  OH
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CROWN',5,ICYC)
C
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE CROWN  CYCLE =',I5)

C  CALL SDICAL TO LOAD THE POINT MAX SDI WEIGHTED BY SPECIES ARRAY XMAXPT()
C  RECENT DEAD ARE NOT INCLUDED. IF THEY NEED TO BE, SDICAL.F NEEDS MODIFIED
C  TO DO SO. IWHO PARAMETER HAS NO AFFECT ON XMAXPT ARRAY VALUES.
C
      IWHO = 2
      CALL SDICAL (IWHO, XMAX)
C-----------
C  LOAD SDI (ZEIDI) FOR INDIVIDUAL POINTS.
C  ALL SPECIES AND ALL SIZES INCLUDED FOR THIS CALCULATION.
C  SDI USED IN CR CALCULATION
C-----------
      DBHLO = 0.0
      DBHHI = 500.0
      ISPC = 0
      IWHO = 1
      I2 = INT(PI)
      
      DO I1 = 1, I2
         CALL SDICLS (ISPC,DBHLO,DBHHI,IWHO,SDICS,SDICZ,A,B,I1)
         ZRD(I1) = SDICZ
      END DO
C----------
C INITIALIZE CROWN VARIABLES TO BEGINNING OF CYCLE VALUES.
C----------
      IF(LSTART)THEN
        DO 10 JJ=1,MAXTRE
        CRNEW(JJ)=0.0
        ISORT(JJ)=0
   10   CONTINUE
      ENDIF
C----------
C  GO TO DUB CROWNS ON DEAD TREES IF NO LIVE TREES IN INVENTORY
C----------
      IF((ITRN.LE.0).AND.(IREC2.LT.MAXTP1))GO TO 74
C----------
C IF THERE ARE NO TREE RECORDS, THEN RETURN
C----------
      IF(ITRN.EQ.0)THEN
        RETURN
      ELSEIF(TPROB.LE.0.0)THEN
        DO I=1,ITRN
        ICR(I)=ABS(ICR(I))
        ENDDO
        RETURN
      ENDIF
C-----------
C  PROCESS CRNMULT KEYWORD.
C-----------
      CALL OPFIND(1,MYACTS,NTODO)
      IF(NTODO .EQ. 0)GO TO 25
      DO 24 I=1,NTODO
      CALL OPGET(I,5,IDATE,IACTK,NP,PRM)
      IDT=IDATE
      CALL OPDONE(I,IDT)
      ISPCC=INT(PRM(1))
C----------
C  ISPCC<0 CHANGE FOR ALL SPECIES IN THE SPECIES GROUP
C  ISPCC=0 CHANGE FOR ALL SPEICES
C  ISPCC>0 CHANGE THE INDICATED SPECIES
C----------
      IF(ISPCC .LT. 0)THEN
        IGRP = -ISPCC
        IULIM = ISPGRP(IGRP,1)+1
        DO 21 IG=2,IULIM
        IGSP = ISPGRP(IGRP,IG)
        IF(PRM(2) .GE. 0.0)CRNMLT(IGSP)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(IGSP)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(IGSP)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(IGSP)=1
   21   CONTINUE
      ELSEIF(ISPCC .EQ. 0)THEN
        DO 22 ISPCC=1,MAXSP
        IF(PRM(2) .GE. 0.0)CRNMLT(ISPCC)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(ISPCC)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(ISPCC)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(ISPCC)=1
   22   CONTINUE
      ELSE
        IF(PRM(2) .GE. 0.0)CRNMLT(ISPCC)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(ISPCC)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(ISPCC)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(ISPCC)=1
      ENDIF
   24 CONTINUE
   25 CONTINUE
C
C  DETERMINE IF DEBUG IS NEEDED
      IF(DEBUG)WRITE(JOSTND,9024)ICYC,CRNMLT
 9024 FORMAT(/' IN CROWN 9024 ICYC,CRNMLT= ',
     & I5/((1X,23F6.2)/))
C----------
C LOAD ISORT ARRAY WITH DIAMETER DISTRIBUTION RANKS.  IF
C ISORT(K) = 10 THEN TREE NUMBER K IS THE 10TH TREE FROM
C THE BOTTOM IN THE DIAMETER RANKING  (1=SMALL, ITRN=LARGE)
C----------
      DO 11 JJ=1,ITRN
      J1 = ITRN - JJ + 1
      ISORT(IND(JJ)) = J1
   11 CONTINUE
C  DETERMINE IF DEBUG IS NEEDED
      IF(DEBUG)THEN
        WRITE(JOSTND,7900)ITRN,(IND(JJ),JJ=1,ITRN)
 7900   FORMAT(' IN CROWN 7900 ITRN,IND =',I6,/,86(1X,32I4,/))
        WRITE(JOSTND,7901)ITRN,(ISORT(JJ),JJ=1,ITRN)
 7901   FORMAT(' IN CROWN 7900 ITRN,ISORT =',I6,/,86(1X,32I4,/))
      ENDIF
C----------
C  CROWN LOOPS OVER SPECIES AND THEN LOOPS OVER TREE RECORDS
C  FOR EACH SPECIES
C----------
C  BEGIN OUTER LOOP OVER SPECIES
      DO 70 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF(I1 .EQ. 0) GO TO 70
      I2 = ISCT(ISPC,2)
C
C  LOAD SPECIES (ISPC) COEFFCIENTS:
C  INTERCEPT(B1), HDR(B2), RD(B3), DQMD(B4)
      B1 = CRINT(ISPC)
      B2 = CRHDR(ISPC)
      B3 = CRRD(ISPC)
      B4 = CRDQMD(ISPC)
C
C  DETERMINE IF DEBUG IS NEEDED
      IF(DEBUG) WRITE(JOSTND,9001) ISPC,
     &  B1,B2,B3,B4
 9001 FORMAT(' IN CROWN 9001 ISPC,',
     &  'B1,B2,B3,B4 = ',/1X,I5,5F10.4)
C
C  BEGIN INNER DO LOOP OVER TREE RECORDS OF SPECIES
      DO 60 I3=I1,I2
      I = IND1(I3)
      IITRE=ITRE(I)
C----------
C  IF THIS IS THE INITIAL ENTRY TO 'CROWN' AND THE TREE IN QUESTION
C  HAS A CROWN RATIO ASCRIBED TO IT, THE WHOLE PROCESS IS BYPASSED.
C----------
      IF(LSTART .AND. ICR(I).GT.0)GOTO 60
C----------
C  IF ICR(I) IS NEGATIVE, CROWN RATIO CHANGE WAS COMPUTED IN A
C  PEST DYNAMICS EXTENSION.  SWITCH THE SIGN ON ICR(I) AND BYPASS
C  CHANGE CALCULATIONS.
C----------
      IF (LSTART) GOTO 40
      IF (ICR(I).GE.0) GO TO 40
      ICR(I)=-ICR(I)
C
C  DETERMINE IF DEBUG IS NEEDED
      IF (DEBUG) WRITE (JOSTND,35) I,ICR(I)
   35 FORMAT (' ICR(',I4,') WAS CALCULATED ELSEWHERE AND IS ',I4)
      GOTO 60
   40 CONTINUE
      D=DBH(I)
      H=HT(I)
C  CALCULATE PLOT LEVEL QMD
      BAPLT = PTBAA(ITRE(I))
      TPAPLT = PTPA(ITRE(I))
      QMDPLT = SQRT((BAPLT/TPAPLT)/0.005454)
C  CALCULATE RD AND CONSTRAIN RD IF NECCESARY
      IF (XMAXPT(ITRE(I)).EQ.0.0) THEN
        RDEN = 0.01
      ELSE
        RDEN = ZRD(ITRE(I)) / XMAXPT(ITRE(I))
      ENDIF
C  DETERMINE IF DEBUG IS NEEDED
      IF(DEBUG) WRITE(JOSTND,*) 'IN CROWN - IITRE,D,H,RDEN,',
     & 'BAPLT, TPAPLT, QMDPLT,ZRD, XMAXPT',
     &  IITRE,D,H,RDEN,BAPLT,TPAPLT,QMDPLT,ZRD(ITRE(I)),XMAXPT(ITRE(I))
C----------
C  BRANCH TO STATEMENT 58 TO HANDLE TREES WITH DBH LESS THAN 1 IN.
C----------
C  CALCULATE SMALL TREE CR IF DBH < 1" FOR ALL SPECIES
      IF(D.LT.1.0 .AND. LSTART) GO TO 58
C----------
C  CALCULATE PREDICTED CURRENT CROWN RATIO USING LOGISITC
C  FUNCTIONAL FORM
C  CROWN RATIO IS A FUNCTION OF HEIGHT-DIAMETER RATIO,
C  RELATIVE DENSITY, and RELATIVE DBH (DBH/QMD)
C----------
C  CALCULATE X
      X = B1
     & + B2 * LOG(H*12/D)
     & + B3 * RDEN
     & + B4 * (D/QMDPLT)
C
C  CALCULATE CROWN RATIO FROM X
      X = 1.0/(1.0+EXP(X))
C
C  DETERMINE IF CROWN RATIO (X) PREDICTION NEEDS TO BE CONSTRAINED
C  (0.05 > X < 0.95)
      IF(X .LT. 0.05) X=0.05
      IF(X .GT. 0.95) X=0.95
C
C  LOAD PREDICTED CR VALUE INTO CRNEW ARRAY
      CRNEW(I) = INT((X * 100) + 0.5)
C----------
C  WRITE DEBUG INFO IF DESIRED
C----------
      IF(DEBUG)WRITE(JOSTND,9002) I,X,CRNEW(I),ICR(I)
 9002 FORMAT(' IN CROWN 9002 WRITE I,X,CRNEW,ICR = ',I5,2F10.5,I5)
C----------
C  COMPUTE THE CHANGE IN CROWN RATIO
C  CALC THE DIFFERENCE BETWEEN THE MODEL AND THE OLD(OBS)
C  LIMIT CHANGE TO 1% PER YEAR DECREASE AND 3% PER YEAR INCREASE
C  (3% BECAUSE OF HIGH GROWTH RATES IN THE AK VARIANT)
C----------
      IF(LSTART .OR. ICR(I).EQ.0) GO TO 9052
      CHG=CRNEW(I) - REAL(ICR(I))
      PDIFPY=CHG/REAL(ICR(I))/FINT
      IF(PDIFPY.GT.0.03)CHG=REAL(ICR(I))*(0.03)*FINT
      IF(PDIFPY.LT.-0.01)CHG=REAL(ICR(I))*(-0.01)*FINT
C
C  DETERMINE IF DEBUG IS NEEDED
      IF(DEBUG)WRITE(JOSTND,9020)I,CRNEW(I),ICR(I),PDIFPY,CHG
 9020 FORMAT(/'  IN CROWN 9020 I,CRNEW,ICR,PDIFPY,CHG =',
     &  I5,F10.3,I5,3F10.3)
C
      IF(DBH(I) .GE. DLOW(ISPC) .AND. DBH(I) .LE. DHI(ISPC))THEN
        CRNEW(I) = REAL(ICR(I)) + CHG * CRNMLT(ISPC)
      ELSE
        CRNEW(I) = REAL(ICR(I)) + CHG
      ENDIF
 9052 CONTINUE
      ICRI = INT(CRNEW(I)+0.5)
      IF(LSTART .OR. ICR(I) .EQ. 0)THEN
        IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))THEN
          ICRI = INT(REAL(ICRI) * CRNMLT(ISPC))
        ENDIF
      ENDIF
C----------
C CALC CROWN LENGTH NOW
C----------
      IF(LSTART .OR. ICR(I) .EQ. 0)GO TO 55
      CRLN=HT(I)*REAL(ICR(I))/100.
C----------
C CALC CROWN LENGTH MAX POSSIBLE IF ALL HTG GOES TO NEW CROWN
C----------
      CRMAX=(CRLN+HTG(I))/(HT(I)+HTG(I))*100.0
      IF(DEBUG)WRITE(JOSTND,9004)CRMAX,CRLN,ICRI,I,CRNEW(I),CHG
 9004 FORMAT('  CRMAX=',F10.2,' CRLN=',F10.2,
     &  ' ICRI=',I10,' I=',I5,' CRNEW=',F10.2,' CHG=',F10.3)
C----------
C IF NEW CROWN EXCEEDS MAX POSSIBLE LIMIT IT TO MAX POSSIBLE
C----------
      IF(REAL(ICRI).GT.CRMAX) ICRI=INT(CRMAX+0.5)
      IF(ICRI.LT.10 .AND. CRNMLT(ISPC).EQ.1.0) ICRI=INT(CRMAX+0.5)
C----------
C  REDUCE CROWNS OF TREES  FLAGGED AS TOP-KILLED ON INVENTORY
C----------
   55 IF (.NOT.LSTART .OR. ITRUNC(I).EQ.0) GO TO 59
      HN=REAL(NORMHT(I))/100.0
      HD=HN-REAL(ITRUNC(I))/100.0
      CL=(REAL(ICRI)/100.)*HN-HD
      ICRI=INT((CL*100./HN)+.5)
C
C  DETERMINE IF DEBUG IS NEEDED
      IF(DEBUG)WRITE(JOSTND,9030)I,ITRUNC(I),NORMHT(I),HN,HD,ICRI,CL
 9030 FORMAT('  IN CROWN 9030 I,ITRUNC,NORMHT,HN,HD,ICRI,CL = ',
     & 3I5,2F10.3,I5,F10.3)
      GO TO 59
C----------
C  CROWNS FOR TREES WITH DBH LT 1 INCH ARE DUBBED HERE.  NO CHANGE
C  IS CALCULATED UNTIL THE TREE ATTAINS A DBH OF 1 INCH.
C----------
   58 CONTINUE
      IF(ICR(I) .NE. 0) GO TO 60
      CALL DUBSCR(ISPC,D,H,RDEN,QMDPLT,CR)

      IF(DEBUG) WRITE(JOSTND,*) 'RETURN FROM DUBSCR IN CROWN'
      ICRI = INT(CR*100.0+0.5)
      IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))
     &  ICRI = INT(REAL(ICRI) * CRNMLT(ISPC))
C----------
C  BALANCING ACT BETWEEN TWO CROWN MODELS OCCURS HERE
C  END OF CROWN RATIO CALCULATION LOOP. BOUND CR ESTIMATE AND FILL
C  THE ICR VECTOR.
C----------
   59 CONTINUE
C  CONSTRAIN CROWN RATIO IF NECCESARY
      IF(ICRI.GT.95) ICRI=95
      IF(ICRI .LT. 10 .AND. CRNMLT(ISPC).EQ.1) ICRI=10
      IF(ICRI.LT.1) ICRI=1
      ICR(I)= ICRI
C
C  END OF TREE RECORD LOOP
   60 CONTINUE
      IF(LSTART .AND. ICFLG(ISPC).EQ.1)THEN
        CRNMLT(ISPC)=1.0
        ICFLG(ISPC)=0
      ENDIF
C
C  END OF SPECIES LOOP
   70 CONTINUE
   74 CONTINUE
C----------
C  DUB MISSING CROWNS ON CYCLE 0 DEAD TREES.
C----------
C  DETERMINE IF CR NEEDS TO BE CALCULATED FOR DEAD TREES
      IF(IREC2 .GT. MAXTRE) GO TO 80
C
C  LOOP THROUGH DEAD TREE RECORDS
      DO 79 I=IREC2,MAXTRE
      IF(ICR(I) .GT. 0) GO TO 79
      ISPC=ISP(I)
      D=DBH(I)
      H=HT(I)
C  CALCULATE PLOT LEVEL QMD
      BAPLT = PTBAA(ITRE(I))
      TPAPLT = PTPA(ITRE(I))
      QMDPLT = SQRT((BAPLT/TPAPLT)/0.005454)
C  CALCULATE RD AND CONSTRAIN RD IF NECCESARY
      IF (XMAXPT(ITRE(I)).EQ.0.0) THEN
        RDEN = 0.01
      ELSE
        RDEN = ZRD(ITRE(I)) / XMAXPT(ITRE(I))
      ENDIF
C  CALL DUBSCR
      CALL DUBSCR(ISPC,D,H,RDEN,QMDPLT,CR)
      ICRI = INT(CR*100.0 + 0.5)
      IF(ITRUNC(I).EQ.0) GO TO 78
      HN=REAL(NORMHT(I))/100.0
      HD=HN-REAL(ITRUNC(I))/100.0
      CL=(REAL(ICRI)/100.)*HN-HD
      ICRI=INT((CL*100./HN)+.5)
   78 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF (ICRI .LT. 10) ICRI=10
      ICR(I)= ICRI
   79 CONTINUE
C  END OF DEAD TREE LOOP
   80 CONTINUE
C
C  DETERMINE IF DEBUG IS NEEDED
      IF(DEBUG)WRITE(JOSTND,9010)ITRN,(ICR(JJ),JJ=1,ITRN)
 9010 FORMAT(' LEAVING CROWN 9010 FORMAT ITRN,ICR= ',I10,/,
     & 43(' ',32I4,/))
      IF(DEBUG)WRITE(JOSTND,90)ICYC
   90 FORMAT(' LEAVING SUBROUTINE CROWN  CYCLE =',I5)
      RETURN
C----------

      ENTRY CRCONS
C----------
C  ENTRY POINT FOR LOADING CROWN RATIO MODEL COEFFICIENTS
C  AND CRNMULT ARRAYS
C
C  SPECIES ORDER:
C  1   2   3   4   5   6   7   8   9   10  11  12
C  SF  AF  YC  TA  WS  LS  BE  SS  LP  RC  WH  MH
C
C  13  14  15  16  17  18  19  20  21  22  23
C  OS  AD  RA  PB  AB  BA  AS  CW  WI  SU  OH
C----------
C
C  CROWN RATIO INTERCEPT COEFFICIENTS
      DATA CRINT/
     & -2.794098, -2.794098,  0.692515,  6.473807, -4.02918,
     & -4.02918,  -2.781453, -2.794098, -0.413757, -0.488056,
     & -0.337728, -0.491195, -4.02918,  -2.742561, -2.742561,
     & -1.268148, -1.268148,  0.982275,  0.802674,  0.982275,
     & -2.406429, -2.406429,  0.982275/
C
C  CROWN RATIO HT/DBH RATIO COEFFICIENTS
      DATA CRHDR/
     & 0.618829,  0.618829, -0.072792, -1.496876,  0.655785,
     & 0.655785,  0.43877,   0.618829,  0.292906,  0.113563,
     & 0.110948,  0.146189,  0.655785,  0.648659,  0.648659,
     & 0.147416,  0.147416, -0.315363, -0.143718, -0.315363,
     & 0.347336,  0.347336, -0.315363/
C
C  CROWN RATIO RELATIVE DENSITY COEFFICIENTS
      DATA CRRD/
     & 0.949546, 0.949546, 0.431611, 0.91515, 0.914283,
     & 0.914283, 0.970268, 0.949546, 0.735503, 0.56448,
     & 0.573791, 0.592768, 0.914283, 0.980929, 0.980929,
     & 1.092648, 1.092648, 0.850711, 1.023344, 0.850711,
     & 0.953225, 0.953225, 0.850711/
C
C  CROWN RATIO DQMD COEFFICIENTS - CONSISTENT ACROSS ALL SPECIES
      DATA CRDQMD/
     & -0.176087, -0.176087, -0.176087, -0.051309, -0.051309,
     & -0.051309, -0.051309, -0.176087, -0.176087, -0.176087,
     & -0.176087, -0.176087, -0.051309, -0.176087, -0.176087,
     & -0.051309, -0.051309, -0.051309, -0.051309, -0.051309,
     & -0.051309, -0.051309, -0.051309/

C  CRNMULT PARAMETERS
      DATA CRNMLT/MAXSP*1.0/
      DATA ICFLG/MAXSP*0/
      DATA DLOW/MAXSP*0.0/
      DATA DHI/MAXSP*999.0/

      RETURN
      END

