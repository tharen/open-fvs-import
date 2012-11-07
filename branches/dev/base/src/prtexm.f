      SUBROUTINE PRTEXM (INPUT,IPRINT,ITITLE)
      IMPLICIT NONE
C----------
C  **PRTEXM--BASE   DATE OF LAST REVISION:  07/23/08
C----------
C
C     READS THE DATA THAT COMPRISES THE EXAMPLE TREE AND STAND
C     ATTRIBUTE TABLE FROM AN UNFORMATTED DATA SET REFERENCED BY
C     INPUT, AND PRINTS THE TABLE IN LINE PRINTER FORMAT USING THE
C     DATA SET REFERENCE NUMBER IPRINT.  IF EATHER INPUT OR IPRINT
C     ARE ZERO, THE ROUTINE EXITS.
C
C     N.L. CROOKSTON--FORESTRY SCIENCES LAB, MOSCOW, ID--JUNE 1980
C
C     IRT   = THE UNFORMATTED RECORD TYPE IDENTIFER:
C
C             0= STAND IDENTIFIER RECORD; FIRST RECORD IN FILE.
C             1= STAND ATTRIBUTE RECORD WITHOUT A RESIDUAL RECORD
C             2= STAND ATTRIBUTE RECORD; A RESIDUAL RECORD FOLLOWS
C             3= THE RESIDUAL RECORD WHICH SHOULD ONLY FOLLOW A TYPE
C                2 RECORD.
C             4= YEAR AND PERIOD LENGTH RECORD.
C             5= EXAMPLE TREE RECORDS.
C
      CHARACTER*3 IONSP(6)
      CHARACTER*4 MGTID
      CHARACTER*26 NPLT
      CHARACTER*72 ITITLE
      INTEGER IPRINT,INPUT,IS,IRT,I1,I,IRTNCD
      INTEGER IFRAC(6)
      REAL DBHIO(6),HTIO(6)
      INTEGER IOICR(6)
      REAL DGIO(6),PCTIO(6)
      REAL PRBIO(6)
      INTEGER I2(2)
      REAL A5(5)
      DATA IFRAC/10,30,50,70,90,100/
      IF (INPUT*IPRINT .EQ. 0) RETURN
      REWIND INPUT
C----------
C  SET FLAG INDICATING THAT SAMPLE TREES HAVE NOT BEEN RESELECTED.
C----------
      IS=0
C----------
C  READ THE FIRST RECORD, THEN WRITE HEADINGS
C----------
      READ (INPUT,END=130) IRT,NPLT,MGTID
      IF (IRT .NE. 0) CALL ERRGRO(.FALSE.,19)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

      CALL GHEADS (NPLT,MGTID,0,IPRINT,ITITLE)
      GO TO 30
   10 CONTINUE
      READ (INPUT,END=120) IRT,I1,A5
      IF (IRT .NE. 1 .AND. IRT .NE. 2) CALL ERRGRO(.FALSE.,19)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

      WRITE (IPRINT,9008) I1,A5
 9008 FORMAT(74X,I3,6X,F4.1,4X,F6.0,4X,F5.0,6X,F5.1,3X,F6.1)
      IF (IRT .EQ. 1) GO TO 30
      READ (INPUT,END=120) IRT,A5
      IF (IRT .NE. 3) CALL ERRGRO(.FALSE.,19)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

      WRITE (IPRINT,9009) A5
 9009 FORMAT(70X,'RESIDUAL:',4X,F4.1,4X,F6.0,4X,F5.0,6X,F5.1,3X,F6.1)
   30 CONTINUE
      READ (INPUT,END=140) IRT,I2
      IF (IRT .NE. 4) CALL ERRGRO(.FALSE.,19)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

C----------
C  IF DATE IS NEGETIVE, THE SAMPLE TREES WERE RESELECTED.  WRITE
C  **, SET FLAG FOR MSG, AND SET DATE POSITIVE.
C----------
      IF (I2(1).LT.0) GOTO 40
      WRITE (IPRINT,9010) I2
 9010 FORMAT(/1X,I4,42X,'(',I3,' YRS)'/)
      GOTO 50
   40 CONTINUE
      I2(1)=-I2(1)
      IS=1
      WRITE (IPRINT,9012) I2
 9012 FORMAT(/1X,I4,' **',39X,'(',I3,' YRS)'/)
   50 CONTINUE
      READ (INPUT,END=120) IRT,IONSP,DBHIO,HTIO,IOICR,DGIO,PCTIO,PRBIO
      IF (IRT .NE. 5) CALL ERRGRO(.FALSE.,19)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

      WRITE (IPRINT,9011) (IFRAC(I),IONSP(I),DBHIO(I),HTIO(I),IOICR(I),
     >                     DGIO(I),PCTIO(I),PRBIO(I),  I=1,6)
 9011 FORMAT(8X,I3,5X,A3,5X,F6.2,3X,F6.2,3X,I3,3X,F6.2,4X,F5.1,
     &       1X,F7.2)
      GO TO 10
C----------
C  END OF DATA TARGETS:
C----------
  120 CALL ERRGRO(.FALSE.,19)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

  130 CALL ERRGRO (.TRUE.,20)
  140 CONTINUE
      REWIND INPUT
      IF (IS.EQ.1) WRITE (IPRINT,9013)
 9013 FORMAT (/' ** NOTE:  DUE TO HARVEST, COMPRESSION, OR REGENER',
     >        'ATION ESTABLISHMENT, NEW SAMPLE TREES WERE SELECTED.')
      RETURN
      END
