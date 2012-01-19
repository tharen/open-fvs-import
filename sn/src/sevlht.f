      SUBROUTINE SEVLHT(D,H,PULPVO,SWVOL,HT,ISPC,
     &           DEBUG,GR,VLSP)
      IMPLICIT NONE
C----------
C  **SEVLHT  SN  DATE OF LAST REVISION: 01/19/2011
C----------
C THIS ROUTINE CALCULATES HEIGHT OF A TREE TO A SPECIFIED TOP DIAMETER.
C DEFAULTS ARE SET IN GRINIT ALTHOUGH THEY CAN BE USER DEFINED.  THIS
C PROGRAM FOLLOWS EQUATIONS FOUND IN SE-282 BY CLARK ET AL, PAGES 5-6,
C 39-41, AND 66-73.
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'SNCOM.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
COMMONS
C
C----------
C  DECLARE AND DIMENSION VARIABLES
C----------
      INTEGER ISPC,PNT,INDVL,IS,IB,IT,IM,GR,CNT,IVLSP,IGR,ICNT,J,I
C     REAL    R1,R2,R3,P,A1,A2,STFAC,H,FCLASS,D,FCLSS,FCDOB,
C    &        TOPDIA,TOPD2,D2,D3,FCDOB2,G,W,X,Y,Z,T,V1,QA,QB,QC,
C    &        V2,SEG1,SEG2,SEG3,HT,FA1,FA2,AF,BF,R8COEF(50,17)
      REAL    R1,R2,R3,P,A1,A2,STFAC,H,D,FCDOB,
     &        TOPDIA,TOPD2,D2,D3,FCDOB2,G,W,X,Y,Z,T,V1,QA,QB,QC,
     &        V2,SEG1,SEG2,SEG3,HT,AF,BF,R8COEF(50,17)
      CHARACTER VLSP*3
      LOGICAL DEBUG,PULPVO,SWVOL
      DIMENSION R1(54),R2(54),R3(54),P(54),A1(54),A2(54)
      DIMENSION INDVL(MAXSP)
C
      INCLUDE 'R8DIB.F77'
