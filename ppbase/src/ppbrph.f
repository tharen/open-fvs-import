      SUBROUTINE PPBRPH (IPH)
      IMPLICIT NONE
C----------
C  **PPBRPH   DATE OF LAST REVISION:  07/31/08
C----------
C
C     CALLED FROM TREGRO TO RETURN THE PROCESSING PHASE FOR THE
C     CURRENTLY PROCESSED STAND
C
C     PART OF THE PARALLEL PROCESSING EXTENSION OF PROGNOSIS SYSTEM.
C     N.L. CROOKSTON--FORESTRY SCIENCES LAB, MOSCOW, ID--FEB 1987
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PPEPRM.F77'
C
C
      INCLUDE 'PPCNTL.F77'
C
C
COMMONS
C
      INTEGER IPH
C
      IPH=ISNKEY(ISTND,4)
      RETURN
      END
