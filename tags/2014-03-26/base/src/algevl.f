      SUBROUTINE ALGEVL (LREG,MXL,XREG,MXX,IOPCD,MXCD,IYR1,IYRCUR,
     >                   LDB,JOUT,IRC)
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C     CALLED FROM EVMON, OPEVAL, EVTSTV, EVAGRP, HVTHN1, HVHRV1,
C                 AND HVALOC.
C
C     EVALUATES EXPRESSIONS AS COMPILED BY ALGCMP
C
C     N.L.CROOKSTON - APR 87 - FORESTRY SCIENCES LAB - MOSCOW, ID
C
C     LREG  = WORK SPACE USED TO HOLD THE LOGICAL STACK...AND...
C             (LOOK OUT FOR THIS ONE:)... THE BOTTOM OF THIS ARRAY
C             HOLDS STATUS CODES FOR CORRESPONDING MEMBERS OF XREG.
C             IF XREG(1) IS DEFINED, LREG(MXL) IS FALSE...IF XREG(2)
C             IS DEFINED LREG(MXL-2+1) IS FALSE...AND TRUE IF
C             UNDEFINED.  THIS ALLOWS THE DECADE AND TIME FUNCTIONS
C             TO IGNORE THE FACT THAT SOME ARGUMENTS ARE UNDEFINED.
C             SORRY ABOUT THIS, I JUST COULD NOT RESIST AVOIDING THE
C             CREATION OF ANOTHER ARRAY.
C     MXL   = MAX LENGTH OF LREG.
C     XREG  = WORK SPACE USED TO HOLD THE REAL STACK.
C     MXX   = MAX LENGTH OF XREG.
C     IOPCD = OPERATION CODE IN POSTFIX LOGIC.
C     MXCD  = MAX LENGTH OF IOPCD.
C     IYR1  = FIRST YEAR OF THE SIMULATION (USED BY THE DECADE FUNC.)
C     IYRCUR= CURRENT YEAR OF THE SIMULATION (USED BY THE DECADE AND
C             TIME FUNCTIONS).
C     LDEB  = TRUE IF DEBUG OUTPUT IS REQUESTED.
C     JOUT  = DEBUG OUTPUT DATA SET REFERENCE NUMBER.
C     IRC   = RETURN CODES, WHERE:
C             0=THE ANSWER YOU WANT IS LREG(1) IF THE EXPRESSION
C               IS A LOGICAL EXPRESSION OR XREG(1) IF THE EXPRESSION
C               IS AN ALGEBRAIC EXPRESSION.  IF THE PARMS FUNCTION IS
C               EXECUTED, XREG(1) IS THE NUMBER OF ARGUMENTS TO THE
C               PARMS FUNCTION AND XREG(2 TO 1+XREG(1)) IS THE
C               LIST OF ARGUMENTS.
C             1=THE OP-CODE REFERENCED AN UNDEFINED VARIABLE.
C             2=THE OP-CODE CONTAINED AN UNDECIPHERABLE CODE (OR
C               DIVIDE BY ZERO).
C             3=THE RESULT OF RUNNING THE OP-CODE LEFT VARIABLES ON
C               ONE OR BOTH OF THE STACKS.
C             4=ONE OF THE STACKS OVERFLOWED OR UNDERFLOWED.
C
      EXTERNAL RANN
      LOGICAL LREG(MXL),LDB
      REAL XREG(MXX)
      INTEGER IOPCD(MXCD)
      INTEGER IRC,JOUT,IYRCUR,IYR1,MXL,MXX,MXCD,ILSTK,IXSTK,IPC
      INTEGER INSTR,I,J,NDC,K,N
      REAL ALGSLP,X,BACHLO
