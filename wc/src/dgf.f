      SUBROUTINE DGF(DIAM)
      IMPLICIT NONE
C----------
C WC $Id: dgf.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C  THIS SUBROUTINE COMPUTES THE VALUE OF DDS (CHANGE IN SQUARED
C  DIAMETER) FOR EACH TREE RECORD, AND LOADS IT INTO THE ARRAY
C  WK2.  DDS IS PREDICTED FROM SITE INDEX, LOCATION, SLOPE,
C  ASPECT, ELEVATION, DBH, CROWN RATIO, BASAL AREA IN LARGER TREES,
C  AND CCF.  THE SET OF TREE DIAMETERS TO BE USED IS PASSED AS THE
C  ARGUEMENT DIAM.  THE PROGRAM THUS HAS THE FLEXIBILITY TO
C  PROCESS DIFFERENT CALIBRATION OPTIONS.  THIS ROUTINE IS CALLED
C  BY **DGDRIV** DURING CALIBRATION AND WHILE CYCLING FOR GROWTH
C  PREDICTION.  ENTRY **DGCONS** IS CALLED BY **RCON** TO LOAD SITE
C  DEPENDENT COEFFICIENTS THAT NEED ONLY BE RESOLVED ONCE.
C----------
C  ** REPLACED OREGON WHITE OAK EQUATION CREATED BY GOULD AND HARRINGTON
C     FROM PNW STATION DATE 04/19/10 ESM
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
      INCLUDE 'PDEN.F77'
C
C
COMMONS
C
C  DIMENSIONS FOR INTERNAL VARIABLES.
C
C     DIAM -- ARRAY LOADED WITH TREE DIAMETERS (PASSED AS AN
C             ARGUEMENT).
C     DGLD -- ARRAY CONTAINING COEFFICIENTS FOR THE LOG(DIAMETER)
C             TERM IN THE DDS MODEL.
C     DGCR -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             RATIO TERM IN THE DDS MODEL.
C   DGCRSQ -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             RATIO SQUARED TERM IN THE DDS MODEL.
C    DGBAL -- ARRAY CONTAINING COEFFICIENTS FOR THE BASAL AREA IN
C             LARGER TREES TERM IN THE DDS MODEL.
C   DGDBAL -- ARRAY CONTAINING COEFFICIENTS FOR THE INTERACTION
C             BETWEEN BASAL AREA IN LARGER TREES AND LN(DBH).
C    DGLBA -- ARRAY OF COEFFICIENTS FOR LOG(BASIL AREA).
C     DGBA -- ARRAY OF COEFFICIENTS OF BASIL AREA.
C   DGSITE -- ARRAY OF COEFFICIENTS OF LOG(SITE).
C     DGEL -- ARRAY OF COEFFICIENTS OF ELEVATION.
C    DGEL2 -- ARRAY OF COEFFICIENTS OF ELEVATION**2.
C   DGCASP -- ARRAY OF COEFFICIENTS OF COS(ASPECT)*SLOPE.
C   DGSASP -- ARRAY OF COEFFICIENTS FOR SIN(ASPECT)*SLOPE.
C   DGSLOP -- ARRAY OF COEFFICIENTS FOR SLOPE.
C   DGSLSQ -- ARRAY OF COEFFICIENTS FOR SLOPE**2.
C   DGPCCF -- ARRAY OF COEFFICIENTS FOR POINT CROWN COMPETITION FACTOR.
C    DGHAH -- ARRAY OF COEFFICIENTS FOR THE RELATIVE HEIGHT TERM.
C
C----------
C
C SPECIES GROUPS
C 1=SF, 2=WF/GF,  3=RF,  4=NF,  5=SP/WP,  6=JP/PP,  7=DF,  8=RC,
C 9=WH,  10=MH,  11=IC/ES/RW/LL/WB/KP/PY,  12=BM, 13=RA,
C 14=WA/PB/GC/AS/CW/J/DG/HT/CH/WI,  15=YC,  16=LP,  17=AF,  18=WO
C
C  THE COEFFICIENTS FOR JP/PP ARE FROM THE CA VARIANT. THE EQUATION
C  DEVELOPED FROM THE VERY LIMITED DATA SET AVAILABLE FROM THE WC 
C  AREA DID NOT PERFORM VERY WELL.  GED 1/29/03
C
      REAL DIAM(MAXTRE),DGLD(18),DGLBA(18),DGCR(18),DGCRSQ(18)
      REAL DGDBAL(18),DGBAL(18),DGFOR(6,18),DGDS(2,18),DGEL(18)
      REAL DGEL2(18),DGSASP(18),DGCASP(18),DGSLOP(18),DGSLSQ(18)
      REAL DGBA(18),DGSITE(18),DGPCCF(18),DGHAH(18)
      INTEGER MAPDSQ(6,18),MAPLOC(6,18),MAPSPC(39),OBSERV(18)
      INTEGER ISPC,I1,I2,JSPC,I3,I,IPCCF,JFOR
      REAL CONSPP,D,BARK,BRATIO,CONST,DIAGR,DDS,CR,BAL,RELHT,X1,XPPDDS
      REAL SASP,XSITE,TEMEL