C
C----------
C  LOADING SPECIES SPECIFIC COEFFICIENTS FOR HEIGHT EQUATIONS.
C----------
      DATA INDVL/
     A  14,11,6,10,2,3,6,4,7,7,8,9,5,10,12,13,14,17,17,17,
     B  17,17,18,32,32,31,33,54,19,54,54,30,31,15,35,15,15,
     C  36,30,54,54,54,30,30,20,21,27,15,27,22,15,54,54,23,
     D  24,24,30,15,54,26,15,15,16,37,42,43,44,51,45,38,51,
     E  39,41,46,39,49,51,40,50,41,53,15,15,28,29,29,29,10,
     F  54,54/
      DATA R1/
     &  21.01306,24.26750,27.16454,19.57711,25.29597,31.09115,
     &   6.93687, 9.98989,10.41255, 9.17462, 3.53038,53.02593,
     &  25.10773,21.36317, 1.48199,37.12714,22.00135, 3.02215,
     &   7.58001,39.02874,26.40588,23.01219,-17.29187,13.27517,
     &   3.85564,25.41167,29.53040,35.87830, 0.81866,17.37375,
     &  44.36826,49.41385,26.74384,19.65583, 0.64600, 7.32061,
     &  26.85889,15.45114,22.30226,30.82091,23.71110,42.73753,
     &  31.98221,50.51179,34.80988,34.76470,-5.45119,35.40807,
     &  31.32975,31.60343,18.48034,19.20350,25.57939,7.62604/
      DATA R2/
     &  0.50856,0.53260,0.79755,0.54088,0.58370,0.51977,0.26874,
     &  0.40750,0.36290,0.38821,0.31298,2.80399,2.23655,0.54174,
     &  0.63392,0.48776,0.45472,0.58715,0.77904,0.92761,0.51359,
     &  1.31139,1.39778,0.43775,1.45568,0.72445,0.84545,0.61921,
     &  0.77141,0.76817,1.22158,1.01241,0.71015,0.76605,0.49680,
     &  0.61584,0.84829,0.62728,0.49235,0.83441,0.66796,0.86145,
     &  0.92734,1.36917,1.36792,1.08768,0.88020,1.26850,0.81328,
     &  0.81484,0.90302,0.80440,0.35922,0.70780/
      DATA R3/
     & 157.11000,107.6500,65.52791,22.15904,221.45000,-43.19648,
     &  96.50804,126.7800,59.64184,48.07668,85.37754,1183.93,
     &  2782.32,47.97097,97.98536,  1.50579,166.10000,-154.7200,
     &  98.86053, 8.382210,118.6400,47.93370,-22.59832,357.6200,
     &  230.65,58.38711,-177.27,-129.42,-51.36724,19.73232,79.44636,
     &  -91.82769,44.42209,156.29,127.87,288.36,232.96,618.81,206.69,
     &  335.71,349.50,214.31,119.69,-215.920,39.52792,-6.46961,-457.82,
     &  38.61354,78.94096,124.19,-118.39,55.79724,-8.66136,19.34425/
      DATA P/
     &   7.78474, 9.22332, 4.88907, 4.34898, 8.88273, 3.70448,
     &   6.15648, 3.90993,11.42481, 9.24015, 8.40597,15.06926,
     &  11.60876, 9.54910,13.13006, 6.18866, 7.31546, 5.04720,
     &  14.72719,17.80982,12.35256,11.28550,10.99759,13.62877,
     &  15.92478,13.54775, 4.83280, 8.73588,18.74117,12.25625,
     &   6.36236,11.23179,15.94480,18.71336, 7.52915,11.17396,
     &  12.28295,14.60416, 9.71683,10.33370,11.92633,13.53863,
     &  12.75583, 9.30537,10.25955,10.78112,21.01569,11.59408,
     &  11.45671,12.19245,14.01655,13.13272, 7.02926,12.85326/
      DATA A1/
     &  .68914,.74591,.76513,.68448,.70372,.64781,.69903,.67531,
     &  .63240,.62645,.60463,.79079,.78623,.60760,.46150,.55071,
     &  .27213,.49221,.21363,.49790,.45728,.58013,.66751,.51314,
     &  .69671,.59893,.41750,.54681,.29448,.34212,.14312,.23928,
     &  .33340,.44660,.47222,.43492,.31541,.38248,.39346,.30931,
     &  .34249,.33330,.36674,.31282,.31023,.38666,.31629,.28533,
     &  .39984,.35814,.31908,.32973,.35218,.35815/
      DATA A2/
     &  2.36095,3.04710,2.76770,2.17272,2.39522,1.96014,2.52679,
     &  2.19115,1.78758,2.11000,1.85489,3.20594,2.88567,1.65131,
     &  1.46888,1.64261,1.17064,1.45465,1.13162,1.60164,1.45155,
     &  1.70245,1.50338,1.71575,2.37582,1.63890,1.45934,1.65110,
     &  1.25822,1.29942,1.11382,1.19704,1.34232,1.49941,1.49287,
     &  1.36940,1.32630,1.35596,1.38908,1.29478,1.28727,1.29882,
     &  1.37269,1.28815,1.31060,1.36987,1.28504,1.23843,1.43496,
     &  1.39091,1.28801,1.28810,1.24010,1.30536/
C----------
      IF (DEBUG) WRITE(JOSTND,10)
   10 FORMAT(' ENTERING SEVLHT')
C----------
C  SET PNT TO DETERMINE WHICH COEFFICIENTS TO USE
C----------
      PNT = INDVL(ISPC)
      READ (VLSP,'(I3)')IVLSP
      IF ((ISPC .GE. 68 .AND. ISPC .LE. 69) .AND. (IREG .EQ. 3
     &     .OR. IREG .EQ. 4 .OR. IREG .EQ. 6)) PNT = 25
C----------
C  ASSIGN AF AND BF FROM R8DIB.  THIS DEPENDS UPON GEOGRAPHIC REGION
C  AND SPECIES.
C----------
      IGR = GR/10
