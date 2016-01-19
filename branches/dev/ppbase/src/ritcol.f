      SUBROUTINE RITCOL (CBISN,IRCOL)
      IMPLICIT NONE
C----------
C  **RITCOL  DATE OF LAST REVISION:  07/31/08
C----------
C
C     FINDS THE RIGHTMOST NON-ZERO POSITON IN THE BRANCHING COMPONENT
C     OF AN INTERNAL STAND NUMBER AND RETURNS THE PLACE POINTER
C     AS VALUE 'IRCOL' (COUNTING FROM LEFT TO RIGHT).
C     IF IBISN IS ALL ZEROS, IRCOL IS RETURNED AS A ZERO.
C
C     PART OF THE PARALLEL PROCESSING EXTENSION OF PROGNOSIS SYSTEM.
C     N.L. CROOKSTON--FORESTRY SCIENCES LAB, MOSCOW, ID--JAN 1981
C
C     CBISN = BRANCHING PART OF AN INTERNAL STAND NUMBER.
C     IRCOL = RIGHTMOST NON-ZERO COLUMN IN IBISN.
C
      INTEGER IRCOL,IV
      CHARACTER CBISN*7
C
      IV=INDEX(CBISN,'0')
      IF (IV.LE.0) THEN
          IRCOL=7
      ELSEIF (IV.EQ.1) THEN
          IRCOL=0
      ELSE
          IRCOL=IV-1
      ENDIF
      RETURN
      END