C
      DATA MAPSPC/
     & 1,2,2,3,17,17,4,15,11,11,16,6,5,5,6,7,11,8,9,10,12,
     & 13,14,14,14,14,14,18,14,11,11,11,11,14,14,14,14,14,14/
C
      DATA DGLD/
     & 0.527758, 0.905119, 0.993986, 0.904253, 0.844690, 0.738750,
     & 0.534138, 0.843013, 0.722462, 0.857131, 0.879338, 1.024186,
     &      0.0, 0.889596, 0.816880, 0.478504, 0.949631, 1.66609/
C
      DATA DGCR/
     & 2.982807, 1.754811, 1.522401, 4.123101, 1.597250, 3.454857,
     & 1.636854, 2.878032, 2.160348, 1.505513, 1.970052, 0.459387,
     & 0.0     , 1.732535, 2.471226, 1.905011, 1.826879, 0.0/
C
      DATA DGCRSQ/
     & -1.331331, 2*0.0, -2.689340, 0.0, -1.773805, -0.045578, 
     & -1.631418, -0.834196, 9*0.0/
C
      DATA DGSITE/
     & 0.534255, 0.318254, 0.349888, 0.684939, 0.404010, 1.011504,
     & 1.020863, 0.139734, 0.380416, 0.208040, 0.252853, 1.965888,
     & 0.0     , 0.227307, 0.244694, 0.391327, 0.375175, 0.14995/
C
      DATA DGDBAL/
     & -0.011247, -0.005355, -0.002979, -0.006368, -0.003726, -0.013091,
     & -0.009363, -0.003923, -0.004065, -0.004101, -0.004215, -0.010222,
     &  0.0     , -0.001265, -0.005950, -0.004706, -0.005350,  0.0/
C
      DATA DGLBA/
     & -0.030730, 4*0.0, -0.131185, 12*0.0/
C
      DATA DGBA/
     & 2*0.0, -0.000137, 3*0.0, -0.000215, 3*0.0, -0.000173,
     & 2*0.0, -0.000981, -0.000147, -0.000114, 0.000040,-0.00204/
C
      DATA DGBAL/
     & 0.002839, 16*0.0, -0.00326/
C
      DATA DGPCCF/
     & 3*0.0, -0.000471, -0.000257, -0.000593, 0.0, -0.000552,
     & 0.0, -0.000201, 0.0, -0.000757, 6*0.0/
C
      DATA DGHAH/
     & 0.0, -0.000661, 6*0.0, -0.000358, 9*0.0/
C----------
C  IDTYPE IS A HABITAT TYPE INDEX THAT IS COMPUTED IN **RCON**.
C  ASPECT IS STAND ASPECT.  OBSERV CONTAINS THE NUMBER OF
C  OBSERVATIONS BY HABITAT CLASS BY SPECIES FOR THE UNDERLYING
C  MODEL (THIS DATA IS ACTUALLY USED BY **DGDRIV** FOR
C  CALIBRATION).
C----------
      DATA  OBSERV/
     & 3664, 1487, 747, 1467, 596, 2482, 14999, 1309,
     & 4836, 2848, 475,   78, 125,  220,     0,  759, 542, 2144/
