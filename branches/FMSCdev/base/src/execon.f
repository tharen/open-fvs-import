      SUBROUTINE EXECON
      IMPLICIT NONE
C----------
C  $Id$
C-------
C
C     EXTRA EXTERNAL REFERENCES FOR THE ECON EXTENSION.
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ECNCOM.F77'
C
C
      INTEGER I1,I2,I3,ICYC,IT,IS,II,IRECNT,KEY
      REAL PREM2,GROSPC,ARRAY22,D
      LOGICAL LNOTBK(7),LKECHO,LPRTND,LTMP
      CHARACTER*4 CARRAY(*),CH1_4,CARRAY2(*)
      CHARACTER*8 KEYWRD
      CHARACTER NPLT*26,ITITLE*72
C
      REAL ARRAY(*),ARRAY1(*)
      INTEGER IY(*),IARRAY(*)
C
C     ECSETP CALLED FROM CUTS

      ENTRY ECSETP(IY)
      RETURN
C
C     ECSETP CALLED FROM GRINCR
C
      ENTRY ECSTATUS(I3, I2, IARRAY, I1)
      RETURN
C
C     ECHARV CALLED FROM CUTS
C
      ENTRY ECHARV (ARRAY,D,ARRAY22,GROSPC,PREM2,IS,
     &  IT,ICYC,IY)
      RETURN
C
C     ECCALC CALLED FROM GRADD
C
      ENTRY ECCALC(IARRAY,II,CARRAY, CH1_4, NPLT, ITITLE)
      RETURN
C
C     ECLOAD CALLED FROM CUTS
C
      ENTRY GETISPRETENDACTIVE(LPRTND)
      LPRTND=.FALSE.
      RETURN
C
C     ECIN CALLED FROM INITRE
C
      ENTRY ECIN(IRECNT,I1,I2,CARRAY2,I3,LKECHO,IARRAY)
      CALL ERRGRO (.TRUE.,11)
      RETURN
C
C     ECKEY CALLED FROM OPLIST
C
      ENTRY ECKEY (KEY,KEYWRD)
      RETURN
C
C     ECINIT CALLED FROM INITRE
C
      ENTRY ECINIT
      isEconToBe=.FALSE.
      RETURN
C
C     ECVOL CALLED FROM VOLS
C
      ENTRY ECVOL (I1,I2,ARRAY,ARRAY1,LTMP)
      RETURN
C
C    ECNGET CALLED FROM GETSTD
C
      ENTRY ECNGET (ARRAY,I1,I2)
      RETURN
C
C    ECNPUT CALLED FROM PUTSTD
C
      ENTRY ECNPUT (ARRAY,I1,I2)
      RETURN
C
      END
