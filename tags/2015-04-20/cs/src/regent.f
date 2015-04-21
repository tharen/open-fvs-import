      SUBROUTINE REGENT(LESTB,ITRNIN)
      IMPLICIT NONE
C----------
C CS $ID$
C----------
C  THIS SUBROUTINE COMPUTES HEIGHT AND DIAMETER INCREMENTS FOR
C  SMALL TREES.  THE HEIGHT INCREMENT MODEL IS APPLIED TO TREES
C  THAT ARE LESS THAN  5 INCHES DBH,
C  AND THE DBH INCREMENT MODEL IS APPLIED TO TREES THAT ARE LESS
C  THAN 5 INCHES DBH.  FOR TREES THAT ARE GREATER THAN 1.5 INCHES
C  DBH, HEIGHT INCREMENT PREDICTIONS
C  ARE AVERAGED WITH THE PREDICTIONS FROM THE LARGE TREE MODEL.
C  THIS ROUTINE IS CALLED FROM **CRATET** DURING CALIBRATION AND
C  FROM **TREGRO** DURING CYCLING.  ENTRY **REGCON** IS CALLED FROM
C  **RCON** TO LOAD MODEL PARAMETERS THAT NEED ONLY BE RESOLVED ONCE.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CALCOM.F77'
C
C
      INCLUDE 'COEFFS.F77'
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
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'ESTCOR.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
COMMONS
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES:
C
C   CORTEM -- A TEMPORARY ARRAY FOR PRINTING CORRECTION TERMS.
C   NUMCAL -- A TEMPORARY ARRAY FOR PRINTING NUMBER OF HEIGHT
C             INCREMENT OBSERVATIONS BY SPECIES.
C    RHCON -- CONSTANT FOR THE HEIGHT INCREMENT MODEL.
C     XMAX -- UPPER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM SMALL AND LARGE TREE MODELS
C             ARE AVERAGED.
C     XMIN -- LOWER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM THE SMALL AND LARGE TREE
C             ARE AVERAGED.
C     DIAM -- BUDWIDTH VALUES (INCHES) BY SPECIES
C----------
C  DECLARATIONS
C  SCALARS
C----------
      EXTERNAL RANN
      REAL AGET,AX,BARK,BAL,BX,CORNEW,CR,D,DDS,DK,DKK,DGMX
      REAL EDH,H,HK,HTNEW,HTGR,HTG1,HTMAX,P,PTCCF,FNT,RAN
      REAL REGYR,SCALE,SCALE2,SCALE3,SNP,SNX,SNY,TERM,XMX,XMN
      REAL XPPMLT,XRDGRO,XRHGRO,XWT,CON,YRS,GMOD,RELHTA,DGGR,DGSM
      INTEGER I,I1,I2,I3,ISPC,ISPEC,ITRNIN,IPCCF,IREFI,K,KK,KOUT
      INTEGER L,MODE0,MODE9,N,IVAR
      CHARACTER SPEC*2
      LOGICAL DEBUG,LESTB,LSKIPH
C----------
C  ARRAYS
C----------
      REAL CORTEM(MAXSP),DGMAX(MAXSP),DIAM(MAXSP),HGADJ(MAXSP)
      REAL XMAX(MAXSP),XMIN(MAXSP)
      INTEGER NUMCAL(MAXSP)
C----------
C  FUNCTIONS
C----------
      REAL BACHLO,BRATIO
C----------
C  INITIALIZATIONS
C----------
      DATA HGADJ/ MAXSP*1.0/
      DATA DGMAX/ MAXSP*5.0 /
      DATA XMIN / MAXSP*1.5 /, XMAX/ MAXSP*5.0 /
      DATA REGYR/10.0/
      HTGR= 0.0
C-----------
C  CHECK FOR DEBUG.
C-----------
      LSKIPH=.FALSE.
      CALL DBCHK (DEBUG,'REGENT',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,9980)ICYC,FINT
 9980 FORMAT('ENTERING SUBROUTINE REGENT  CYCLE =',I5,F10.3)
