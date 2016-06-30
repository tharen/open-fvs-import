      SUBROUTINE EXDFTM
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C     EXTRA EXTERNAL REFERENCES FOR DFTM CALLS
C
      INTEGER II,MGMID,KEY
      INTEGER ICODES(6)
      LOGICAL L,LKECHO
      CHARACTER*8 KEYWRD,NODFTM
      CHARACTER*26 NPLT
C
      DATA NODFTM/'*NO DFTM'/
      ENTRY TMINIT
      RETURN
      ENTRY DFTMIN(LKECHO)
      CALL ERRGRO (.TRUE.,11)
      RETURN
      ENTRY TMDAM (II,ICODES)
      RETURN
      ENTRY TMOPS
      RETURN
      ENTRY TMCOUP
      RETURN
      ENTRY DFTMGO (L)
      L = .FALSE.
      RETURN
      ENTRY TMBMAS
      RETURN
      ENTRY TMHED (NPLT,MGMID)
      RETURN
      ENTRY TMOUT
      RETURN
      ENTRY TMKEY(KEY,KEYWRD)
      KEYWRD=NODFTM
      RETURN
      END
