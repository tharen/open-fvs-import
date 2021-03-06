      SUBROUTINE DUBSCR(ISPC,D,H,CR,TPCT,TPCCF)
      IMPLICIT NONE
C----------
C NC $Id$
C----------
C  THIS SUBROUTINE CALCULATES CROWN RATIOS FOR TREES INSERTED BY
C  THE REGENERATION ESTABLISHMENT MODEL.  IT ALSO DUBS CROWN RATIOS
C  FOR TREES IN THE INVENTORY THAT ARE MISSING CROWN RATIO
C  MEASUREMENTS AND ARE LESS THAN 1.0 INCH DBH.  
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
C----------
      EXTERNAL RANN
      INTEGER ISPC
      REAL D,H,CR,FCR,SD,TPCT,TPCCF,BACHLO
      REAL BCR0(MAXSP),BCR1(MAXSP),BCR2(MAXSP),BCR3(MAXSP),
     & CRSD(MAXSP),BCR5(MAXSP),BCR6(MAXSP),
     & BCR8(MAXSP),BCR9(MAXSP),BCR10(MAXSP)
      REAL RDANUW
C----------
      DATA BCR0/
     & -1.669490, -1.669490,  -.426688,  -.426688,  -.426688,  -.426688,
     & -1.669490,  -.426688,  -.426688, -1.669490,  -2.19723/
C
      DATA BCR1/
     &  -.209765,  -.209765,  -.093105,  -.093105,  -.093105,  -.093105,
     &  -.209765,  -.093105,  -.093105,  -.209765,   .000000/
C
      DATA BCR2/
     &   .000000,   .000000,   .022409,   .022409,   .022409,   .022409,
     &   .000000,   .022409,   .022409,   .000000,   .000000/
C
      DATA BCR3/
     &   .003359,   .003359,   .002633,   .002633,   .002633,   .002633,
     &   .003359,   .002633,   .002633,   .003359,   .000000/
C
      DATA BCR5/
     &   .011032,   .011032,   .000000,   .000000,   .000000,   .000000,
     &   .011032,   .000000,   .000000,   .011032,   .000000/
C
      DATA BCR6/
     &   .000000,   .000000,  -.045532,  -.045532,  -.045532,  -.045532,
     &   .000000,  -.045532,  -.045532,   .000000,   .000000/
C
      DATA BCR8/
     &   .017727,   .017727,   .000000,   .000000,   .000000,   .000000,
     &   .017727,   .000000,   .000000,   .017727,   .000000/
C
      DATA BCR9/
     &  -.000053,  -.000053,   .000022,   .000022,   .000022,   .000022,
     &  -.000053,   .000022,   .000022,  -.000053,   .000000/
C
      DATA BCR10/
     &   .014098,   .014098,  -.013115,  -.013115,  -.013115,  -.013115,
     &   .014098,  -.013115,  -.013115,   .014098,   .000000/
C
      DATA CRSD/
     &  .5000,.5000,.6957,.6957,.6957,.9310,
     &  .6124,.6957,.6957,.4942,0.200/
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = TPCT
C-----------
C  CHECK FOR DEBUG.
C-----------
C     CALL DBCHK (DEBUG,'DUBSCR',6,ICYC)
C----------
C  EXPECTED CROWN RATIO IS A FUNCTION OF SPECIES, DBH, BASAL AREA, BAL,
C  AND PCCF.  THE MODEL IS BASED ON THE LOGISTIC FUNCTION,
C  AND RETURNS A VALUE BETWEEN ZERO AND ONE.
C----------
      CR = BCR0(ISPC)
     *   + BCR1(ISPC)*D
     *   + BCR2(ISPC)*H
     *   + BCR3(ISPC)*BA
     *   + BCR5(ISPC)*TPCCF
     *   + BCR6(ISPC)*(AVH/H)
     *   + BCR8(ISPC)*AVH
     *   + BCR9(ISPC)*(BA*TPCCF)
     *   + BCR10(ISPC)*RMAI
C----------
C  A RANDOM ERROR IS ASSIGNED TO THE CROWN RATIO PREDICTION
C  PRIOR TO THE LOGISTIC TRANSFORMATION.  LINEAR REGRESSION
C  WAS USED TO FIT THE MODELS AND THE ELEMENTS OF CRSD
C  ARE THE STANDARD ERRORS FOR THE LINEARIZED MODELS BY SPECIES.
C----------
      SD=CRSD(ISPC)
   10 FCR=BACHLO(0.0,SD,RANN)
      IF(ABS(FCR).GT.SD) GO TO 10
      IF(ABS(CR+FCR).GE.86.)CR=86.
      CR=1.0/(1.0+EXP(CR+FCR))
      IF(CR .GT. .95) CR = .950
      IF(CR .LT. .05) CR=.05
C     IF(DEBUG)WRITE(JOSTND,600)ISPC,D,H,TBA,TPCCF,CR,FCR,RMAI
C 600 FORMAT(' IN DUBSCR, ISPC=',I2,' DBH=',F4.1,' H=',F5.1,
C    & ' TBA=',F7.3,' TPCCF=',F8.4,' CR=',F4.3,
C    &   ' RAN ERR = ',F6.4,' RMAI= ',F9.4)
C
      RETURN
      END
