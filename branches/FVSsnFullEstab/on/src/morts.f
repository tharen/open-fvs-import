      SUBROUTINE MORTS
      IMPLICIT NONE
C----------
C  **MORTS--ON   DATE OF LAST REVISION:  09/23/11
C----------
C  THIS SUBROUTINE COMPUTES PERIODIC MORTALITY RATES FOR
C  EACH TREE RECORD AND THEN REDUCES THE NUMBER OF TREES/ACRE
C  REPRESENTED BY THE TREE RECORD.
C  THIS ROUTINE IS CALLED FROM **TREGRO** WHEN CYCLING FOR GROWTH
C  PREDICTION.  ENTRY **MORCON** IS CALLED TO LOAD SITE DEPENDENT
C  CONSTANTS.
C
C  SDI BASED MORTALITY USES MAXIMUM SDI EQUATIONS FROM:
C  PENNER, MARGARET. 3/31/2010. FVS_ONTARIO MORTALITY EQUATIONS.
C  REPORT PREPARED FOR JOHN PARTON OMNR. EQUATION (9).
C
C  EQUATIONS FOR MATURE STAND BOUNDARY WERE DEVELOPED BY GARY DIXON AND
C  APPROXIMATE PENNER'S EQUATION (10) IN THE SAME REPORT.
C   
C  IF A BASAL AREA MAXIMUM HAS BEEN SET BY THE USER, A CHECK IS MADE TO
C  MAKE SURE BASAL AREA HAS NOT EXCEEDED THE SPECIFIED LIMIT.
C----------
COMMONS
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'ARRAYS.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'OUTCOM.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'COEFFS.F77'
      INCLUDE 'ESTREE.F77'
      INCLUDE 'MULTCM.F77'
      INCLUDE 'PDEN.F77'
      INCLUDE 'VARCOM.F77'
      INCLUDE 'WORKCM.F77'
      INCLUDE 'METRIC.F77'
C
COMMONS
C
C  DEFINITIONS OF LOCAL VARIABLES:
C
C    BKG_MAP = MAPPING FUNCTION RELATING ONTARIO SPECIES TO ONE OF
C              THE 4 BACKGROUND MORTALITY COEFFICIENT SETS
C    C0 -- CONSTANT TERM FOR SDI RELATIONSHIP
C             LN(T) = LN(C0)-1.605 *LN(QMD)
C    D -- TREE DIAMETER.
C    DQ0     = START OF CYCLE MEAN SQUARE DIAMETER
C    DQ10    = QUADRATIC DBH AT END OF CYCLE IF TREES/ACRE IS HELD CONSTANT
C    DR0     = START OF CYCLE REINEKE'S DIAMETER
C    DR10    = REINEKE'S DBH AT END OF CYCLE IF TREES/ACRE IS HELD CONSTANT
C    I -- TREE SUBSCRIPT.
C    INDX_BA = FVS SEQUENCE NUMBER OF THE SPECIES WITH THE MOST BA
C    MATURE STAND BOUNDARY LINE:  LN(TPH)=A+B*LN(QMDcm)
C    GARY DIXON'S APPROXIMATION OF MARGARET PENNER'S EQUATION 10 SPLINED
C    TO MEET THE SDI MAXIMUM LINE AT THE BREAKPOINT DBH
C      MSB_DBH = BREAKPOINT LN(QMDcm) AT WHICH STAND DENSITY CONTROL 
C                SWITCHES FROM THE MAXIMUM SDI LINE TO THE MATURE 
C                STAND BOUNDARY LINE
C      MSB_INT = INTERCEPT FOR THE MATURE STAND BOUNDARY LINE
C      MSB_SLP = SLOPE OF THE MATURE STAND BOUNDARY LINE
C    MSB_MAP = MAPPING FUNCTION RELATING ONTARIO SPECIES TO ONE OF 
C              PENNER'S 13 MAXIMUM SDI EQUATIONS
C    P -- NUMBER OF TREES PER ACRE REPRESENTED BY A TREE.
C    PMSC -- CONSTANT TERMS FOR EACH SPECIES FOR THE BACKGROUND
C             MORTALITY RATE EQUATION (B0).
C    PMD -- COEFFICIENTS FOR EACH SPECIES FOR THE DIAMETER TERM
C             IN THE BACKGROUND MORTALITY RATE EQUATION (B1).
C    RI -- ESTIMATED ANNUAL BACKGROUND MORTALITY RATE
C    RIP -- WEIGHTED AVERAGE MORTALITY RATE BASED ON TREE DBH, RI,
C           AND RN.
C    RN -- MORTALITY RATE THAT WILL MATCH THE TREND IN TREES PER
C          ACRE THAT IS PREDICTED FROM THE SDI RELATIONSHIP
C          TREES/ACRE LOSS EXPRESSED AS PER YEAR LOSS
C   MARGARET PENNER'S MAXIMUM SDI EQUATION: LN(QMDcm)=A+B*LN(TPH)
C     WHEN USED THIS EQUATION IS SOLVED: LN(TPH)=(-A/B)+(1/B)*LN(QMDcm)
C     WHERE SDIINT = (-A/B), AND SDISLP = (1/B)
C     SDI_INT = MARGARET PENNER'S INTERCEPT FOR THE MAXIMUM SDI LINE
C     SDI_SLP = MARGARET PENNER'S SLOPE FOR THE MAXIMUM SDI LINE
C    T       = TREES/ACRE AT START OF CYCLE
C    TN10    = PREDICTED TREES/ACRE AT THE END OF THE CYCLE
C    WKI -- SCALAR USED FOR CALCULATION AND TEMPORARY STORAGE
C           OF TREE MORTALITY (TREES/ACRE).

      LOGICAL DEBUG,LINCL

      INTEGER I,IACTK,IDATE,IDMFLG,IG,IGRP,INDX,INDX_BA
      INTEGER IP,IPASS,IPATH,IS,ISPC,ISPCC,ITODO,IULIM,IX,I1,I2,I3
      INTEGER J,KBIG,KNT,KNT2,KPOINT
      INTEGER NTODO,NP

      INTEGER BKG_MAP(MAXSP),MSB_MAP(MAXSP)
      INTEGER MYACTS(2)

      REAL ADJFAC,BADEAD,BANEW,BARK,BRATIO,B0,B1
      REAL CEPT,CIOBDS,CONST,CREDIT
      REAL D,DBHEND,DIA0,DIFF,DR0,DR10,DR10N,DQ0,DQ10
      REAL DQ10N,D1,D2,D10,D10N,D55M,D85M,G,P,PRES,QMDNEW
      REAL RI,RIP,RN
      REAL SDIINT,SDISLP,SDQ0,SD2SQ,SD2SQN,SLP
      REAL SUMBA,SUMDR0,SUMDR10,SUMDR10N,SUMKIL,SUMTRE
      REAL T,TBAM1,TEM,TEMQMD,TEMEFF,TEMINT,TEMP,TEMSLP,TMD0,TMD10
      REAL TMMSB,TMORE,TN,TNEW,TN10,TPACLS,TPHMAX
      REAL TPRIME,TREEIT,T55D0,T55D10,T55M,T85D0,T85D10,T85M,T85MSB
      REAL VLOS,WKI,X,XMORE,XMORT
      
      REAL BASP(MAXSP)
      REAL MSB_DBH(13),MSB_INT(13),MSB_SLP(13)
      REAL PMSC(4),PMD(4),PRM(6)
      REAL SDI_INT(13),SDI_SLP(13)

C----------
C  DATA STATEMENTS.
C----------
      DATA MYACTS/94,97/


