      SUBROUTINE EVALNK (JOSTND,IEN,IALNK)
      IMPLICIT NONE
C----------
C  $Id: evalnk.f 767 2013-04-10 22:29:22Z rhavis@msn.com $
C----------
C
C     CALLED FROM EVMON & PPEVMI:  FOR A GIVEN EVENT, IEN, FINDS A
C     POINTER, IALNK, TO THE FIRST ACTIVITY GROUP (ROW IN IEVACT)
C     THAT CORRESPONDS TO THE EVENT.
C
C     EVENT MONITOR ROUTINE - NL CROOKSTON - JAN 1987 - MOSCOW, ID
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
COMMONS
C
      INTEGER IALNK,IEN,JOSTND,N,I
C
C     FIND THE EVENT IN THE EVENT/ACTIVITY LINKAGE ARRAY.
C
      N=IEVA-1
      DO 10 I=IEN,N
      IALNK=I
      IF (IEVACT(IALNK,1).EQ.IEN) GOTO 20
   10 CONTINUE
C
C     IF THE LOOP EXITS, THE PROGRAM CAN'T LINK THE EVENT TO AN
C     ACTIVITY GROUP.
C
      WRITE (JOSTND,11) IEVA,IEN,(IEVACT(I,1),I=1,N)
   11 FORMAT (/' IEVA,IEN,IEVACT(1 TO IEVA-1,1)='/10(1X,15I6))
      CALL ERRGRO (.TRUE.,18)
      IALNK=0
   20 CONTINUE
      RETURN
      END