C
C     NOTE: THIS ROUTINE USES RPN LOGIC TO EVALUATE LOGICAL
C     EXPRESSIONS. LREG IS AN ANALOG TO A LOGICAL STACK IN A COMPUTER,
C     AND XREG IS AN ANALOG TO A REAL STACK.  THEY ARE LOADED BY
C     INCREMENTING A STACK POINTER, AND PLACING THE NEW VALUE IN THE
C     STACK AT THE LOCATION POINTED TO BY THE POINTER.
C
C     INITIALIZE STACK POINTERS.
C
      ILSTK=0
      IXSTK=0
C
C     WRITE DEBUG OUTPUT...
C
      IF (LDB) WRITE (JOUT,1) MXL,MXX,MXCD,IYR1,IYRCUR
    1 FORMAT (/' IN ALGEVL: MXL=',I5,'; MXX=',I5,'; MXCD=',I5,
     >         '; IYR1=',I5,'; IYRCUR=',I5)
C
C     START DOWN THRU THE INSTRUCTION LIST.  THE LAST INSTRUCTION
C     WILL BE A STOP INSTRUCTION, SO BRANCH TO EXIT THE LOOP IF
C     THE OPCODE IS ZERO.
C
C     LET IPC BE A PROGRAM COUNTER.
C
      DO 1000 IPC=1,MXCD
C
C     LOAD THE INSTRUCTION.
C
      INSTR=IOPCD(IPC)
C
C     PRINT DEBUG INFO.
C
      IF (LDB) THEN
         IF (ILSTK.GT.0) WRITE (JOUT,11) (LREG(I),I=1,ILSTK)
   11    FORMAT (' LREG=',((T8,20L3)))
         IF (IXSTK.GT.0) THEN
            WRITE (JOUT,12) (XREG(I),I=1,IXSTK)
            WRITE (JOUT,11) (LREG(MXL-I+1),I=1,IXSTK)
   12       FORMAT (' XREG=',((T8,5E14.6)))
         ENDIF
         WRITE (JOUT,13) IPC,INSTR,ILSTK,IXSTK
   13    FORMAT (' PROG COUNTER=',I6,'; INSTR= ',I5,'; ILSTK= ',I4,
     >           '; IXSTK=',I4)
      ENDIF
C
C     IF INSTRUCTION IS A ZERO (END-OF-COMPUTIONS), THEN: BRANCH
C     TO EXIT LOOP.
C
      IF (INSTR.EQ.0) GOTO 1020
C
C     IF THE INSTRUCTION IS A NEGATIVE NUMBER, IT'S VALUE IS A
C     SPECIES CODE OR A SPECIES GROUP CODE. IF IT IS BETWEEN
C     -1 AND -1000 IT IS A SPECIES CODE AND IT NEEDS TO BE CHANGED
C     TO A POSITIVE NUMBER. IF IT IS LESS THAN -1000 THEN ADD
C     1000 TO THE NUMBER SO THAT IT IS < -1.
C     THEN LOAD THE RESULT ONTO THE XREG.
C
      IF (INSTR.LT.0) THEN
         IXSTK=IXSTK+1
         IF (IXSTK.GT.MXX .OR. ILSTK.GE.MXL-IXSTK+1) GOTO 2040
         IF (INSTR.LT. -1000) THEN
            INSTR = INSTR+1000
         ELSE
            INSTR = -INSTR
         ENDIF
         XREG(IXSTK)=FLOAT(INSTR)
         LREG(MXL-IXSTK+1)=.FALSE.
         GOTO 1000
      ENDIF
C
C     IS THE INSTRUCTION LOGICAL OR BOOLEAN?
C
      IF (INSTR.LE.9) GOTO 20
C
C     IS THE INSTRUCTION BINARY ARITHMETIC?
C
      IF (INSTR.GT.10 .AND. INSTR.LE.15) GOTO 100
C
C     IS THE INSTRUCTION UNARY ARITHMETIC (INCLUDING FUNCTIONS
C     OF ONLY ONE ARGUMENT)?
C
      IF (INSTR.LE.34) GOTO 70
