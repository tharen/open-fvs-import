      SUBROUTINE EXBUDL
      IMPLICIT NONE
C----------
C  $Id: exbudl.f 767 2013-04-10 22:29:22Z rhavis@msn.com $
C----------
C     THE PURPOSE OF THIS SUBROUTINE IS TO SATISFY EXTRA EXTERNAL
C     REFERENCES TO THE GENDEFOL/BUDWORM ("BUDLITE") MODEL              
C
      LOGICAL     L,LKECHO
      INTEGER     I1,I2,I3,KEY
      REAL        R1
      CHARACTER*8 KEYWRD,NOKEY
C
      DATA NOKEY/'*NO WSBE'/
C
      ENTRY BWECUP
      RETURN
C
      ENTRY BWEGO (L)
      L= .FALSE.
      RETURN
C
      ENTRY BWEINT
      RETURN
C
      ENTRY BWEIN(LKECHO)
      RETURN
C
      ENTRY BWEOUT
      RETURN
C
      ENTRY BWEKEY (KEY, KEYWRD)
      KEYWRD=NOKEY
      RETURN
C
      ENTRY BWEPPATV (L)
      L= .FALSE.
      RETURN
C
      ENTRY BWEPPGT (R1,I1,I2,I3)
      RETURN
C
      ENTRY BWEPPPT (R1,I1,I2,I3)
      RETURN
      END
