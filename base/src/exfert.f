      SUBROUTINE EXFERT
      IMPLICIT NONE
C----------
C  $Id: exfert.f 767 2013-04-10 22:29:22Z rhavis@msn.com $
C----------
C
C     EXTRA EXTERNAL REFERENCES FOR FERTILIZER CALLS
C
      LOGICAL LNOTBK(7),LKECHO
      REAL ARRAY(7)
      INTEGER IRECNT,JOSTND
      CHARACTER*8 KEYWRD
      CHARACTER*10 KARD(7)
C
      ENTRY FFIN (JOSTND,IRECNT,KEYWRD,ARRAY,LNOTBK,KARD,LKECHO)
      CALL ERRGRO (.TRUE.,11)
      RETURN
      ENTRY FFERT
      RETURN
      END
