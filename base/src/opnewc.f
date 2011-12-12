      SUBROUTINE OPNEWC (KODE,JOSTND,IREAD,IDT,IACTK,KEYWRD,KARD,
     >                   IPRMPT,IRECNT,ICYC)
      IMPLICIT NONE
C----------
C  **OPNEWC--BS DATE OF LAST REVISION:  07/23/08
C----------
C
C     OPTION PROCESSING ROUTINE - NL CROOKSTON - JULY 1988 - MOSCOW
C
C     OPNEWC IS USED TO ADD USER-SPCEIFED OPTIONS TO THE ACTIVITY LIST
C     WHEN THE OPTION USES EXPRESSIONS AS ARGUMENTS.
C
C     KODE  = THE RETURN CODE WHERE:
C             0   ALL WENT OK,
C             1   OPTION COULD NOT BE ADDED BECAUSE OF SOME ERROR
C     JOSTND= OUTPUT LOGICAL UNIT NUMBER.
C     IREAD = INPUT READER LOGICAL UNIT NUMBER.
C     IDT   = THE DATE, CYCLE, OR A ZERO (ALL CYCLES) CODE TO
C             INDECATE WHEN THE ACTIVITY IS TO BE IMPLIMENTED.
C     IACTK = THE ACTIVITY CODE.
C     KEYWRD= THE KEYWORD.
C     KARD  = ARRAY OF FIELDS STORED AS CHARACTERS.
C     IPRMPT= FIELD NUMBER WHERE 'PARMS' STARTS.
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
      INTEGER ICYC,IRECNT,IPRMPT,IACTK,IDT,IREAD,JOSTND,KODE,ICEX
      INTEGER J,K,I,IAMP,ISTLNB,IRC
      CHARACTER RECORD*80
      EQUIVALENCE (RECORD,WKSTR3)
      CHARACTER*10 KARD(7)
      CHARACTER*8 KEYWRD
      LOGICAL DEBUG
C
C     SEE IF WE NEED TO DO SOME DEBUG.
C
      CALL DBCHK (DEBUG,'OPNEWC',6,ICYC)
C
C     MOVE THE EXPRESSION INTO CEXPRS.
C
      ICEX=0
      DO 10 J=IPRMPT,7
      DO 10 K=1,10
      ICEX=ICEX+1
      CEXPRS(ICEX)=KARD(J)(K:K)
      CALL UPCASE(CEXPRS(ICEX))
   10 CONTINUE
C
C     WRITE THE FIRST LINE.
C
      WRITE (JOSTND,20) KEYWRD,IDT,(CEXPRS(I),I=1,ICEX)
   20 FORMAT (/1X,A8,'   DATE/CYCLE=',I5,';  ',70A1)
C
C     LOOK FOR AN AMPERSAND
C
      IAMP=0
      DO 30 I=1,ICEX
      IF (CEXPRS(I).EQ.'&') THEN
         IAMP=I
         GOTO 35
      ENDIF
   30 CONTINUE
   35 CONTINUE
C
C     IF THERE IS AN AMPERSAND, READ ANOTHER RECORD AND ADD IT TO CEXPRS
C
      IF (IAMP.GT.0) THEN
         ICEX=IAMP
         READ (IREAD,'(A)',END=200) RECORD
         J=ISTLNB(RECORD)
         IF (J.EQ.0) J=1
         IRECNT=IRECNT+1
         IAMP=0
         DO 50 I=1,J
         CALL UPCASE (RECORD(I:I))
         CEXPRS(ICEX)=RECORD(I:I)
         IF (CEXPRS(ICEX).EQ.'&') THEN
            IAMP=ICEX
            GOTO 55
         ENDIF
         ICEX=ICEX+1
         IF (ICEX.GT.MXEXPR) THEN
            CALL ERRGRO (.TRUE.,4)
            KODE=1
            RETURN
         ENDIF
   50    CONTINUE
         ICEX=ICEX-1
   55    CONTINUE
         WRITE (JOSTND,'(T12,A)') RECORD(1:J)
         GOTO 35
      ENDIF
C
C     TRIM OFF TRAILING BLANKS.
C
      K=ICEX
      DO 60 I=K,1,-1
      IF (CEXPRS(I).EQ.' ') GOTO 60
      ICEX=I
      GOTO 65
   60 CONTINUE
   65 CONTINUE
C
C     STORE THE LOCATION OF THE OPCODE IN KODE.
C
      KODE=ICOD
C
C     COMPILE THE EXPRESSION.
C
      CALL ALGCMP(IRC,.FALSE.,CEXPRS,ICEX,JOSTND,DEBUG,1000,
     >   IPTODO,MXPTDO,IEVCOD,ICOD,MAXCOD,PARMS,IMPL,ITOPRM,MAXPRM)
C
C     IF THE RETURN CODE FROM THE COMPILATION IS NON ZERO, STORE
C     THE ACTIVITY.
C
      IF (IRC.GT.0) THEN
         KODE=1
         CALL ERRGRO (.TRUE.,12)
         RETURN
      ENDIF
C
C     STORE THE ACTIVITY AND THE PARAMETERS; INSURE THAT THE
C     ACTIVITY IS LISTED AS 'NOT ACCOMPLISHED'.
C     IF THE ACTIVITY IS TO BE STORED UNTIL AN EVENT OCCURS, THEN:
C     STORE THE POINTERS IN THE BOTTOM OF IACT.
C
      I=IMGL
      IF (LOPEVN) I=IEPT
      IACT(I,1)=IACTK
      IACT(I,4)=0
      IACT(I,5)=0
      IACT(I,2)=-KODE
      IACT(I,3)=0
      IDATE(I)=IDT
      LEVUSE=.TRUE.
C
C     IF THE ACTIVITY IS BEING STORED FOR SCHEDULING AFTER AN EVENT,
C     THEN: UPDATE THE VALUE OF IEPT.
C
      IF (LOPEVN) THEN
         IEPT=IEPT-1
      ELSE
C
C        ELSE: STORE THE POINTER IN IOPSRT AND UPDATE IMGL.
C
         IOPSRT(IMGL)=IMGL
         IMGL=IMGL+1
      ENDIF
      RETURN
  200 CONTINUE
      CALL ERRGRO (.FALSE.,2)
      RETURN
      END