C----------
C  DGFOR CONTAINS LOCATION CLASS CONSTANTS FOR EACH SPECIES.
C  MAPLOC IS AN ARRAY WHICH MAPS FOREST ONTO A LOCATION CLASS.
C----------
C
      DATA MAPLOC/
     & 1,2,3,4,5,6,
     & 1,1,1,1,1,1,
     & 1,1,1,2,1,1,
     & 1,1,2,2,2,2,
     & 1,1,1,1,1,2,
     & 1,1,1,1,1,1,
     & 1,2,3,4,5,6,
     & 1,1,2,1,1,1,
     & 1,1,2,3,2,1,
     & 1,1,2,2,1,1,
     & 1,1,1,1,1,2,
     & 1,1,1,1,1,2,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,2,
     & 1,1,1,1,1,2,
     & 1,1,1,2,2,2,
     & 1,1,1,1,2,1,
     & 1,1,1,1,1,1/

      DATA DGFOR/
     & -0.619069, -0.479015, -0.291244, 0.0, -0.420228, -0.746419,
     & -0.643920, 5*0.0,
     & -1.888949, -1.276180, 4*0.0,
     & -1.401865, -1.127977, 4*0.0,
     & -0.589570, -0.909553, 4*0.0,
     & -2.922255, 5*0.0,
     & -2.750874, -2.787499, -2.672664, -2.533437, -2.693964, -2.718852,
     &  0.412763, 0.645645, 4*0.0,
     & -0.298310, -0.147675, -0.006413, 3*0.0,
     & -1.052161, -0.793945, 4*0.0,
     & -1.310067, -1.432659, 4*0.0,
     & -7.753469, -8.279266, 4*0.0,
     &  6*0.0,
     & -0.107648, -0.098335, 4*0.0,
     & -1.277664, -1.178041, 4*0.0,
     & -0.524624, -0.803095, 4*0.0,
     & -9.211184, -9.800653, 4*0.0,
     & -1.33299 , 5*0.0/
C----------
C  DGDS CONTAINS COEFFICIENTS FOR THE DIAMETER SQUARED TERMS
C  IN THE DIAMETER INCREMENT MODELS    ARRAYED BY FOREST BY
C  SPECIES.  MAPDSQ IS AN ARRAY WHICH MAPS FOREST ONTO A DBH**2
C  COEFFICIENT.
C----------
      DATA MAPDSQ/
     & 1,1,1,2,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1/
C
      DATA DGDS/
     & -0.0001983, 0.0,
     & -0.0003137, 0.0,
     & -0.0002621, 0.0,
     & -0.0003996, 0.0,
     & -0.0000596, 0.0,
     & -0.0004708, 0.0,
     & -0.0001039, 0.0,
     & -0.0000644, 0.0,
     & -0.0001546, 0.0,
     & -0.0002214, 0.0,
     & -0.0001323, 0.0,
     & -0.0001737, 0.0,
     &  2*0.0,
C + DSQ TERM CAUSING BLOWUPS, SET TO 0 FOR NOW. DIXON 4-29-93.
C    &  0.0001809, 0.0,
     &  2*0.0,
     & -0.0002536, 0.0,
     &  2*0.0,
     & -0.0003552, 0.0,
     & -0.00154  , 0.0/
C
C----------
C  DGEL CONTAINS THE COEFFICIENTS FOR THE ELEVATION TERM IN THE
C  DIAMETER GROWTH EQUATION.  DGEL2 CONTAINS THE COEFFICIENTS FOR
C  THE ELEVATION SQUARED TERM IN THE DIAMETER GROWTH EQUATION.
C  DGSASP CONTAINS THE COEFFICIENTS FOR THE SIN(ASPECT)*SLOPE
C  TERM IN THE DIAMETER GROWTH EQUATION.  DGCASP CONTAINS THE
C  COEFFICIENTS FOR THE COS(ASPECT)*SLOPE TERM IN THE DIAMETER
C  GROWTH EQUATION.  DGSLOP CONTAINS THE COEFFICIENTS FOR THE
C  SLOPE TERM IN THE DIAMETER GROWTH EQUATION.  DGSLSQ CONTAINS
C  COEFFICIENTS FOR THE (SLOPE)**2 TERM IN THE DIAMETER GROWTH
C  MODELS.  ALL OF THESE ARRAYS ARE SUBSCRIPTED BY SPECIES.
C----------
      DATA DGCASP/
     & 2*0.0, -0.782418, -0.374512, 0.0, 0.0, -0.080943, 2*0.0,
     & -0.104495, 3*0.0, 0.085958, -0.023186, 0.207853, -0.935870,
     &  0.0/
