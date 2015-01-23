      SUBROUTINE DUBSCR(ISPC,D,H,CR,TPCT,TPCCF)
      IMPLICIT NONE
C----------
C  **DUBSCR--WC   DATE OF LAST REVISION:  05/19/08
C----------
C
C  THIS SUBROUTINE CALCULATES CROWN RATIOS FOR TREES
C  IN THE INVENTORY THAT ARE MISSING CROWN RATIO
C  MEASUREMENTS AND ARE LESS THAN 1.0 INCH DBH.
C
C  ALSO USED TO DUB CROWN RATIOS FOR ALL DEAD TREES.
C
C  SF,WF,GF,AF,RF,NF,ES  USES BCR_(1) COEFFICIENTS
C  DF USES BCR_(2) COEFFICIENTS
C  YC,IC,RC,WH,MH USES BCR_(3) COEFFICIENTS
C  LP,JP,SP,WP,PP,LL,WB,KP,PY USES BCR_(4) COEFFICIENTS
C  BM,RA,WA,PB,GC,AS,CO,WO,DG,HW,BC,WI CONSTANT ICR=5
C  J  CONSTANT ICR=9
C
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
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
COMMONS
C
      LOGICAL DEBUG
      EXTERNAL RANN
      REAL BCR0(6),BCR1(6),BCR2(6),CRSD(6),TPCCF,TPCT,CR,H,D,SD,FCR
      REAL BACHLO
      INTEGER IMAP(39),ISPC,IISPC
C
      DATA IMAP/7*1,2*3,1,5*4,2*2,3*3,8*5,6,4*4,6*5/
C
      DATA BCR0/
     & 8.042774, 8.477025, 7.558538, 6.489813, 5.000000, 9.000000/
      DATA BCR1/
     & 0.007198, -0.018033, -0.015637, -0.029815, 0.000000, 0.000000/
      DATA BCR2/
     & -0.016163, -0.018140, -0.009064, -0.009276, 0.000000, 0.000000/
      DATA CRSD/
     & 1.3167, 1.3756, 1.9658, 2.0426, 0.5, 0.5 /
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'DUBSCR',6,ICYC)
C----------
C  EXPECTED CROWN RATIO IS A FUNCTION OF SPECIES, HEIGHT,
C  AND BASAL AREA. THE EQUATION RETURNS A CROWN CODE VALUE 0-9
C----------
      IISPC=IMAP(ISPC)
      CR=BCR0(IISPC) + BCR1(IISPC)*H + BCR2(IISPC)*BA
C----------
C  ASSIGN A RANDOM ERROR TO THE CROWN RATIO PREDICTION
C  VALUES OF CRSD ARE THE STANDARD ERROR VALUES FROM REGRESSION
C----------
      SD=CRSD(IISPC)
   10 FCR=BACHLO(0.0,SD,RANN)
      IF(ABS(FCR).GT.SD) GO TO 10
      IF(DEBUG)WRITE(JOSTND,*)' IN DUBSCR H,BA,CR,FCR= ',
     &H,BA,CR,FCR
      CR=CR+FCR
C----------
C  CONVERT CODE VALUE TO A CROWN RATIO 0-100.
C----------
      CR=((CR-1.0)*10.0 + 1.0) / 100.
      IF(CR .GT. .95) CR=.95
      IF(CR .LT. .05) CR=.05
      IF(DEBUG)WRITE(JOSTND,600)ISPC,H,BA,CR
  600 FORMAT(' IN DUBSCR, ISPC= ',I2,' H= ',F5.1,' BA= ',F9.4,
     &' CR= ',F4.3)
      RETURN
      END