C----------
C  HEIGHT INCREMENT IS DERIVED FROM A HEIGHT-AGE CURVE AND IS NOMINALLY
C  BASED ON A 10-YEAR GROWTH PERIOD.   SCALE IS USED TO CONVERT
C  HEIGHT INCREMENT PREDICTIONS TO A FINT-YEAR PERIOD.  DIAMETER
C  INCREMENT IS PREDICTED FROM CHANGE IN HEIGHT, AND IS SCALED TO A 10-
C  YEAR PERIOD BY APPLICATION OF THE VARIABLE SCALE2. DIAMETER INCREMENT
C  IS CONVERTED TO A FINT-YEAR BASIS IN **UPDATE**.
C----------
      FNT=FINT
      IF(LSTART) FNT=IFINTH
      IF(LESTB) THEN
        IF(FINT.LE.5.0) THEN
          LSKIPH=.TRUE.
        ELSE
          FNT=FNT-5.0
        ENDIF
      ENDIF
C----------
C  IF THIS IS THE FIRST CALL TO REGENT, BRANCH TO STATEMENT 40 FOR
C  MODEL CALIBRATION.
C----------
      IF(LSTART) GOTO 40
      CALL MULTS (3,IY(ICYC),XRHMLT)
      CALL MULTS(6,IY(ICYC),XRDMLT)
      IF (ITRN.LE.0) GO TO 91
C
      SCALE= FNT/REGYR
      SCALE2=YR/FNT
C----------
C  ENTER GROWTH PREDICTION LOOP.  PROCESS EACH SPECIES AS A GROUP;
C  LOAD CONSTANTS FOR NEXT SPECIES.
C----------
      DO 30 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 30
      I2=ISCT(ISPC,2)
C----------
      XRDGRO=XRDMLT(ISPC)
      XRHGRO=XRHMLT(ISPC)
      CON = RHCON(ISPC) * EXP(HCOR(ISPC))
      XMX=XMAX(ISPC)
      XMN=XMIN(ISPC)
      DGMX = DGMAX(ISPC) * SCALE
C----------
C  PROCESS NEXT TREE RECORD.
C----------
      DO 25 I3=I1,I2
      I=IND1(I3)
      BAL=(1.0-(PCT(I)/100.))*BA
      IPCCF=ITRE(I)
      D=DBH(I)
      IF(D .GE. XMX) GO TO 25
C----------
C  BYPASS INCREMENT CALCULATIONS IF CALLED FROM ESTAB AND THIS IS NOT A
C  NEWLY CREATED TREE.
C----------
      IF(LESTB) THEN
        IF(I.LT.ITRNIN) GO TO 25
C----------
C  ASSIGN CROWN RATIO FOR NEWLY ESTABLISHED TREES.
C----------
        CR = 0.89722 - 0.0000461*PCCF(IPCCF)
    1   CONTINUE
        RAN = BACHLO(0.0,1.0,RANN)
        IF(RAN .LT. -1.0 .OR. RAN .GT. 1.0) GO TO 1
        CR = CR + 0.07985 * RAN
        IF(CR .GT. .90) CR = .90
        IF(CR .LT. .20) CR = .20
        ICR(I)=(CR*100.0)+0.5
      ENDIF
      K=I
      L=0
      H=HT(I)
      IF(LSKIPH) THEN
        HTG(K)=0.0
        GO TO 4
      ENDIF
C----------
C     RETURN HERE TO PROCESS NEXT TRIPLE.
C----------
    2 CONTINUE
C----------
C  ESTIMATE SITE CURVE HEIGHT INCREMENT VALUES FOR INCOMING TREES.
C
C  HEIGHT GROWTH EQUATION, USING NC128 TREE HEIGHT COEFFS.
C  EVALUATED FOR EACH TREE EACH CYCLE, 10.0 YEAR CYCLE
C  FIRST FIND EFFECTIVE TREE AGE BASED ON H
C-----------
      MODE0= 0
      IVAR=2
      YRS=10.
      H=HT(I)
      CALL HTCALC (MODE0,IVAR,ISPC,SITEAR(ISPC),YRS,H,AGET,HTMAX,
     &               HTG1,JOSTND,DEBUG)
