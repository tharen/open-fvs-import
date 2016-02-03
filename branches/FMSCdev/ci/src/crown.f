      SUBROUTINE CROWN
      IMPLICIT NONE
C----------
C  **CROWN--CI   DATE OF LAST REVISION:  08/14/12
C----------
C  THIS SUBROUTINE IS USED TO DUB MISSING CROWN RATIOS AND
C  COMPUTE CROWN RATIO CHANGES FOR TREES THAT ARE GREATER THAN
C  3 INCHES DBH.  THE EQUATION USED PREDICTS CROWN RATIO FROM
C  HABITAT TYPE, BASAL AREA, CROWN COMPETITION FACTOR, DBH, TREE
C  HEIGHT, AND PERCENTILE IN THE BASAL AREA DISTRIBUTION.  WHEN
C  THE EQUATION IS USED TO PREDICT CROWN RATIO CHANGE, VALUES
C  OF THE PREDICTOR VARIABLES FROM THE START OF THE CYCLE ARE USED
C  TO PREDICT OLD CROWN RATIO, VALUES FROM THE END OF THE CYCLE
C  ARE USED TO PREDICT NEW CROWN RATIO, AND THE CHANGE IS
C  COMPUTED BY SUBTRACTION.  THE CHANGE IS APPLIED TO ACTUAL
C  CROWN RATIO.  THIS ROUTINE IS CALLED FROM **CRATET** TO DUB
C  MISSING VALUES, AND BY **TREGRO** TO COMPUTE CHANGE DURING
C  REGULAR CYCLING.  ENTRY **CRCONS** IS CALLED BY **RCON** TO
C  LOAD MODEL CONSTANTS THAT ARE SITE DEPENDENT AND NEED ONLY
C  BE RESOLVED ONCE.  A CALL TO **DUBSCR** IS ISSUED TO DUB
C  CROWN RATIO WHEN DBH IS LESS THAN 3 INCHES.  PROCESSING OF
C  CROWN CHANGE FOR SMALL TREES IS CONTROLLED BY **REGENT**.
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
      INCLUDE 'VARCOM.F77'
C
C
COMMONS
C----------
      LOGICAL DEBUG
      INTEGER MYACTS(1),ICFLG(MAXSP),ISORT(MAXTRE)
      INTEGER JJ,NTODO,I,NP,IACTK,IDATE,IDT,ISPCC,IGRP,IULIM,IG,IGSP
      INTEGER J1,ISPC,I1,I2,I3,ICRI,IITRE,IERR
      REAL CRNEW(MAXTRE),WEIBA(MAXSP),WEIBB0(MAXSP),
     &  WEIBB1(MAXSP),WEIBC0(MAXSP),WEIBC1(MAXSP),C0(MAXSP),C1(MAXSP),
     &  CRNMLT(MAXSP),DLOW(MAXSP),DHI(MAXSP),PRM(5),BARK,BRATIO,HF
      REAL RELSDI,ACRNEW,A,B,C,D,H,SCALE,X,RNUMB,CRHAT,PCTHAT,DIFF,CHG
      REAL PDIFPY,CRLN,CRMAX,HN,HD,CL,CR
      REAL RMAIAS,RMAILM,TEMMAI,ADJMAI,TPCCF
C
      DATA MYACTS/81/
