      SUBROUTINE GROHED (IUNIT)
      IMPLICIT NONE
C----------
C  **GROHED--SN DATE OF LAST REVISION:  02/22/13
C----------
C     WRITES HEADER FOR BASE MODEL PORTION OF PROGNOSIS SYSTEM
C
      INTEGER IUNIT
      CHARACTER DAT*10,TIM*8,VVER*7,DVVER*7,REV*10,SVN*4
      DATA DVVER/'SN     '/
      INCLUDE 'INCLUDESVN.F77'
C----------
C     CALL REVISE TO GET THE LATEST REVISION DATE FOR THIS VARIANT.
C----------
      CALL REVISE (DVVER,REV)
C
C     CALL THE DATE AND TIME ROUTINE FOR THE HEADING.
C
      CALL GRDTIM (DAT,TIM)
C
C     CALL PPE TO CLOSE OPTION TABLE IF IT IS OPEN.
C
      CALL PPCLOP (IUNIT)
C
      WRITE (IUNIT,40) SVN,REV,DAT,TIM
   40 FORMAT (//T10,'FOREST VEGETATION SIMULATOR',
     >  5X,'VERSION ',A,' -- SOUTHERN U.S. PROGNOSIS',
     >  T97,'RV:',A,T112,A,2X,A)
      RETURN
C
C
      ENTRY VARVER (VVER)
C
C     SUPPLY THE VARIANT AND VERSION NUMBER.
C
      VVER=DVVER
      RETURN
      END