C----------
C  IF INITIAL TREE HEIGHT IS >= MAX HEIGHT FOR SITE (HTMAX).
C  IF TRUE, THEN SET HTG= 0.1 FT.
C----------
      IF(HTMAX-H.LE.1.) THEN
        IF(DEBUG) WRITE(JOSTND,*) 'HTI>=HTMAX , ABIRTH= ',ABIRTH(I)
        HTGR = 0.10
      ELSE
C----------
C     FIND HTGR
C----------
      MODE0=9
      IVAR=2
      YRS=10.
      H=HT(I)
      CALL HTCALC (MODE0,IVAR,ISPC,SITEAR(ISPC),YRS,H,AGET,HTMAX,
     &             HTGR,JOSTND,DEBUG)
C
        IF(DEBUG)WRITE(JOSTND,*)'I,ISPC,HGADJ,FNT,ABIRTH= ',
     &  I,ISPC,HGADJ(ISPC),FNT,ABIRTH(I)
        IF(DEBUG)WRITE(JOSTND,*)'I,SCALE,SCALE2,HTGR,DBH,BA,IPCCF= ',
     &  I,SCALE,SCALE2,HTGR,D,BA,IPCCF
C
        HTGR =HTGR*CON*SCALE*HGADJ(ISPC)*XRHGRO
      ENDIF
C----------
C  GET BAL MODIFIER BORROWED FROM THE DIAMETER GROWTH EQUATIONS AND
C  ADJUST THE HEIGHT GROWTH ESTIMATE.
C  POTENTIALLY ONLY AFFECT HEIGHT GROWTH HALF AS MUCH AS DIA GROWTH
C  TEMPER THE ADJUSTMENT BY RELATIVE HEIGHT
C----------
      CALL BALMOD(ISPC,D,BAL,BA,GMOD,DEBUG)
      IF(DEBUG)WRITE(16,*)'AFTER BALMOD GMOD,HT,AVH= ',GMOD,HT(I),AVH
C      GMOD = (GMOD+1.0)/2.0
      RELHTA=0.
      IF(AVH .GT. 0.)RELHTA=MIN((HT(I)/AVH),1.0)
      GMOD=1.0-((1.0-GMOD)*(1.0-RELHTA))
      HTGR=HTGR*GMOD
      IF(DEBUG)WRITE(JOSTND,*)'I,GMOD,HTGR= ',I,GMOD,HTGR
C
      IF(HTGR .LT. 0.1) HTGR = 0.1
C----------
C     GET A MULTIPLIER FOR THIS TREE FROM PPREGT TO ACCOUNT FOR
C     THE DENSITY EFFECTS OF NEIGHBORING TREES.
C----------
      XPPMLT=0.
      CALL PPREGT (XPPMLT)
      HTGR = HTGR + XPPMLT
C-------------
C     COMPUTE WEIGHTS FOR THE LARGE AND SMALL TREE HEIGHT INCREMENT
C     ESTIMATES.  IF DBH IS LESS THAN OR EQUAL TO XMN, THE LARGE TREE
C     PREDICTION IS IGNORED (XWT=0.0).
C----------
      XWT=(D-XMN)/(XMX-XMN)
      IF(D.LE.XMN .OR. LESTB) XWT = 0.0
C----------
C     COMPUTE WEIGHTED HEIGHT INCREMENT FOR NEXT TRIPLE.
C----------
      IF(DEBUG)WRITE(JOSTND,9982)XWT,HTGR,HTG(K),I,K
 9982 FORMAT('IN REGENT 9982 FORMAT',3(F10.4,2X),2I7)
