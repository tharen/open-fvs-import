      SUBROUTINE DGF(DIAM)
      IMPLICIT NONE
C----------
C  **DGF--AK    DATE OF LAST REVISION:   02/14/08
C----------
C  THIS SUBROUTINE COMPUTES THE VALUE OF DDS (CHANGE IN SQUARED
C  DIAMETER) FOR EACH TREE RECORD, AND LOADS IT INTO THE ARRAY
C  WK2.  THE SET OF TREE DIAMETERS TO BE USED IS PASSED AS THE
C  ARGUMENT DIAM.  THE PROGRAM THUS HAS THE FLEXIBILITY TO
C  PROCESS DIFFERENT CALIBRATION OPTIONS.  THIS ROUTINE IS CALLED
C  BY **DGDRIV** DURING CALIBRATION AND WHILE CYCLING FOR GROWTH
C  PREDICTION.  ENTRY **DGCONS** IS CALLED BY **RCON** TO LOAD SITE
C  DEPENDENT COEFFICIENTS THAT NEED ONLY BE RESOLVED ONCE.
C
C  EQUATIONS FOR SMALL WH & SS ADDED 5/24/95.  GD.
C  EQUATIONS FOR RED ALDER AND COTTONWOOD ADDED 3/13/98
C   (FROM PN VARIANT)
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CALCOM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
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
COMMONS
C
C  DIMENSIONS FOR INTERNAL VARIABLES.
C
C     DIAM -- ARRAY LOADED WITH TREE DIAMETERS (PASSED AS AN
C             ARGUEMENT).
C     DGLD -- ARRAY CONTAINING COEFFICIENTS FOR THE LOG(DIAMETER)
C             TERM IN THE DDS MODEL (ONE COEFFICIENT FOR EACH
C             SPECIES).
C     DGCR -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             RATIO TERM IN THE DDS MODEL (ONE COEFFICIENT FOR
C             EACH SPECIES).
C   DGCRSQ -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             RATIO SQUARED TERM IN THE DDS MODEL (ONE
C             COEFFICIENT FOR EACH SPECIES).
C    DGBAL -- ARRAY CONTAINING COEFFICIENTS FOR THE BASAL AREA IN
C             LARGER TREES TERM IN THE DDS MODEL
C             (ONE COEFFICIENT FOR EACH SPECIES).
C   DGDBAL -- ARRAY CONTAINING COEFFICIENTS FOR THE INTERACTION
C             BETWEEN BASAL AREA IN LARGER TREES AND LN(DBH) (ONE
C             COEFFICIENT PER SPECIES).
C----------
      LOGICAL DEBUG
      INTEGER SMMAPS(MAXSP)
      INTEGER MAPLOC(7,MAXSP),ISPC,I1,I2,I3,I,INDXS,IASP,MAPDSQ(7,MAXSP)
      REAL DGHAH(MAXSP),DGBA(MAXSP),DGLNBA(MAXSP),OBSERV(MAXSP),SMDS(3)
      REAL SMDBAL(3),SMSL2(3),SMFOR(4,3)
      REAL SMSL(3),SMCASP(3),SMSASP(3),SMEL2(3),SMEL(3),SMCR2(3),SMCR(3)
      REAL SMLD(3),SMLBA(3)
      REAL SMSITE(3),CONSPP,SMCONS,DGLDS,DGBALS,DGCRS,DGCRS2
      REAL DGDSQS,DGDBLS,D,BARK,DIAGR,DDS,CR,BAL,H,RELHT,ALD
      REAL DDSL,DDSS,XWT,XPPDDS,SSITE,TEMEL,DGSLSQ(MAXSP),DGSLOP(MAXSP)
      REAL DGCASP(MAXSP),DGSASP(MAXSP),DGEL2(MAXSP),DGEL(MAXSP)
      REAL DGDS(4,MAXSP),DGFOR(6,MAXSP),DGSITE(MAXSP),DGDBAL(MAXSP)
      REAL DGCRSQ(MAXSP),DGCR(MAXSP),DGBAL(MAXSP),DGLD(MAXSP)
      REAL CONST,DIAM(MAXTRE),BRATIO