C
C     IS THE INSTRUCTION A FUNCTION OF MORE THAN ONE ARGUMENT?
C
      IF (INSTR.GT.10000) GOTO 300
C
C     THE INSTRUCTION LOAD OPERAND: 100 < INSTR < 10000
C
      IF (INSTR.GT.100 .AND. INSTR.LT.10000) GOTO 200
      GOTO 2020
   20 CONTINUE
C
C     INSTRUCTION IS A LOGICAL OR BOOLEAN OPERATION.
C
C     RULES FOR LOGICAL/BOOLEAN OPERATIONS:
C     OPT CODE   NAME   PROGRAM OPERATION
C     --------   ----   ---------------------------------------------
C        1       NOT    SWITCH LREG(ILSTK)
C
C        2       AND    LOGICALLY AND LREG(ILSTK+1) AND LREG(ILSTK),
C        3        OR    LOGICALLY OR LREG(ILSTK+1) AND LREG(ILSTK),
C                       STORE RESULT IN LREG(ILSTK) AND POP THE STACK.
C
C        4        EQ
C        5        NE    INCREMENT ILSTK, COMPARE XREG(IXSTK) AND
C        6        GT    XREG(IXSTK+1), AND PUT THE RESULT IN
C        7        GE    LREG(ILSTK)
C        8        LT
C        9        LE
C
      IF (INSTR.EQ.1) THEN
C
C        IF THE LOGICAL STACK IS ZERO, THEN: STACK UNDERFLOW.
C
         IF (ILSTK.EQ.0) GOTO 2040
         LREG(ILSTK)=.NOT.LREG(ILSTK)
         GOTO 1000
      ENDIF
      IF (INSTR.LE.3) THEN
C
C        IF THE LOGICAL STACK IS LE 1, THEN: STACK UNDERFLOW.
C
         IF (ILSTK.LE.1) GOTO 2040
         ILSTK=ILSTK-1
         IF (INSTR.EQ.2) THEN
            LREG(ILSTK)=LREG(ILSTK+1).AND.LREG(ILSTK)
         ELSE
            LREG(ILSTK)=LREG(ILSTK+1).OR.LREG(ILSTK)
         ENDIF
         GOTO 1000
      ENDIF
C
C     INCREMENT THE LOGICAL STACK POINTER AND DECREMENT THE REAL
C     STACK POINTER.
C
      IXSTK=IXSTK-2
      IF (IXSTK.LT.0) GOTO 2040
      ILSTK=ILSTK+1
      IF (ILSTK.GT.MXL-IXSTK) GOTO 2040
C
C     IF EITHER OPERAND IS NOT DEFINED, BRANCH TO EXIT.
C
      IF (LREG(MXL-IXSTK).OR.LREG(MXL-IXSTK-1)) GOTO 2010
C
C     DECODE THE INSTRUCTION AND BRANCH TO OPERATION.
C
      I=INSTR-3
      GOTO (21,22,23,24,25,26),I
   21 CONTINUE
      LREG(ILSTK)=XREG(IXSTK+1).EQ.XREG(IXSTK+2)
      GOTO 1000
   22 CONTINUE
      LREG(ILSTK)=XREG(IXSTK+1).NE.XREG(IXSTK+2)
      GOTO 1000
   23 CONTINUE
      LREG(ILSTK)=XREG(IXSTK+1).GT.XREG(IXSTK+2)
      GOTO 1000
   24 CONTINUE
      LREG(ILSTK)=XREG(IXSTK+1).GE.XREG(IXSTK+2)
      GOTO 1000
   25 CONTINUE
      LREG(ILSTK)=XREG(IXSTK+1).LT.XREG(IXSTK+2)
      GOTO 1000
   26 CONTINUE
      LREG(ILSTK)=XREG(IXSTK+1).LE.XREG(IXSTK+2)
      GOTO 1000
   70 CONTINUE
