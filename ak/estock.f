      SUBROUTINE ESTOCK (TLAT,ELEV,IFT,XPRD,XPTA,PN)
      IMPLICIT NONE
C----------
C AK $Id$
C----------
C     CALCULATES PROBABILITY OF STOCKING FOR REGENERATION MODEL.
C     COEFFICIENTS FOR PLANTING ARE NOT INCLUDED IN EQUATIONS.
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
C               12 = 904 (MAPPED TO 703)
C               13 = 911
C               14 = OTHER (MAPPED TO 122)
C  XPRD     -- PLOT RELATIVE DENSITY >= REGNBK, (SDIZ/SDIMAX)
C  XPTA     -- PLOT TREES PER ACRE >= REGNBK
C  SLO      -- PLOT SLOPE IN PERCENT (ESCOMN.F77)
C  ELEV     -- STAND ELEVATION (100S OF FEET)
C  ELEVSQ   -- STAND ELEVATION (100S OF FEET) SQUARED (ESCOMN.F77)
C  XCOS     -- COSINE(ASPECT IN RADIANS) * SLOPE (ESCOMN.F77)
C  TLAT     -- STAND LATITUDE
C  PNFT     -- FOREST TYPE COEFFICIENT (B1)
C  PNRDA    -- RELATIVE DENSITY COEFFICIENT (B2)
C  PNPTPAA  -- TPA COEFFICIENT (B3)
C  PNSLO    -- SLOPE COEFFICIENT (B4)
C  PNEVEL   -- ELEVATION COEFFICIENT (B5)
C  PNELEVSQ -- ELEVATION SQUARED COEFFICIENT (B6)
C  PNXCOS   -- COS(ASPECT)*SLOPE COEFFICIENT (B7)
C  PNTLAT   -- STAND LATTITUDE COEFFICIENT (B8)
C  PN       -- USED IN DETERMINING PROBABILITY OF STOCKING
C----------
C  VARIABLE DECLARATIONS:
C----------  
      REAL PN,TLAT,ELEV,XPRD,XPTA,PNFT(14),PNRDA,PNPTPAA,PNSLO,
     &     PNELEV,PNELEVSQ,PNXCOS,PNTLAT,B1,B2,B3,B4,B5,B6,B7,B8
      INTEGER IFT
C
C----------
      DATA PNFT /
     & 1.913788,  3.05961, 2.409203, 3.477146, 3.427658,
     & 3.159311, 4.103006, 2.171868, 2.243229, 3.032731,
     &  2.08559, 2.243229, 2.074072, 1.913788 /
      DATA PNRDA / -1.11817 /
      DATA PNPTPAA / 0.001757 /
      DATA PNSLO / -0.00191 /
      DATA PNELEV / 0.000445 /
      DATA PNELEVSQ / -0.00000013 /
      DATA PNXCOS / -0.00189 /
      DATA PNTLAT / -0.03772 /
      
C  SET COEFFICIENTS FOR COMPUTING PN           
      B1 = PNFT(IFT)
      B2 = PNRDA
      B3 = PNPTPAA
      B4 = PNSLO
      B5 = PNELEV
      B6 = PNELEVSQ
      B7 = PNXCOS
      B8 = PNTLAT
      
      PN = B1 + B2 * XPRD + B3 * XPTA + B4 * SLO + B5 * ELEV + 
     &     B6 * ELEVSQ + B7 * XCOS + B8 * TLAT
C
      RETURN
      END