C----------
C SPECIES ORDER
C  1    2    3    4    5    6    7    8    9   10   11  12  13
C WS  WRC  PSF   MH   WH  AYC   LP   SS   SAF  RA   CW  OH  OS
C----------
      DATA DGLD/
     & 0.56846, 1.07184, 0.56846, 0.38233,  0.62381,  0.99465,
     & 0.99465, 0.68136, 0.56846, 0.511442, 0.889596, 0.99465, 0.56846,
     & 0.56846, 0.56846, 0.56846, 0.56846,  0.56846,  0.56846, 0.56846,
     & 0.56846, 0.56846, 0.56846/
      DATA DGCR/
     & 4.60641, 2.46701, 4.60641, 3.28729,  3.06852,  2.39021,
     & 2.39021, 3.08338, 4.60641, 0.623093, 1.732535, 2.39021,
     & 4.60641, 4.60641, 4.60641, 4.60641,  4.60641,  4.60641,
     & 4.60641, 4.60641, 4.60641, 4.60641,  4.60641/
      DATA DGCRSQ/
     & -3.33043, -1.86814, -3.33043, -2.36796, -2.07432, -1.60504,
     & -1.60504, -1.86516, -3.33043,  0.0    , 0.0     , -1.60504,
     & -3.33043, -3.33043, -3.33043, -3.33043, -3.33043,- 3.33043,
     & -3.33043, -3.33043, -3.33043, -3.33043, -3.33043/
      DATA DGBAL/
     & 0.00840, 0.00198, 0.00840, 0.00608,     0.0, 0.00402,
     & 0.00402,     0.0, 0.00840, 0.008903, 0.0, 0.00402, 0.00840,
     & 0.00840, 0.00840, 0.00840, 0.00840, 0.00840, 0.00840,
     & 0.00840, 0.00840, 0.00840,0.00840/
      DATA DGDBAL/
     & -0.02759, -0.00128, -0.02759, -0.02029, -0.00638, -0.00646,
     & -0.00646, -0.00881, -0.02759,-0.027074,-0.001265, -0.00646,
     & -0.02759, -0.02759, -0.02759, -0.02759, -0.02759, -0.02759,
     & -0.02759, -0.02759, -0.02759, -0.02759, -0.02759/
      DATA DGLNBA/
     &      0.0, -0.44018,      0.0,       0.0, -0.14942, -0.20534,
     & -0.20534, -0.26754,      0.0, -0.481983,      0.0, -0.20534,
     &      0.0,      0.0,      0.0,       0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,       0.0,      0.0/
      DATA DGBA/
     & -0.00215,      0.0, -0.00215, -0.00137,      0.0,      0.0,
     &      0.0,      0.0, -0.00215,      0.0,-0.000981,      0.0,
     & -0.00215, -0.00215, -0.00215, -0.00215, -0.00215, -0.00215,
     & -0.00215, -0.00215, -0.00215, -0.00215, -0.00215/
      DATA DGHAH/
     &      0.0,  0.29750,      0.0,      0.0,      0.0, -0.10963,
     & -0.10963,      0.0,      0.0,      0.0,      0.0, -0.10963,
     &      0.0,      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0/
C----------
C  IDTYPE IS A HABITAT TYPE INDEX THAT IS COMPUTED IN **RCON**.
C  ASPECT IS STAND ASPECT.  OBSERV CONTAINS THE NUMBER OF
C  OBSERVATIONS BY HABITAT CLASS BY SPECIES FOR THE UNDERLYING
C  MODEL (THIS DATA IS ACTUALLY USED BY **DGDRIV** FOR CALIBRATION).
C----------
      DATA  OBSERV/
     & 2678.0,  301.0, 2678.0, 5000.0, 5000.0,  557.0,
     &  557.0, 2678.0, 2678.0,  1369.,   220.,  557.0,
     & 2678.0, 2678.0, 2678.0, 2678.0, 2678.0, 2678.0,
     & 2678.0, 2678.0, 2678.0, 2678.0, 2678.0/
C----------
C  DGSITE IS AN ARRAY THAT CONTAINS SITE CLASS INTERCEPTS FOR
C  EACH SPECIES.
C----------
      DATA DGSITE/
     & 1.12514, 0.00573, 1.12514, 0.74079, 0.83695, 0.20346,
     & 0.20346, 1.27029, 1.12514, 0.237269,0.227307,0.20346,
     & 1.12514, 1.12514, 1.12514, 1.12514, 1.12514, 1.12514,
     & 1.12514, 1.12514, 1.12514, 1.12514, 1.12514/
