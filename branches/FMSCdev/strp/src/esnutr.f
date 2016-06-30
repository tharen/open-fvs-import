      SUBROUTINE ESNUTR
      IMPLICIT NONE
C----------
C  **ESNUTR DATE OF LAST REVISION:  10/02/12
C----------
C
C     INTERFACE ROUTINE TO COUPLE THE REGEN MODEL AND PROGNOSIS.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'ESHAP.F77'
C
C
COMMONS
C
      INTEGER NCLAS,MYACT2(5),IESTB(3),NTODO,KDT,I,NP,IACTK,IDT,J,IGRP
      INTEGER IULIM,IG,IGSP,ITRGT,ISQ,KD,IST,NP1,NT,ITODO,NPNATS
      REAL PRMS(3)
      PARAMETER (NCLAS=MAXTRE*.4)
      LOGICAL DEBUG,LONE
      DATA IESTB/427,428,429/,MYACT2/95,440,442,430,431/
      LONE=.FALSE.
C
C     SET THE DEBUG OPTION
C
      CALL DBCHK (DEBUG,'ESNUTR',6,ICYC)
C
C     CALL ESADDT TO ADD TREES (OR OPTIONS) FROM EXTERNAL SOURCES
C
      CALL ESADDT(1)
C
C     PROCESS SPECMULT, STOCKADJ, AND HTADJ OPTIONS.
C
      CALL OPFIND (3,MYACT2,NTODO)
      IF (DEBUG) WRITE (JOSTND,5) NTODO
    5 FORMAT ('IN ESNUTR: OPTS NTODO=',I2)
      IF (NTODO.GT.0) THEN
         KDT=IY(ICYC)
         DO 60 I=1,NTODO
         CALL OPGET (I,2,IDT,IACTK,NP,PRMS)
         IF (IACTK.LT.0) GOTO 60
         IF (IACTK.EQ.95) THEN
           J=IFIX(PRMS(1))
           IF(J .LT. 0) THEN
             IGRP = -J
             IULIM = ISPGRP(IGRP,1)+1
             DO 19 IG=2,IULIM
             IGSP = ISPGRP(IGRP,IG)
             XESMLT(IGSP)=PRMS(2)
   19        CONTINUE
           ELSEIF (J .EQ. 0) THEN
             DO 20 J=1,MAXSP
             XESMLT(J)=PRMS(2)
   20        CONTINUE
           ELSE
             XESMLT(J)=PRMS(2)
           ENDIF
         ELSEIF (IACTK.EQ.440) THEN
           STOADJ=PRMS(1)
         ELSEIF (IACTK.EQ.442) THEN
           J=IFIX(PRMS(1))
           IF(J .LT. 0) THEN
             IGRP = -J
             IULIM = ISPGRP(IGRP,1)+1
             DO 21 IG=2,IULIM
             IGSP = ISPGRP(IGRP,IG)
             HTADJ(IGSP)=PRMS(2)
   21        CONTINUE
           ELSEIF (J .EQ. 0) THEN
             DO 30 J=1,MAXSP
             HTADJ(J)=PRMS(2)
   30        CONTINUE
           ELSE
             HTADJ(J)=PRMS(2)
           ENDIF
         ENDIF
         CALL OPDONE (I,KDT)
   60    CONTINUE
      ENDIF
C
C     IF THE DATE OF DISTURBANCE IS -9999 THEN IT HAS NEVER BEEN
C     ESTABLISHED...SET THE DEFAULT VALUE TO 20 YRS PRIOR TO INVENTORY.
C
      IF (IDSDAT.EQ.-9999) IDSDAT=IY(1)-20
C
C     SET DATE OF LAST REMOVAL.  RULES: IF MORE THAN ZERO TREES
C     HAVE BEEN CUT THIS CYCLE.
C
      IF (IYRLRM.EQ.-9999 ) IYRLRM=IY( 1  )-20
      IF (ONTREM(7).GT.0.0) IYRLRM=IY(ICYC)
