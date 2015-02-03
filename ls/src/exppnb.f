      SUBROUTINE EXPPNB
      IMPLICIT NONE
C----------
C  **EXPPNB-LS  DATE OF LAST REVISION:  07/11/08
C----------
C
C     VARIANT DEPENDENT EXTERNAL REFERENCES FOR THE
C     PARALLEL PROCESSING EXTENSION
C
      REAL BDBL,BBAL,BCCF,DBH,CCFO,BALO,XPPDDS,XPPMLT
C
C     CALLED TO COMPUTE THE DDS MODIFIER THAT ACCOUNTS FOR THE DENSITY
C     OF NEIGHBORING STANDS (CALLED FROM DGF).
C
      ENTRY PPDGF (XPPDDS,BALO,CCFO,DBH,BCCF,BBAL,BDBL)
      RETURN
C
C     CALLED TO COMPUTE THE REGENT MULTIPLIER THAT ACCOUNTS FOR
C     THE DENSITY OF NEIGHBORING STANDS (CALLED FROM REGENT).
C
      ENTRY PPREGT (XPPMLT,CCFO,BALO,BCCF,BBAL)
      RETURN
      END