C
C     UNARY OPERATIONS.
C     OPT CODE     OPERATION         OPT CODE    OPERATION
C     --------     -------------     --------    ----------
C        16        UNARY MINUS         22        SQRT
C        23        EXP                 24        ALOG
C        25        ALOG10              26        FRAC
C        27        INT                 28        SIN
C        29        COS                 30        TAN
C        31        ARCSIN              32        ARCCOS
C        33        ARCTAN              34        ABS
C
      IF (INSTR.EQ.16) THEN
         J=1
      ELSE
         J=INSTR-20
         IF (J.LT.2 .OR. J.GT.14) GOTO 2020
      ENDIF
C
C     ARITHMETIC UPON AN UNDEFINED VARIABLE CREATES AN UNDEFINED
C     VARIABLE.
C
      IF (LREG(MXL-IXSTK+1)) GOTO 1000
      GOTO (71,72,73,74,75,76,77,78,79,80,81,82,83,84),J
   71 CONTINUE
      XREG(IXSTK)=-XREG(IXSTK)
      GOTO 1000
   72 CONTINUE
      XREG(IXSTK)=SQRT(XREG(IXSTK))
      GOTO 1000
   73 CONTINUE
      XREG(IXSTK)=EXP(XREG(IXSTK))
      GOTO 1000
   74 CONTINUE
      XREG(IXSTK)=ALOG(XREG(IXSTK))
      GOTO 1000
   75 CONTINUE
      XREG(IXSTK)=ALOG10(XREG(IXSTK))
      GOTO 1000
   76 CONTINUE
      XREG(IXSTK)=XREG(IXSTK)-AINT(XREG(IXSTK))
      GOTO 1000
   77 CONTINUE
      XREG(IXSTK)=AINT(XREG(IXSTK))
      GOTO 1000
   78 CONTINUE
      XREG(IXSTK)=SIN(XREG(IXSTK))
      GOTO 1000
   79 CONTINUE
      XREG(IXSTK)=COS(XREG(IXSTK))
      GOTO 1000
   80 CONTINUE
      XREG(IXSTK)=TAN(XREG(IXSTK))
      GOTO 1000
   81 CONTINUE
      XREG(IXSTK)=ASIN(XREG(IXSTK))
      GOTO 1000
   82 CONTINUE
      XREG(IXSTK)=ACOS(XREG(IXSTK))
      GOTO 1000
   83 CONTINUE
      XREG(IXSTK)=ATAN(XREG(IXSTK))
      GOTO 1000
   84 CONTINUE
      XREG(IXSTK)=ABS(XREG(IXSTK))
      GOTO 1000
  100 CONTINUE
C
C     BINARY OPERATIONS ON THE XREG.
C     OPT CODE     OPERATION     OPT CODE   OPERATION
C     --------     -----------   --------   ---------
C        11        PLUS             12        MINUS
C        13        MULT             14        DIVIDE
C        15        RAISE TO A POWER.
C
C     DECREMENT THE STACK POINTER.
C
      IXSTK=IXSTK-1
      IF (IXSTK.LE.0) GOTO 2040
C
C     ARITHMETIC UPON UNDEFINED OPERANDS CREATES AN UNDEFINED
C     RESULT.
C
      LREG(MXL-IXSTK+1)=LREG(MXL-IXSTK+1).OR.LREG(MXL-IXSTK)
      IF (LREG(MXL-IXSTK+1)) THEN
         XREG(IXSTK)=0.0
         GOTO 1000
      ENDIF
