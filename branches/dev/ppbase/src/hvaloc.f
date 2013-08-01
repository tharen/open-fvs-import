      SUBROUTINE HVALOC
      IMPLICIT NONE
C----------
C  **HVALOC DATE OF LAST REVISION:  03/05/10
C----------
C
C     CALLED FROM ALSTD1...SET UP THE MULTISTAND SELCTION.
C        CALL PPWEIG TO FETCH THE STAND WEIGHTING FACTOR.
C        CALL GETSTD TO FETCH THE STAND
C        CALL EVTSTV TO STORE STATISTICS ABOUT THE STAND
C        CALL HVTHN1 TO COMPUTE YIELDS DERIVED ASSUMING THE STAND
C                    IS NOT SELECTED
C        CALL HVHRV1 TO COMPUTE YIELDS DERIVED ASSUMING THE STAND
C                    IS SELECTED
C        CALL ALGEVL TO EVALUATE PRIORITY, TARGET, AND CREDIT
C        CALL HVSEL  TO SET UP THE STATUS WORD FOR ALL OF
C                    THE STANDS AND POLICIES.
C        CALL HVDNSL TO SET UP THE DENSITY STATISTICS FOR REPRESENTING
C                    NEIGHBORING DENSITY EFFECTS.
C
C
C     MULTISTAND POLICY ROUTINE - N.L. CROOKSTON  - JULY 1987
C     FORESTRY SCIENCES LABORATORY - MOSCOW, ID 83843
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
      INCLUDE 'PPHVCM.F77'
C
C
      INCLUDE 'PPEXCM.F77'
C
C
      INCLUDE 'PPCNTL.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'HVDNCM.F77'
C
C
COMMONS
C
      LOGICAL LMORE,LBMEMR
      INTEGER IBA,IHV,J,I,LENHRV,IRC,II,IST
      REAL STAGEA,STAGEB,WEIGHT,A
C
C     INITIALIZE THE TARGET STATISTIC ARRAYS.
C
      DO 11 IHV=1,IXHRVP
      TRGETS(IHV)=0
      DO 10 J=1,8
      TRGSTS(J,IHV)=0
   10 CONTINUE
   11 CONTINUE
C
C     CHECK THE VALIDITY OF HIERARCHIES
C
      IF (MICYC.EQ.2) THEN
         IF (LHIER) THEN
            I=0
            DO 15 IHV=1,IXHRVP
            IF (IHVTAB(IHV,1).GT.0) I=I+1
   15       CONTINUE
            IF (I.LE.1) LHIER=.FALSE.
         ENDIF
      ENDIF
C
      IF (LHVDEB) WRITE (JOPPRT,'(/'' IN HVALOC, NOSTND='',
     >   I5,'' MICYC='',I3)') NOSTND,MICYC
C
C     IF EXTERNAL SELECTION IS BEING USED, THEN OPEN THE DATA FILE
C     THAT CONTAINS THE SELECTION INFORMATION
C
      IF (IHVEXT.EQ.1) THEN
         OPEN (UNIT=83,FILE='PPE_FFESelData.txt',STATUS='REPLACE')
         WRITE(83,16)
   16    FORMAT ('"StandID","Year","SelCode","CrBaseHt","CrBlkDen",',
     >          '"CanCov","TopHt","PBAK","PVolK","FM1","FM2","FM3",',
     >          '"FM4","WT1","WT2","WT3","WT4","1hrLoad","10hrLoad",',
     >          '"100hrLoad","1000hrLoad","HabType","ForTyp",'
     >          '"RTPA","Fire","FireYear"')
      ENDIF
C
C     LOOP THRU ALL OF THE STANDS, STORE PRIORITIES, CREDITS, AND
C     STATISTICS USED TO COMPUTE TARGETS FOR STANDS THAT
C     CAN CONTRIBUTE TO ANY POLICY.  SET THE INITIAL VALUE
C     OF THE STATUS WORD (IHVSTA) FOR EACH STAND AND POLICY.
C
      WRITE (*,17)
   17 FORMAT (/' Note: MSPolicy logic is starting.')

      DO 100 ISTND=1,NOSTND