C----------
C  DGFOR CONTAINS LOCATION CLASS CONSTANTS FOR EACH SPECIES.
C  MAPLOC IS AN ARRAY WHICH MAPS FOREST ONTO A LOCATION CLASS.
C----------
      DATA MAPLOC/
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 1, 2, 2, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 2, 3, 1, 0, 0, 0,
     & 1, 2, 3, 3, 0, 0, 0,
     & 1, 2, 3, 3, 0, 0, 0,
     & 1, 2, 3, 1, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 1, 1, 1, 0, 0, 0,
     & 1, 1, 1, 1, 0, 0, 0,
     & 1, 2, 3, 3, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0,
     & 1, 2, 3, 4, 0, 0, 0/
      DATA DGFOR/
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &   1.10897,   1.52503,       0.0,       0.0,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &  -1.86637,  -1.71679,  -1.56184,  -1.99657,     0.0,     0.0,
     &  -2.23801,  -2.09016,  -1.94542,       0.0,     0.0,     0.0,
     &  -0.79657,  -1.14325,  -0.41948,       0.0,     0.0,     0.0,
     &  -0.79657,  -1.14325,  -0.41948,       0.0,     0.0,     0.0,
     &  -3.14889,  -3.20919,  -2.96203,       0.0,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &  4.253807,       0.0,       0.0,       0.0,     0.0,     0.0,
     & -0.107648,       0.0,       0.0,       0.0,     0.0,     0.0,
     &  -0.79657,  -1.14325,  -0.41948,       0.0,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0,
     &  -3.46832,  -3.48281,  -3.23448,  -3.61663,     0.0,     0.0/
C----------
C  DGDS CONTAINS COEFFICIENTS FOR THE DIAMETER SQUARED TERMS
C  IN THE DIAMETER INCREMENT MODELS; ARRAYED BY FOREST BY
C  SPECIES.  MAPDSQ IS AN ARRAY WHICH MAPS FOREST ONTO A DBH**2
C  COEFFICIENT.
C----------
      DATA MAPDSQ/
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 1, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 1, 1, 0, 0, 0,
     & 1, 1, 1, 1, 0, 0, 0,
     & 1, 1, 1, 1, 0, 0, 0,
     & 1, 1, 1, 1, 0, 0, 0,
     & 1, 1, 1, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 1, 1, 0, 0, 0,
     & 1, 1, 1, 1, 0, 0, 0,
     & 1, 1, 1, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0,
     & 1, 1, 2, 1, 0, 0, 0/
      DATA DGDS/
     & -0.000165, -0.000042,       0.0,       0.0,
     & -0.000239,       0.0,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0,
     &       0.0,       0.0,       0.0,       0.0,
     & -0.000124,       0.0,       0.0,       0.0,
     & -0.000003,       0.0,       0.0,       0.0,
     & -0.000003,       0.0,       0.0,       0.0,
     & -0.000703,       0.0,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0,
     &-0.0005099,       0.0,       0.0,       0.0,
     &       0.0,       0.0,       0.0,       0.0,
     & -0.000003,       0.0,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0,
     & -0.000165, -0.000042,       0.0,       0.0/
