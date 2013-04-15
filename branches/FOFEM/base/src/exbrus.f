      SUBROUTINE EXBRUS
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C     ENTRY POINTS FOR PROGNOSIS EXTERNAL REFERENCES TO
C     THE WHITE PINE BLISTER RUST MODEL SUBROUTINES WHEN
C     WHITE PINE BLISTER RUST IS NOT INCLUDED.
C
C
C
      LOGICAL LNOTBK(7),LKECHO
      CHARACTER*8 KEYWRD,NOBR
      REAL ARRAY(7),PROB(*),WEIGHT,TIME
      INTEGER IND(*),IND1(*)
      INTEGER I3(6),NCLAS,I1,I2,KEY,IREC,IVAC,I,ITFN
      DATA NOBR/'*NO BRUS'/

C     CALLED FROM COMPRS
C
      ENTRY BRCMPR (NCLAS,PROB,IND,IND1)
      RETURN

C     CALLED FROM DAMCDS
C
C     RNH
      ENTRY BRDAM (I1, I3)
      RETURN

C     CALLED FROM ESTAB
C
      ENTRY BRESTB (TIME, I1, I2)
      RETURN

C     CALLED FROM GRADD
C
      ENTRY BRTREG
      RETURN

C     CALLED FROM INITRE
C
      ENTRY BRINIT
      RETURN

      ENTRY BRIN (KEYWRD,ARRAY,LNOTBK,LKECHO)
      CALL ERRGRO (.TRUE.,11)
      RETURN

C     CALLED FROM MAIN
C
      ENTRY BRSETP
      RETURN

      ENTRY BRPR
      RETURN

      ENTRY BRROUT
      RETURN

C     CALLED FROM OPLIST
C
      ENTRY BRKEY (KEY,KEYWRD)
      KEYWRD=NOBR
      RETURN

C     CALLED FROM TREDEL
C
      ENTRY BRTDEL (IVAC,IREC)
      RETURN

C     CALLED FROM TRESOR
C
      ENTRY BRSOR
      RETURN

C     CALLED FROM TRIPLE
C
      ENTRY BRTRIP (ITFN,I,WEIGHT)
      RETURN

      END