C----------
C     SPECIES LIST FOR CENTRAL IDAHO VARIANT.
C
C     1 = WESTERN WHITE PINE (WP)          PINUS MONTICOLA
C     2 = WESTERN LARCH (WL)               LARIX OCCIDENTALIS
C     3 = DOUGLAS-FIR (DF)                 PSEUDOTSUGA MENZIESII
C     4 = GRAND FIR (GF)                   ABIES GRANDIS
C     5 = WESTERN HEMLOCK (WH)             TSUGA HETEROPHYLLA
C     6 = WESTERN REDCEDAR (RC)            THUJA PLICATA
C     7 = LODGEPOLE PINE (LP)              PINUS CONTORTA
C     8 = ENGLEMANN SPRUCE (ES)            PICEA ENGELMANNII
C     9 = SUBALPINE FIR (AF)               ABIES LASIOCARPA
C    10 = PONDEROSA PINE (PP)              PINUS PONDEROSA
C    11 = WHITEBARK PINE (WB)              PINUS ALBICAULIS
C    12 = PACIFIC YEW (PY)                 TAXUS BREVIFOLIA
C    13 = QUAKING ASPEN (AS)               POPULUS TREMULOIDES
C    14 = WESTERN JUNIPER (WJ)             JUNIPERUS OCCIDENTALIS
C    15 = CURLLEAF MOUNTAIN-MAHOGANY (MC)  CERCOCARPUS LEDIFOLIUS
C    16 = LIMBER PINE (LM)                 PINUS FLEXILIS
C    17 = BLACK COTTONWOOD (CW)            POPULUS BALSAMIFERA VAR. TRICHOCARPA
C    18 = OTHER SOFTWOODS (OS)
C    19 = OTHER HARDWOODS (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C  FROM THE IE VARIANT:
C      USE 17(PY) FOR 12(PY)             (IE17 IS REALLY TT2=LM)
C      USE 18(AS) FOR 13(AS)             (IE18 IS REALLY UT6=AS)
C      USE 13(LM) FOR 11(WB) AND 16(LM)  (IE13 IS REALLY TT2=LM)
C      USE 19(CO) FOR 17(CW) AND 19(OH)  (IE19 IS REALLY CR38=OH)
C
C  FROM THE UT VARIANT:
C      USE 12(WJ) FOR 14(WJ)
C      USE 20(MC) FOR 15(MC)             (UT20 = SO30=MC, WHICH IS
C                                                  REALLY WC39=OT)
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CROWN',5,ICYC)
C
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE CROWN  CYCLE =',I5)
C----------
C  CALCULATE THE MAI VALUES FOR AS AND THE WB/LM/PY SPECIES GROUP.
C  THIS WILL BE USED LATER IN CROWN DUBBING FOR THESE SPECIES INSTEAD
C  OF THE RMAI VALUE COMPUTED IN CRATET. THESE ARE THE ONLY SPECIES
C  WHICH HAVE AN MAI TERM IN THE ESTIMATION OF CROWN RATIO.
C----------
      RMAIAS = ADJMAI(746,SITEAR(13),10.0,IERR)
      IF(RMAIAS .GT. 128.0)RMAIAS=128.0
      RMAILM = ADJMAI(101,SITEAR(11),10.0,IERR)
      IF(RMAILM .GT. 128.0)RMAI=128.0
      IF(DEBUG)WRITE(JOSTND,*)' SITEAS,RMAIAS,SITELM,RMAILM= ',
     &SITEAR(13),RMAIAS,SITEAR(11),RMAILM 
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
C  DUB CROWNS ON DEAD TREES IF NO LIVE TREES IN INVENTORY
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
      ISPCC=IFIX(PRM(1))
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
      IF(DEBUG)WRITE(JOSTND,9024)ICYC,CRNMLT
 9024 FORMAT(/' IN CROWN 9024 ICYC,CRNMLT= ',
     & I5/((1X,11F6.2)/))
C----------
C LOAD ISORT ARRAY WITH DIAMETER DISTRIBUTION RANKS.  IF
C ISORT(K) = 10 THEN TREE NUMBER K IS THE 10TH TREE FROM
C THE BOTTOM IN THE DIAMETER RANKING  (1=SMALL, ITRN=LARGE)
C----------
      DO 11 JJ=1,ITRN
      J1 = ITRN - JJ + 1
      ISORT(IND(JJ)) = J1
   11 CONTINUE
      IF(DEBUG)THEN
        WRITE(JOSTND,7900)ITRN,(IND(JJ),JJ=1,ITRN)
 7900   FORMAT(' IN CROWN 7900 ITRN,IND =',I6,/,86(1H ,32I4,/))
        WRITE(JOSTND,7901)ITRN,(ISORT(JJ),JJ=1,ITRN)
 7901   FORMAT(' IN CROWN 7900 ITRN,ISORT =',I6,/,86(1H ,32I4,/))
      ENDIF
C----------
C  ENTER THE LOOP FOR SPECIES DEPENDENT VARIABLES
C----------
      DO 70 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF(I1 .EQ. 0) GO TO 70
      I2 = ISCT(ISPC,2)
C----------
C ESTIMATE MEAN CROWN RATIO FROM SDI, AND ESTIMATE WEIBULL PARAMETERS
C----------
      SELECT CASE (ISPC)
      CASE(11:16)
        IF(SDIDEF(ISPC) .GT. 0.)THEN
          RELSDI = SDIAC / SDIDEF(ISPC)
        ELSE
          RELSDI = 1.0
        ENDIF
      CASE DEFAULT
        RELSDI = BA / BAMAX
      END SELECT
C
      IF(RELSDI .GT. 1.5)RELSDI = 1.5
      ACRNEW = C0(ISPC) + C1(ISPC) * RELSDI*100.0
      A = WEIBA(ISPC)
      B = WEIBB0(ISPC) + WEIBB1(ISPC) * ACRNEW
      C = WEIBC0(ISPC) + WEIBC1(ISPC)*ACRNEW
C----------
      SELECT CASE (ISPC)
C
C  SPECIES FROM THE IE VARIANT
C
      CASE (11,12,13,14,15,16,17,19)
        IF(B .LT. 1.0) B=1.0
C
C  SPECIES FROM THE ORIGINAL CI VARIANT
C
      CASE DEFAULT
        IF(B .LT. 3.0) B=3.0
      END SELECT
C----------
      IF(C .LT. 2.0) C=2.0
      IF(DEBUG) WRITE(JOSTND,9001) ISPC,SDIAC,ORMSQD,RELSDI,
     & ACRNEW,A,B,C,BA,BAMAX,SDIDEF(ISPC)
 9001 FORMAT(' IN CROWN 9001 ISPC,SDIAC,ORMSQD,RELSDI,ACRNEW,A,B,C,BA,',
     &'BAMAX,SDIDEF = '/1X,I5,F8.2,F8.4,F8.2,F8.2,6F10.4)
C----------
C  BEGIN TREE LOOP
C----------
      DO 60 I3=I1,I2
      I = IND1(I3)
      IITRE = ITRE(I)
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
      IF (LSTART) GO TO 40
      IF (ICR(I).GE.0) GO TO 40
      ICR(I)=-ICR(I)
      IF (DEBUG) WRITE (JOSTND,35) I,ICR(I)
   35 FORMAT (' ICR(',I4,') WAS CALCULATED ELSEWHERE AND IS ',I4)
      GO TO 60
   40 CONTINUE
      D=DBH(I)
      H=HT(I)
      BARK=BRATIO(ISPC,D,H)
C--------
C  17=BLACK COTTONWOOD, 19=OTHER HARDWOODS
C  USE CR OTHER HARDWOODS LOGIC, VIA UT VARIANT
C  THIS LOGIC IS USED FOR TREES OF ALL SIZES FOR THESE TWO SPECIES.
C--------
      SELECT CASE (ISPC)
      CASE(17,19)
        HF=H+HTG(I)
        CL = 5.17281 + 0.32552 * HF - 0.01675 * BA
        IF(CL .LT. 1.0) CL = 1.0
        IF(CL .GT. HF) CL = HF
        CR = CL / HF
        CRNEW(I) = CR*100.
        GO TO 53
      END SELECT
C----------
C  BRANCH TO STATEMENT 58 TO HANDLE TREES WITH DBH LESS THAN 1 IN.
C----------
      IF(D.LT.1.0 .AND. LSTART) GO TO 58
C----------
C  JUNIPER FROM UT VARIANT
C----------
      SELECT CASE(ISPC)
C
      CASE(14)
        HF = H + HTG(I)
        CL = -0.59373 + 0.67703 * HF
        IF(CL .LT. 1.0) CL = 1.0
        IF(CL .GT. HF) CL = HF
        CRNEW(I) = (CL/HF)*100.
        IF(DEBUG)WRITE(JOSTND,*)' I,HF,BA,CL,CRNEW= ',
     &  I,HF,BA,CL,CRNEW(I)
C
      CASE DEFAULT
C----------
C  CALCULATE THE PREDICTED CURRENT CROWN RATIO
C----------
        SCALE = (1.0 - .00167 * (RELDEN-100.0))
        IF(SCALE .GT. 1.0) SCALE = 1.0
        IF(SCALE .LT. 0.30) SCALE = 0.30
        IF(DBH(I) .GT. 0.0) THEN
          X = (FLOAT(ISORT(I)) / FLOAT(ITRN)) * SCALE
        ELSE
          CALL RANN(RNUMB)
          X = RNUMB * SCALE
        ENDIF
        IF(X .LT. .05) X=.05
        IF(X .GT. .95) X=.95
        CRNEW(I) = A + B*((-1.0*ALOG(1-X))**(1.0/C))
C----------
C  WRITE DEBUG INFO IF DESIRED
C----------
   50   CONTINUE
        IF(DEBUG)WRITE(JOSTND,9002) I,X,CRNEW(I),ICR(I)
 9002   FORMAT(' IN CROWN 9002 WRITE I,X,CRNEW,ICR = ',I5,2F10.5,I5)
        CRNEW(I) = CRNEW(I)*10.0
      END SELECT
C----------
C  COMPUTE THE CHANGE IN CROWN RATIO
C  CALC THE DIFFERENCE BETWEEN THE MODEL AND THE OLD(OBS)
C  LIMIT CHANGE TO 1% PER YEAR
C----------
  53  CONTINUE
      IF(LSTART .OR. ICR(I).EQ.0) GO TO 9052
      CHG=CRNEW(I) - ICR(I)
      PDIFPY=CHG/ICR(I)/FINT
      IF(PDIFPY.GT.0.01)CHG=ICR(I)*(0.01)*FINT
      IF(PDIFPY.LT.-0.01)CHG=ICR(I)*(-0.01)*FINT
      IF(DEBUG)WRITE(JOSTND,9020)I,CRNEW(I),ICR(I),PDIFPY,CHG
 9020 FORMAT(/'  IN CROWN 9020 I,CRNEW,ICR,PDIFPY,CHG =',
     &I5,F10.3,I5,3F10.3)
      IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))THEN
        CRNEW(I) = ICR(I) + CHG * CRNMLT(ISPC)
      ELSE
        CRNEW(I) = ICR(I) + CHG
      ENDIF
 9052 ICRI = CRNEW(I)+0.5
      IF(LSTART .OR. ICR(I).EQ.0)THEN
        IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))THEN
          ICRI = ICRI * CRNMLT(ISPC)
        ENDIF
      ENDIF