C----------
C  DGEL CONTAINS THE COEFFICIENTS FOR THE ELEVATION TERM IN THE
C  DIAMETER GROWTH EQUATION.  DGEL2 CONTAINS THE COEFFICIENTS FOR
C  THE ELEVATION SQUARED TERM IN THE DIAMETER GROWTH EQUATION.
C  DGSASP CONTAINS THE COEFFICIENTS FOR THE SIN(ASPECT)*SLOPE
C  TERM IN THE DIAMETER GROWTH EQUATION.  DGCASP CONTAINS THE
C  COEFFICIENTS FOR THE COS(ASPECT)*SLOPE TERM IN THE DIAMETER
C  GROWTH EQUATION.  DGSLOP CONTAINS THE COEFFICIENTS FOR THE
C  SLOPE TERM IN THE DIAMETER GROWTH EQUATION.  DGSLSQ CONTAINS
C  COEFFICIENTS FOR THE (SLOPE)**2 TERM IN THE DIAMETER GROWTH MODELS.
C  ALL OF THESE ARRAYS ARE SUBSCRIPTED BY SPECIES.
C----------
      DATA DGCASP/
     & -0.18793,  0.00794, -0.18793,  0.04097, -0.03751,  0.09184,
     &  0.09184, -0.23642, -0.18793, 0.022254, 0.085958,  0.09184,
     & -0.18793, -0.18793, -0.18793, -0.18793, -0.18793, -0.18793,
     & -0.18793, -0.18793, -0.18793, -0.18793, -0.18793/
      DATA DGSASP/
     & -0.19185,  0.01670, -0.19185, -0.10205, -0.07308, -0.18677,
     & -0.18677, -0.13790 ,-0.19185,-0.085538, -0.86398, -0.18677,
     * -0.19185, -0.19185, -0.19185, -0.19185, -0.19185, -0.19185,
     & -0.19185, -0.19185, -0.19185, -0.19185, -0.19185/
      DATA DGSLOP/
     & -1.42938,  0.02871, -1.42938, -1.35921, -1.56867,  1.27878,
     &  1.27878, -0.86127, -1.42938,      0.0,      0.0,  1.27878,
     & -1.42938, -1.42938, -1.42938, -1.42938, -1.42938, -1.42938,
     & -1.42938, -1.42938, -1.42938, -1.42938, -1.42938/
      DATA DGSLSQ/
     &  1.09399,  0.03586,  1.09399,  1.15906,  1.23542, -1.02205,
     & -1.02205,  0.54058,  1.09399,      0.0,      0.0, -1.02205,
     &  1.09399,  1.09399,  1.09399,  1.09399,  1.09399,  1.09399,
     &  1.09399,  1.09399,  1.09399,  1.09399,  1.09399/
      DATA DGEL/
     &  0.00039, -0.01052,  0.00039,  0.00224,  0.00438, -0.01272,
     & -0.01272,  0.00047,  0.00039,      0.0, -0.075986,-0.01272,
     &  0.00039,  0.00039,  0.00039,  0.00039,  0.00039,  0.00039,
     &  0.00039,  0.00039,  0.00039,  0.00039,  0.00039/
      DATA DGEL2/
     & -0.000009,  0.000104, -0.000009, -0.000009, -0.000019,  0.000046,
     &  0.000046, -0.000008, -0.000009,       0.0,  0.001193,  0.000046,
     & -0.000009, -0.000009, -0.000009, -0.000009, -0.000009, -0.000009,
     & -0.000009, -0.000009, -0.000009, -0.000009, -0.000009/
C----------
C SECTION FOR TREES < 10" DBH.
C 1ST POSITION = WH, 2ND POSITION = SS
C----------
      DATA SMSITE/ 0.000972, 0.001258, 0. /
      DATA SMLBA /-0.583329,-0.595877, 0. /
      DATA SMLD  / 1.525250, 1.780276, 0. /
      DATA SMCR  / 1.507640, 4.428345, 0. /
      DATA SMCR2 / 0.      ,-2.518086, 0. /
      DATA SMEL  / 0.000884, 0.000682, 0. /
      DATA SMEL2 /-0.000001,-0.000001, 0. /
      DATA SMSASP/ 0.157749, 0.493114, 0. /
      DATA SMCASP/ 0.104729, 0.024501, 0. /
      DATA SMSL  /-1.100789,-1.817615, 0. /
      DATA SMSL2 / 2.114845, 4.122238, 0. /
      DATA SMDBAL/-0.005402,-0.006182, 0. /
      DATA SMDS  /-0.000792,-0.000866, 0. /
      DATA SMFOR / 2.125668, 2.177696, 2.071918, 0.,
     &             1.165812, 1.165812, 1.321460, 0.,
     &             0.      , 0.      , 0.      , 0. /
      DATA SMMAPS / 3, 3, 3, 3, 1, 3, 3, 2, 3, 3, 3, 3,
     &              3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3/
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'DGF',3,ICYC)
      IF(DEBUG) WRITE(JOSTND,2)ICYC
    2 FORMAT(' ENTERING DGF  CYCLE =',I5)
C----------
C  DEBUG OUTPUT: MODEL COEFFICIENTS.
C----------
      IF(DEBUG)WRITE(JOSTND,*) 'IN DGF,HTCON=',HTCON,
     *'RMAI=',RMAI,'ELEV=',ELEV,'RELDEN=',RELDEN
      IF(DEBUG)
     & WRITE(JOSTND,9000) DGCON,DGDSQ,DGLD,DGCR,DGCRSQ,DGBAL
 9000 FORMAT(/11(1X,F10.5))
