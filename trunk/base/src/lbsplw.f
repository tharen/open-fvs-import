      SUBROUTINE LBSPLW (JOSTND)
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C     WRITE THE STAND POLICY LABEL SET ON DATA SET JOSTND
C
C     PART OF THE LABEL PROCESSING COMPONENT OF THE PROGNOSIS SYSTEM
C     N.L. CROOKSTON -- INTERMOUNTAIN RESEARCH STATION -- JAN 1987
C
C     JOSTND= PRINT MESSAGE FILE.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
COMMONS
C
      INTEGER JOSTND,I1,I2
C
C     IF LABEL PROCESSING HAS NOT BEEN ACTIVIATED, BRANCH TO EXIT.
C
      IF (.NOT.LBSETS) GOTO 40
C
C     IF THE STAND POLICY LABEL IS UNSET (LENSLS=-1) THEN: BRANCH
C     TO EXIT.
C
      IF (LENSLS.EQ.-1) GOTO 40
C
C     WRITE THE STAND LABEL SET.
C
      I1=1
      I2=100
   20 CONTINUE
      IF (I2.GT.LENSLS) I2=LENSLS
      IF (I1.EQ.1) THEN
         WRITE (JOSTND,'(/''STAND POLICIES:'',T19,A)') SLSET(I1:I2)
      ELSE
         WRITE (JOSTND,'(T19,A)') SLSET(I1:I2)
      ENDIF
      IF (I2.LT.LENSLS) THEN
         I1=I2+1
         I2=I2+100
         GOTO 20
      ENDIF
   40 CONTINUE
      RETURN
      END