C----------
C CALC CROWN LENGTH NOW
C----------
      IF(LSTART .OR. ICR(I).EQ.0)GO TO 55
      CRLN=HT(I)*ICR(I)/100.
C
C CALC CROWN LENGTH MAX POSSIBLE IF ALL HTG GOES TO NEW CROWN
C
      CRMAX=(CRLN+HTG(I))/(HT(I)+HTG(I))*100.0
      IF(DEBUG)WRITE(JOSTND,9004)CRMAX,CRLN,ICRI,I,CRNEW(I),
     & CHG
 9004 FORMAT(' CRMAX=',F10.2,' CRLN=',F10.2,
     &       ' ICRI=',I10,' I=',I5,' CRNEW=',F10.2,' CHG=',F10.3)
C
C IF NEW CROWN EXCEEDS MAX POSSIBLE LIMIT IT TO MAX POSSIBLE
C
      IF(ICRI.LT.10 .AND. CRNMLT(ISPC).EQ.1.0)ICRI=CRMAX+0.5
      IF(ICRI.GT.CRMAX) ICRI=CRMAX+0.5
C----------
C  REDUCE CROWNS OF TREES  FLAGGED AS TOP-KILLED ON INVENTORY
C----------
   55 IF (.NOT.LSTART .OR. ITRUNC(I).EQ.0) GO TO 59
      HN=NORMHT(I)/100.0
      HD=HN-ITRUNC(I)/100.0
      CL=(FLOAT(ICRI)/100.)*HN-HD
      ICRI=IFIX((CL*100./HN)+.5)
      IF(DEBUG)WRITE(JOSTND,9030)I,ITRUNC(I),NORMHT(I),HN,HD,
     & ICRI,CL
 9030 FORMAT(' IN CROWN 9030 I,ITRUNC,NORMHT,HN,HD,ICRI,CL = ',
     & 3I5,2F10.3,I5,F10.3)
      GO TO 59
