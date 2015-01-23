      SUBROUTINE ESSUBH (I,HHT,EMSQR,DILATE,DELAY,ELEV,IHTSER,
     &  GENTIM,TRAGE)
      IMPLICIT NONE
C----------
C  **ESSUBH--ESTB   DATE OF LAST REVISION:   07/25/08
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ESPARM.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C
C
      INCLUDE 'ESCOM2.F77'
C
C
COMMONS
C
C     ASSIGNS HEIGHTS TO SUBSEQUENT AND PLANTED TREE RECORDS
C     CREATED BY THE ESTABLISHMENT MODEL.
C
      INTEGER IHTSER,I,N,ITIME,IAGE
      REAL TRAGE,GENTIM,ELEV,DELAY,DILATE,EMSQR,HHT,AGE,AGELN,BNORM,PN
      REAL UPRE(4,MAXSP),UHAB(5,MAXSP),UPHY(5,MAXSP)
C
C     UHAB CONTAINS COEFFICIENT FOR SUBSEQUENT HEIGHTS
C     BY SPECIES AND H.T. GROUP
C     H.T.GROUP--> WET DF  DRY D-FIR  GRAND F   WRC/WH     SAF
C
      DATA UHAB/   0.0,       0.0,      0.0,      0.0,    0.0,
     2           -0.01541, -0.03814,  0.11409,  0.35334,  0.0,
     3           -0.21858, -0.03354,  0.22756,  0.51988,  0.0,
     4             0.0,      0.0,      0.0,      0.0,     0.0,
     5             0.0,      0.0,      0.0,      0.0,     0.0,
     6             0.0,      0.0,      0.0,      0.0,     0.0,
     7           -0.29969, -0.15449,  0.04545, -0.00601,  0.0,
     8             0.0,      0.0,    0.18740,  0.26511,   0.0,
     9             0.0,      0.0,      0.0,      0.0,     0.0,
     O           -0.02287, -0.14710,  0.19278,  0.13817,  0.0,
     A             0.0,      0.0,      0.0,      0.0,     0.0/
C
C     UPRE HOLDS COEFFICIENTS FOR SUBSEQUENT HEIGHTS BY PREP/SPECIES
C     SITE PREP--> NONE      MECH       BURN      ROAD
C
      DATA UPRE/   0.0,      0.0,       0.0,      0.0,
     2             0.0,  -0.11310,  -0.06246,  0.009632,
     3             0.0,   0.06961,   0.19508,  0.17952,
     4             0.0,  -0.08010,   0.01032, -0.05975,
     5             0.0,      0.0,       0.0,     0.0,
     6             0.0,  -0.41961,  -0.22326,  0.15608,
     7             0.0,   0.11502,   0.02486,  0.13080,
     8             0.0,   0.10587,   0.27072,  0.16240,
     9             0.0,     0.0,       0.0,      0.0,
     O             0.0,   0.20729,   0.18491,  0.11864 ,
     A             0.0,      0.0,       0.0,     0.0/
C
C     UPHY HOLDS COEF'S FOR SUBS HEIGHTS BY PHYS & H.T. GROUP
C     PHYS.POS-->  BOTTOM    LOWER      MID      UPPER   RIDGE
C
      DATA UPHY/ -0.18731, -0.48682, -0.32160, -0.16113, 0.0,
     2             0.0,       0.0,       0.0,     0.0,   0.0,
     3           -0.27801, -0.20433, -0.12317, -0.26736, 0.0,
     4           -0.06976, -0.16483, -0.10900, -0.15873, 0.0,
     5             0.0,       0.0,       0.0,     0.0,   0.0,
     6             0.0,      0.0,      0.0,      0.0,    0.0,
     7            0.32401,  0.14743,  0.22165,  0.24559, 0.0,
     8            0.41120,  0.01164,  0.22217,  0.15834, 0.0,
     9             0.0,       0.0,      0.0,      0.0,   0.0,
     O             0.0,       0.0,      0.0,      0.0,   0.0 ,
     A             0.0,       0.0,       0.0,     0.0,   0.0/