C----------
C  BEGIN SPECIES LOOP.  ASSIGN VARIABLES WHICH ARE SPECIES DEPENDENT
C----------
      DO 20 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 20
      I2=ISCT(ISPC,2)
      CONSPP= DGCON(ISPC) + COR(ISPC)
      SMCONS= SMCON(ISPC) + COR(ISPC)
      DGLDS= DGLD(ISPC)
      DGBALS = DGBAL(ISPC)
      DGCRS= DGCR(ISPC)
      DGCRS2=DGCRSQ(ISPC)
      DGDSQS=DGDSQ(ISPC)
      DGDBLS=DGDBAL(ISPC)
C----------
C  BEGIN TREE LOOP WITHIN SPECIES ISPC.
C----------
      DO 10 I3=I1,I2
      I=IND1(I3)
      D=DIAM(I)
      IF (D.LE.0.0) GOTO 10
C----------
C  RED ALDER USES A DIFFERENT EQUATION.
C  FUNCTION BOTTOMS OUT AT D=18. DECREASE LINERALY AFTER THAT TO
C  DG=0 AT D=28, AND LIMIT TO .1 ON LOWER END.  GED 4-15-93.
C----------
      IF(ISPC .EQ. 10) THEN
	BARK=BRATIO(22,D,HT(I))
	CONST=3.250531 - 0.003029*BA
	IF(D .LE. 18.) THEN
	  DIAGR = CONST - 0.166496*D + 0.004618*D*D
	ELSE
	  DIAGR = CONST - (CONST/10.)*(D-18.)
	ENDIF
	IF(DIAGR .LT. 0.1) DIAGR=0.1
	DDS = ALOG(DIAGR*(2.0*D*BARK+DIAGR))+ALOG(COR2(ISPC))+COR(ISPC)
	GO TO 5
      ENDIF
C
      CR=ICR(I)*0.01
      BAL = (1.0 - (PCT(I)/100.)) * BA
      H=HT(I)
      RELHT = 0.0
      IF(AVH .GT. 0.0) RELHT=HT(I)/AVH
      IF(RELHT .GT. 1.5)RELHT=1.5
      ALD=ALOG(D)
      DDSL=CONSPP + DGLDS*ALD + DGBALS*BAL + CR*(DGCRS+CR*DGCRS2)
     &          +DGDSQS*D*D  + DGDBLS*BAL/(ALOG(D+1.0))
     &                    +DGHAH(ISPC)*RELHT
     & + DGLNBA(ISPC)*ALOG(BA) + DGBA(ISPC)*BA
C
      IF(DEBUG) WRITE(JOSTND,8000) DGCON(ISPC),COR(ISPC),
     $RELDEN,DGBA(ISPC),RMAI,CONSPP,DGLDS,ALD,
     $DGBALS,BAL,CR,DGCRS,DGCRS2,DGDSQS,D,DGDBLS,
     $DGHAH(ISPC),H,AVH,DDSL
 8000 FORMAT(1H0,'IN DGF AT LINE 178',9F12.5,/,1H ,9F12.5,/,
     $ 1H ,2F12.5,//)
C----------
C  SECTION FOR WH & SS < 10" DBH.
C----------
      DDSS=0.
      DDS = DDSL
      IF(ISPC.EQ.5 .OR. ISPC.EQ.8) THEN
        IF(D.LT.10.)THEN
          INDXS = SMMAPS(ISPC)
          DDSS = SMCONS + SMLBA(INDXS)*ALOG(BA) + SMLD(INDXS)*ALD
     &         + SMCR(INDXS)*CR + SMCR2(INDXS)*CR*CR
     &         + SMDBAL(INDXS)*BAL/(ALOG(D+1.)) + SMDS(INDXS)*D*D
C----------
C  SPLINE THE TWO ESTIMATES OVER THE DIAMETER RANGE 7"-10".
C----------
          XWT=1.
          IF(D.GT.7.) XWT=(10.-D)/3.
          IF(XWT.LT.0.) XWT=0.
          DDS = XWT*DDSS + (1.-XWT)*DDSL
        ENDIF
      ENDIF
    5 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)' I,ISPC,D,XWT,DDSS,DDSL,DDS= ',
     &I,ISPC,D,XWT,DDSS,DDSL,DDS
C---------
C     CALL PPDGF TO GET A MODIFICATION VALUE FOR DDS THAT ACCOUNTS
C     FOR THE DENSITY OF NEIGHBORING STANDS.
C
      XPPDDS=0.
      CALL PPDGF (XPPDDS)
C
      DDS=DDS+XPPDDS
C---------
      IF(DDS.LT.-9.21) DDS=-9.21
      WK2(I)=DDS