C     MAX SDI MORTALITY COEFFICIENTS FROM MARGARET PENNER
C     Source: FVS_Mortality_Report.docx, Table 6; Eqn (9)
C     SDI_INT,SDI_SLP MAPPED BY MSB_MAP

      DATA SDI_INT /
     >   7.77029,  6.25277,  5.98521,  5.85622, 4.85176,
     >   8.99134,  4.49037,  6.90979,  6.97823, 6.32553,
     >   7.40806,  8.26319,  6.69982/
      DATA SDI_SLP /
     >  -0.61566, -0.40357, -0.38783,  -0.3828, -0.25916,
     >   -0.8304, -0.20807, -0.49564, -0.54518, -0.46181,
     >  -0.58078, -0.74894, -0.51312 /
      
C     MSB COEFFICIENTS 
C     Source: Gary Dixon
C     APPROXIMATE MARGARET PENNER
C     FVS_Mortality_Report.docx, Table 7; Eqn (10)
C     MSB_DBH, MSB_INT, MSB_SLP; MAPPED BY MSB_MAP

      DATA MSB_DBH /
     >      3.00,     3.30,     2.00,     2.90,     2.75,
     >      3.70,     2.80,     3.10,     3.50,     2.90,
     >      3.10,     3.30,     2.40/
      DATA MSB_INT /
     >  14.64825, 20.51662, 16.27566, 21.06262, 32.03489,
     >  15.99204, 29.68404, 17.91661, 13.23997, 20.46762,
     >  15.78771, 18.28047, 13.65976/
      DATA MSB_SLP /
     >     -2.30,    -4.00,    -3.00,    -4.60,    -8.70,
     >     -2.60,    -7.70,    -3.30,    -1.96,    -4.50,
     >     -2.70,    -3.60,    -2.20/

C     MAP EACH SPECIES TO ONE OF 13 FITTED EQUATIONS 
C     MSB = MAXIMUM STAND BOUNDARY; THE SAME MAPPING
C     IS USED FOR SDI-BASED MORTALITY: SDI_INT & SDI_SLP

      DATA MSB_MAP /
     >   3, 2, 2, 2, 1, 4, 4, 6, 5, 3, ! 10
     >   8, 7, 2, 5,11,11,13,10,10,11,
     >  10,10,10,12,10, 9,10, 9,11,12, ! 30
     >  12,12,12,12,12,12,11,12,12,13,
     >  13,13,11,12,12,12,10,13,12,10, ! 50
     >  10,10,10,10,12,10,11,11,10,12,
     >  11,11,11,12,13,13,11,12, 3, 1, ! 70
     >   4, 5 /


C BACKGROUND MORTALITY CONSTANTS
C MAPPED BY BKG_MAP

      DATA PMSC/5.1676998,   9.6942997,   5.5876999,   5.9617000/
      DATA PMD/-0.0077681,  -0.0127328,  -0.0053480,  -0.0340128/
      DATA BKG_MAP/
     & 1, 3, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 3, 3, 4, 1, 4, 1, 1, 4,
     & 1, 1, 1, 4, 1, 1, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
     & 4, 4, 4, 1, 4, 4, 1, 1, 4, 4, 4, 4, 1, 4, 4, 1, 4, 4, 1, 4,
     & 4, 4, 4, 1, 1, 4, 1, 4, 1, 3, 1, 1/

C     SEE IF WE NEED TO DO SOME DEBUG.

      CALL DBCHK (DEBUG,'MORTS',5,ICYC)
      IF(DEBUG)WRITE(JOSTND,9000)ICYC
 9000 FORMAT(' ENTERING SUBROUTINE MORTS  CYCLE =',I4)

C     INITIALIZATIONS

      TREEIT= 0.
      KNT = 0
      TPHMAX = 35000.0*HAtoACR

C     PROCESS MORTMULT KEYWORD.

      CALL OPFIND(1,MYACTS(1),NTODO)
      IF(NTODO .EQ. 0)GO TO 25
      DO 24 I=1,NTODO
      CALL OPGET(I,4,IDATE,IACTK,NP,PRM)
      CALL OPDONE(I,IY(ICYC))
      ISPCC=IFIX(PRM(1))
      IF(ISPCC .EQ. 0)GO TO 21
      XMMULT(ISPCC)=PRM(2)
      XMDIA1(ISPCC)=PRM(3)
      XMDIA2(ISPCC)=PRM(4)
      GO TO 24
   21 CONTINUE
      DO 22 ISPCC=1,MAXSP
      XMMULT(ISPCC)=PRM(2)
      XMDIA1(ISPCC)=PRM(3)
      XMDIA2(ISPCC)=PRM(4)
   22 CONTINUE
   24 CONTINUE
   25 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9010)ICYC,RMSQD
 9010 FORMAT(1H0,'IN MORTS 9010 ICYC,RMSQD= ',
     & I5,5X,F10.5)
      IF(RMSQD .EQ. 0.) THEN
        CEPMRT=0.
        SLPMRT=0.
      ENDIF

C     IF BARE GROUND PLANT, LIMITS WERE NOT ADJUSTED FROM A PERCENT TO A
C     PROPORTION IN CRATET, ADJUST THEM HERE.

      IF(PMSDIL .GT. 1.0)PMSDIL = PMSDIL/100.
      IF(PMSDIU .GT. 1.0)PMSDIU = PMSDIU/100.

C     INITIALIZE STARTING VALUES.
C     DQ0, CALCULATED BELOW, IS THE SAME AS RMSQD THAT IS CALCULATED IN DENSE
C     WHEN DBHSDI=0.

      IPASS=0
      SUMKIL= 0.0

C     COMPUTE QUADRATIC MEAN DIAMETER AT THE BEGINNING OF THE CYCLE.
C     COMPUTE INITIAL ESTIMATES OF QMD AND BASAL AREA BY SPECIES AT THE END 
C     OF THE CYCLE USING END-CYCLE DIAMETER AND START-CYCLE PROB. THESE
C     END-OF-CYCLE QMD WILL BE ADJUSTED AS TREES ARE KILLED UNTIL
C     A SOLUTION IS REACHED WITHIN SPECIFIED LIMITS.

      T = 0.0
      DQ0 = 0.0
      SDQ0 = 0.0
      SD2SQ = 0.0
      SUMDR0 = 0.0
      SUMDR10 = 0.0
      DR0 = 0.0
      DR10 = 0.0
      SUMBA = 0.0
      DO 20 ISPC=1,MAXSP
      BASP(ISPC) = 0.0
      I1=ISCT(ISPC,1)
      IF(I1 .LE. 0)GO TO 20
      I2=ISCT(ISPC,2)
      DO 12 I3=I1,I2
      I=IND1(I3)
      P=PROB(I)
      IS=ISP(I)
      WK2(I) = 0.0
      D=DBH(I)
      IF(D.LT.DBHSDI)GO TO 12   ! BRANCH IF D IS LT USER'S DBHSDI
      BARK=BRATIO(IS,D,HT(I))
      G = (DG(I)/BARK) * (FINT/10.0)
      CIOBDS=(2.0*D*G+G*G)
      TEM = P*(D*D+CIOBDS)
      SD2SQ=SD2SQ+TEM
      SDQ0=SDQ0+P*(D)**2.
      IF(LZEIDE)THEN
        SUMDR10=SUMDR10+P*(D+G)**1.605
        SUMDR0=SUMDR0+P*(D)**1.605
      ENDIF
      T=T+P
      BASP(ISPC) = BASP(ISPC) + TEM*0.0054542
      SUMBA = SUMBA + TEM*0.0054542
   12 CONTINUE
   20 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)'SDQ0,SD2SQ,SUMDR0,SUMDR10= ',
     &SDQ0,SD2SQ,SUMDR0,SUMDR10
      IF(DEBUG)WRITE(JOSTND,9002)SUMBA,BASP
 9002 FORMAT(' SUMBA,BASP= ',F10.5,(/10(F10.5)))