C
C     DECODE INSTRUCTION, AND BRANCH.
C
      J=INSTR-10
      GOTO (101,102,103,104,105),J
  101 CONTINUE
      XREG(IXSTK)=XREG(IXSTK)+XREG(IXSTK+1)
      GOTO 1000
  102 CONTINUE
      XREG(IXSTK)=XREG(IXSTK)-XREG(IXSTK+1)
      GOTO 1000
  103 CONTINUE
      XREG(IXSTK)=XREG(IXSTK)*XREG(IXSTK+1)
      GOTO 1000
  104 CONTINUE
      IF (XREG(IXSTK+1).EQ.0.0) THEN
         LREG(MXL-IXSTK+1)=.TRUE.
      ELSE
         XREG(IXSTK)=XREG(IXSTK)/XREG(IXSTK+1)
      ENDIF
      GOTO 1000
  105 CONTINUE
      XREG(IXSTK)=XREG(IXSTK)**XREG(IXSTK+1)
      GOTO 1000
  200 CONTINUE
C
C     THE INSTRUCTION IS A LOAD XREG(IXSTK) INSTRUCTION.  INCREMENT
C     IXSTK AND LOAD THE VARIABLE INTO XREG(IXSTK).  MAKE SURE THERE
C     IS ROOM FOR THE NEW X AND ITS STATUS IN LREG.
C
      IXSTK=IXSTK+1
      IF (IXSTK.GT.MXX .OR. ILSTK.GE.MXL-IXSTK+1) GOTO 2040
      IF (INSTR.LT.7000) THEN
         CALL EVLDX (XREG(IXSTK),1,INSTR,IRC)
      ELSE
         CALL PPLDX (XREG(IXSTK),INSTR,IRC)
      ENDIF
      LREG(MXL-IXSTK+1)=.NOT.(IRC.EQ.0)
      IF (IRC.EQ.2) GOTO 2020
      GOTO 1000
  300 CONTINUE
C
C     OPERATIONS ON MORE THAN ONE ARGUMENT.  NN = THE NUMBER
C     OF ARGUMENTS IN THE FUNCTION.
C
C     OPT CODE     OPERATION     OPT CODE   OPERATION
C     --------     -----------   --------   ---------
C      101NN       MOD            102NN       DECADE
C      103NN       TIME           104NN       SUMSTAT
C      105NN       DBHDIST        106NN       SPMCDBH
C      107NN       PARMS          108NN       LININT
C      109NN       MIN            110NN       MAX
C      111NN       BOUND          112NN       BCCFSP
C      113NN       ACCFSP         114NN       MININDEX
C      115NN       MAXINDEX       116NN       NORMAL
C      117NN       FUELLOAD       118NN       SNAGS
C      119NN       POTFLEN        120NN       INDEX
C      121NN       POTFMORT       122NN       FUELMODS
C      123NN       SALVVOL        124NN       POINTID
C      125NN       STRSTAT        126NN       POTFTYPE
C      127NN       POTSRATE       128NN       POTREINT
C      129NN       TREEBIO        130NN       CARBSTAT
C      131NN       HTDIST         132NN       HERBSHRB
C      133NN       DWDVAL         134NN       ACORNS
C
C     LET I = THE OPT CODE, 1=MOD,2=DECADE,3=TIME,...
C         J = THE NUMBER OF OPERANDS = NN
C
      I=(INSTR/100)-100
      J=MOD(INSTR,100)
C
C     POP THE STACK J TIMES.  IXSTK NOW POINTS TO THE LOCATION
C     OF THE RESULT.  IF THE XREG STACK HAS FEWER THAN J ENTRIES,
C     STACK UNDERFLOW HAS OCCURRED.
C
      IF (IXSTK-J.LT.0) GOTO 2040
      IXSTK=IXSTK-J+1
C
C     BRANCH TO EXECUTE THE OPERATION.
C
      GOTO (2020,301,302,303,340,340,340,350,360,370,370,380,340,340,
     >   390,390,400,340,340,340,410,340,340,340,340,340,340,340,340,
     >   340,340,340,340,340,340,2020),(I+1)
  301 CONTINUE
C
C     IF EITHER ARGUMENT IS UNDEFINED, SO IS THE RESULT.
C
      LREG(MXL-IXSTK+1)=LREG(MXL-IXSTK+1).OR.LREG(MXL-IXSTK)
      IF (LREG(MXL-IXSTK+1)) GOTO 1000
