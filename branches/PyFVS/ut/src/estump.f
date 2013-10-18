      SUBROUTINE ESTUMP (JSSP,DBH,PREM,JPLOT,ISHAG)
      IMPLICIT NONE
C----------
C  **ESTUMP--UT   DATE OF LAST REVISION:  11/03/2009
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
      INCLUDE 'ESHOOT.F77'
C
C
      INCLUDE 'ESHAP.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C
C
COMMONS
C
C     STORE INFORMATION FOR STUMP SPROUT SUBROUTINE.
C
      INTEGER*4 MDBH,IPLT,MSP
      INTEGER ISHAG,JPLOT,JSSP,I,ISSP,IDBH
      REAL PREM,DBH,DBHEND
      DATA MDBH/10000000/,MSP/10000/
      DO 10 I=1,NSPSPE
      IF(JSSP.EQ.ISPSPE(I)) GO TO 11
   10 CONTINUE
      GO TO 900
   11 CONTINUE
      ISSP=I
C
C     DETERMINE DIAMETER CLASS OF THE TREE BEING CUT.
C
      DO 100 I=1,NDBHCL-1
      DBHEND=(DBHMID(I)+DBHMID(I+1))/2.0
      IF(DBH.GT.DBHEND) GO TO 100
      IDBH=I
      GO TO 110
  100 CONTINUE
      IDBH=NDBHCL
  110 CONTINUE
      IPLT=JPLOT
      IF(IPLT.GT.9999) IPLT=9999
      ITRNRM=ITRNRM+1
C----------
C ISHOOT() IS A NUMBER COMPOSED OF DDDSSSPPPP, WHERE DDD = DBH CLASS,
C SSS = SPECIES, AND PPPP = PLOT.  DECODED IN **ESUCKR**.
C PRBREM() CONTAINS AMOUNT OF PROB REMOVED IN CUTTING TREE RECORD.
C----------
      DSTUMP(ITRNRM) = DBH
      ISHOOT(ITRNRM) = IDBH*MDBH + ISSP*MSP + IPLT
      PRBREM(ITRNRM) = PREM
      JSHAGE(ITRNRM) = ISHAG
      IF(JSSP.EQ.6)THEN
        ASTPAR = ASTPAR + PREM
        ASBAR = ASBAR + 0.0054542*PREM*DBH**2.
      ENDIF
  900 CONTINUE
      RETURN
      END