C----------
C  CROWNS FOR TREES WITH DBH LT 1.0 IN ARE DUBBED HERE.  NO CHANGE
C  IS CALCULATED UNTIL THE TREE ATTAINS A DBH OF 1 INCH.
C----------
   58 CONTINUE
      IF(ICR(I) .NE. 0) GO TO 60
      TPCCF = PCCF(IITRE)
      SELECT CASE (ISPC)
        CASE(11,12,16)
          TEMMAI = RMAILM
        CASE(13)
          TEMMAI = RMAIAS
        CASE DEFAULT
          TEMMAI = RMAI
      END SELECT
      CALL DUBSCR(ISPC,D,H,BA,CR,TPCCF,AVH,TEMMAI)
      ICRI=CR*100.0+0.5
      IF(DEBUG)WRITE(JOSTND,*)' AFTER DUBSCR I,ISPC,D,H,BA,CR,ICRI= ',
     &I,ISPC,D,H,BA,CR,ICRI
      IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))
     &ICRI = ICRI * CRNMLT(ISPC)
C----------
C  BALANCING ACT BETWEEN TWO CROWN MODELS OCCURS HERE
C  END OF CROWN RATIO CALCULATION LOOP.  BOUND CR ESTIMATE AND FILL
C  THE ICR VECTOR.
C----------
   59 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF (ICRI .LT. 10 .AND. CRNMLT(ISPC).EQ.1.0) ICRI=10
      IF(ICRI.LT.1)ICRI=1
      ICR(I)= ICRI
   60 CONTINUE
      IF(LSTART .AND. ICFLG(ISPC).EQ.1)THEN
        CRNMLT(ISPC)=1.0
        ICFLG(ISPC)=0
      ENDIF
   70 CONTINUE
   74 CONTINUE