C
C     PROTECT AGAINST DIVISION BY ZERO.
C
      IF (XREG(IXSTK+1).EQ.0.0) THEN
         LREG(MXL-IXSTK+1)=.TRUE.
      ELSE
         XREG(IXSTK)=AMOD(XREG(IXSTK),XREG(IXSTK+1))
      ENDIF
      GOTO 1000
C
C     COMPUTE THE DECADE FUNCTION.  THE RESULT CARRIES THE DEFINED
C     OR NOT DEFINED STATUS OF THE ARGUMENT THAT IS PICKED.  THUS
C     THE DECADE FUNCTION MAY BE A DEFINED FUNCTION OF SOME, BUT NOT
C     ALL, UNDEFINED ARGUMENTS.
C
  302 CONTINUE
      NDC=((IYRCUR-IYR1)/10)+1
      IF (NDC.GT.J) NDC=J
      LREG(MXL-IXSTK+1)=LREG(MXL-IXSTK-NDC+2)
      IF (.NOT.LREG(MXL-IXSTK+1)) XREG(IXSTK)=XREG(IXSTK+NDC-1)
      GOTO 1000
C
C     COMPUTE THE TIME FUNCTION.  THE TIME FUNCTION IS UNDEFINED IF
C     A CRITICAL YEAR LEVEL IS UNDEFINED OR IF THE CHOSEN ARGUMENT
C     CARRIES AN UNDEFINED STATUS.
C
  303 CONTINUE
      IF (J.LE.2) GOTO 320
      DO 310 NDC=(IXSTK+1),(IXSTK+J-1),2
      XREG(IXSTK)=XREG(NDC-1)
C
C     LET THE "DEFINED" STATUS OF THE ARGUMENT FOLLOW ON THE STACK.
C
      LREG(MXL-IXSTK+1)=LREG(MXL-NDC+2)
C
C     IF THERE IS AN ARGUEMENT FOLLOWING THE YEAR, THEN THE YEAR
C     IS CRITICAL TO THE RESULT.  IF THE YEAR IS UNDEFINED, SET
C     THE DEFINED STATUS OF THE RESULT TO UNDEFINED AND EXIT.
C
      IF (NDC+1.LE.(IXSTK+J-1)) THEN
         IF (LREG(MXL-NDC+1)) THEN
            LREG(MXL-IXSTK+1)=.TRUE.
            GOTO 320
         ENDIF
C
C        CHECK THE YEAR, IF THE CURRENT YEAR IS GE THE YEAR ON
C        THE STACK, THEN PICK THE NEXT ARGUMENT FOLLOWING THE DATE.
C
         IF (IYRCUR.GE.IFIX(XREG(NDC))) THEN
             XREG(IXSTK)=XREG(NDC+1)
             LREG(MXL-IXSTK+1)=LREG(MXL-NDC)
         ELSE
             GOTO 320
         ENDIF
      ENDIF
  310 CONTINUE
  320 CONTINUE
      GOTO 1000
C
C     DO THE SUMSTAT, DBHDIST, BCCFSP, ACCFSP, SPMCDBH, FUELLOAD,
C          SNAGS, POTFLEN, POTFMORT, FUELMODS, SALVVOL, 
C          POINTID, STRSTAT, POTFTYPE, POTSRATE, POTREINT, TREEBIO, 
C          HTDIST, HERBSHRB, DWDVAL AND ACORNS FUNCTIONS.
C
  340 CONTINUE
C
C     ALL THE ARGUMENTS MUST BE DEFINED.
C
      DO 345 NDC=(IXSTK+1),(IXSTK+J-1)
      LREG(MXL-IXSTK+1)=LREG(MXL-NDC+2)
      IF (LREG(MXL-IXSTK+1)) GOTO 1000
  345 CONTINUE