C  DETERMINE SPECIES WITH THE MOST BA; THIS WILL DETERMINE WHICH
C  MAXIMUM SDI OR MSB RELATIONSHIP IS CONTROLLING STAND DENSITY

      INDX_BA = 1
      TEM = BASP(1)
      DO ISPC=1,MAXSP
      IF(BASP(ISPC).GT. TEM) THEN
        INDX_BA=ISPC
        TEM = BASP(ISPC)
      ENDIF
      ENDDO
      IF(DEBUG)WRITE(JOSTND,*)' INDX_BA,IBASP= ',INDX_BA,IBASP
      IF(INDX_BA .NE. IBASP)THEN
        IBASP = INDX_BA
        CEPMRT = 0.
        SLPMRT = 0.
      ENDIF

C     SOME EVENTS CAN CHANGE THE TRAJECTORY OF A STAND. FOR EXAMPLE,
C     REGENERATION, THINNING, USER MORTALITY, FIRE, I&P EFFECTS.
C     IF THE TRAJECTORY IS CHANGED,
C     RESET SLOPE AND INTERCEPT FOR CALCULATION.
C     (THE VALUE OF 1. IS TO ALLOW FOR ROUNDING ERROR)

      IF(ICYC.GT.1 .AND. ABS(T-TPAMRT).GT.1.) THEN
        CEPMRT=0.
        SLPMRT=0.
        IF(DEBUG)WRITE(JOSTND,*)' RESETTING SLOPE,INTERCEPT T,TPAMRT= ',
     &  T,TPAMRT
      ENDIF
C
      IF(T .LT. 1.0) GO TO 45
      DQ0=SQRT(SDQ0/T)
      DQ10=SQRT(SD2SQ/T)
      IF(LZEIDE)THEN
        DR0=(SUMDR0/T)**(1./1.605)
        DR10=(SUMDR10/T)**(1./1.605)
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)' IN MORTS, T,ISISP,LZEIDE= ',
     *T,ISISP,LZEIDE
      IF(LZEIDE)THEN
        DIA0=DR0
        D10=DR10
      ELSE
        DIA0=DQ0
        D10=DQ10
      ENDIF
   10 CONTINUE
      IF(DEBUG) WRITE(JOSTND,9020) DQ0,DQ10,T,SD2SQ,DR0,DR10
 9020 FORMAT(1H ,'IN MORTS  DQ0 = ',F10.5,' DQ10 = ',F10.2,
     &' T = ',F8.2,' SD2SQ = ',F10.2,' DR0= ',F10.2,' DR10= ',F10.2)

C     IF D IS TOO LOW, NUMERICAL PROBLEMS OCCUR. RESET IF NECESSARY.

       IF(DIA0 .LT. 0.3) THEN
         D10 = 0.3 + D10 - DIA0
         DIA0  = 0.3
         IF(DEBUG) WRITE(JOSTND,*)' RESETTING DIA0,D10= ',DIA0,D10
       ENDIF

C***********************************************************************
C THIS SECTION OF CODE COMPUTES MORTALITY IN TERMS OF THE RELATIONSHIP
C T = A*(D**B)  WHERE T IS THE TOTAL NUMBER OF TREES AND D IS THE 
C QUADRATIC MEAN DIAMETER OR REINEKE DIAMATER. THIS IS THE REINEKE
C SDI RELATIONSHIP WHEN B = -1.605. ON A LN-LN SCALE THIS BECOMES
C LN(T) = A + B*LN(D). FOR THE ONTARIO VARIANT, WE USE PENNER'S SDI
C MAXIMUM EQUATION SOLVED FOR LN(T) = A + B*LN(D) 
C
C AT A SPECIFIED BREAKPOINT LN(DBH), THE MAXIMUM STAND DENSITY SWITCHES FROM
C BEING CONTROLLED BY THE SDI MAXIMUM EQUATION TO A MATURE STAND BOUNDARY
C (MSB) EQUATION. FOR THE ONTARIO VARIANT, PENNER GIVES EQUATIONS FOR THE
C MATURE STAND BOUNDARY FUNCTION. THE MAXIMUM SDI AND MSB EQUATIONS NEED
C TO BE SEAMLESSLY SPLINED AT THE BREAKPOINT LN(DBH). GARY DIXON ESTIMATED
C COEFFICIENTS TO APPROXIMATE PENNER'S MSB FUNCTION THAT FIT THIS CRITERIA.
C
C DEFAULT LIMITS: LO = 55% MAX SDI (PMSDIL); UP = 85% MAX SDI (PMSDIU)
C THAT IS TO SAY, DENSITY RELATED MORTALITY WILL BE INVOKED WHEN STAND 
C DENSITY REACHES THE LOWER LIMIT, AND WILL BE CAPPED AT THE UPPER LIMIT.
C THESE LIMITS ARE UNDER USER CONTROL USING THE SDIMAX KEYWORD.
C
C FROM RELATIONSHIPS BETWEEN LN(TREES PER ACRE) VS
C LN(DIAMETER), THE MAXIMUM LINE, 85 PERCENT OF MAXIMUM LINE, AND 
C 55 PERCENT OF MAXIMUM LINE, ARE DETERMINED. WHEN STAND DENSITY IS BELOW
C THE LOWER THRESHOLD TREES ARE ONLY SUBJECT TO BACKGROUND MORTALITY. AS
C SUCH, TREES PER ACRE DECREASES ONLY SLIGHTLY UNTIL THE LOWER LIMIT IS
C REACHED. ONCE THE LOWER LIMIT IS REACHED TREES PER ACRE STARTS DECREASING 
C ACCORDING TO AN INTERNALLY COMPUTED LINEAR FN (ON THE LN-LN SCALE) UNTIL 
C IT REACHES THE UPPER LIMIT.  FROM THIS POINT ON, TREES PER ACRE FOLLOWS 
C DOWN THE UPPER LIMIT WHICH IS BASED ON EITHER THE MAXIMUM SDI OR MSB
C RELATIONSHIPS DEPENDING ON STAND QMD AND SPECIES.  FOR STANDS WHERE THE
C INITIAL NUMBER OF TREES EXCEEDS THE UPPER LIMIT, THE NUMBER OF TREES IS 
C DECREASED TO THE UPPER LIMIT THE FIRST CYCLE.
C
C THIS SECTION OF CODE WAS DEVELOPED BY GARY DIXON FMSC FT COLLINS, CO.
C DEFINITION OF VARIABLES IMPORTANT TO THIS SECTION -
C
C     T      = TOTAL NUMBER OF TREES
C     ISISP  = INDEX OF SPECIES WITH MAXIMUM BASAL AREA
C     TMD0   = MAXIMUM NUMBER OF TREES FOR A GIVEN DQ0 OR DRO
C     T85D0  = 85 PERCENT LEVEL OF TMD0
C     T55D0  = 55 PERCENT LEVEL OF TMD0
C     TMD10  = MAXIMUM NUMBER OF TREES FOR A GIVEN DQ10 OR DR10
C     T85D10 = 85 PERCENT LEVEL OF TMD10
C     T55D10 = 55 PERCENT LEVEL OF TMD10
C     D55M   = DIAMETER VALUE CORRESPONDING TO LN(T) ON THE 55 PERCENT L
C     D85M   = DIAMETER VALUE CORRESPONDING TO THE POINT WHERE THE LINEA
C              INTERSECTS THE 85 PERCENT LINE
C     SLPMRT = SLOPE COEFFICIENT FOR THE LINEAR FN
C     CEPMRT = INTERCEPT COEFFICIENT FOR THE LINEAR FN
C     KNT    = COUNTER FOR NUMBER OF ITERATIONS IN DETERMINING COEFFICIE
C     TREEIT = NUMBER OF TREES VALUE USED IN ITERATION PROCESS
C     TEM    = TEMPORARY STORAGE VARIABLE
C     IPATH  = PATH THROUGH LINEAR FN COEFFICIENT SECTION -
C              1 IF ITERATIVE DETERMINATION
C              2 IF STRAIGHT COMPUTATION
C     TMMSB  = MAXIMUM NUMBER OF TREES FOR A GIVEN DQ10 OR DR10
C              ACCORDING TO THE MATURE STAND BOUNDARY FUNCTION
C     T85MSB = 85 PERCENT LEVEL OF TMMSB