C
      IF (LHVDEB) WRITE (JOPPRT,'('' IN HVALOC, ISTND='',I6,
     >   '' ID= '',A)') ISTND,STDIDS(ISTND)
      WRITE (*,18) ISTND,TRIM(STDIDS(ISTND)),NOSTND
   18 FORMAT (' Note: MSPolicy processing stand',I7,
     >        ' (ID: ',A,') of',I7)
C
C     GET THE STAND FROM DISK.
C
      CALL GETSTD
C
C     IF THIS IS THE BEGINNING OF THE FIRST MASTER CYCLE (MICYC=2)
C
      LMORE=.FALSE.
      IF (MICYC.EQ.2) THEN
C
C        SET THE INITIAL STATUS FOR THE STAND.
C
         DO 20 IHV=1,IXHRVP
C
C        IF THE FIRST PART OF THE MSPLABEL IS A MEMBER OF THE
C        STAND LABEL SET, THEN THE STAND IS A CANDIDATE AND MAY BE USED
C        IN CALCULATING THE TARGET SO SET THE STATUS TO 1. IF IT IS NOT
C        A CANDIDATE, SET THE STATUS TO ZERO.  IF THE STAND IS
C        NOT A CANDIDATE FOR ANY POLICY, GO ON TO THE NEXT STAND.
C
C        FIRST CHECK TO SEE IF THE POLICY IS DEFINED.
C
         IF (IHVTAB(IHV,1).EQ.0) THEN
            IHVSTA(ISTND,IHV)=0
         ELSE
            LENHRV=LNHPLB(IHV,2)
            WKHPLB=HVPLAB(IHV)(1:LENHRV)
            IF (LBMEMR(LENHRV,WKHPLB,LENSLS,SLSET)) THEN
               LMORE=.TRUE.
               IHVSTA(ISTND,IHV)=1
            ELSE
               IHVSTA(ISTND,IHV)=0
            ENDIF
         ENDIF
   20    CONTINUE
      ELSE
C
C        IF PAST THE FIRST MASTER CYCLE, THEN SIMPLY CHECK TO SEE IF
C        ALL OF THE STATUS CODES ARE ZERO OR NOT.
C
         DO 25 IHV=1,IXHRVP
         LMORE=IHVSTA(ISTND,IHV).NE.0
         IF (LMORE) GOTO 26
   25    CONTINUE
   26    CONTINUE
      ENDIF
      IF (LHVDEB) WRITE (JOPPRT,'(/'' IN HVALOC, ISTND='',I6,
     >   '' LMORE='',L2,'' ICYC='',I3,'' IHVSTA(ISTND,1:15)='',15I2)')
     >   ISTND,LMORE,ICYC,(IHVSTA(ISTND,IHV),IHV=1,IXHRVP)
C
C     IF THE STAND IS NOT NEEDED ANY LONGER, GO ON TO THE NEXT.
C
      IF (.NOT.LMORE) GOTO 100
C
C     IT IS NEEDED.  LOAD VARIABLES USED TO COMPUTE THE PRIORITIES
C     AND THE TARGET.  THIS IS DONE WITH A FULL CALL TO THE EVENT
C     MONITOR SO THAT ALL COMPUTE VARIABLES WILL BE UPDATED, EVEN
C     THOSE THAT FOLLOW AN IF TEST.  THE CALL IS MADE WITH THE
C     VALUE OF SELECTED SET TO "UNDEFINED" (UNSET).  IN THE CALL
C     TO HVTHN1, THE VALUE OF SELECTED IS SET TO NO AND THE EVENT
C     MONITOR IS RECALLED.
C
      IPHASE=1
      CALL OPCSET (ICYC)
      IBA = 1
      CALL SSTAGE (IBA,ICYC,.TRUE.)
      CALL SDICAL(BTSDIX)
      CALL SDICLS(0,0.,999.,1,SDIBC,SDIBC2,STAGEA,STAGEB,0)
      CALL EVUST4 (9)
      CALL EVMON (1,2)
C
C     GO BACK THRU THE POLICIES.  COMPUTE THE PRIORITY FOR THE
C     STAND AND SAVE THE STATISTICS NEEDED TO COMPUTE TARGETS.
C
      DO 90 IHV=1,IXHRVP
      IF (IHVSTA(ISTND,IHV).EQ.0) THEN
         HVPRI(ISTND,IHV)=0.0
      ELSE
         CALL ALGEVL (LREG,MXLREG,XREG,MXXREG,IPEXCD(IHVTAB(IHV,2)),
     >      MPEXCD-IHVTAB(IHV,2)+1,IY(1),IY(ICYC),LHVDEB,JOPPRT,IRC)
         IF (IRC.GE.1) THEN

