      SUBROUTINE DGBND (ISPC,DBH,DDG)
      IMPLICIT NONE
C----------
C  **DGBND--WC   DATE OF LAST REVISION:   05/19/08
C----------
C  THIS SUBROUTINE IS USED TO INSURE THAT A MAXIMUM VALUE FOR DG
C  IS NOT EXCEEDED.
C
C ALL SPECIES USE THE SAME BOUNDING FUNCTION WHICH WAS DEVELOPED
C FOR DOUGLAS-FIR.
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
C MAX DG CHECK.
C----------
      INTEGER ISPC
      REAL DDG,DBH,TEMDBH,DGMAX
      TEMDBH=DBH
      IF(TEMDBH .GT. 150.)TEMDBH=150.
      DGMAX = 7.92*EXP(-0.03*TEMDBH)
      IF(DDG .GT. DGMAX) DDG = DGMAX
      IF(DDG .LT. 0.0) DDG = 0.0
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((DBH+DDG).GT.SIZCAP(ISPC,1) .AND. SIZCAP(ISPC,3).LT.1.5)THEN
        DDG=SIZCAP(ISPC,1)-DBH
        IF(DDG .LT. 0.01) DDG=0.01
      ENDIF
C
      RETURN
      END