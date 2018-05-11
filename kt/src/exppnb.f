      SUBROUTINE EXPPNB
      IMPLICIT NONE
C----------
C KT $Id: exppnb.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C
C     VARIANT DEPENDENT EXTERNAL REFERENCES FOR THE
C     PARALLEL PROCESSING EXTENSION
C
C
C     CALLED TO COMPUTE THE DDS MODIFIER THAT ACCOUNTS FOR THE DENSITY
C     OF NEIGHBORING STANDS (CALLED FROM DGF).
C
      REAL BSBA,BBAL,BCCF2,BCCF,DBH,BAO,CCFO,BALO,XPPDDS,BLBA,ALBAO
      REAL XPPMLT
      INTEGER JSPC
      REAL RDANUW
      INTEGER IDANUW
C----------
C  ENTRY PPDGF
C----------
      ENTRY PPDGF (XPPDDS,BALO,CCFO,BAO,DBH,BCCF,BCCF2,
     &             BBAL,BSBA,JSPC)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = XPPDDS
      RDANUW = BALO
      RDANUW = CCFO
      RDANUW = BAO
      RDANUW = DBH
      RDANUW = BCCF
      RDANUW = BCCF2
      RDANUW = BBAL
      RDANUW = BSBA
      IDANUW = JSPC
C
      RETURN
C----------
C  ENTRY PPREGT
C----------
C
C     CALLED TO COMPUTE THE REGENT MULTIPLIER THAT ACCOUNTS FOR
C     THE DENSITY OF NEIGHBORING STANDS (CALLED FROM REGENT).
C
      ENTRY PPREGT (XPPMLT,CCFO,BALO,ALBAO,BCCF,BBAL,BLBA,JSPC)
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = XPPMLT
      RDANUW = CCFO
      RDANUW = BALO
      RDANUW = ALBAO
      RDANUW = BCCF
      RDANUW = BBAL
      RDANUW = BLBA
      IDANUW = JSPC
C
      RETURN
      END