C
C     LOGIC FOR CALLING THE SPROUT SUBROUTINE.
C
      IF (DEBUG) WRITE (JOSTND,70) ITRNRM,LSPRUT
   70 FORMAT ('IN ESNUTR: ITRNRM=',I5,'; LSPRUT=',L2)
      IF (LSPRUT) THEN
         IF (ITRNRM.GE.1) THEN
            IF(ITRN+ITRNRM.GT.MAXTRE) THEN
               ITRGT=MAXTRE-ITRNRM
               IF (NCLAS.GT.ITRGT) ITRGT=NCLAS
               CALL ESCPRS (ITRGT,DEBUG)
            ENDIF
            CALL ESUCKR
C
C           SET THE VALUE OF IREC1 TO POINT TO THE LAST LOCATION IN THE
C           TREELIST. CALL SPESRT TO REESTABLISH THE SPECIES ORDER SORT.
C
            IREC1=ITRN
            CALL SPESRT
C
C           REESTABLISH THE DIAMETER SORT (INCLUDE THE NEW TREES).
C
            IF (ITRN .GT. 0) CALL RDPSRT (ITRN,DBH,IND,.TRUE.)
C
C           SET IFST=1 SO THAT THE SAMPLE TREE RECORDS WILL BE REPICKED
C           NEXT TIME DIST IS CALLED.
C
            IFST=1
         ENDIF
      ELSE
C
C        INSURE THAT ITRNRM IS ZERO
C
         ITRNRM=0
      ENDIF
C
C     SET KDT TO THE LAST YEAR OF THE CYCLE.
C
      KDT=IY(ICYC+1)-1
C
C     FIND OUT IF THE REGEN MODEL IS TO BE CALLED THIS CYCLE.
C     FIRST, FIND ALL TALLYONE'S THAT ARE SCHEDULED FOR THIS CYCLE.
C
      CALL OPFIND (1,IESTB(2),NTODO)
C
C     IF THERE IS NO TALLYONE, LOOK FOR A TALLYTWO.
C
      IF (NTODO.EQ.0) THEN
         CALL OPFIND (1,IESTB(3),NTODO)
C
C        IF THERE IS NO TALLYTWO, BRANCH TO TALLY PROCESSING.
C
         IF (NTODO.EQ.0) GOTO 100
      ENDIF
C
C     GET EITHER TALLY (ONE OR TWO), COMPUTE NTALLY (THE TALLY NUMBER),
C     USING THE ACTIVITY CODES.
C
      CALL OPGET (NTODO,1,IDT,IACTK,NP,PRMS)
      IF (IACTK.LT.0) GOTO 100
      NTALLY=IACTK-427
      IDSDAT=IFIX(PRMS(1))
      LONE=.TRUE.
C      
C     CONVERT IDSDAT TO YEAR IF REQUIRED
C
      IF((IDSDAT.LT.1000).AND.(IDSDAT.GE.1))IDSDAT=IY(IDSDAT)
C
C     IF THE SCHEDULING OF TALLYONE OR TALLYTWO RESULTS IN THEM
C     BEING ACCOMPLISHED GREATER THAN 20 YEARS FROM THE DATE OF
C     DISTURBANCE, ISSUE AN ERROR MESSAGE, CANCEL THEM, RETURN.
C
      IF(KDT+1-IDSDAT.GT.20) THEN
         WRITE (JOSTND,80) IDSDAT,KDT,NTALLY
   80    FORMAT(/'REGENERATION MODEL CANNOT PREDICT REGENERATION',
     &     ' TALLIES BEYOND 20 YEARS FROM DATE OF DISTURBANCE',/,
     &     'DISTURBANCE DATE=',I6,'  TALLY DATE=',I6,'  TALLY=',I3)
         GOTO 300
      ENDIF
