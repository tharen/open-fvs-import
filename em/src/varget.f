      SUBROUTINE VARGET (WK3,IPNT,ILIMIT,REALS,LOGICS,INTS)
      IMPLICIT NONE
C----------
C EM $Id: varget.f 1744 2016-03-28 21:01:34Z rhavis $
C----------
C
C     READ THE VARIANT SPECIFIC VARIABLES.
C
C     PART OF THE PARALLEL PROCESSING EXTENSION TO PROGNOSIS.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'EMCOM.F77'
C
C
COMMONS
C
C     NOTE: THE ACTUAL STORAGE LIMIT FOR INTS, LOGICS, AND REALS
C     IS MAXTRE (SEE PRGPRM).  
C
      INTEGER ILIMIT,IPNT,MXL,MXI,MXR
      PARAMETER (MXL=1,MXI=1,MXR=1)
      LOGICAL LOGICS(*)
      REAL WK3(MAXTRE)
      INTEGER INTS(*)
      REAL REALS(*)
C
C     GET THE INTEGER SCALARS.
C
      CALL IFREAD (WK3, IPNT, ILIMIT, INTS, MXI, 2)
      IEMTYP = INTS(1) 
C
C     GET THE LOGICAL SCALARS.
C
C**   CALL LFREAD (WK3, IPNT, ILIMIT, LOGICS, MXL, 2)
C
C     GET THE REAL SCALARS.
C
C**   CALL BFREAD (WK3, IPNT, ILIMIT, REALS, MXR, 2)
      RETURN
      END

      SUBROUTINE VARCHGET (CBUFF, IPNT, LNCBUF)
      IMPLICIT NONE
C----------
C     Get variant-specific character data
C----------

      INCLUDE 'PRGPRM.F77'

      INTEGER LNCBUF
      CHARACTER CBUFF(LNCBUF)
      INTEGER IPNT
      ! Stub for variants which need to get/put character data
      ! See /bc/varget.f and /bc/varput.f for examples of VARCHGET and VARCHPUT
      RETURN
      END