C
      HTGR=HTGR*(1.0-XWT) + XWT*HTG(K)
      IF(HTGR .LT. .1) HTGR = .1
C----------
C   ADD RANDOM AFFECTS. LIMIT TO + OR -  1/10 HTGR
C----------
      RAN=0.
      IF(DGSD .GE. 1.0) THEN
    3   CONTINUE
        RAN = BACHLO(0.0,1.0,RANN)
        IF(RAN.LT.-1.0 .OR. RAN.GT.1.0) GO TO 3
      ENDIF
      HTGR = HTGR + RAN*0.1*HTGR
C
      HTG(K)= HTGR
      IF(HTG(K) .LT. .1) HTG(K) = .1
C
      IF(DEBUG)WRITE(JOSTND,9985)HTGR,HTG(K),I,K,LESTB
 9985 FORMAT('IN REGENT HTGR,HTG(K),I,K,LESTB= '/
     & 2(F10.4,2X),2I10,L10)
C
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((H+HTG(K)).GT.SIZCAP(ISPC,4))THEN
        HTG(K)=SIZCAP(ISPC,4)-H
        IF(HTG(K) .LT. 0.1) HTG(K)=0.1
      ENDIF
C
    4 CONTINUE
C----------
C     ASSIGN DBH AND COMPUTE DBH INCREMENT FOR TREES WITH DBH LESS
C     THAN 5 INCHES (COMPUTE 10-YEAR DBH INCREMENT REGARDLESS OF
C     PROJECTION PERIOD LENGTH).
C----------
      IF(D.GE.XMX) GO TO 23
      HK=H + HTG(K)
      IF(HK .LE. 4.5) THEN
        DG(K)=0.0
        DBH(K)=D+0.001*HK
      ELSE
C----------
C   USE WYKOFF EQ. FOR DBH
C      DKK = DIAMETER WITH HTG ADDED TO THE STARTING HEIGHT
C      DK  = DIAMETER AT THE START OF THE PROJECTION
C---------
        BX=HT2(ISPC)
        IF(IABFLG(ISPC).EQ.1) THEN
          AX=HT1(ISPC)
        ELSE
          AX=AA(ISPC)
        ENDIF
        DKK=(BX/(ALOG(HK-4.5)-AX))-1.0
        IF(H .LE. 4.5) THEN
          DK=D
        ELSE
          DK=(BX/(ALOG(H-4.5)-AX))-1.0
        ENDIF
C
        IF(DEBUG)WRITE(JOSTND,*)'I,ISPC,DBH,H,HK,DK,DKK=
     &  ',I,ISPC,DBH(K),H,HK,DK,DKK
C----------
C  USE INVENTORY EQUATIONS IF CALIBRATION OF THE HT-DBH FUNCTION IS TURNED
C  OFF, OR IF WYKOFF CALIBRATION DID NOT OCCUR.
C  NOTE: THIS SIMPLIFIES TO IF(IABFLB(ISPC).EQ.1) BUT IS SHOWN IN IT'S
C        ENTIRITY FOR CLARITY.
C----------
        IF(.NOT.LHTDRG(ISPC) .OR. 
     &     (LHTDRG(ISPC) .AND. IABFLG(ISPC).EQ.1))THEN
          CALL HTDBH (IFOR,ISPC,DKK,HK,1)
          IF(H .LE. 4.5) THEN
            DK=D
          ELSE
            CALL HTDBH (IFOR,ISPC,DK,H,1)
          ENDIF
          IF(DEBUG)WRITE(JOSTND,*)'INV EQN DUBBING IFOR,ISPC,H,HK,DK,'
     &    ,'DKK= ',IFOR,ISPC,H,HK,DK,DKK
          IF(DEBUG)WRITE(JOSTND,*)'ISPC,LHTDRG,IABFLG= ',
     &    ISPC,LHTDRG(ISPC),IABFLG(ISPC)
        ENDIF