C
      DATA DGSASP/
     & 2*0.0, 0.022160, -0.207659, 0.0, 0.0, -0.038992, 2*0.0,
     & -0.126130, 3*0.0, -0.863980, 0.679903, 0.378860, 0.202507,
     &  0.0/
C
      DATA DGSLOP/
     & 0.245548, 0.0, 0.319956, 0.400223, 0.0, 0.0, 0.077787,
     & 0.0, 0.421486, 0.411602, 5*0.0, -0.066440, 0.0, 0.0/
C
      DATA DGSLSQ/
     & 5*0.0, 0.0, -0.215778, 0.0, -0.693610, 9*0.0/
C
      DATA DGEL/
     & -0.048852, -0.003051, -0.003773, -0.069045, -0.023376,-0.003784,
     & -0.037591, -0.050081, -0.040067, -0.003809, 0.0, -0.012111,
     &  0.0,      -0.075986,  0.0,      -0.005414, 0.323546, 0.0/

      DATA DGEL2/
     & 0.000478, 2*0.0, 0.000608, 0.0, 0.00006660, 0.000549, 0.000660,
     & 0.000395, 4*0.0, 0.001193, 2*0.0, -0.003130, 0.0/
C
      LOGICAL DEBUG
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'DGF',3,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE DGF  CYCLE =',I5)
C----------
C  DEBUG OUTPUT: MODEL COEFFICIENTS.
C----------
      IF(DEBUG) WRITE(JOSTND,*) 'IN DGF,HTCON=',HTCON,
     *'ELEV=',ELEV,'RELDEN=',RELDEN
      IF(DEBUG)
     & WRITE(JOSTND,9000) DGCON,DGDSQ
 9000 FORMAT(/11(1X,F10.5))
C----------
C  BEGIN SPECIES LOOP.  ASSIGN VARIABLES WHICH ARE SPECIES
C  DEPENDENT
C----------
      DO 20 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 20
      I2=ISCT(ISPC,2)
      JSPC=MAPSPC(ISPC)
      CONSPP= DGCON(ISPC) + COR(ISPC)
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
      IF(JSPC .EQ. 13) THEN
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
      IPCCF=ITRE(I)
      RELHT = 0.0
      IF(AVH .GT. 0.0) RELHT=HT(I)/AVH
      IF(RELHT .GT. 1.5)RELHT=1.5
C----------
C  THIS FUNCTION OCCASIONALLY GIVES UNDERFLOW ERROR ON PC. SPLITTING
C  IT UP INTO TWO PARTS IS A TEMPORARY SOLUTION WHICH WORKS. GD 2/20/97
C----------
       DDS = CONSPP + DGLD(JSPC)*ALOG(D)
     & + CR*(DGCR(JSPC) + CR*DGCRSQ(JSPC))
     & + DGDSQ(JSPC)*D*D  + DGDBAL(JSPC)*BAL/(ALOG(D+1.0))
      DDS = DDS + DGPCCF(JSPC)*PCCF(IPCCF) + DGHAH(JSPC)*RELHT
     & + DGLBA(JSPC)*ALOG(BA)
     & + DGBAL(JSPC)*BAL + DGBA(JSPC)*BA
    5 IF(DEBUG) WRITE(JOSTND,8000)
     &I,ISPC,CONSPP,D,BA,CR,BAL,PCCF(IPCCF),RELDEN,HT(I),AVH
 8000 FORMAT(1H0,'IN DGF 8000F',2I5,9F11.4)
C---------
C     CALL PPDGF TO GET A MODIFICATION VALUE FOR DDS THAT ACCOUNTS
C     FOR THE DENSITY OF NEIGHBORING STANDS.
C
      X1=0.
      XPPDDS=0.
      CALL PPDGF (XPPDDS,X1,X1,X1,X1,X1,X1)
C
      DDS=DDS+XPPDDS
C---------
      IF(DDS.LT.-9.21) DDS=-9.21
      WK2(I)=DDS