C----------
C  DUB MISSING CROWNS ON CYCLE 0 DEAD TREES.
C----------
      IF(IREC2 .GT. MAXTRE) GO TO 80
      DO 79 I=IREC2,MAXTRE
      IF(ICR(I) .GT. 0) GO TO 79
      ISPC=ISP(I)
      D=DBH(I)
      H=HT(I)
      IITRE=ITRE(I)
      TPCCF=PCCF(IITRE)
      SELECT CASE(ISPC)
      CASE(17,19)
        CL = 5.17281 + 0.32552 * H - 0.01675 * BA
        IF(CL .LT. 1.0) CL = 1.0
        IF(CL .GT. H) CL = H
        CR = CL / H
        ICRI = CR*100.
C
      CASE DEFAULT
        SELECT CASE(ISPC)
        CASE(11,12,16)
          TEMMAI = RMAILM
        CASE(13)
          TEMMAI = RMAIAS
        CASE DEFAULT
          TEMMAI = RMAI
        END SELECT
        CALL DUBSCR(ISPC,D,H,BA,CR,TPCCF,AVH,TEMMAI)
        ICRI=CR*100.0 + 0.5
      END SELECT
      IF(ITRUNC(I).EQ.0) GO TO 78
      HN=NORMHT(I)/100.0
      HD=HN-ITRUNC(I)/100.0
      CL=(FLOAT(ICRI)/100.)*HN-HD
      ICRI=IFIX((CL*100./HN)+.5)
   78 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF (ICRI .LT. 10) ICRI=10
      ICR(I)= ICRI
   79 CONTINUE
C
   80 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9010)ITRN,(ICR(JJ),JJ=1,ITRN)
 9010 FORMAT(' LEAVING CROWN 9010 FORMAT ITRN,ICR= ',I10,/,
     & 43(1H ,32I4,/))
      IF(DEBUG)WRITE(JOSTND,90)ICYC
   90 FORMAT(' LEAVING SUBROUTINE CROWN  CYCLE =',I5)
      RETURN
C
C
      ENTRY CRCONS