C  SDIMAX IS USED HERE TO CARRY WEIGHTED SDI MAXIMUM
C  THIS IS COMPUTED USING REINEKE'S EQUATIONS AND IS ONLY USED
C  IN THIS VARIANT FOR THE CLIMATE CHANGE CHECK.

      CALL SDICAL(SDIMAX)
      CONST = SDIMAX / (10**(-1.605))
      IF(DEBUG)WRITE(JOSTND,*)' SDIMAX,CONST,BAMAX= ',
     &SDIMAX,CONST,BAMAX

C IF SDIMAX IS LESS THAN 5, ASSUME CLIMATE HAS CHANGED ENOUGH THAT THE
C SITE WILL NO LONGER SUPPORT TREES, AND KILL ALL EXISTING TREES.

      IF(SDIMAX .LT. 5)THEN
        TN10=0.
        GO TO 271
      ENDIF

      IPATH = 0
      IF(T .GT. TPHMAX) T=TPHMAX

C     GIVEN DQ0, DETERMINE MAXIMUM TREES, 85 PERCENT LEVEL AND 
C     55 PERCENT LEVEL

  190 CONTINUE
      INDX = MSB_MAP(INDX_BA)
      SDIINT = -SDI_INT(INDX)/SDI_SLP(INDX)
      SDISLP = 1.0 /SDI_SLP(INDX)
      CONST = EXP(SDIINT)
      IF(DEBUG)WRITE(JOSTND,*)' INDX,SDIINT,SDISLP,CONST= ',
     &INDX,SDIINT,SDISLP,CONST 
      TMD0 = ACRtoHA*EXP(SDIINT+SDISLP*ALOG(DIA0*INtoCM))
      IF(TMD0 .GT. TPHMAX) TMD0 = TPHMAX
      T55D0 = TMD0 * PMSDIL
      T85D0 = TMD0 * PMSDIU
      IF(DEBUG)WRITE(JOSTND,*)' INDX_BA,INDX,DIA0,D10,CONST= ',
     &INDX_BA,INDX,DIA0,D10,CONST             
      IF(DEBUG)WRITE(JOSTND,*)' TMD0,PMSDIU,PMSDIL,T85D0,T55D0= ',
     &TMD0,PMSDIU,PMSDIL,T85D0,T55D0

C     GIVEN DQ10 OR DR10 DETERMINE MAXIMUM TREES, 85 PERCENT LEVEL
C     AND 55 PERCENT L

      TMD10 = ACRtoHA*EXP(SDIINT+SDISLP*ALOG(D10*INtoCM))
      IF(TMD10 .GT. TPHMAX) TMD10 = TPHMAX
      T55D10 = TMD10 * PMSDIL
      T85D10 = TMD10 * PMSDIU      
      IF(DEBUG)WRITE(JOSTND,*)' TMD10,PMSDIU,PMSDIL,T85D10,T55D10= ',
     &TMD10,PMSDIU,PMSDIL,T85D10,T55D10
      IF(DEBUG)WRITE(JOSTND,9040)ICYC,SDIMAX
 9040 FORMAT(' IN MORTS ICYC,MAX SDI =',I5,F10.1)

C IF A USER-SPECIFIED (MORTMSB KEYWORD) MSB IS IN EFFECT, 
C THEN COMPUTE THE MSB EQUATION INTERCEPT. 
C ASSUMES QMDMSB IS IN INCHES AT THIS POINT
C SLPMSB IS CARRIED IN COMMON AND IS THE USER-ENTERED SLOPE
C SDISLP IS THE SLOPE OF PENNER'S SDI EQN SOLVED LN(T)=A+B*LN(QMDcm)
C CONST IS THE CONSTANT OF PENNER'S SDI EQN T=C*QMDcm**(-D)

      IF(SLPMSB .NE. 0.)THEN
        TEMP = INtoCM*QMDMSB
        CEPMSB = ALOG(CONST*(TEMP**(SDISLP)))-SLPMSB*ALOG(TEMP)
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)' MATURE STAND BOUNDARY SETTINGS, QMDMSB,'
     &,'CEPMSB,SLPMSB,D10= ',QMDMSB,CEPMSB,SLPMSB,D10 

C     IF TOTAL NUMBER OF TREES EXCEEDS 85 PERCENT OF THE COMPUTED MAXIMUM,
C     KILL BACK TO 85 PERCENT LEVEL.

      IF(T .LE. T85D0) GO TO 210
      TN10 = T85D10
      GO TO 270
  210 CONTINUE

C     IF TOTAL NUMBER OF TREES IS BETWEEN 55 PERCENT AND 85 PERCENT, FIND
C     LINEAR FN COEFFICIENTS (ITERATIVE METHOD) AND KILL ACCORDING TO
C     LINEAR FN.

      IF(T .LE. T55D0) GO TO 240

C       SPECIAL CASE WHERE T IS CLOSE TO THE 85% LINE AT DIA0

      IF(ABS(T85D0-T).LE.5.)THEN
        TN10=T85D10
        GO TO 270
      ENDIF

      KNT = 1
      TREEIT = T + 0.1 * T
      IPATH = 1
  220 CONTINUE
      TEM = TREEIT
      IF(IPATH .EQ. 2) TEM = T
      IF(DEBUG)WRITE(JOSTND,*)' MORTS 220,TEM,CONST',TEM,CONST
      TEMP = TEM*HAtoACR
      D55M = (ALOG(TEMP) - ALOG(PMSDIL*CONST)) / (SDISLP)
      T55M = ALOG(TEMP)
      D85M = D55M * 1.25
      IF(DEBUG)WRITE(JOSTND,*)' D55M,T55M,D85M= ',D55M,T55M,D85M
  221 IF(D85M .GT. 5.0) D85M = 5.0
      IF(D85M .LT. 0.125)D85M=0.125
      T85M = ALOG(CONST * (EXP(D85M) ** (SDISLP)) * PMSDIU)
      SLP = (T85M-T55M) / (D85M - D55M)
      IF(DEBUG)WRITE(JOSTND,*)' D55M,D85M,T55M,T85M,SLP= ',
     &D55M,D85M,T55M,T85M,SLP
      IF(SLP .GT. -0.5 .AND. D85M .LT. 5.0)THEN
        D85M = D85M + .1
        GO TO 221
      ENDIF
      CEPT = T55M - SLP * D55M
      IF(T .LE. T55D0) GO TO 230
      IF(DEBUG)WRITE(JOSTND,*)' MORTS,359,DIA0',DIA0
      TPRIME = CEPT + SLP * ALOG(DIA0*INtoCM)
      DIFF = T - EXP(TPRIME)*ACRtoHA
      IF(DEBUG)WRITE(JOSTND,9050) DIA0,D10,T,TREEIT,TEM,D55M,
     *T55M,D85M,T85M,SLP,CEPT,TPRIME,DIFF,KNT
 9050 FORMAT(1H0,'MORTS 9050',13F9.3,I4)
      IF(DIFF .LE. 5.0 .AND. DIFF .GE. -5.0) GO TO 230
      TREEIT = TREEIT + 0.5 * DIFF
      KNT = KNT + 1
      IF(KNT .LE. 100) GO TO 220
  230 CONTINUE
      IF(SLPMRT .EQ. 0.) SLPMRT = SLP
      IF(CEPMRT .EQ. 0.) CEPMRT = CEPT
      IF(DEBUG)WRITE(JOSTND,*)' D10,CEPMRT,SLPMRT= ',D10,CEPMRT,SLPMRT
      TEM = ALOG(D10*INtoCM)
      TN10 = CEPMRT + SLPMRT*TEM
      TN10 = EXP(TN10)*ACRtoHA
      IF(TN10 .GE. T85D10)  TN10 = T85D10
      GO TO 270
  240 CONTINUE