C
      CALL EVLDX (XREG(IXSTK),MXX-IXSTK+1,INSTR,IRC)
      LREG(MXL-IXSTK+1)=.NOT.(IRC.EQ.0)
      IF (IRC.EQ.2) GOTO 2020
      GOTO 1000
C
C     DO THE PARMS FUNCTION.
C     LREG(1) IS TRUE IF ALL PARMS ARE DEFINED, FALSE OTHERWISE
C     XREG(1) IS THE NUMBER OF PARAMETERS
C     XREG(2) IS THE FIRST PARAMETER, LREG(2) IS TRUE IF XREG(2)
C                                     IS DEFINED, FALSE OTHERWISE
C     XREG(3) IS THE SECOND, LREG(3) IS TRUE IF XREG(3) IS DEFINED
C     XREG(N+1) IS THE NTH, LREG(N+1) IS TRUE IF XREG(N+1) IS DEFINED
C
C     THE NUMBER OF ARGUMENTS J SHOULD BE EQUAL TO THE NUMBER OF VALUES
C     ON THE XREG AND THE MAX SIZE OF LREG MUST BE 2*J+1 OR LARGER.
C
  350 CONTINUE
      IF (J+1.GT.MXX .OR. J*2+1.GT.MXL) GOTO 2040
      LREG(1)=.TRUE.
      K=MXL
      DO 355 NDC=J+1,2,-1
      XREG(NDC)=XREG(NDC-1)
      LREG(NDC)=LREG(K)
      K=K-1
      LREG(1)=LREG(1).AND. .NOT.LREG(NDC)
  355 CONTINUE
      XREG(1)=J
      LREG(MXL)=.NOT.LREG(1)
      GOTO 1000
  360 CONTINUE
C
C     EVALUATE THE LINEAR INTERPOLATION FUNCTION.
C
      IF (J.GE.5 .AND. MOD(J-1,2).EQ.0) THEN
         DO 362 K=1,J
         IF (LREG(MXL-IXSTK+2-K)) GOTO 366
  362    CONTINUE
         XREG(IXSTK)=ALGSLP(XREG(IXSTK),XREG(IXSTK+1),
     >                      XREG(IXSTK+((J-1)/2)+1),(J-1)/2)
         LREG(MXL-IXSTK+1)=.FALSE.
         GOTO 1000
      ENDIF
  366 CONTINUE
      LREG(MXL-IXSTK+1)=.TRUE.
      XREG(IXSTK)=0.0
      GOTO 1000
  370 CONTINUE
C
C     COMPUTE THE MIN AND MAX FUNCTIONS.  IF THERE IS ONLY ONE ARG,
C     THE MIN OR MAX IS EQUAL TO THE ARG, SO SIMPLY BRANCH TO 1000.
C     USE THE FORTRAN MIN,MAX FUNCTIONS IN A PAIR-WISE MANNER.
C
      IF (J.EQ.1) THEN
         IF (LREG(MXL-IXSTK+1)) GOTO 376
         GOTO 1000
      ENDIF
      DO 372 K=2,J
      IF (LREG(MXL-IXSTK+2-K)) GOTO 376
      IF (I.EQ.9) THEN
         XREG(IXSTK)=AMIN1(XREG(IXSTK),XREG(IXSTK+K-1))
      ELSE
         XREG(IXSTK)=AMAX1(XREG(IXSTK),XREG(IXSTK+K-1))
      ENDIF
  372 CONTINUE
      GOTO 1000
  376 CONTINUE
      LREG(MXL-IXSTK+1)=.TRUE.
      XREG(IXSTK)=0.0
      GOTO 1000
  380 CONTINUE
C
C     COMPUTE THE BOUND FUNCTION
C
      IF (J.NE.3) GOTO 2040
      IF  (LREG(MXL-IXSTK+1).OR.LREG(MXL-IXSTK).OR.LREG(MXL-IXSTK-1)
     >    .OR.XREG(IXSTK).GE.XREG(IXSTK+2)) GOTO 366
      XREG(IXSTK)=AMIN1(AMAX1(XREG(IXSTK),XREG(IXSTK+1)),XREG(IXSTK+2))
      GOTO 1000
  390 CONTINUE