C----------
C         IF CALLED FROM **ESTAB** ASSIGN DIAMETER
C----------
        IF(LESTB) THEN
          DBH(K)=DKK
          IF(DBH(K).LT.DIAM(ISPC) .OR. HK.LT.4.5) DBH(K)=DIAM(ISPC)
          DBH(K)=DBH(K)+0.001*HK
          DG(K)=DBH(K)
        ELSE
C----------
C         COMPUTE DIAMETER INCREMENT BY SUBTRACTION, APPLY USER
C         SUPPLIED MULTIPLIERS, AND CHECK TO SEE IF COMPUTED VALUE
C         IS WITHIN BOUNDS.
C         THE INCREMENT FOR TREES BETWEEN 1.5 AND 5 INCHES DBH IS A 
C         WEIGHTED AVERAGE OF PREDICTIONS FROM THE LARGE AND SMALL 
C         TREE MODELS. SCALE ADJUSTMENT IS ON GROWTH IN DDS TERMS RATHER 
C         THAN INCHES OF DG TO MAINTAIN CONSISTENCY WITH GRADD.
C         
C         NOTE: LARGE TREE DG IS ON A 10-YR BASIS; SMALL TREE DG IS ON A 
C         FINT-YR BASIS. CONVERT SMALL TREE DG TO A 10-YR BASIS BEFORE
C         WEIGHTING. DG GETS CONVERTED BACK TO A FINT-YR BASIS IN **GRADD**.
C----------
          BARK=BRATIO(ISPC,D,H)
          IF(DEBUG)WRITE(JOSTND,*)'BARK,XRDGRO= ',BARK,XRDGRO
          IF(DK.LT.0.0 .OR. DKK.LT.0.0)THEN
            DG(K)=HTG(K)*0.2*BARK*XRDGRO
            DKK=D+DG(K)
          ELSE
            DGSM=(DKK-DK)*BARK*XRDGRO
            IF(DGSM .LT. 0.0) DGSM=0.0
            DDS=DGSM*(2.0*BARK*D+DGSM)*SCALE2
            DGSM=SQRT((D*BARK)**2.0+DDS)-BARK*D
            IF(DGSM.LT.0.0) DGSM=0.0
C----------
C         COMPUTE WEIGHTED DIAMETER INCREMENT FOR NEXT TRIPLE.
C----------
            IF(DEBUG)WRITE(JOSTND,9983)XWT,DGSM,DG(K),I,K
 9983       FORMAT('IN REGENT 9983 FORMAT',3(F10.4,2X),2I7)
C
            DGGR=DGSM*(1.0-XWT) + XWT*DG(K)
            IF(DGGR .LT. .1) DGGR = .1
            DG(K)=DGGR
          ENDIF
          IF(DEBUG)WRITE(JOSTND,*)'K,DK,DKK,DG= ',K,DK,DKK,DG(K)
C
          IF(DG(K) .LT. 0.0) DG(K)=0.1
          IF(DG(K) .GT. DGMX) DG(K)=DGMX
C
        ENDIF
        IF((DBH(K)+DG(K)).LT.DIAM(ISPC))THEN
          DG(K)=DIAM(ISPC)-DBH(K)
        ENDIF
      ENDIF
C----------
C  CHECK FOR TREE SIZE CAP COMPLIANCE
C----------
      CALL DGBND(ISPC,DBH(K),DG(K))
C
      IF(DEBUG)THEN
        HTNEW=HT(I)+HTG(I)
        WRITE(JOSTND,9987) I,ISPC,HT(I),HTG(I),HTNEW,DBH(I),DG(I),DG(K)
 9987   FORMAT('IN REGENT, I=',I4,',  ISPC=',I3,'  CUR HT=',F7.2,
     &       ',  HT INC=',F7.4,',  NEW HT=',F7.2,',  CUR DBH=',F10.5,
     &       ',  DBH INC(I,K)=',2F7.4)
      ENDIF
   23 CONTINUE