C
C     COMING INTO ESSUBH, TRAGE IS THE AGE OF THE TREE AS SPECIFIED ON 
C     THE PLANT OR NATURAL KEYWORD.  LEAVING ESSUBH, TRAGE IS THE NUMBER 
C     BETWEEN PLANTING (OR NATURAL REGENERATION) AND THE END OF THE 
C     CYCLE.  AGE IS TREE AGE UP TO THE TIME REGENT WILL BEGIN GROWING 
C     THE TREE.
C
      N=DELAY+0.5
      IF(N.LT.-3) N=-3
      DELAY=FLOAT(N)
      ITIME=TIME+0.5
      IF(N.GT.ITIME) DELAY=TIME
      AGE=TIME-DELAY-GENTIM
      IAGE=AGE+0.5
      IF(IAGE.LT.1) IAGE=1
      AGE=AGE+TRAGE
      IF(AGE.LT.1.0) AGE=1.0
      AGELN=ALOG(AGE)
      BNORM=BNORML(IAGE)
      TRAGE=TIME-DELAY
      GO TO (10,20,30,40,50,60,70,80,90,100,110),I
C
C     HT OF TALLEST SUBS. WWP. 6JAN88 CARLSON
C
   10 CONTINUE
      PN= -1.51302 +1.24537*AGELN -0.003052*BAA +UPHY(IPHY,1)
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.46010)
      GO TO 120
C
C     HEIGHT OF TALLEST SUBSEQUENT WESTERN LARCH. 7JAN88 CARLSON
C
   20 CONTINUE
      PN= -1.36257 +1.21548*AGELN -0.003797*BAA +UHAB(IHTSER,2)
     &    +UPRE(IPREP,2)
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.52668)
      GO TO 120
C
C     HT OF TALLEST SUBS. D-FIR. 8JAN88 CARLSON
C
   30 CONTINUE
      PN= -2.16416 +1.28151*AGELN -0.0031363*BAA +UHAB(IHTSER,3)
     &    +UPRE(IPREP,3) +UPHY(IPHY,3) -0.09626*XCOS
     &    -0.23946*XSIN -0.14589*SLO
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.55942)
      GO TO 120
C
C     HT OF TALLEST SUBS. GRAND FIR. 6JAN88 CARLSON
C
   40 CONTINUE
      PN= -2.62001 +1.19408*AGELN -0.0035489*BAA +UPRE(IPREP,4)
     &    +UPHY(IPHY,4) +0.01871*XCOS +0.09002*XSIN -0.37365*SLO
     &    +0.05070*ELEV -0.000736*ELEV*ELEV
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.52958)
      GO TO 120
C
C     HT OF TALLEST SUBS. W. HEMLOCK. 7JAN88 CARLSON
C
   50 CONTINUE
      PN= -2.42379 +1.52366*AGELN -0.003256*BAA
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.54116)
      GO TO 120
C
C     HT OF TALLEST SUB. W.CEDAR.
C
   60 CONTINUE
      PN= -0.89895 +1.08584*AGELN -0.00205*BAA +UPRE(IPREP,6)
     &    -0.01594*ELEV
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.56107)
      GO TO 120
C
C     HT OF TALLEST SUBS. LPP. 7JAN88 CARLSON
C
   70 CONTINUE
      PN= -0.27105 +1.32027*AGELN -0.008208*BAA +UPRE(IPREP,7)
     &    +UPHY(IPHY,7) +UHAB(IHTSER,7) -0.15385*XCOS +0.04156*XSIN
     &    -0.49186*SLO -0.04744*ELEV +0.0003511*ELEV*ELEV
     &    +0.01105*BWAF +0.02588*BWB4
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.47557)
      GO TO 120
C
C     HT OF TALLEST SUBS. E. SPRUCE. 7JAN88 CARLSON
C
   80 CONTINUE
      PN= -2.93213 +1.43503*AGELN -0.002504*BAA +UPRE(IPREP,8)
     &    +UPHY(IPHY,8) +UHAB(IHTSER,8)
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.48951)
      GO TO 120
C
C     HT OF TALLEST SUBS. SAF.  6JAN88 CARLSON
C
   90 CONTINUE
      PN= -2.06377 +1.18184*AGELN -0.0044465*BAA +0.06615*XCOS
     &    +0.03085*XSIN -0.37402*SLO
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.56740)
      GO TO 120
C
C     HEIGHT OF TALLEST SUBSEQUENT PONDEROSA PINE.
C
  100 CONTINUE
      PN= -1.99480 +1.53946*AGELN -0.00402*BAA +UHAB(IHTSER,10)
     &    +UPRE(IPREP,10) -0.01155*ELEV
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.49076)
      GO TO 120
  110 CONTINUE
C
C     HT OF TALLEST SUBS. M. HEMLOCK (USES WH EQUATION).
C
      PN= -2.42379 +1.52366*AGELN -0.003256*BAA
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.54116)
  120 CONTINUE
      RETURN
      END