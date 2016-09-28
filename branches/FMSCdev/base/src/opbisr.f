      SUBROUTINE OPBISR(N,IA,IF,IP)
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C     OPTION PROCESSING ROUTINE - NL CROOKSTON - JAN 1981 - MOSCOW
C
C     BINARY SEARCH ROUTINE:  FINDS THE SUBSCRIPT LOCATION OF IF IN
C     ARRAY IA.
C
C     N  = THE LENGTH OF IA.
C     IA = A LIST OF INTEGERS SORTED INTO ASCENDING ORDER
C     IF = AN INTEGER WHICH YOU WISH FIND IN IA.
C     IP = THE POSITION IN IA WHERE IF WAS FOUND; OR
C          0 WHEN IF IS NOT A MEMBER OF IA.
C
      INTEGER IA(*),IP,IF,N,IMID,ITOP,IBOT
C
      IMID=1
      IF (IF.LE.IA(1)) GOTO 40
      IMID=N
      IF (IF.GE.IA(N)) GOTO 40
      ITOP=1
      IBOT=N
   20 CONTINUE
      IMID=(IBOT+ITOP)/2
      IF (IF.GE.IA(IMID)) GOTO 30
      IBOT=IMID-1
      IF (IF.GT.IA(IBOT)) GOTO 40
      GOTO 20
   30 CONTINUE
      ITOP=IMID+1
      IF (IF.LT.IA(ITOP)) GOTO 40
      GOTO 20
   40 CONTINUE
      IP=IMID
      IF (IF.NE.IA(IP)) IP=0
      RETURN
      END