C----------
C  RETURN TO PROCESS NEXT TRIPLE IF TRIPLING.  OTHERWISE,
C  PRINT DEBUG AND RETURN TO PROCESS NEXT TREE.
C----------
      IF(LESTB .OR. .NOT.LTRIP .OR. L.GE.2) GO TO 22
      L=L+1
      K=ITRN+2*I-2+L
      GO TO 2
C----------
C  END OF GROWTH PREDICTION LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
   22 CONTINUE
   25 CONTINUE
   30 CONTINUE
      GO TO 91
C----------
C  SMALL TREE HEIGHT CALIBRATION SECTION.
C----------
   40 CONTINUE
C
      DO 45 ISPC=1,MAXSP
      HCOR(ISPC)=0.0
      CORTEM(ISPC)=1.0
      NUMCAL(ISPC)=0
   45 CONTINUE
      IF (ITRN.LE.0) GO TO 91
      SCALE3 = REGYR / FINTH
C----------
C  BEGIN PROCESSING TREE LIST IN SPECIES ORDER.  DO NOT CALCULATE
C  CORRECTION TERMS IF THERE ARE NO TREES FOR THIS SPECIES.
C----------
      DO 100 ISPC=1,MAXSP
      CORNEW=1.0
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0 .OR. .NOT. LHTCAL(ISPC)) GO TO 100
      N=0
      SNP=0.0
      SNX=0.0
      SNY=0.0
      I2=ISCT(ISPC,2)
      IREFI=IREF(ISPC)
      CON = RHCON(ISPC)
C----------
C  BEGIN TREE LOOP WITHIN SPECIES.  IF MEASURED HEIGHT INCREMENT IS
C  LESS THAN OR EQUAL TO ZERO, OR DBH IS LESS THAN 5.0, THE RECORD
C  WILL BE EXCLUDED FROM THE CALIBRATION.
C----------
      DO 60 I3=I1,I2
      I=IND1(I3)
      BAL=(1.0-(PCT(I)/100.))*BA
      H=HT(I)
      K= I
      IF(IHTG.LT.2) H=H-HTG(I)
      IF(DBH(I).GE.5.0.OR.H.LT.0.01) GO TO 60
      IPCCF=ITRE(I)
      PTCCF = PCCF(IPCCF)
C
      IF (DEBUG) WRITE(JOSTND,*)'IN REGENT 8900 H =',H
C----------
C  CALCULATE TREE HEIGHT INCREMENT
C  HEIGHT GROWTH EQUATION, USING NC128 TREE HEIGHT COEFFS.
C  EVALUATED FOR EACH TREE EACH CYCLE, 5.0 YEAR CYCLE
C  FIRST FIND EFFECTIVE TREE AGE BASED ON H
C-----------
      MODE0= 0
      IVAR=2
      YRS=10.
      H=HT(I)
      CALL HTCALC (MODE0,IVAR,ISPC,SITEAR(ISPC),YRS,H,AGET,HTMAX,
     &               HTG1,JOSTND,DEBUG)
C----------
C     THEN FIND HTGR
C----------
      MODE0=9
      IVAR=2
      YRS=10.
      H=HT(I)
      CALL HTCALC (MODE0,IVAR,ISPC,SITEAR(ISPC),YRS,H,AGET,HTMAX,
     &             HTGR,JOSTND,DEBUG)
C
C----------
C  GET BAL MODIFIER BORROWED FROM THE DIAMETER GROWTH EQUATIONS AND
C  ADJUST THE HEIGHT GROWTH ESTIMATE.
C  POTENTIALLY ONLY AFFECT HEIGHT GROWTH HALF AS MUCH AS DIA GROWTH
C  TEMPER THE ADJUSTMENT BY RELATIVE HEIGHT
C----------
      CALL BALMOD(ISPC,D,BAL,BA,GMOD,DEBUG)
      IF(DEBUG)WRITE(16,*)'AFTER BALMOD GMOD,HT,AVH= ',GMOD,HT(I),AVH
