      SUBROUTINE DBSEVM (ITODO,IACTK,IDT,JOSTND)
      IMPLICIT NONE
C----------
C $Id$
C----------
C     PURPOSE: TO RUN SCHEDULED DBS COMMANDS
C
C     AUTH: D. GAMMEL -- RMRS -- MOSCOW MAY 2003
C           NL CROOKSTON -- RMRS -- MOSCOW
C
C
COMMONS
C
C
      INCLUDE 'DBSCOM.F77'
C
C
COMMONS
C
      CHARACTER*2000 SQLCMD
      INTEGER ITODO,IACTK,IDT,IRC,KODE,JOSTND
      CALL OPGETC (ITODO,SQLCMD)

      IF (SQLCMD.EQ.' ') RETURN
C
C     PREPROCESS THE COMMAND STRING.
C
      IRC=1
      KODE=0
      IF (IACTK.EQ.101) THEN          ! 101 IS SQLIN
        !SPECIFY TRUE FOR SCHEDULED
        IF(ConnHndlIn.EQ.-1) CALL DBSOPEN(DSNIN,EnvHndlIn,
     -                            ConnHndlIn,DBMSIN,0,.FALSE.,KODE)
C       CHECK TO SEE IF CONNECTION WAS SUCCESSFUL
        IF (KODE.EQ.1) THEN
          WRITE (JOSTND,100)TRIM(DSNIN)
  100     FORMAT(T12,'DBS ERROR: INPUT CONNECTION FAILED FOR DSN: ',A)
          RETURN
        ENDIF
        CALL DBSEXECSQL(SQLCMD,ConnHndlIn,.TRUE.,IRC)
      ELSE IF (IACTK.EQ.102) THEN     ! 102 IS SQLOUT
        !SPECIFY TRUE FOR SCHEDULED
        IF(ConnHndlOut.EQ.-1) CALL DBSOPEN(DSNOUT,EnvHndlOut,
     -                        ConnHndlOut,DBMSOUT,0,.FALSE.,KODE)
C       CHECK TO SEE IF CONNECTION WAS SUCCESSFUL
        IF (KODE.EQ.1) THEN
          WRITE (JOSTND,200)TRIM(DSNOUT)
  200     FORMAT(T12,'DBS ERROR: OUTPUT CONNECTION FAILED FOR DSN: ',A)
          RETURN
        ENDIF
        CALL DBSEXECSQL(SQLCMD,ConnHndlOut,.TRUE.,IRC)
      ENDIF
      IF (IRC.EQ.0) CALL OPDONE (ITODO,IDT)
      RETURN
      END