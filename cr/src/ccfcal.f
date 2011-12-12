      SUBROUTINE CCFCAL(ISPC,D,H,JCR,P,LTHIN,CCFT,CRWDTH,MODE)
      IMPLICIT NONE
C----------
C  **CCFCAL--CR  DATE OF LAST REVISION:  12/15/09
C----------
C  THIS ROUTINE COMPUTES CROWN WIDTH AND CCF FOR INDIVIDUAL TREES.
C  CALLED FROM DENSE, PRTRLS, SSTAGE, AND CVCW.
C
C  ARGUMENT DEFINITIONS:
C    ISPC = NUMERIC SPECIES CODE
C       D = DIAMETER AT BREAST HEIGHT
C       H = TOTAL TREE HEIGHT
C     JCR = CROWN RATIO IN PERCENT (0-100)
C       P = TREES PER ACRE
C   LTHIN = .TRUE. IF THINNING HAS JUST OCCURRED
C         = .FALSE. OTHERWISE
C    CCFT = CCF REPRESENTED BY THIS TREE
C  CRWDTH = CROWN WIDTH OF THIS TREE
C    MODE = 1 IF ONLY NEED CCF RETURNED
C           2 IF ONLY NEED CRWDTH RETURNED
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
COMMONS
C----------
C  DIMENSION AND DATA STATEMENTS FOR INTERNAL VARIABLES.
C
C     CCF COEFFICIENTS FOR TREES THAT ARE GREATER THAN 10.0 IN. DBH:
C      RD1 -- CONSTANT TERM IN CROWN COMPETITION FACTOR EQUATION,
C             SUBSCRIPTED BY SPECIES
C      RD2 -- COEFFICIENT FOR SUM OF DIAMETERS TERM IN CROWN
C             COMPETITION FACTOR EQUATION,SUBSCRIPTED BY SPECIES
C      RD3 -- COEFFICIENT FOR SUM OF DIAMETER SQUARED TERM IN
C             CROWN COMPETITION EQUATION, SUBSCRIPTED BY SPECIES
C
C     CCF COEFFICIENTS FOR TREES THAT ARE LESS THAN 10.0 IN. DBH:
C      RDA -- MULTIPLIER.
C      RDB -- EXPONENT.  CCF(I) = RDA*DBH**RDB
C
C----------
C  SPECIES ORDER:
C   1=AF,  2=CB,  3=DF,  4=GF,  5=WF,  6=MH,  7=RC,  8=WL,  9=BC, 10=LM,
C  11=LP, 12=PI, 13=PP, 14=WB, 15=SW, 16=UJ, 17=BS, 18=ES, 19=WS, 20=AS,
C  21=NC, 22=PW, 23=GO, 24=AW, 25=EM, 26=BK, 27=SO, 28=PB, 29=AJ, 30=RM,
C  31=OJ, 32=ER, 33=PM, 34=PD, 35=AZ, 36=CI, 37=OS, 38=OH
C
C  SPECIES EXPANSION:
C  UJ,AJ,RM,OJ,ER USE CR JU                              
C  NC,PW USE CR CO
C  GO,AW,EM,BK,SO USE CR OA                             
C  PB USES CR AS                              
C  PM,PD,AZ USE CR PI
C  CI USES CR PP                              
C----------
C
C  CCF EQUATIONS ORDER:
C     1 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE
C     2 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: DOUGLAS-FIR
C     3 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: GRAND FIR
C     4 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN HEMLOCK
C     5 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN RED CEDAR
C     6 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: ENGELMANN SPRUCE
C     7 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: SUBALPINE FIR
C     8 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: PONDEROSA PINE
C
C      WYKOFF, CROOKSTON, STAGE, 1982. USER'S GUIDE TO THE STAND
C        PROGNOSIS MODEL. GEN TECH REP INT-133. OGDEN, UT:
C        INTERMOUNTAIN FOREST AND RANGE EXP STN. 112P.
C
C----------
      LOGICAL LTHIN
      REAL RD1(8),RD2(8),RD3(8),RDA(8),RDB(8)
      INTEGER MAP1(MAXSP),MAP2(MAXSP),MAP3(MAXSP),MAP4(MAXSP)
      INTEGER MAP5(MAXSP),MODE,ISPC,IMAP,JCR
      REAL CRWDTH,CCFT,P,H,D