C
C     IF THIS IS A TALLYTWO: FIND OUT IF TALLYONE HAS BEEN EXECUTED
C     WITHIN THE LAST 19 YEARS.  IF ONE HAS NOT BEEN, CHANGE THE
C     TALLYTWO TO TALLYONE.
C
      IF (NTALLY.EQ.2) THEN
         ISQ=0
         CALL OPSTUS (428,IDSDAT,KDT,ISQ,NT,IDT,NP1,IST,KD)
         IF (KD.GT.0 .OR. IST.LE.IDSDAT) THEN
            WRITE (JOSTND,90) IY(ICYC+1)-1
   90       FORMAT (/,'TALLYTWO CHANGED TO TALLYONE. YEAR=',I4)
            NTALLY=1
         ENDIF
      ENDIF
      GOTO 200
  100 CONTINUE
C
C     CHECK FOR THE TALLY KEYWORD.
C
      CALL OPFIND (1,IESTB(1),NTODO)
C
      IF (DEBUG) WRITE (JOSTND,105) NTODO,IDSDAT
  105 FORMAT ('IN ESNUTR: NTODO=',I4,'; IDSDAT=',I5)
C
C     IF A TALLY ACTIVITY IS PRESENT, FIND THE ONE WITH THE 'LATEST'
C     DATE OF DISTURBANCE, SET NTALLY=1, CALL OPDONE, AND BRANCH TO
C     ESTAB CALLING SEQUENCE.
C
      IF (NTODO.GT.0) THEN
         IDSDAT=-1
         DO 110 ITODO=1,NTODO
         CALL OPGET(ITODO,1,IDT,IACTK,NP,PRMS)
         IF (IACTK.LT.0) GOTO 120
         I=IFIX(PRMS(1))
         IF (I.GT.IDSDAT) THEN
            IDSDAT=I
            ISQ=ITODO
         ENDIF
  110    CONTINUE
C      
C     CONVERT IDSDAT TO YEAR IF REQUIRED
C
         IF((IDSDAT.LT.1000).AND.(IDSDAT.GE.1))IDSDAT=IY(IDSDAT)
C
C        IF THE TALLY GREATER THAN 20 YEARS FROM THE DATE OF
C        DISTURBANCE, ISSUE AN ERROR MESSAGE, CANCEL THEM, RETURN.
C
         IF(KDT+1-IDSDAT.GT.20) THEN
            WRITE (JOSTND,80) IDSDAT,KDT,NTALLY
            GOTO 300
         ENDIF
C
         NTODO=ISQ
         NTALLY=1
         GOTO 200
      ENDIF
  120 CONTINUE
C
C     SET NUMBER OF ACTIVITIES TO DO TO ZERO...THE FOLLOWING LOGIC
C     TRIGGERS ESTAB CALLS WITHOUT AN ACTIVITY BEING PRESENT.
C
      NTODO=0
C
C     CALL ESTAB IF CURRENT DATE IS WITHIN 20-YRS OF A DISTURBANCE
C     AND IF NTALLY IS GT 0.
C
      IF (DEBUG) WRITE (JOSTND,150) KDT,IDSDAT,NTALLY
  150 FORMAT ('IN ESNUTR: KDT=',I6,'; IDSDAT=',I6,'; NTALLY=',I5)
C
      IF (KDT-IDSDAT.LE.19 .AND. NTALLY.GT.0) THEN
         PRMS(1)=FLOAT(IDSDAT)
         NTALLY=NTALLY+1
         PRMS(2)=FLOAT(NTALLY)
         NP=2
         KDT=IY(ICYC+1)-1
         CALL OPADD (KDT,IESTB(1),KDT,NP,PRMS,I)
         GOTO 200
      ENDIF
C
C     CALL ESTAB IF THERE ARE PLANT OR NATURAL KEYWORDS IN THE CASE
C     WHERE ESTAB WOULD NOT OTHERWISE BE CALLED.
C
      CALL OPFIND (2,MYACT2(4),NPNATS)
      IF (DEBUG) WRITE (JOSTND,170) NPNATS
  170 FORMAT ('IN ESNUTR: OPTS NPNATS=',I2)
      IF (NPNATS.GT.0) THEN
