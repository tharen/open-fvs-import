      SUBROUTINE DBPRSE (IREAD,RECORD,JOUT,ICYC,IRC)
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C
COMMONS
C
C
      INCLUDE 'DBSTK.F77'
C
C
COMMONS
C
C
      INTEGER IRC,ICYC,JOUT,IREAD,ISTLNB,IS,IE,IP,LP,NC,IQ,II
      CHARACTER*(*) RECORD
      CHARACTER BLANK,AMPER
C
      DATA BLANK/' '/,AMPER/'&'/
      IRC=0
 3030 CONTINUE
      READ(IREAD,3035,END=3070) RECORD
 3035 FORMAT (A)
      WRITE (JOUT,3037) RECORD(1:ISTLNB(RECORD))
 3037 FORMAT (T13,A)
      IS=0
      IE=LEN(RECORD)+1
 3040 CONTINUE
      IE=IE-1
      IF ((RECORD(IE:IE).EQ.BLANK).AND.(IE.GT.1)) GOTO 3040
 3050 CONTINUE
      IS=IS+1
      IF ((RECORD(IS:IS).EQ.BLANK).AND.(IS.LT.IE)) GOTO 3050
      IF (RECORD(IS:IS).EQ.AMPER) GOTO 3030
      IF (IE.LT.IS) GOTO 9999
 3060 CONTINUE
      IP=INDEX(RECORD(IS:IE),BLANK)
      IF (IP.GT.0) THEN
        LP=IP+IS-2
      ELSE
        LP=IE
      ENDIF
      NC=LP-IS+1
      IQ=LP+1
      IF (NC.GT.MAXLEN) THEN
        LP=IS+MAXLEN-1
        NC=LP-IS+1
        IQ=LP
      ENDIF
      DO 3065 II=IS,LP
      CALL UPCASE (RECORD(II:II))
 3065 CONTINUE
      CALL DBADD (RECORD(IS:LP),NC,ICYC,IRC)
      IF (IRC.GT.0) GOTO 9999
      IS=IQ
      IF (IS.LT.IE) GOTO 3050
      GOTO 9999
 3070 CONTINUE
      IRC=1
 9999 CONTINUE
      RETURN
      END