C     OPEN(31,FILE='R8DIB',FORM='FORMATTED',
C    &      PAD='YES')
      CNT = 1
      ICNT=0
   30 ICNT=ICNT+1
      DO 40 J=1,17
         R8COEF(CNT,J)=TTMP2(ICNT,J)
   40 CONTINUE
      IF((IGR .EQ. NINT(R8COEF(CNT,1)) .AND. IVLSP .EQ.
     &    NINT(R8COEF(CNT,2))) .OR. (NINT(R8COEF(CNT,1)) .EQ. 9 .AND.
     &    IVLSP .EQ. NINT(R8COEF(CNT,2))))THEN
           AF = R8COEF(CNT,13)
           BF = R8COEF(CNT,14)
C          CLOSE(31)
      ELSE
           GOTO 30
      ENDIF
C----------
C  COMPUTE DIAMETER OF TREE AT 17.3 FEET.
C----------
       STFAC = 1.0
       IF(H .LE. 17.3) THEN
         STFAC = (H-.5)/(17.31-.5)
         H = 17.31
       ENDIF
       FCDOB = D * (AF + BF * (17.3/H)**2)
C----------
C  DECIDE WHAT DOB IS NEEDED.
C----------
       IF (PULPVO .EQV. .TRUE.) THEN
          TOPDIA = TOPD(ISPC)
       ELSEIF (SWVOL .EQV. .TRUE.)THEN
          TOPDIA = BFTOPD(ISPC)
       ENDIF
C----------
C  CALCULATE VARIABLES NEEDED FOR HEIGHT EQUATION.
C----------
       TOPD2 = TOPDIA*TOPDIA
       D2 = D*D
       D3 = D2*D
       FCDOB2=FCDOB*FCDOB
C---------
C  TRUNCATE G WHEN (1-4.5/H) =>0.0
C---------
       IF ((1.-4.5/H) .LT .01) THEN
       G= 0.00000000001
       ELSE
       G = (1.-4.5/H)**R1(PNT)
       ENDIF
C
       W = (R2(PNT) + R3(PNT)/D3)/(1-G)
C---------
C  TRUNCATE X WHEN (1-4.5/H) =>0.0
C---------
       IF ((1.-4.5/H) .LT .005) THEN
       X= 0.000000000012
       ELSE
       X = (1-4.5/H)**P(PNT)
       ENDIF
C---------
C  TRUNCATE Y WHEN (1-17.3/H) =>0.0
C---------
       IF ((1.-17.3/H) .LT .005) THEN
       Y= 0.000000000013
       ELSE
       Y = (1.-17.3/H)**P(PNT)
       ENDIF
C
       Z = (D2 - FCDOB2)/(X-Y)
       T = (D2-Z*X)
C----------
C  SET INDICATOR VARIABLES.
C----------
      IS = 0
      IB = 0
      IT = 0
      IM = 0
      IF(TOPD2 .GE. D2)IS = 1
      IF(D2 .GT. TOPD2 .AND. TOPD2 .GE. FCDOB2)IB=1
      IF(FCDOB2 .GT. TOPD2)IT=1
      IF(TOPD2 .GT.((A2(PNT)*(A1(PNT)-1.0)**2)*FCDOB2)) IM=1
C----------
C  CALCULATE HEIGHT
C----------
      V1= 0.
      V2= 0.
      SEG1 = 0.0
      SEG2 = 0.0
      SEG3 = 0.0
      IF (IT .EQ. 1) THEN
       V1 = H-17.3
       QA = A2(PNT) + IM*((1-A2(PNT))/A1(PNT)**2)
       QB = -2*A2(PNT) - IM*2*(1-A2(PNT))/A1(PNT)
       QC = A2(PNT) + (1-A2(PNT))*IM - TOPD2/FCDOB2
       V2 = (-QB - (SQRT(QB**2 - 4*QA*QC)))/(2*QA)
      ENDIF
      IF (IS .EQ. 1) THEN
       SEG1 = IS*H*(1.0-((TOPD2/D2-1.0)/W+G)**(1.0/R1(PNT)))
      ENDIF
      IF (IB .EQ. 1) THEN
       SEG2 = IB*H*(1-(X-(D2-TOPD2)/Z)**(1/P(PNT)))
      ENDIF
      SEG3 = IT*(17.3+V1*V2)
      HT = SEG1 + SEG2 + SEG3
      RETURN
      END