C
C        CALL ESTAB WITH NTALLY=1 AND AN OLD DATE OF DISTURBANCE
C
         NTALLY=1
         IDSDAT=IY(ICYC+1)-20
         IDT=0
         GOTO 200
      ENDIF
C
      IF (DEBUG) WRITE (JOSTND,'(''IN ESNUTR: NO ESTAB.'')')
C
      GOTO 400
C
C     CALLING SEQUENCE USED REGARDLESS OF THE OPTION FOR TALLIES.
C
  200 CONTINUE
C
C     THE DATE OF LAST REMOVAL IS NO OLDER THAN THE DATE OF DISTURB.
C
      IF (IYRLRM.LT.IDSDAT) IYRLRM=IDSDAT
C
C     IF ALL OF THE PLOTS ARE NONSTOCKABLE, WRITE A MSG, BRANCH
C     TO CANCEL THESE TALLIES, AND RETURN.
C
      IF (IPINFO.GE.4) THEN
         WRITE (JOSTND,210) NPLT,IY(ICYC+1)-1
  210    FORMAT (/,'NOTE: NONE OF THE PLOTS ARE STOCKABLE. ',
     >           ' STAND ID: ',A,'; YEAR=',I5)
         GOTO 300
      ENDIF
C
C     SIGNAL THAT THE TALLY IS DONE (ONLY IF NTODO IS GT 0).
C     THIS IS DONE BEFORE CALL TO ESTAB BECAUSE ESTAB CALLS OPFIND
C     AND CALLS TO OPFIND CANNOT BE NESTED.
C
      IF (NTODO.GT.0) CALL OPDONE (NTODO,KDT)
C
C     MAKE SURE THERE IS ROOM IN THE TREELIST TO HOLD NEW TREES.
C
      IF (ITRN.GT.MAXTRE*.7 .AND. NTODO.GT.0) CALL ESCPRS (NCLAS,DEBUG)
C
C     ESTABLISH NEW TREES
C
      IF (DEBUG) WRITE (JOSTND,220) IDT,IDSDAT,IYRLRM,LONE,
     >                              NTALLY,KDT,ITRN,NTODO
  220 FORMAT('IN ESNUTR: CALLING ESTAB: IDT=',I5,'; IDSDAT=',I5,
     >       '; IYRLRM=',I5,'; LONE=',L2/T13,'NTALLY=',I3,'; KDT=',
     >       I5,'; ITRN=',I5,'; NTODO=',I2)
C
      CALL ESTAB (KDT)
C
C     REESTABLISH THE DIAMETER SORT (INCLUDE THE NEW TREES).
C
      IF(ITRN .GT. 0) CALL RDPSRT (ITRN,DBH,IND,.TRUE.)
C
C     SET IFST=1 SO THAT THE SAMPLE TREE RECORDS WILL BE REPICKED
C     NEXT TIME DIST IS CALLED.
C
      IFST=1
C
C     IF THE CALL WAS BASED ON A TALLYONE OR TALLYTWO, OR
C     IF THE CALL WAS TRIGGERED BY A MODERATE REMOVAL, OR INGROWTH
C     THEN, SET NTALLY EQUAL TO 0.
C
      IF (LONE) NTALLY=0
  300 CONTINUE
C
C     FIND ALL OF THE TALLIES THAT ARE SCHEDULED FOR THIS CYCLE, BUT
C     NOT YET DONE, AND DELETE THEM.
C
      CALL OPFIND (3,IESTB,NTODO)
      IF(NTODO.GT.0) THEN
         DO 310 I=1,NTODO
         CALL OPDEL1(I)
  310    CONTINUE
      ENDIF
  400 CONTINUE
      RETURN
      END
