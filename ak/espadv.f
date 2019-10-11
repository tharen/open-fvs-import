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
     &   0.000000,  0.000000, 0.000000,  0.000000,  1.471425, 0.000000, ! 122 WHITE SPRUCE
     &  -11.88816, -3.580646, 0.000000,  0.000000,  0.000000,-9.559295,
     &   0.000000,  0.000000, 0.000000,  8.547234,  0.000000, 0.000000,
     &  -4.526472,  3.219113, 0.000000,  0.000000,  0.000000,      
     &   0.000000,  0.000000, 0.000000,  0.000000,  1.243563, 0.000000, ! 125 BLACK SPRUCE
     & -10.510008, -1.034805, 0.000000,  0.000000,  0.000000,-9.456109,
     &   0.000000,  0.000000, 0.000000,  8.643347,  0.000000, 0.000000,
     &  -4.375067,  5.941031, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 1.458321,  0.000000,  3.030634, 0.000000, ! 270 MOUNTAIN HEMLOCK
     &   0.000000, -4.170319, 1.482148, 36.588067, 13.217701, -9.40155,
     &   0.000000,  0.000000, 0.000000,  7.849981,  0.000000, 0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000, 
     &   0.000000,  0.000000,  1.76921,  0.000000,  0.000000, 0.000000, ! 271 ALASKA CEDAR
     &   0.000000,  2.043042, 1.482148, 36.581939,  8.896934,-9.090822,
     &   0.000000,  0.000000,-1.474859,  0.000000,  0.000000, 0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 1.274212,  0.000000,  0.000000, 0.000000, ! 281 LODGEPOLE PINE
     &   0.000000,  3.712095, 1.482147, 36.572701, 13.369776,-9.319077, 
     &   0.000000,  0.000000,-1.554912,  0.000000,  0.000000, 0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.176945,  0.000000,  0.000000, 0.000000, ! 301 WESTERN HEMLOCK
     &   0.000000,  -4.48137, 1.482147, 36.062864, 13.323218,-9.935344,
     &   0.000000,  0.000000,-0.594657,  0.000000,  0.000000, 0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.826001,  0.000000,  0.000000, 0.000000, ! 304 WESTERN REDCEDAR
     &   0.000000,  1.532052, 1.482148, 36.266853, 14.203206,-9.229601,
     &   0.000000,  0.000000,-1.967077,  0.000000,  0.000000, 0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.540438,  0.000000,  0.000000, 0.000000, ! 305 SITKA SPRUCE
     &   0.000000,   1.43183, 1.482148, 36.266622, 14.509695,-9.497144,
     &   0.000000,  0.000000,-0.594657,   7.97435,  0.000000, 0.000000,
     &   0.000000,  0.401228, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  1.880452, 0.000000, ! 703 COTTONWOOD
     &  -9.931552,  1.710791, 0.000000,  0.000000, 11.118062,-9.592054,
     &   0.000000,  0.000000,-0.753581,  8.743442,  0.000000, 0.000000,
     &  -4.042781,  5.809518, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  2.661743, 0.000000, ! 901 ASPEN
     & -10.566521,  0.000000, 0.000000,  0.000000,  0.000000, 0.000000,
     &   0.000000,  0.000000, 0.000000,  9.518702,  0.000000, 0.000000,
     &   -4.58838,  5.122209, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.385404, 0.000000, ! 902 PAPER BIRCH
     &   -6.29543,   1.85565, 0.000000,  0.000000, 13.774043,-9.555463,
     &   0.000000,  0.000000, 0.000000,  8.256621,  0.000000, 0.000000,
     &  -3.937314,  3.805018, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  0.000000, 0.000000, ! 911 RED ALDER
     &   0.000000,    2.7976, 0.000000,  0.000000, 13.516612, 0.000000,
     &   0.000000,  0.000000,-1.018934,  0.000000,  0.000000, 0.000000,
     &   0.000000,  9.663092, 0.000000,  0.000000,  0.000000,
     &   0.000000,  0.000000, 0.000000,  0.000000,  1.471425, 0.000000, ! OTHER F.T. MAPPED TO 122 WHITE SPRUCE
     &  -11.88816, -3.580646, 0.000000,  0.000000,  0.000000,-9.559295,
     &   0.000000,  0.000000, 0.000000,  8.547234,  0.000000, 0.000000,
     &  -4.526472,  3.219113, 0.000000,  0.000000,  0.000000 /
      DATA PNRDA / 
     &  0.000000,  0.000000, -2.788345,  0.000000,  0.693934, 0.000000,  
     &  1.570363, -1.624496, -4.111564, -1.817895,  0.468398,-1.200631,  
     &  0.000000,  0.000000,  0.000000,  -2.28833,  0.000000, 0.000000, 
     & -0.888837, -1.007344,  0.000000,  0.000000,  0.000000 /     
      DATA PBAPER / 
     &  0.000000,  0.000000,   0.68339,  0.000000,  2.466831, 0.000000,
     &  18.13823,  -1.88262,  0.000000, -1.158659,  0.000000,-0.157366,
     &  0.000000,  0.000000,  0.000000,  0.977943,  0.000000, 0.000000,
     &  3.337736,  5.003048,  0.000000,  0.000000,  0.000000 /
      DATA PNELEV /
     &  0.000000,  0.000000, 0.000685,  0.000000,    0.0005, 0.000000,
     &  0.000316,  0.000000, 0.000000,  0.000000, -0.000559, 0.000494,
     &  0.000000,  0.000000, 0.000000, -0.000676,  0.000000, 0.000000,
     &  -0.00069, -0.000651, 0.000000,  0.000000,  0.000000 /      
      DATA PNSLO / 
     &  0.000000,  0.000000, 0.000000,  0.000000, -0.018294,  0.000000,
     & -0.042474,  0.000000,  0.00917,  0.000000,  0.000000, -0.007242,
     &  0.000000,  0.000000, 0.000000,  0.021314,  0.000000,  0.000000,
     &  0.041635,  0.021902, 0.000000,  0.000000,  0.000000 /      
      DATA PNTLAT / 
     &  0.000000,  0.000000, 0.000000,  0.000000,-0.053831, 0.000000,
     &  0.119919,  0.000000, 0.000000, -0.630731, -0.20721, 0.183249,
     &  0.000000,  0.000000, 0.000000, -0.135065, 0.000000, 0.000000,
     &  0.055629, -0.122001, 0.000000,  0.000000, 0.000000 /    
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
      IF(IFT.EQ.13) PADV(II)=0.
   10 CONTINUE
C
      RETURN
      END