C IF TOTAL NUMBER OF TREES IS LESS THAN 55 PERCENT AT DIA0 BUT GREATER TH
C 55 PERCENT AT D10, FIND LINEAR FN (STRAIGHT COMPUTATION) AND KILL
C ACCORDING TO LINEAR FN.
C IF TOTAL NUMBER OF TREES IS LESS THAN 55 PERCENT AT DIA0 AND D10,
C HOLD NUMBER OF TREES CONSTANT.

      IF(T .LE. T55D10) THEN
        TN10 = T
        GO TO 270
      ELSE
        IPATH = 2
        GO TO 220
      ENDIF
  270 CONTINUE
  
      IF(DEBUG)WRITE(JOSTND,9060)DIA0,D10,T,TN10,TREEIT,
     *CONST,KNT
 9060 FORMAT(1H0,'MORTS 9060',6(F10.3,3X),I4)

C   BOUND TN10 (THE NUMBER OF TREES REMAINING IN THE STAND AFTER MORTALITY)
C   IF TN10 IS GREATER THAN T, SET TN10 = T
C   IF TN10 IS SMALL, JUST KILL ALL THE TREES

  271 CONTINUE
      IF(TN10 .GT. T)TN10=T
      IF(TN10 .LT. 0.1)TN10=0.
      
C     RN IS SDI-DRIVEN ANNUAL MORTALITY 
C     PREDICTED AT THE STAND LEVEL

      RN=1.0-(1.0-((T-TN10)/T))**(1./FINT)
      
      IF(DEBUG) WRITE(JOSTND,*) 'TESTMORTS, RN=',RN,
     *'T=',T,'TN10=',TN10
     
C  START LOOP TO ESTIMATE SDI BASED MORTALITY RATE.
C  TREES ARE PROCESSED ONE AT A TIME WITHIN A SPECIES.

      DO 50 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.LE.0) GO TO 50
      I2=ISCT(ISPC,2)
      XMORT = XMMULT(ISPC)
      D1=XMDIA1(ISPC)
      D2=XMDIA2(ISPC)
      B0 = PMSC(BKG_MAP(ISPC))
      B1 = PMD(BKG_MAP(ISPC))
      
C  START TREE LOOP WITHIN SPECIES.
      DO 40 I3=I1,I2

C  INITIALIZE FOR NEXT TREE.

      I=IND1(I3)
      P=PROB(I)
      WKI=0.0
      WK2(I)=0.0
      IF(P.LE.0.0) GO TO 40
      D=DBH(I)

C     COMPUTE BACKGROUND MORTALITY RATE RI

      RI=(1.0/(1.0+EXP(B0+B1*D)))

C TEST RUNS SHOW BACKGROUND MORTALITY RATE IS HIGH, CUT IT IN HALF.
      RI = 0.5 * RI

C MERGE ESTIMATES OF RI AND RN
      RIP = RI

C IF SDI NOT IN EFFECT YET SET RIP TO BACKGROUND MORTALITY RATE.
C OTHERWISE SET TO SDI MORTALITY RATE.

      RIP=RN
      TEM=CONST*((D10*INtoCM)**(SDISLP))
      IF(TEM .GT. TPHMAX)TEM=TPHMAX
      TEM=TEM*PMSDIL*ACRtoHA
      IF(T .LE. TEM .OR. RN .LE. 0.0)RIP=RI
      IF(RIP.GT.1.0) RIP=1.0
      X=1.0
      IF(D .GE. D1 .AND. D .LT. D2)X=XMORT

C     APPLY MORTALITY MULTIPLIER ONLY TO BACKGROUND RATE

      IF(RIP .EQ. RN) X=1.0
      WKI=P*(1.0-(1.0-RIP)**FINT)*X
      IF(WKI.GT.P) WKI=P
      IF(DEBUG) WRITE(JOSTND,9070) I,D,RI,RN,RIP
 9070 FORMAT(' MORTALITY RATE ESTIMATES FOR TREE ',I4,', DBH = ',F6.2/
     *'  RI = ',F7.5,' RN = ',F7.5,' RIP = ',F7.5)
      WK2(I)=WKI

C  END OF TREE LOOP.  PRINT DEBUG INFO IF DESIRED.

      IF(DEBUG) THEN
        PRES=P-WKI
        VLOS=WKI*CFV(I)/FINT
        WRITE(JOSTND,9080) I,ISPC,D,P,WKI,PRES,VLOS
 9080   FORMAT(' IN MORTS, I=',I4,',  ISPC=',I3,',  DBH=',F7.2,
     &       ',  INIT PROB=',F7.3,
     &       ',  TREES DYING=',F7.3,'RES PROB=',F7.3,
     &       ',  VOL LOST=',F9.3)
      ENDIF
   40 CONTINUE

C  END OF SPECIES LOOP.  PRINT DEBUG INFO IF DESIRED.

   50 CONTINUE

C DISTRIBUTE MORTALITY BY VARIANT SPECIFIC METHOD
C IF ALL TREES ARE BEING KILLED, WE DON'T NEED TO DO THIS

      SUMTRE = 0.0
      IF(RIP .EQ. RN)SUMTRE = T-TN10
      IF(SUMTRE .LT. 0.0)SUMTRE=0.0
      IF(TN10 .GE. 0.1)THEN
        CALL VARMRT(SUMTRE,DEBUG,SUMKIL,D10)
      ENDIF

C ESTIMATE NEW QUADRATIC MEAN DIAMETER AND SEE HOW BAD OUR
C INITIAL ESTIMATE WAS.

      TN=0.0
      SD2SQN=0.0
      SUMDR10N=0.
      DR10N=0.
      IPASS = IPASS+1
      DO 30 I=1,ITRN
      P=PROB(I)-WK2(I)
      IS=ISP(I)
      D=DBH(I)
      IF(D.LT.DBHSDI)GO TO 30   ! BRANCH IF D IS LT USER'S DBHSDI
      BARK=BRATIO(IS,D,HT(I))
      G = (DG(I)/BARK) * (FINT/10.0)
      CIOBDS=(2.0*D*G+G*G)
      SD2SQN=SD2SQN+P*(D*D+CIOBDS)
      IF(LZEIDE)THEN
        SUMDR10N=SUMDR10N+P*(D+G)**(1.605)
      ENDIF
      TN=TN+P
   30 CONTINUE
      IF(TN .EQ. 0.0)GO TO 35
      DQ10N=SQRT(SD2SQN/TN)
      IF(LZEIDE)THEN
        DR10N=(SUMDR10N/TN)**(1./1.605)
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)' MORTS CHECK DIA. IPASS,DQ10,DR10,',
     *'DQ10N,DR10N= ',IPASS,DQ10,DR10,DQ10N,DR10N
      IF(LZEIDE)THEN
        D10N=DR10N
      ELSE
        D10N=DQ10N
      ENDIF
      IF(IPASS .EQ. 10)GO TO 35
      DIFF=ABS(DQ10-D10N)
      IF(DIFF .GT. 0.2)THEN

C SOMETIMES SELECTIVE KILLING CAN DECREASE QMD.  IF SO, TAKE
C CALCULATED MORTALITY AND RECALIBRATE NEXT CYCLE.
        IF(DEBUG)WRITE(JOSTND,*)' D10,DIA0,DQ10,D10N= ',
     &  D10,DIA0,DQ10,D10N
        IF(D10N .LE. DIA0)THEN
          IPATH = 0
          GO TO 35
        ENDIF
        D10=D10N
        GO TO 10
      ENDIF
   35 CONTINUE