C      GMOD = (GMOD+1.0)/2.0
      RELHTA=0.
      IF(AVH .GT. 0.)RELHTA=MIN((HT(I)/AVH),1.0)
      GMOD=1.0-((1.0-GMOD)*(1.0-RELHTA))
      HTGR=HTGR*GMOD
      IF(DEBUG)WRITE(JOSTND,*)'I,GMOD,HTGR= ',I,GMOD,HTGR
C
      IF(HTGR .LT. .1) HTGR = .1
C
      EDH = HTGR * RHCON(ISPC)
      IF(EDH .LT. 0.1) EDH=0.1
      P=PROB(I)
      IF(HTG(I).LT.0.001) GO TO 60
      TERM=HTG(I) * SCALE3
      SNP=SNP+P
      SNX=SNX+EDH*P
      SNY=SNY+TERM*P
      N=N+1
C----------
C  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG)WRITE(JOSTND,9991) NPLT,I,ISPC,H,DBH(I),ICR(I),
     & PCT(I),RELDM1,RHCON(ISPC),EDH,TERM,HTGR,SCALE3,HGADJ(ISPC),
     &ICR(I)
 9991 FORMAT('NPLT=',A8,',  I=',I5,',  ISPC=',I3,',  H=',F6.1,
     & ',  DBH=',F5.1,',  ICR',I5,',  PCT=',F6.1,',  RELDEN=',
     & F6.1 / 12X,'RHCON=',F10.3,',  EDH=',F10.3,', TERM=',F10.3,
     &' HTGR= ',F10.3,' SCALE3= ',F10.3,' HGADJ(ISPC)= ',F10.3/
     &' ICR= ',I5)
C----------
C  END OF TREE LOOP WITHIN SPECIES.
C----------
   60 CONTINUE
      IF(DEBUG) WRITE(JOSTND,9992) ISPC,SNP,SNX,SNY
 9992 FORMAT(/'SUMS FOR SPECIES ',I2,':  SNP=',F10.2,
     & ';  SNX=',F10.2,';  SNY=',F10.2)
C----------
C  COMPUTE CALIBRATION TERMS.  CALIBRATION TERMS ARE NOT COMPUTED
C  IF THERE WERE FEWER THAN NCALHT (DEFAULT=5) HEIGHT INCREMENT
C  OBSERVATIONS FOR A SPECIES.
C----------
      IF(N.LT.NCALHT) GO TO 80
C----------
C  CALCULATE MEANS FOR THE POPULATION AND FOR THE SAMPLE ON THE
C  NATURAL SCALE.
C----------
      SNX=SNX/SNP
      SNY=SNY/SNP
C----------
C  CALCULATE RATIO ESTIMATOR.
C----------
      CORNEW = SNY/SNX
      IF(CORNEW.LE.0.0) CORNEW=1.0E-4
      HCOR(ISPC)=ALOG(CORNEW)
C----------
C  TRAP CALIBRATION VALUES OUTSIDE 2.5 STANDARD DEVIATIONS FROM THE 
C  MEAN. IF C IS THE CALIBRATION TERM, WITH A DEFAULT OF 1.0, THEN
C  LN(C) HAS A MEAN OF 0.  -2.5 < LN(C) < 2.5 IMPLIES 
C  0.0821 < C < 12.1825
C----------
      IF(CORNEW.LT.0.0821 .OR. CORNEW.GT.12.1825) THEN
        CALL ERRGRO(.TRUE.,27)
        WRITE(JOSTND,9194)ISPC,JSP(ISPC),CORNEW
 9194   FORMAT(T28,'SMALL TREE HTG: SPECIES = ',I2,' (',A3,
     &  ') CALCULATED CALIBRATION VALUE = ',F8.2)
        CORNEW=1.0
        HCOR(ISPC)=0.0
      ENDIF
   80 CONTINUE
      CORTEM(IREFI) = CORNEW
      NUMCAL(IREFI) = N
  100 CONTINUE
