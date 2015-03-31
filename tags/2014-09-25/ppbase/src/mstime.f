      SUBROUTINE MSTIME
      IMPLICIT NONE
C----------
C  **MSTIME  DATE OF LAST REVISION:  07/31/08
C----------
C
C     INSURES THAT THE MASTER TIME INTERVALS, STARTING YEAR, AND
C     NUMBER OF CYCLES ARE DEFINED AND INITIALIZED.
C
C     PART OF THE PARALLEL PROCESSING EXTENSION OF PROGNOSIS SYSTEM.
C     N.L. CROOKSTON--FORESTRY SCIENCES LAB, MOSCOW, ID--DEC 1979
C
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
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PPCNTL.F77'
C
C
COMMONS
C
      INTEGER I,J
C
C     NUMBER OF CYCLES:
C
      IF (LMCYC) GO TO 20
      MNCYC = NCYC
      IF (NCYC.GT.0) GOTO 20
      NCYC=1
      MNCYC=1
      LMCYC=.TRUE.
   20 CONTINUE
C
C     STARTING YEAR:
C
      IF (LSTYR) GO TO 40
      LSTYR=.TRUE.
      MIY(1) = IY(1)
   40 CONTINUE
C
C     SIGNAL THAT TIME INTERVALS HAVE BEEN SET (DONE IN PPINIT).
C
      LMINT=.TRUE.
C
C     INITIALIZE TIME MASTER INTERVAL ARRAY.
C
      DO 70 I=2,MAXCY1
      MIY(I)=MIY(I-1)+MIY(I)
   70 CONTINUE
C
      IF (PDEBUG) THEN
         J=MNCYC+1
         WRITE (JOSTND,80) MNCYC,(MIY(I),I=1,J)
   80    FORMAT (/' IN MSTIME, MNCYC =',I3,'; MIY ='/
     >           ((1X,20I5)))
      ENDIF
      RETURN
      END