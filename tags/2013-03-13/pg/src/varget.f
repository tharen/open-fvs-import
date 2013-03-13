      SUBROUTINE VARGET (WK3,IPNT,ILIMIT,REALS,LOGICS,INTS)
      IMPLICIT NONE
C----------
C  **VARGET--  DATE OF LAST REVISION:  09/18/08
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
C**   CALL IFREAD (WK3, IPNT, ILIMIT, INTS, MXI, 2)
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