C----------
C  END OF CALIBRATION LOOP.  PRINT CALIBRATION STATISTICS AND RETURN
C----------
      WRITE(JOSTND,9993) (NUMCAL(I),I=1,NUMSP)
 9993 FORMAT(/'NUMBER OF RECORDS AVAILABLE FOR SCALING'/
     >       'THE SMALL TREE HEIGHT INCREMENT MODEL',
     >        ((T48,11(I4,2X)/)))
   95 CONTINUE
      WRITE(JOSTND,9994) (CORTEM(I),I=1,NUMSP)
 9994 FORMAT(/'INITIAL SCALE FACTORS FOR THE SMALL TREE'/
     >      'HEIGHT INCREMENT MODEL',
     >       ((T48,11(F5.2,1X)/)))
C----------
C OUTPUT CALIBRATION TERMS IF CALBSTAT KEYWORD WAS PRESENT.
C----------
      IF(JOCALB .GT. 0) THEN
        KOUT=0
        DO 207 K=1,MAXSP
        IF(CORTEM(K).NE.1.0 .OR. NUMCAL(K).GE.NCALHT) THEN
          SPEC=NSP(MAXSP,1)(1:2)
          ISPEC=MAXSP
          DO 203 KK=1,MAXSP
          IF(K .NE. IREF(KK)) GO TO 203
          ISPEC=KK
          SPEC=NSP(KK,1)(1:2)
          GO TO 2031
  203     CONTINUE
 2031     WRITE(JOCALB,204)ISPEC,SPEC,NUMCAL(K),CORTEM(K)
  204     FORMAT(' CAL: SH',1X,I2,1X,A2,1X,I4,1X,F6.3)
          KOUT = KOUT + 1
        ENDIF
  207   CONTINUE
        IF(KOUT .EQ. 0)WRITE(JOCALB,209)
  209   FORMAT(' NO SH VALUES COMPUTED')
        WRITE(JOCALB,210)
  210   FORMAT(' CALBSTAT END')
      ENDIF
   91 IF(DEBUG)WRITE(JOSTND,9995)ICYC
 9995 FORMAT('LEAVING SUBROUTINE REGENT  CYCLE =',I5)
      RETURN
      ENTRY REGCON
C----------
C  ENTRY POINT FOR LOADING OF REGENERATION GROWTH MODEL
C  CONSTANTS  THAT REQUIRE ONE-TIME RESOLUTION.
C  IF THE BUDWIDTH VALUES IN THE DIAM ARRAY, BELOW, ARE MODIFIED
C  THEN ALSO MODIFY THE VALUES IN THE SNDBAL ARRAY IN **HTDBH
C---------
      DATA DIAM/
     &   0.5, 0.3, 0.5, 0.5, 0.5, 0.3, 0.4, 0.4, 0.3, 0.2,
     &   0.2, 0.2, 0.2, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3,
     &   0.3, 0.3, 0.3, 0.1, 0.2, 0.2, 0.2, 0.1, 0.2, 0.3,
     &   0.2, 0.1, 0.1, 0.3, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,
     &   0.2, 0.1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.1, 0.2,
     &   0.2, 0.2, 0.1, 0.1, 0.2, 0.2, 0.1, 0.1, 0.2, 0.2,
     &   0.1, 0.2, 0.2, 0.1, 0.2, 0.1, 0.1, 0.2, 0.1, 0.1,
     &   0.3, 0.1, 0.1, 0.2, 0.2, 0.3, 0.1, 0.2, 0.1, 0.2,
     &   0.1, 0.2, 0.1, 0.1, 0.1, 0.2, 0.2, 0.1, 0.1, 0.1,
     &   0.2, 0.2, 0.2, 0.2, 0.2, 0.2/
C
      DO 90 ISPC=1,MAXSP
      RHCON(ISPC) = 1.0
      IF(LRCOR2.AND.RCOR2(ISPC).GT.0.0)
     &RHCON(ISPC) = RCOR2(ISPC)
   90 CONTINUE
      RETURN
      END