C----------
C  END OF TREE LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG) THEN
      WRITE(JOSTND,9001) I,ISPC,D,BAL,CR,RELDEN,BA,DDS
 9001 FORMAT(' IN DGF, I=',I4,',  ISPC=',I3,',  DBH=',F7.2,
     &      ',  BAL=',F7.2,',  CR=',F7.4/
     &      '       RELDEN=',F9.3,',  BA=',F9.3,',   LN(DDS)=',F7.4)
      ENDIF
   10 CONTINUE
C----------
C  END OF SPECIES LOOP.
C----------
   20 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9002)ICYC
 9002 FORMAT(' LEAVING SUBROUTINE DGF  CYCLE =',I5)
      RETURN
      ENTRY DGCONS
      CALL DBCHK (DEBUG,'DGCONS',6,ICYC)
C----------
C  ENTRY POINT FOR LOADING COEFFICIENTS OF THE DIAMETER INCREMENT
C  MODEL THAT ARE SITE SPECIFIC AND NEED ONLY BE RESOLVED ONCE.
C----------
C  ENTER LOOP TO LOAD SPECIES DEPENDENT VECTORS.
C
C  CONSTRAIN ELEVATION TERM FOR BLACK COTTONWOOD TO BE LE 30
C  IN EQUATION ELEVATION WAS FIT IN 100'S OF FEET (PN&WC), 
C  USED HERE IN 10'S OF FEET SO IT NEEDS TO BE DIVIDED BY 10  
C  TO GET CORRECT ELEVATION EFFECT.
C----------
      DO 30 ISPC=1,MAXSP
      SSITE=SITEAR(ISPC)
      ISPFOR=MAPLOC(IFOR,ISPC)
      ISPDSQ=MAPDSQ(IFOR,ISPC)
      IASP=ASPECT
      TEMEL=ELEV
      IF(ISPC.EQ.11 .AND. TEMEL.GT.30.)TEMEL=30.
      IF(ISPC.EQ.11)TEMEL=TEMEL/10.
      DGCON(ISPC)= DGSITE(ISPC) * ALOG(SSITE)
     &                 + DGFOR(ISPFOR,ISPC)
     &                 + DGEL(ISPC) * TEMEL
     &                 + DGEL2(ISPC) * TEMEL * TEMEL
     &                 +(DGSASP(ISPC) * SIN(ASPECT)
     &                 + DGCASP(ISPC) * COS(ASPECT)
     &                 + DGSLOP(ISPC)) * SLOPE
     &                 + DGSLSQ(ISPC) * SLOPE * SLOPE
      DGDSQ(ISPC)=DGDS(ISPDSQ,ISPC)
      ATTEN(ISPC)=OBSERV(ISPC)
C----------
C SECTION FOR WH & SS < 10" DBH.
C----------
      INDXS=SMMAPS(ISPC)
      SMCON(ISPC)= SMSITE(INDXS) * ALOG(SSITE)
     &                 + SMFOR(ISPFOR,INDXS)
     &                 + SMEL(INDXS) * ELEV
     &                 + SMEL2(INDXS) * ELEV * ELEV
     &                 +(SMSASP(INDXS) * SIN(ASPECT)
     &                 + SMCASP(INDXS) * COS(ASPECT)
     &                 + SMSL(INDXS)) * SLOPE
     &                 + SMSL2(INDXS) * SLOPE * SLOPE
C----------
C  IF READCORD OR REUSCORD WAS SPECIFIED (LDCOR2 IS TRUE) ADD
C  LN(COR2) TO THE BAI MODEL CONSTANT TERM (DGCON).  COR2 IS
C  INITIALIZED TO 1.0 IN BLKDATA.
C----------
      IF (LDCOR2.AND.COR2(ISPC).GT.0.0) THEN
        DGCON(ISPC) = DGCON(ISPC) + ALOG(COR2(ISPC))
        SMCON(ISPC) = SMCON(ISPC) + ALOG(COR2(ISPC))
      ENDIF
C
      IF(DEBUG)WRITE(JOSTND,40)SITEAR(ISPC),ISPC,ISPFOR,ELEV,IASP,
     &SLOPE,COR2(ISPC),DGCON(ISPC),SMCON(ISPC)
   40 FORMAT('0IN DGF 40 FORMAT SITEAR(ISPC),ISPC,ISPFOR,ELEV,IASP,
     &SLOPE,COR2,D,GCON =',/,1H ,F5.1,2I5,F7.1,I5,4F10.3)
   30 CONTINUE
      RETURN
      END