C IF ALTERNATE MORTALITY IS IN EFFECT, THEN COMPUTE NECESSARY PARAMETERS
C AND KILL ADDITIONAL TREES TO SIMULATE STAND BREAK-UP. QMD WILL CHANGE
C SO SET FLAG TO RECALIBRATE NEXT CYCLE.

C IF USER HAS ENTERED THEIR OWN MSB RELATIONSHIP USING THE MORTMSB KEYWORD,
C THEN USE IT; USE GARY DIXON'S APPROXIMATION TO MARGARET PENNER'S EQN 10
C AS THE DEFALUT MSB LINE.

      TMMSB=0.
      T85MSB=0.
      IF(SLPMSB .NE. 0.)THEN
        TEMINT = CEPMSB
        TEMSLP = SLPMSB
        TEMQMD = ALOG(INtoCM*QMDMSB)
      ELSE
        TEMINT = MSB_INT(INDX)
        TEMSLP = MSB_SLP(INDX)
        TEMQMD = MSB_DBH(INDX)
      ENDIF
      TEMP = ALOG(INtoCM*D10)
      IF(DEBUG)WRITE(JOSTND,*)' TEMP,TEMQMD,TN= ',TEMP,TEMQMD,TN
      IF(TEMP.GT.TEMQMD .AND. TN.GT.0.)THEN
        TMMSB=EXP(TEMINT+TEMSLP*TEMP)
        IF(DEBUG)WRITE(JOSTND,*)' TEMINT,TEMSLP,TEMP,TMMSB= ',
     &  TEMINT,TEMSLP,TEMP,TMMSB
        T85MSB=TMMSB*PMSDIU
        IF(DEBUG)WRITE(JOSTND,*)' TMMSB,PMSDIU,T85MSB= ',
     &  TMMSB,PMSDIU,T85MSB
        TMORE=TN-T85MSB*ACRtoHA
        IF(DEBUG)WRITE(JOSTND,*)' TN,T85MSB,ACRtoHA,TMORE= ',
     &  TN,T85MSB,ACRtoHA,TMORE
        IF(TMORE .LT. 0.)TMORE=0.
        IF(DEBUG)WRITE(JOSTND,*)' ALTERNATE MORTALITY LOGIC, D10,TN,',
     &  'TEMQMD,TEMINT,TEMSLP,TMMSB,T85MSB,PMSDIU,TMORE= '
        IF(DEBUG)WRITE(JOSTND,*)
     &  D10,TN,TEMQMD,TEMINT,TEMSLP,TMMSB,T85MSB,PMSDIU,TMORE  

C MAKE SURE MSB EFFICIENCY IS SET HIGH ENOUGH; SINCE MORTALITY IS
C CONCENTRATED IN A DBH RANGE, FIRST COMPUTE THE TPA LEFT IN THE DBH
C RANGE AFTER DENSITY RELATED MORTALITY HAS BEEN ACCOUNTED FOR.
C CALL SUBROUTINE MSBMRT TO KILL TMORE TREES AND SET RECALIBRATE FLAG.
C
C IF THERE AREN'T ENOUGH TREES LEFT IN THE CLASS TO ACHIEVE THE
C ALTERNATE MORTALITY LEVEL EVEN IF THEY ARE ALL KILLED, THEN CANCEL 
C THE ALTERNATE MORTALITY LOGIC; IF THE EFFICIENCY IS SET TO LOW TO
C ACHIEVE THE ALTERNATE MORTALITY LEVEL THEN RECOMPUTE IT AND CONTINUE
C WITH THE LOGIC.

        TPACLS=0.
        DO I=1,ITRN
        BARK=BRATIO(ISP(I),DBH(I),HT(I))
        DBHEND=DBH(I)+(DG(I)/BARK)*(FINT/10.0)
        IF(DBHEND.GE.DLOMSB .AND. DBHEND.LT.DHIMSB)THEN
          TPACLS=TPACLS+PROB(I)-WK2(I)
        ENDIF
        ENDDO
        IF(DEBUG)WRITE(JOSTND,*)' ALT MORT LOGIC DLOMSB,DHIMSB,TPACLS',
     &  ' = ',DLOMSB,DHIMSB,TPACLS

        IF(TMORE .GT. TPACLS)THEN
          WRITE(JOSTND,351)TPACLS,TMORE
  351     FORMAT(/,2(' ***************'/),' WARNING: FOR ALTERNATE ',
     &    'MORTALITY, TPA IN DBH CLASS OF ',F8.1,
     &    ' TREES/ACRE IS LESS THAN THE ADDITIONAL MORTALITY TPA',
     &    /,10X,' OF ',F8.1,' TREES/ACRE.  '
     &    'ALTERNATE MORTALITY CANCELLED.',/2(' ***************'/),/)
          GO TO 353
        ENDIF

        TEMEFF=EFFMSB
        IF(MFLMSB .EQ. 3) THEN
          TEMEFF=TMORE/TPACLS
        ELSE
          IF(TPACLS*TEMEFF .LT. TMORE)THEN
            TEMEFF=TMORE/TPACLS
            WRITE(JOSTND,352)EFFMSB,TEMEFF
  352       FORMAT(/,2(' ***************'/),' WARNING: FOR ALTERNATE ',
     &      'MORTALITY, MORTALITY EFFICIENCY OF ',F8.4,
     &      ' IS TOO LOW TO REACH THE ADDITIONAL MORTALITY LEVEL. ',
     &      /,10X,'MORTALITY EFFICIENCY RESET TO ',F8.4,
     &      ' FOR FURTHER PROCESSING.',
     &      /2(' ***************'/),/)
          ENDIF
        ENDIF
        CALL MSBMRT(TEMEFF,TMORE,DLOMSB,DHIMSB,MFLMSB,DEBUG)
        IPATH=0
      ENDIF
  353 CONTINUE
   
C  LOOP THROUGH TREES AND CHECK FOR SIZE (aka AGE) CAP RESTRICTIONS

      DO 354 I=1,ITRN
      IS = ISP(I)
      D = DBH(I)
      P = PROB(I)
      BARK=BRATIO(IS,D,HT(I))
      G = (DG(I)/BARK) * (FINT/10.0)
      IDMFLG=IFIX(SIZCAP(IS,3))
      IF((D+G).GE.SIZCAP(IS,1) .AND. IDMFLG.NE.1) THEN
        WK2(I) = AMAX1(WK2(I),(P*SIZCAP(IS,2)*FINT/10.0))
        IF(WK2(I) .GT. P)WK2(I)=P
        IF(DEBUG)WRITE(JOSTND,*)' SIZE CAP RESTRICTION IMPOSED, ',
     &  'I,IS,D,P,SIZCAP 1-3,WK2 = ',
     &  I,IS,D,P,SIZCAP(IS,1),SIZCAP(IS,2),SIZCAP(IS,3),WK2(I)
      ENDIF
  354 CONTINUE

C  CHECK TO SEE IF BA IS STILL WITHIN LIMITS. IF OUT OF BOUNDS,
C  ADJUST THE MORTALITY VALUES PROPORTIONATELY ACROSS ALL TREE RECORDS.

      KNT2=0