C
      DATA MAP1/
     &  7,  7,  2,  7,  3,  1,  1,  1,  1,  1,
     &  1,  1,  8,  1,  1,  1,  1,  6,  6,  5,
     &  4,  4,  4,  4,  4,  4,  4,  5,  1,  1,
     &  1,  1,  1,  1,  1,  8,  1,  4/
      DATA MAP2/
     &  3,  3,  2,  3,  3,  1,  1,  1,  1,  1,
     &  1,  7,  8,  1,  1,  1,  1,  1,  1,  5,
     &  4,  4,  6,  6,  6,  6,  6,  5,  1,  1,
     &  1,  1,  7,  7,  7,  8,  1,  4/
      DATA MAP3/
     &  1,  1,  2,  1,  1,  1,  1,  1,  1,  1,
     &  1,  1,  8,  1,  1,  1,  6,  6,  6,  5,
     &  1,  1,  4,  4,  4,  4,  4,  5,  1,  1,
     &  1,  1,  1,  1,  1,  8,  1,  4/
      DATA MAP4/
     &  7,  7,  2,  7,  7,  1,  1,  1,  1,  1,
     &  1,  1,  1,  1,  1,  1,  6,  6,  6,  5,
     &  4,  4,  4,  4,  4,  4,  4,  5,  1,  1,
     &  1,  1,  1,  1,  1,  1,  1,  4/
      DATA MAP5/
     &  7,  7,  2,  7,  7,  1,  1,  1,  1,  1,
     &  1,  1,  8,  1,  1,  1,  6,  6,  6,  5,
     &  4,  4,  4,  4,  4,  4,  4,  5,  1,  1,
     &  1,  1,  1,  1,  1,  8,  1,  4/
C
      DATA RD1 /.01925, .11, .04, .03, .03, .03, .03, .03/
      DATA RD2 /.01676, .0333, .0270, .0215, .0238, .0173, .0216, .0180/
      DATA RD3 /0.00365, 0.00259, 0.00405, 0.00363,
     &          0.00490, 0.00259, 0.00405, 0.00281/
      DATA RDA/ 0.009187, 0.017299, 0.015248, 0.011109,
     &          0.008915, 0.007875, 0.011402, 0.007813/
      DATA RDB/ 1.7600, 1.5571,  1.7333,  1.7250,
     &          1.7800, 1.7360,  1.7560,  1.7680/
C----------
C  INITIALIZE RETURN VARIABLES.
C----------
      CCFT = 0.
      CRWDTH = 0.
C----------
C  SET UP MAPPING INDEX BY  MODEL TYPE.
C----------
      IF(IMODTY .EQ. 1) THEN
        IMAP=MAP1(ISPC)
      ELSEIF(IMODTY .EQ. 2) THEN
        IMAP=MAP2(ISPC)
      ELSEIF(IMODTY .EQ. 3) THEN
        IMAP=MAP3(ISPC)
      ELSEIF(IMODTY .EQ. 4) THEN
        IMAP=MAP4(ISPC)
      ELSE
        IMAP=MAP5(ISPC)
      ENDIF
C----------
C  COMPUTE CCF
C----------
      IF (D .GE. 10.0) THEN
        CCFT = RD1(IMAP) + D*RD2(IMAP) + D*D*RD3(IMAP)
      ELSEIF (D .GT. 0.1) THEN
        CCFT = RDA(IMAP) * (D**RDB(IMAP))
      ELSE
        CCFT = 0.001
      ENDIF
C----------
C  COMPUTE CROWN WIDTH
C----------
      CRWDTH = SQRT(CCFT/0.001803)
      IF(CRWDTH .GT. 99.9) CRWDTH=99.9
C
      CCFT = CCFT * P
C
      RETURN
      END