C
C     COMPUTE THE MININDEX AND MAXINDEX FUNCTIONS.
C
      IF (J.EQ.1) THEN
         IF (LREG(MXL-IXSTK+1)) GOTO 396
         XREG(IXSTK)=1.0
         GOTO 1000
      ENDIF
      N=0
      IF (I.EQ.14) THEN
         X=1E30
      ELSE
         X=-1E30
      ENDIF
      DO 392 K=1,J
      IF (LREG(MXL-IXSTK+2-K)) GOTO 396
      IF (I.EQ.14) THEN
         IF (XREG(IXSTK+K-1).LT.X) THEN
            N=K
            X=XREG(IXSTK+K-1)
         ENDIF
      ELSE
         IF (XREG(IXSTK+K-1).GT.X) THEN
            N=K
            X=XREG(IXSTK+K-1)
         ENDIF
      ENDIF
  392 CONTINUE
      IF (N.EQ.0) GOTO 2040
      XREG(IXSTK)=N
      GOTO 1000
  396 CONTINUE
      LREG(MXL-IXSTK+1)=.TRUE.
      XREG(IXSTK)=0.0
      GOTO 1000
C
C     COMPUTE THE NORMAL FUNCTION.
C
  400 CONTINUE
C
C     IF EITHER ARGUMENT IS UNDEFINED, SO IS THE RESULT...
C     AND THERE MUST BE EXACTLY 2 ARGUMENTS.
C
      LREG(MXL-IXSTK+1)=(J.NE.2).OR.LREG(MXL-IXSTK+1).OR.
     >                              LREG(MXL-IXSTK)
      IF (LREG(MXL-IXSTK+1)) GOTO 1000
      XREG(IXSTK)=BACHLO(XREG(IXSTK), XREG(IXSTK+1), RANN)
      GOTO 1000
C
C     COMPUTE THE INDEX FUNCTION.
C
  410 CONTINUE
      IF (J.LT.2) THEN
         LREG(MXL-IXSTK+1)=.TRUE.
         XREG(IXSTK)=0.0
         GOTO 1000
      ENDIF

C     IF FIRST ARGUMENT IS UNDEFINED, THE FUNCTION IS UNDEFINED.

      IF (LREG(MXL-IXSTK+1)) THEN
         XREG(IXSTK)=0.0
         GOTO 1000
      ENDIF

C     K IS THE ARGUMENT WE WANT...BOUNDED TO THE NUMBER OF ARGUMENTS.

      K = IFIX(XREG(IXSTK)+.5)
      IF (K.LT.1) K=1
      IF (K.GT.J-1) K=J-1

C     IF THE ARGUMENT WE WANT IS UNDEFINED, THEN THE RESULT IS UNDEFINED.

      IF (LREG(MXL-IXSTK+1-K)) THEN
         LREG(MXL-IXSTK+1)=.TRUE.
         XREG(IXSTK)=0.0
         GOTO 1000
      ENDIF

      XREG(IXSTK) = XREG(IXSTK+K)
      LREG(MXL-IXSTK+1)=.FALSE.
      GOTO 1000
C
 1000 CONTINUE
 1020 CONTINUE
C
C     END OF COMPUTATIONS.
C
      IF (ILSTK+IXSTK.EQ.1) THEN
         IRC=0
      ELSE
         IRC=3
      ENDIF
C
C     IF THE RESULT IS UNDEFINED, BRANCH TO CORRECT RETURN CODE.
C
      IF (LREG(MXL)) GOTO 2010
      RETURN
 2010 CONTINUE
      IRC=1
      RETURN
 2020 CONTINUE
      IRC=2
      RETURN
 2040 CONTINUE
      IRC=4
      RETURN
      END