9001  CONTINUE
      TNEW=0.
      BANEW=0.
      QMDNEW=0.
      BADEAD=0.
      DO 36 I=1,ITRN
      P=PROB(I)-WK2(I)
      D=DBH(I)
      BARK=BRATIO(ISP(I),D,HT(I))      
      G = (DG(I)/BARK) * (FINT/10.0)
      TNEW=TNEW+P
      BANEW=BANEW+(0.0054542*(D+G)**2.)*P
      BADEAD=BADEAD+(0.0054542*(D+G)**2.)*WK2(I)      
      QMDNEW=QMDNEW + ((D+G)**2.)*P
      IF(DEBUG)WRITE(JOSTND,*)' I,P,D,G,TNEW,BANEW,QMDNEW,BADEAD= ',
     &I,P,D,G,TNEW,BANEW,QMDNEW,BADEAD 
   36 CONTINUE
      IF(TNEW .GT. 0.) THEN
        QMDNEW=SQRT(QMDNEW/TNEW)
      ELSE
        QMDNEW = 0.
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)' ICYC,BANEW,TBAM1,TNEW,QMDNEW,KNT2= ',
     &ICYC,BANEW,TBAM1,TNEW,QMDNEW,KNT2
      IF((BANEW-BAMAX) .GT. 1.) THEN

C       CALCULATE ADJUSTMENT FACTOR NEEDED TO GET RESIDUAL BA WITHIN
C       THE BA MAXIMUM LIMIT. INCREASE IT BY 10% AND PLACE A LOWER
C       BOUND ON THE FACTOR TO SPEED UP ITERATION.

        ADJFAC = ((BANEW-BAMAX)/BADEAD)
        IF(DEBUG)WRITE(JOSTND,*)' BANEW,TBAM1,ADJFAC= ',
     &  BANEW,TBAM1,ADJFAC

C       LOOP THROUGH THE TREE LIST AND ADJUST THE MORTALITY VALUES.

        TNEW=0.
        DO 1500 I=1,ITRN
        P=PROB(I)
        WKI=WK2(I)*(1+ADJFAC)
        IF(WKI.GT.P) WKI=P
        WK2(I)=WKI
        IF(DEBUG)WRITE(JOSTND,*)' ADJUSTING FOR BAMAX I,P,WKI= ',
     &  I,P,WKI   

C       PRINT DEBUG INFO IF DESIRED.

        TNEW=TNEW+P-WKI
        IF(.NOT.DEBUG) GO TO 1500
        PRES=P-WKI
        VLOS=WKI*CFV(I)/FINT
        WRITE(JOSTND,9080) I,ISPC,D,P,WKI,PRES,VLOS
 1500   CONTINUE

C LOOP BACK AND SEE IF THE BAMAX TARGET HAS BEEN ACHIEVED YET.
C (I.E. IF THE COMPUTED MORTALITY RATE EXCEEDED THE PROB, AND WE 
C  HAD TO LIMIT MORTALITY TO THE PROB VALUE FOR SOME TREE RECORDS,
C  THEN WE MAY NOT REACH THE BA LIMIT IN ONE PASS.) 

        KNT2=KNT2+1
        IF(KNT2 .LT. 100)GO TO 9001

        IPATH=0
        IF(DEBUG)WRITE(JOSTND,*)' AFTER BA ADJUSTMENT RESIDUAL TPA = ',
     &  TNEW
      ENDIF
      TPAMRT=TNEW
   45 CONTINUE

C  COMPUTE THE FIXMORT OPTION.  LOOP OVER ALL SCHEDULED FIXMORT'S
C  LINCL IS USED TO INDICATE WHETHER A TREE GETS AFFECTED OR NOT

      CALL OPFIND (1,MYACTS(2),NTODO)
      IF (NTODO.GT.0) THEN
        IF(DEBUG)WRITE(JOSTND,*)' FIXMORT PROCESSING, ITODO= ',ITODO
         DO 300 ITODO=1,NTODO
         CALL OPGET (ITODO,6,IDATE,IACTK,NP,PRM)
         IF (IACTK.LT.0) GOTO 300
         CALL OPDONE(ITODO,IY(ICYC))
         ISPCC=IFIX(PRM(1))
         IF(NP .LE. 4)THEN
           IF(PRM(2).GT. 1.0)PRM(2)=1.0
         ENDIF
         IF(PRM(3).LT. 0.0)PRM(3)=0.0
         IF(PRM(4).LE. 0.0)PRM(4)=999.
         IP=1
         IF (NP.GT.4) THEN
            IF (PRM(5).EQ.1.0) THEN
               IP=2
            ELSEIF (PRM(5).EQ.2.0) THEN
               IP=3
            ELSEIF (PRM(5).EQ.3.) THEN
               IP=4
            ENDIF
         ENDIF

C  SET FLAG FOR POINT MORTALITY, OR KILLING FROM ABOVE
C    PRM(6)    POINT      SIZE   KBIG     KILL DIRECTION
C      0         NO        NO     0                       DEFAULT CONDITION
C      1         YES       NO     0
C     10         NO        YES    1       BOTTOM UP
C     11         YES       YES    1       BOTTOM UP
C     20         NO        YES    2       TOP DOWN
C     21         YES       YES    2       TOP DOWN

         KPOINT=0
         KBIG=0
         IF(PRM(6).GT.0.)THEN
           IF(PRM(6) .EQ. 1)THEN
             KPOINT=1
           ELSEIF(PRM(6) .EQ. 10)THEN
             KBIG=1
           ELSEIF(PRM(6) .EQ. 11)THEN
             KPOINT=1
             KBIG=1
           ELSEIF(PRM(6) .EQ. 20)THEN
             KBIG=2
           ELSEIF(PRM(6) .EQ. 21)THEN
             KPOINT=1
             KBIG=2
           ENDIF
         ENDIF
         IF (ITRN.GT.0) THEN

