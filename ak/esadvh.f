      SUBROUTINE ESADVH (I,HHT,DELAY,GENTIM,TRAGE,WMAX)
      IMPLICIT NONE
C----------
C AK $Id$
C----------
C     CALCULATES HEIGHTS OF ADVANCE TREES FOR REGENERATION MODEL
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
      INCLUDE 'ESCOM2.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C
C
      INCLUDE 'ESHAP.F77'
C
C
COMMONS
C
C----------
C  VARIABLE DECLARATIONS:
C----------
C
      INTEGER I,N
C
      REAL AGE,BB,DELAY,GENTIM,HHT,TRAGE,WMAX,X
C
C----------
      N = INT(DELAY+0.5)
      IF(N.GT.2) N=1
      DELAY=REAL(N)
      TRAGE=3.0-DELAY
      AGE=3.0-DELAY-GENTIM
      IF(AGE.LT.1.0) AGE=1.0
      GO TO (10,20,30,40,50,60,70,80,90,100,100,100,110),I
C----------
C     HEIGHT OF TALLEST ADVANCE WHITE PINE.
C----------
   10 CONTINUE
      HHT = 1.0
      GO TO 120
C----------
C     HEIGHT OF TALLEST ADVANCE WESTERN RED CEDAR.
C----------
   20 CONTINUE
      BB = -0.26203 + 0.44249*TIME
   21 CALL ESRANN(X)
      IF(X .GT. WMAX) GO TO 21
      IF(NTALLY.EQ.1 .AND. X.LT.0.8) GO TO 21
      IF(NTALLY.EQ.2 .AND. X.GE.0.5) GO TO 21
      HHT = ((-(ALOG(1.0-X)))**(1.0/1.195))*BB
      GO TO 120
C----------
C     HEIGHT OF TALLEST ADVANCE PACIFIC SILVER FIR.
C----------
   30 CONTINUE
      HHT = 1.0
      GO TO 120
C----------
C     HEIGHT OF TALLEST ADVANCE MOUNTAIN HEMLOCK.
C----------
   40 CONTINUE
      HHT = 1.0
      GO TO 120
C----------
C     HEIGHT OF TALLEST ADVANCE WESTERN HEMLOCK.
C----------
   50 CONTINUE
      BB = -0.26203 + 0.44249*TIME
   51 CALL ESRANN(X)
      IF(X .GT. WMAX) GO TO 51
      IF(NTALLY.EQ.1 .AND. X.LT.0.8) GO TO 51
      IF(NTALLY.EQ.2 .AND. X.GE.0.5) GO TO 51
      HHT = ((-(ALOG(1.0-X)))**(1.0/1.195))*BB
      GO TO 120
C----------
C     HEIGHT OF TALLEST ADVANCE ALASKA CEDAR.
C----------
   60 CONTINUE
      BB = -0.26203 + 0.44249*TIME
   61 CALL ESRANN(X)
      IF(X .GT. WMAX) GO TO 61
      IF(NTALLY.EQ.1 .AND. X.LT.0.8) GO TO 61
      IF(NTALLY.EQ.2 .AND. X.GE.0.5) GO TO 61
      HHT = ((-(ALOG(1.0-X)))**(1.0/1.195))*BB
      GO TO 120
C----------
C     HEIGHT OF TALLEST ADVANCE LODGEPOLE PINE.
C----------
   70 CONTINUE
      HHT = 1.0
      GO TO 120
C----------
C     HEIGHT OF TALLEST ADVANCE SITKA SPRUCE.
C----------
   80 CONTINUE
      BB = -0.26203 + 0.44249*TIME
   81 CALL ESRANN(X)
      IF(X .GT. WMAX) GO TO 81
      IF(NTALLY.EQ.1 .AND. X.LT.0.8) GO TO 81
      IF(NTALLY.EQ.2 .AND. X.GE.0.5) GO TO 81
      HHT = ((-(ALOG(1.0-X)))**(1.0/1.195))*BB
      GO TO 120
C----------
C     HEIGHT OF TALLEST ADVANCE SUBALPINE FIR.
C----------
   90 CONTINUE
      HHT = 1.0
      GO TO 120
C----------
C     HEIGHT OF TALLEST ADVANCE HARDWOOD.
C----------
  100 CONTINUE
      HHT = 1.0
      GO TO 120
C----------
C     HEIGHT OF TALLEST ADVANCE OTHER SPECIES.
C----------
  110 CONTINUE
      HHT = 1.0
C
  120 CONTINUE
C----------
C  HEIGHTS TO TALL --- TEMPORARY FIX  11-20-93
C----------
      HHT=HHT*0.25
      IF(HHT.LT.1.0)HHT=1.0
      RETURN
      END
