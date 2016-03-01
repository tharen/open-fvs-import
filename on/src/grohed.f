      SUBROUTINE GROHED (IUNIT)
      IMPLICIT NONE
C----------
C  **GROHED--LS DATE OF LAST REVISION:  10/13/11
C----------
C     WRITES HEADER FOR BASE MODEL PORTION OF PROGNOSIS SYSTEM
C
      INTEGER IUNIT
      CHARACTER DAT*10,TIM*8,VVER*7,DVVER*7,REV*10,SVN*4
      DATA DVVER/'ON 3.3'/
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
      WRITE (IUNIT,40) DVVER(4:7),SVN,REV,DAT,TIM
   40 FORMAT ('1',T10,'FOREST VEGETATION SIMULATOR',
     >  5X,'VERSION ',A,' (',A,') -- FVS-ONTARIO',
     >  T98,'RV:',A,T113,A,2X,A)
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
