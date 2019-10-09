      SUBROUTINE ESPADV (IFT)
      IMPLICIT NONE
C----------
C AK $Id$
C----------
C     SUBROUTINE TO PREDICT THE PROBS OF ADVANCE SPECIES.
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
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'ESHAP.F77'
C
C WHY DOES THIS ROUTINE NEED ESHAP2?
      INCLUDE 'ESHAP2.F77'
C
C
COMMONS
C
C----------
C  VARIABLE DEFINITIONS:
C----------
C
C  IFT      -- STAND FOREST TYPE CATEGORY WHERE:
C                1 = 122
C                2 = 125
C                3 = 270
C                4 = 271
C                5 = 281
C                6 = 301
C                7 = 304
C                8 = 305
C                9 = 703
C               10 = 901
C               11 = 902
C               12 = 911
C               13 = OTHER (NO ADVANCED REGENERATION)
C  MAXSP    -- MAXIMUM NUMBER OF SPECIES, PASSED IN PRGPRM.F77
C  PNFT     -- FOREST TYPE COEFFICIENT (B1)
C  PNRDA    -- RELATIVE DENSITY COEFFICIENT (B2)
C  PBAPER   -- SPECIES BASAL AREA COEFFICIENT (B3)
C  PNEVEL   -- ELEVATION COEFFICIENT (B4)
C  PNSLO    -- SLOPE COEFFICIENT (B5)
C  PNTLAT   -- STAND LATTITUDE COEFFICIENT (B6)
C  PN       -- USED IN DETERMINING SPECIES PROBABILITY
C  XPRD     -- PLOT RELATIVE DENSITY >= REGNBK, PASSED IN AS 
C              PRDA(MAXPLOT) IN PDEN.F77
C  BAPER    -- PLOT SPECIES BASAL AREA >= REGNBK, PASSED IN AS 
C              OVER(MAXSP,MAXPLOT) IN PDEN.F77
C  ELEV     -- STAND ELEVATION (100S OF FEET), PASSED IN PLOT.F77
C  SLO      -- PLOT SLOPE IN PERCENT, PASSED IN ESCOMN.F77
C  TLAT     -- STAND LATTITUDE, PASSED IN PLOT.F77
C  NNID     -- BASE MODEL PLOT NUMBER, PASSE IN ESCOMN.F77
C  OCURFT   -- SPECIES OCCURANCE BY FOREST TYPE, 0=NO, 1=YES,
C              PASSED IN ESCOMN.F77
C  XESMLT   -- SPECIES MULTIPLIER, PASSED IN ESHAP.F77
C  PADV     -- SPECIES PROBABILITY, PASSED TO ESCOM2.F77
C----------
C  VARIABLE DECLARATIONS:
C----------
C
      INTEGER IFT, I, II, J
C
      REAL PN,PNFT(13,MAXSP),PNRDA(MAXSP),PBAPER(MAXSP),PNELEV(MAXSP), 
     & PNSLO(MAXSP),PNTLAT(MAXSP),B1,B2,B3,B4,B5,B6,XPRD,BAPER 
