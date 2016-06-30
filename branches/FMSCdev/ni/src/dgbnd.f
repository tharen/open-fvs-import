      SUBROUTINE DGBND (ISPC,DBH,DDG)
      IMPLICIT NONE
C----------
C  **DGBND--NI  DATE OF LAST REVISION:  04/09/08
C----------
C  THIS SUBROUTINE IS INSURES THAT A MAXIMUM VALUE FOR DIAMETER
C  GROWTH IS NOT EXCEEDED.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
COMMONS
C
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
      INTEGER ISPC
      REAL DDG,DBH
C----------
      IF((DBH+DDG).GT.SIZCAP(ISPC,1) .AND. SIZCAP(ISPC,3).LT.1.5)THEN
        DDG=SIZCAP(ISPC,1)-DBH
        IF(DDG .LT. 0.01) DDG=0.01
      ENDIF
C
      RETURN
      END