C IF CONCENTRATING MORTALITY ON A POINT, AND/OR BY SIZE TREES IS IN
C EFFECT, DETERMINE EFFECT OF THIS FIXMORT AND REALLOCATE BY POINT:
C   REALLOCATE ALL MORTALITY IF REPLACE OPTION OR MULTIPLY OPTION
C   ARE IN EFFECT.
C   ONLY REALLOCATE ADDITIONAL MORTALITY IF "ADD" OPTION IS IN EFFECT
C   ONLY REALLOCATE ADDITIONAL MORTALITY IF "MAX" OPTION IS IN EFFECT
C   (I.E. MORTALITY OVER AND ABOVE WHAT WAS PREVIOUSLY PREDICTED.

            IF(KBIG.GE.1 .OR. (KPOINT.EQ.1 .AND. IPTINV.GT.1)) THEN
              XMORE=0.
              DO 199 I=1,ITRN
              LINCL = .FALSE.
              IF(ISPCC.EQ.0 .OR. ISPCC.EQ.ISP(I))THEN
                LINCL = .TRUE.
              ELSEIF(ISPCC.LT.0)THEN
                IGRP = -ISPCC
                IULIM = ISPGRP(IGRP,1)+1
                DO 90 IG=2,IULIM
                IF(ISP(I) .EQ. ISPGRP(IGRP,IG))THEN
                  LINCL = .TRUE.
                  GO TO 91
                ENDIF
   90           CONTINUE
              ENDIF
   91         CONTINUE
              IF (LINCL .AND.
     >          (PRM(3).LE.DBH(I) .AND. DBH(I).LT.PRM(4))) THEN
                GOTO (191,192,193,194),IP
  191           CONTINUE
                XMORE=XMORE+PROB(I)*PRM(2)
                WK2(I)=0.
                GOTO 199
  192           CONTINUE
                XMORE=XMORE+(AMAX1(0.0,PROB(I)-WK2(I))*PRM(2))
                GOTO 199
  193           CONTINUE
                TEMP=AMAX1(WK2(I),(PROB(I)*PRM(2)))
                IF(TEMP .GT. WK2(I)) THEN
                  XMORE=XMORE+TEMP-WK2(I)
                ENDIF
                GOTO 199
  194           CONTINUE
                XMORE=XMORE+WK2(I)*PRM(2)
                WK2(I)=0.
                GOTO 199
              ENDIF
  199         CONTINUE
              IF(DEBUG)WRITE(JOSTND,*)' KPOINT,KBIG,ITRN,XMORE= ',
     &                 KPOINT,KBIG,ITRN,XMORE
              CREDIT=0.
              DO 201 I=1,ITRN
              IWORK1(I)=IND1(I)
              IF(KBIG .EQ. 1)THEN
                WORK3(I)=(-1.0)*
     &                  (DBH(I)+DG(I)/BRATIO(ISP(I),DBH(I),HT(I)))
              ELSE
                WORK3(I)=DBH(I)+DG(I)/BRATIO(ISP(I),DBH(I),HT(I))
              ENDIF
  201         CONTINUE
              CALL RDPSRT(ITRN,WORK3,IWORK1,.FALSE.)
              IF(DEBUG)WRITE(JOSTND,*)' DBH= ',(DBH(IG),IG=1,ITRN)
              IF(DEBUG)WRITE(JOSTND,*)' IWORK1= ',(IWORK1(IG),IG=1,ITRN)
              IF(DEBUG)WRITE(JOSTND,*)' WK2= ',(WK2(IG),IG=1,ITRN)

              IF(KBIG.GE.1 .AND. KPOINT.EQ.0)THEN

C  CONCENTRATION BY SIZE ONLY

                DO 310 I=1,ITRN
                IX=IWORK1(I)
                LINCL = .FALSE.
                IF(ISPCC.EQ.0 .OR. ISPCC.EQ.ISP(IX))THEN
                  LINCL = .TRUE.
                ELSEIF(ISPCC.LT.0)THEN
                  IGRP = -ISPCC
                  IULIM = ISPGRP(IGRP,1)+1
                  DO 92 IG=2,IULIM
                  IF(ISP(IX) .EQ. ISPGRP(IGRP,IG))THEN
                    LINCL = .TRUE.
                    GO TO 93
                  ENDIF
   92             CONTINUE
                ENDIF
   93           CONTINUE
                IF (LINCL .AND.
     >          (PRM(3).LE.DBH(IX) .AND. DBH(IX).LT.PRM(4))) THEN
                  TEMP=CREDIT+PROB(IX)-WK2(IX)
                  IF((TEMP .LE. XMORE).OR.
     >               (ABS(TEMP-XMORE).LT.0.0001))THEN
                    CREDIT=CREDIT+PROB(IX)-WK2(IX)
                    WK2(IX)=PROB(IX)
                  ELSE
                    WK2(IX)=WK2(IX)+XMORE-CREDIT
                    CREDIT=XMORE
                    GO TO 295
                  ENDIF
                ENDIF
  310           CONTINUE
                GO TO 295

              ELSEIF(KPOINT.EQ.1 .AND. KBIG.EQ.0)THEN

C  CONCENTRATION ON POINTS ONLY

              DO 205 J=1,IPTINV
              DO 204 I=1,ITRN
              IF(ITRE(I) .NE. J)GO TO 204
              LINCL = .FALSE.
              IF(ISPCC.EQ.0 .OR. ISPCC.EQ.ISP(I))THEN
                LINCL = .TRUE.
              ELSEIF(ISPCC.LT.0)THEN
                IGRP = -ISPCC
                IULIM = ISPGRP(IGRP,1)+1
                DO 94 IG=2,IULIM
                IF(ISP(I) .EQ. ISPGRP(IGRP,IG))THEN
                  LINCL = .TRUE.
                  GO TO 95
                ENDIF
   94           CONTINUE
              ENDIF
   95         CONTINUE
              IF (LINCL .AND.
     >          (PRM(3).LE.DBH(I) .AND. DBH(I).LT.PRM(4))) THEN
                TEMP=CREDIT+PROB(I)-WK2(I)
                IF((TEMP .LE. XMORE).OR.
     >             (ABS(TEMP-XMORE).LT.0.0001))THEN
                  CREDIT=CREDIT+PROB(I)-WK2(I)
                  WK2(I)=PROB(I)
                ELSE
                  WK2(I)=WK2(I)+XMORE-CREDIT
                  CREDIT=XMORE
                  GO TO 295
                ENDIF
              ENDIF
  204         CONTINUE
  205         CONTINUE
              GO TO 295

C  CONCENTRATION BY SIZE ON POINTS (POINTS HAVE PRIORITY, SO TREES
C  WILL BE KILLED BY SIZE ON ONE POINT BEFORE MOVING TO THE NEXT
C  POINT TO START WITH THE BIGGEST/SMALLEST TREES ON THAT POINT.
              ELSE
              DO 312 J=1,IPTINV
              DO 311 I=1,ITRN
              IX=IWORK1(I)
              IF(ITRE(IX) .NE. J)GO TO 311
              LINCL = .FALSE.
              IF(ISPCC.EQ.0 .OR. ISPCC.EQ.ISP(IX))THEN
                LINCL = .TRUE.
              ELSEIF(ISPCC.LT.0)THEN
                IGRP = -ISPCC
                IULIM = ISPGRP(IGRP,1)+1
                DO 96 IG=2,IULIM
                IF(ISP(IX) .EQ. ISPGRP(IGRP,IG))THEN
                  LINCL = .TRUE.
                  GO TO 97
                ENDIF
   96           CONTINUE
              ENDIF
   97         CONTINUE
              IF (LINCL .AND.
     >          (PRM(3).LE.DBH(IX) .AND. DBH(IX).LT.PRM(4))) THEN
                TEMP=CREDIT+PROB(IX)-WK2(IX)
                IF((TEMP .LE. XMORE).OR.
     >             (ABS(TEMP-XMORE).LT.0.0001))THEN
                  CREDIT=CREDIT+PROB(IX)-WK2(IX)
                  WK2(IX)=PROB(IX)
                ELSE
                  WK2(IX)=WK2(IX)+XMORE-CREDIT
                  CREDIT=XMORE
                  GO TO 295
                ENDIF
              ENDIF
  311         CONTINUE
  312         CONTINUE
              GO TO 295
              ENDIF

            ENDIF

C  NORMAL FIXMORT PROCESSING WHEN POINT OR SIZE CONCENTRATION
C  IS NOT IN EFFECT.

            DO 290 I=1,ITRN
              LINCL = .FALSE.
              IF(ISPCC.EQ.0 .OR. ISPCC.EQ.ISP(I))THEN
                LINCL = .TRUE.
              ELSEIF(ISPCC.LT.0)THEN
                IGRP = -ISPCC
                IULIM = ISPGRP(IGRP,1)+1
                DO 98 IG=2,IULIM
                IF(ISP(I) .EQ. ISPGRP(IGRP,IG))THEN
                  LINCL = .TRUE.
                  GO TO 99
                ENDIF
   98           CONTINUE
              ENDIF
   99         CONTINUE
            IF (LINCL .AND.
     >         (PRM(3).LE.DBH(I) .AND. DBH(I).LT.PRM(4))) THEN
               GOTO (610,620,630,640),IP
  610          CONTINUE
               WK2(I)=PROB(I)*PRM(2)
               GOTO 290
  620          CONTINUE
               WK2(I)=WK2(I)+(AMAX1(0.0,PROB(I)-WK2(I))*PRM(2))
               GOTO 290
  630          CONTINUE
               WK2(I)=AMAX1(WK2(I),(PROB(I)*PRM(2)))
               GOTO 290
  640          CONTINUE
               WK2(I)=AMIN1(PROB(I),WK2(I)*PRM(2))
               GOTO 290
            ENDIF
  290       CONTINUE
  295    CONTINUE
         IF(DEBUG)WRITE(JOSTND,*)' ITODO,WK2= ',
     &    ITODO,(WK2(IG),IG=1,ITRN)
         ENDIF
  300    CONTINUE
      ENDIF
      RETURN

      ENTRY MORCON

C  ENTRY POINT FOR LOADING MORTALITY MODEL CONSTANTS THAT
C  REQUIRE ONE-TIME RESOLUTION.

      CEPMRT = 0.
      SLPMRT = 0.
      TPAMRT = 0.
      RETURN
      END