C----------
C  END OF TREE LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG)THEN
      WRITE(JOSTND,9001) I,ISPC,DDS
 9001 FORMAT(' IN DGF, I=',I4,',  ISPC=',I3,',  LN(DDS)=',F7.4)
      ENDIF
   10 CONTINUE
C----------
C  END OF SPECIES LOOP.
C----------
   20 CONTINUE
      IF(DEBUG) WRITE(JOSTND,100)ICYC
  100 FORMAT(' LEAVING SUBROUTINE DGF  CYCLE =',I5)
      RETURN
      ENTRY DGCONS
C----------
C  ENTRY POINT FOR LOADING COEFFICIENTS OF THE DIAMETER INCREMENT
C  MODEL THAT ARE SITE SPECIFIC AND NEED ONLY BE RESOLVED ONCE.
C----------
C  CHECK FOR DEBUG.
C----------
      CALL DBCHK (DEBUG,'DGF',3,ICYC)
C----------
C  ALIGN BLM ADMINISTRATIVE UNIT WITH CLOSEST NF:
C  SALEM -- MT HOOD       EUGENE -- WILLAMETTE
C  ROSEBURG -- UMPQUA     MEDFORD -- ROGUE RIVER
C
      IF(IFOR .LE. 6) THEN
        JFOR=IFOR
      ELSEIF(IFOR .EQ. 7) THEN
        JFOR=3
      ELSEIF(IFOR .EQ. 8) THEN
        JFOR=6
      ELSEIF(IFOR .EQ. 9) THEN
        JFOR=5
      ELSEIF(IFOR .EQ. 10) THEN
        JFOR=4
      ELSE
        JFOR=3
      ENDIF
C----------
C  ENTER LOOP TO LOAD SPECIES DEPENDENT VECTORS.
C  CONSTRAIN ELEVATION TERM FOR MODEL 14 TO BE LE 30
C  WO USES KINGS SI FOR DF IN DDS EQUATION, SO HAS TO BE TRANSLATED
C----------
      DO 30 ISPC=1,MAXSP
      JSPC=MAPSPC(ISPC)
      ISPFOR=MAPLOC(JFOR,JSPC)
      ISPDSQ=MAPDSQ(JFOR,JSPC)
      SASP =
     &                 +(DGSASP(JSPC) * SIN(ASPECT)
     &                 + DGCASP(JSPC) * COS(ASPECT)
     &                 + DGSLOP(JSPC)) * SLOPE
     &                 + DGSLSQ(JSPC) * SLOPE * SLOPE
      XSITE=SITEAR(ISPC)
      IF(JSPC.EQ.10)XSITE=XSITE*3.281
      IF(JSPC.EQ.18)XSITE=-37.60812*ALOG(1-(XSITE/114.24569)**.4444)
      TEMEL=ELEV
      IF(JSPC.EQ.14 .AND. TEMEL.GT.30.)TEMEL=30.
      DGCON(ISPC) =
     &                   DGFOR(ISPFOR,JSPC)
     &                 + DGEL(JSPC) * TEMEL
     &                 + DGEL2(JSPC) * TEMEL * TEMEL
     &                 + DGSITE(JSPC)*ALOG(XSITE)
     &                 + SASP
      DGDSQ(JSPC)=DGDS(ISPDSQ,JSPC)
      ATTEN(JSPC)=OBSERV(JSPC)
      SMCON(ISPC)=0.
      IF(DEBUG)WRITE(JOSTND,9030)DGFOR(ISPFOR,JSPC),
     &DGEL(JSPC),ELEV,DGEL2(JSPC),DGSASP(JSPC),ASPECT,
     &DGCASP(JSPC),DGSLOP(JSPC),SLOPE,DGSITE(JSPC),
     &SITEAR(ISPC),DGCON(ISPC),SASP,XSITE
 9030 FORMAT(' IN DGF 9030',14F9.5)
C----------
C  IF READCORD OR REUSCORD WAS SPECIFIED (LDCOR2 IS TRUE) ADD
C  LN(COR2) TO THE BAI MODEL CONSTANT TERM (DGCON).  COR2 IS
C  INITIALIZED TO 1.0 IN BLKDATA.
C----------
      IF (LDCOR2.AND.COR2(ISPC).GT.0.0) DGCON(ISPC)=DGCON(ISPC)
     &  + ALOG(COR2(ISPC))
   30 CONTINUE
      RETURN
      END
