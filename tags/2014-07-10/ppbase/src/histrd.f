      SUBROUTINE HISTRD (IUNIT)
      IMPLICIT NONE
C----------
C  **HISTRD  DATE OF LAST REVISION:  07/31/08
C----------
C
C     READ THE SUMULATION HISTORY FILE AND STORE THE DATA.
C
C     PART OF THE PARALLEL PROCESSING EXTENSION OF PROGNOSIS SYSTEM.
C     N.L. CROOKSTON--FORESTRY SCIENCES LAB, MOSCOW, ID--JULY 1980
C
C     IUNIT = THE INPUT DATA SET REFERNECE NUMBER.
C
C     THE DATA FILE WILL BE REWOUND BEFORE THE HISTRY FILE IS READ
C     BUT WILL NOT BE REWOUND AFTER READING.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PPEPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'PPCNTL.F77'
C
C
      INCLUDE 'PPCISN.F77'
C
C
COMMONS
C
C     STORAGE ALLOCATION:
C
      REAL ALL(15000)
      INTEGER ISNUMS(3000),ICYCS(3000),LOCS(3000),IELTS(3000)
      INTEGER IUNIT,IPTS(3000)
      EQUIVALENCE (ALL(1),BFV(1)),(ALL(1),ISNUMS(1)),
     >            (ALL(3001 ),ICYCS(1)),
     >            (ALL(6001 ),LOCS (1)),
     >            (ALL(9001 ),IELTS(1)),
     >            (ALL(12001),IPTS (1))
C
C     REWIND THE HISTORY FILE AND INDICATE IT IS OPEN FOR INPUT.
C
      REWIND IUNIT
      LHIST=.TRUE.
C
C     INITIALIZE THE PRINT-DATA RECORD COUNTER
C
      NMPRTD=0
   40 CONTINUE
C
C     BUMP THE RECORD COUNT, IF OVER THE MAX ALLOWABLE; THEN:
C     EXIT VIA CALL TO ERRGRO.
C
      NMPRTD=NMPRTD+1
      IF (NMPRTD .GT. MXPRTD) CALL PPERRP (.FALSE.,10)
C
C     READ A RECORD.
C
      READ (IUNIT,100,END=200) ISNUMS(NMPRTD),CISNS(NMPRTD),
     >      LOCS(NMPRTD),IELTS(NMPRTD),ICYCS(NMPRTD)
  100 FORMAT (1X,I5,A11,T24,I5,2I6)
C
C     READ ANOTHER RECORD.
C
      GO TO 40
C
C     END-OF-DATA.
C
  200 CONTINUE
C
C     DROP NMPRTD DOWN ONE TO ACCOUNT FOR END OF FILE CONDITION.
C
      NMPRTD=NMPRTD-1
C
C     WRITE DEBUG OUTPUT
C
  230 CONTINUE
      IF (.NOT.PDEBUG) RETURN
      WRITE (JOPPRT,240) NOSTND,NMPRTD,NAVPRT
  240 FORMAT (/' IN HISTRD: NOSTND=',I4,'; NMPRTD=',I6,'; NAVPRT=',I6)
      RETURN
      END