C
C----------
      DATA ((PNFT(I,II),I=1,13),II=1,MAXSP) / 
     &   0.000000,  0.000000, 0.000000,  0.000000,  1.471426,  0.000000,  ! 122 WHITE SPRUCE
     &  11.493216, -3.580646, 0.000000,  0.000000,  0.000000, -7.075718,
     &   0.000000,  0.000000, 0.000000,  9.120266,  0.000000,  0.000000,
     &  -4.358911,  5.749049, 0.000000,  0.000000,  0.000000, 
     &   0.000000,  0.000000, 0.000000,  0.000000,  1.243564,  0.000000,  ! 125 BLACK SPRUCE
     & -10.281310, -1.034805, 0.000000,  0.000000,  0.000000, -7.007493,
     &   0.000000,  0.000000, 0.000000,  9.144233,  0.000000,  0.000000,
     &  -4.194344,  8.251633, 0.000000,  0.000000,  0.000000, 
     &   0.000000,  0.000000, 1.458322,  0.000000,  3.030635,  0.000000,  ! 270 MOUNTAIN HEMLOCK
     &   0.000000, -4.170319, 1.482148, 36.588059, 13.217702, -6.973545,
     &   0.000000,  0.000000, 0.000000,  8.386837,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 1.769211,  0.000000,  0.000000,  0.000000,  ! 271 ALASKA CEDAR
     &   0.000000,  2.043042, 1.482148, 36.581927,  8.896936, -6.961341,
     &   0.000000,  0.000000,-1.474859,  0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,   
     &   0.000000,  0.000000, 1.274212,  0.000000,  0.000000,  0.000000,  ! 281 LODGEPOLE PINE
     &   0.000000,  3.712094, 1.482147, 36.572693, 13.369778, -6.895402,
     &   0.000000,  0.000000,-1.554912,  0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.176946,  0.000000,  0.000000,  0.000000, ! 301 WESTERN HEMLOCK
     &   0.000000, -4.481370, 1.482147, 36.062857, 13.323220, -7.393010,
     &   0.000000,  0.000000,-0.594657,  0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.826002,  0.000000,  0.000000,  0.000000, ! 304 WESTERN REDCEDAR
     &   0.000000,  1.532051, 1.482148, 36.266845, 14.203208, -6.746706,
     &   0.000000,  0.000000,-1.967077,  0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.540438,  0.000000,  0.000000,  0.000000, ! 305 SITKA SPRUCE
     &   0.000000,  1.431829, 1.482148, 36.266615, 14.509697, -7.005095,
     &   0.000000,  0.000000,-0.594657,  8.587479,  0.000000,  0.000000,
     &   0.000000,  6.747939, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  1.880453,  0.000000, ! 703 COTTONWOOD
     &  -9.726929,  1.710791, 0.000000,  0.000000, 11.118064, -7.071561,
     &   0.000000,  0.000000,-0.753581,  9.266584,  0.000000,  0.000000,
     &  -3.895989,  8.142779, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  2.661744,  0.000000, ! 901 ASPEN
     & -10.398359,  0.000000, 0.000000,  0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  9.902025,  0.000000,  0.000000,
     &  -4.514192,  7.457246, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.385405,  0.000000, ! 902 PAPER BIRCH
     &  -7.573761,  1.855650, 0.000000,  0.000000, 13.774044, -7.026493,
     &   0.000000,  0.000000, 0.000000,  8.789654,  0.000000,  0.000000,
     &  -3.726488,  6.523982, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,  0.000000, ! 911 RED ALDER
     &   0.000000,  2.797599, 0.000000,  0.000000, 13.516613,  0.000000,
     &   0.000000,  0.000000,-1.018934,  0.000000,  0.000000,  0.000000,
     &   0.000000, 11.306232, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,  0.000000, ! OTHER F.T.
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000 /
      DATA PNRDA / 
     &   0.000000, 0.000000,-2.788345, 0.000000, 0.693935, 0.000000,
     &   1.619417,-1.624496,-4.111564,-1.817895, 0.468398,-1.128078,
     &   0.000000, 0.000000, 0.000000,-2.241321, 0.000000, 0.000000,
     &  -0.935659,-1.019883, 0.000000, 0.000000, 0.000000 /
      DATA PBAPER / 
     &   0.000000, 0.000000, 0.683387, 0.000000, 2.466831, 0.000000,
     &  20.044319,-1.882619, 0.000000,-1.158645, 0.000000, 0.783047, 
     &   0.000000, 0.000000, 0.000000, 1.229318, 0.000000, 0.000000,
     &   3.537052, 4.898331, 0.000000, 0.000000, 0.000000 /
      DATA PNELEV /
     &  0.000000, 0.000000, 0.000685, 0.000000, 0.000500, 0.000000,
     &  0.000316, 0.000000, 0.000000, 0.000000,-0.000559, 0.000362, 
     &  0.000000, 0.000000, 0.000000,-0.000670, 0.000000, 0.000000,
     & -0.000716,-0.000636, 0.000000, 0.000000, 0.000000 /
      DATA PNSLO / 
     &  0.000000, 0.000000, 0.000000, 0.000000,-0.018294, 0.000000,
     & -0.039864, 0.000000, 0.009170, 0.000000, 0.000000,-0.007171,
     &  0.000000, 0.000000, 0.000000, 0.021199, 0.000000, 0.000000,
     &  0.042059, 0.022760, 0.000000, 0.000000, 0.000000 /
      DATA PNTLAT / 
     &  0.000000, 0.000000, 0.000000, 0.000000,-0.053831, 0.000000,
     &  0.115305, 0.000000, 0.000000,-0.630730,-0.207210, 0.137386,
     &  0.000000, 0.000000, 0.000000,-0.143896, 0.000000, 0.000000,
     &  0.053527,-0.159289, 0.000000, 0.000000, 0.000000 /
C CYCLE THROUGH SPECIES TO COMPUTE SPECIES PROBABILITIES
      DO 5 J=1,MAXSP
C  SET COEFFICIENTS FOR COMPUTING PN
        B1 = PNFT(IFT,J)
        B2 = PNRDA(J)
        B3 = PBAPER(J)
        B4 = PNELEV(J)
        B5 = PNSLO(J)
        B6 = PNTLAT(J)
        XPRD = PRDA(NNID)
        BAPER = OVER(J,NNID)
        PN = B1 + B2 * XPRD + B3 * BAPER + B4 * ELEV + 
     &       B5 * SLO + B6 * TLAT
        PADV(J) = (EXP(PN)/(1 + EXP(PN))) * OCURFT(IFT,J) * XESMLT(J)
    5 CONTINUE
C
C  MAKE SURE SPECIES PROBABILITIES ARE BETWEEN 0 AND 1.
      DO 10 II=1,MAXSP
      IF(PADV(II).LT.0.)PADV(II)=0.
      IF(PADV(II).GT.1.)PADV(II)=1.
   10 CONTINUE
C
      RETURN
      END