C----------
C  ENTRY POINT FOR LOADING CROWN RATIO MODEL COEFFICIENTS
C
C     SPECIES LIST FOR CENTRAL IDAHO VARIANT.
C
C     1 = WESTERN WHITE PINE (WP)          PINUS MONTICOLA
C     2 = WESTERN LARCH (WL)               LARIX OCCIDENTALIS
C     3 = DOUGLAS-FIR (DF)                 PSEUDOTSUGA MENZIESII
C     4 = GRAND FIR (GF)                   ABIES GRANDIS
C     5 = WESTERN HEMLOCK (WH)             TSUGA HETEROPHYLLA
C     6 = WESTERN REDCEDAR (RC)            THUJA PLICATA
C     7 = LODGEPOLE PINE (LP)              PINUS CONTORTA
C     8 = ENGLEMANN SPRUCE (ES)            PICEA ENGELMANNII
C     9 = SUBALPINE FIR (AF)               ABIES LASIOCARPA
C    10 = PONDEROSA PINE (PP)              PINUS PONDEROSA
C    11 = WHITEBARK PINE (WB)              PINUS ALBICAULIS
C    12 = PACIFIC YEW (PY)                 TAXUS BREVIFOLIA
C    13 = QUAKING ASPEN (AS)               POPULUS TREMULOIDES
C    14 = WESTERN JUNIPER (WJ)             JUNIPERUS OCCIDENTALIS
C    15 = CURLLEAF MOUNTAIN-MAHOGANY (MC)  CERCOCARPUS LEDIFOLIUS
C    16 = LIMBER PINE (LM)                 PINUS FLEXILIS
C    17 = BLACK COTTONWOOD (CW)            POPULUS BALSAMIFERA VAR. TRICHOCARPA
C    18 = OTHER SOFTWOODS (OS)
C    19 = OTHER HARDWOODS (OH)
C----------
C LOAD WEIBULL 'A' PARAMETER BY SPECIES
C----------
      DATA WEIBA/
     &        2.,        0.,       1.,       1.,       0.,
     &        1.,        0.,       1.,       1.,       0.,
     &        1.,        1.,       0.,       0.,       0.,
     &        1.,        0.,       0.,       0./
C----------
C LOAD WEIBULL 'B' PARAMETER EQUATION CONSTANT COEFFICIENT
C----------
      DATA WEIBB0/
     &  -2.12713,   0.07609, -1.19297, -1.19297,  0.06593,
     &  -1.38636,   0.07609, -0.91567, -0.91567,  0.24916,
     &  -0.82631,  -0.82631, -0.08414,      0.0, -0.23830,
     &  -0.82631,       0.0,  0.07609,      0.0/
C----------
C LOAD WEIBULL 'B' PARAMETER EQUATION SLOPE COEFFICIENT
C----------
      DATA WEIBB1/
     &   1.10526,   1.10184,  1.12928,  1.12928,  1.09624,
     &   1.16801,   1.10184,  1.06469,  1.06469,  1.04831,
     &   1.06217,   1.06217,  1.14765,      0.0,  1.18016,
     &   1.06217,       0.0,  1.10184,      0.0/
C----------
C LOAD WEIBULL 'C' PARAMETER EQUATION CONSTANT COEFFICIENT
C----------
      DATA WEIBC0/
     &      2.77,      3.01,     3.42,     3.42,     3.71,
     &      3.02,      3.01,     3.50,     3.50,     4.36,
     &   3.31429,   3.31429,  2.77500,      0.0,     3.04,
     &   3.31429,       0.0,     3.01,      0.0/
C----------
C LOAD WEIBULL 'C' PARAMETER EQUATION SLOPE COEFFICIENT
C----------
      DATA WEIBC1 /MAXSP*0.0/
C----------
C LOAD CR=F(SDI) EQUATION CONSTANT COEFFICIENT
C----------
      DATA C0/
     &   7.16846,   5.50719,  5.52653,  5.52653,  6.61291,
     &   6.17373,   5.50719,  6.77400,  6.12779,  6.41166,
     &   6.19911,   6.19911,  4.01678,      0.0,  4.62512,
     &   6.19911,       0.0,  7.23800,      0.0/
C----------
C LOAD CR=F(SDI) EQUATION SLOPE COEFFICIENT
C----------
      DATA C1/
     &  -0.02375,  -0.01833,      0.0,      0.0, -0.02182,
     &  -0.01795,  -0.01833,      0.0, -0.01269, -0.02041,
     &  -0.02216,  -0.02216, -0.01516,      0.0, -0.01604,
     &  -0.02216,       0.0,      0.0,      0.0/
C
      DATA CRNMLT/MAXSP*1.0/
      DATA ICFLG/MAXSP*0/
      DATA DLOW/MAXSP*0.0/
      DATA DHI/MAXSP*99.0/
C
      RETURN
      END