C           UNDER EXTERNAL SELECTION LOGIC, IT IS NOT AN ERROR
C           TO HAVE THE PRIORITY CALCULATION FAIL AT THIS POINT

            IF (IHVEXT.NE.1) THEN
               CALL RCDSET (4,.TRUE.)
               CALL ERRGRO (.TRUE.,21)
               IHVSTA(ISTND,IHV)=0
            ENDIF
            HVPRI(ISTND,IHV)=0.0
         ELSE
            HVPRI(ISTND,IHV)=XREG(1)
         ENDIF
         CALL PPWEIG (ISTND,WEIGHT)
C
C        VARIABLES: 1=AVBTPA, 2=AVBTCUFT, 3=AVBMCUFT, 4=AVBBDFT,
C        5=AVBBA, 6=AVACC, 7=AVMORT, 8=TOTALWT, 9=OLDTARG (SET
C        INITIALLY IN HVINIT/HVIN AND KEEP UP TO DATE IN BELOW.
C
         TRGSTS(1,IHV)=TRGSTS(1,IHV)+TSTV1(3)*WEIGHT
         TRGSTS(2,IHV)=TRGSTS(2,IHV)+TSTV1(4)*WEIGHT
         TRGSTS(3,IHV)=TRGSTS(3,IHV)+TSTV1(5)*WEIGHT
         TRGSTS(4,IHV)=TRGSTS(4,IHV)+TSTV1(6)*WEIGHT
         TRGSTS(5,IHV)=TRGSTS(5,IHV)+TSTV1(7)*WEIGHT
         TRGSTS(6,IHV)=TRGSTS(6,IHV)+TSTV3(1)*WEIGHT
         TRGSTS(7,IHV)=TRGSTS(7,IHV)+TSTV3(2)*WEIGHT
         TRGSTS(8,IHV)=TRGSTS(8,IHV)+WEIGHT
C
         IF (LHVDEB) WRITE (JOPPRT,40) IHV,IRC,IHVSTA(ISTND,IHV),
     >               WEIGHT,HVPRI(ISTND,IHV),(TRGSTS(II,IHV),II=1,8)
   40    FORMAT (/' IN HVALOC, IHV=',I3,' IRC=',I2,
     >           ' IHVSTA=',I4,' WEIGHT=',E15.7,' HVPRI=',E15.7
     >           /'   TRGSTS(1:8,IHV)=',8E14.7)
      ENDIF
   90 CONTINUE
C
C     COMPUTE THE YIELD THAT WILL BE DERIVED FROM EACH STAND;
C     FIRST, ASSUMING EACH WILL NOT BE SELECTED.
C
      IF (LHVDEB) WRITE (JOPPRT,'(/'' IN HVALOC CALLING HVTHN1'')')
C
      CALL HVTHN1
      IF (IHVEXT.EQ.1) CALL HVPROJ(1)
C
C     RELOAD THE STAND.
C
      IF (LHVDEB) WRITE (JOPPRT,'(/'' IN HVALOC CALLING GETSTD'')')
C
      CALL GETSTD
      CALL OPCSET (ICYC)
C
C     SECOND, ASSUMING EACH WILL BE SELECTED.
C
      IF (LHVDEB) WRITE (JOPPRT,'(/'' IN HVALOC CALLING HVHRV1'')')
C
      CALL HVHRV1
      IF (IHVEXT.EQ.1) CALL HVPROJ(2)
  100 CONTINUE
C
C     SET THE DEFINED FLAGS TO TRUE FOR THE TARGET STATS...AND SET
C     THE MASTER TIME INTERVAL LENGTH.
C
      DO 110 I=1,10
      LPTST1(I)=.TRUE.
  110 CONTINUE
      PTSTV1(10)=FLOAT(MIY(MICYC)-MIY(MICYC-1))
C
C     COMPUTE THE PRIORITIES FOR EACH POLICY
C
      DO 150 IHV=1,IXHRVP
C
C     IF THE MULTISTAND POLICY IS ACTIVE....
C
      IF (IHVTAB(IHV,1).LE.0) GOTO 150
C
C     SAVE THE TOTAL WEIGHT AND OLD TARGET FOR THIS POLICY IN THE
C     PPE DEFINED VARIABLE LIST.
C
      PTSTV1(8)=TRGSTS(8,IHV)
      PTSTV1(9)=TRGSTS(9,IHV)
C
C     LOOP THROUGH THE TARGET STATS AND COMPUTE THE VALUES USEFUL
C     FOR COMPUTING THE ACTUAL TARGET.
C
      DO 120 I=1,7
      IF (PTSTV1(8).GT.0.) THEN
         PTSTV1(I)=TRGSTS(I,IHV)/PTSTV1(8)
      ELSE
         PTSTV1(I)=0.0
      ENDIF
 120  CONTINUE
C
C     COMPUTE THE TARGET.
C
      CALL ALGEVL (LREG,MXLREG,XREG,MXXREG,IPEXCD(IHVTAB(IHV,1)),
     >             MPEXCD-IHVTAB(IHV,1)+1,MIY(1),MIY(MICYC-1),
     >             LHVDEB,JOPPRT,IRC)
      IF (IRC.GE.1) THEN
         CALL RCDSET (3,.TRUE.)
         CALL ERRGRO (.TRUE.,21)
         TRGETS(IHV)=0.0
      ELSE
         TRGETS(IHV)=XREG(1)
         IF (TRGETS(IHV).LT.1E-20) TRGETS(IHV)=0.0
      ENDIF
C
C     SAVE THE TARGET AS THE 'OLDTARG', IN TRGSTS.
C
      TRGSTS(9,IHV)=TRGETS(IHV)
C
      IF (LHVDEB) WRITE (JOPPRT,140) IHV,IRC,TRGETS(IHV)
  140 FORMAT (/' IN HVALOC, IHV=',I3,' IRC=',I3,' TRGETS(IHV)=',
     >        E14.5)
  150 CONTINUE
C
C     IF EXTERNAL SELECTION IS BEING USED, THEN CLOSE THE DATA FILE
C     THAT CONTAINS THE SELECTION INFORMATION, CALL A SYSTEM
C     PROGRAM TO COMPUTE SELECTIONS AND THEN FORCE A READ OF THE
C     "ROAD ACCESS" FILE. FOR NOW, THAT FILE WILL BE USED TO CARRY
C     THE NEW SELECTION PRIORITY.
C
      IF (IHVEXT.EQ.1) THEN
         CLOSE (UNIT=83)
         WRITE (6,154) MIY(MICYC-1)
  154    FORMAT (/' PPE Note: Year=',I4,' SYSTEM CALL ComputePriority')
         CALL SYSTEM ("ComputePriority")
         I=0
         IRC=3
         OPEN (UNIT=83,FILE='PPE_FFERdAccess.txt',STATUS='OLD',ERR=155)
         CALL SPRDIT
         CALL SPRDRD (1.,83,I,IRC)
         CLOSE (83)

C        IF SUCCESSFUL READ OCCURED, THEN RESET THE PRIORITIES EQUAL
C        TO THE RDACCESS VALUE.

         IF (IRC.LE.1) THEN
            DO IST=1,NOSTND
               IF (IHVSTA(IST,1).EQ.1) THEN
                  CALL SPRDIS (STDIDS(IST),A,IRC)
                  IF (IRC.EQ.0) THEN
                     HVPRI(IST,1)=A
                  ELSE
                     HVPRI(IST,1)=0.
                  ENDIF
               ENDIF
            ENDDO
         ENDIF
  155    CONTINUE
         IF (LHVDEB) WRITE(JOPPRT,'(" AFTER SPRDRD,I=",I5," IRC=",I2)')
     >               I,IRC
      ENDIF
C
C     CALL HVSEL TO SET UP THE STATUS WORDS FOR EACH OF
C     THE STANDS AND MULTISTAND POLICIES.
C
      IF (LHVDEB) WRITE (JOPPRT,'(/'' IN HVALOC CALLING HVSEL'')')
C
      CALL HVSEL
C
C     CALL HVDNSL TO SET UP THE DENSITY STATISTICS FOR REPRESENTING
C     NEIGHBORING DENSITY EFFECTS.
C
      IF (LHVDEB) WRITE (JOPPRT,'(/'' IN HVALOC CALLING HVDNSL'')')
C
      CALL HVDNSL
      RETURN
      END
