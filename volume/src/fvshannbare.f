      SUBROUTINE FVSHANNBARE(VN,VM,VMAX,ISPC,D,H,CTKFLG)
      IMPLICIT NONE
C----------
C VOLUME $Id: fvshannbare.f 1744 2016-03-28 21:01:34Z rhavis $
C----------
C  This routine calculates volumes for the CR variant using
C  the Hann and Bare method METHC = 8, R2 forestes use coefficients
C  from the Cibola NF
C  called from **FVSVOL
C
COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'GGCOM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C  DECLARATIONS: NOTE THAT THIS IS A R2 VOLUME CALCULATION METHOD only SO
C  THE MAXSP ELEMENT IN THE IEQMAP ARRAY IS HARD CODDED TO THe NUMBER
C  OF SPECIES IN THE CR VARIANT
C
      INTEGER IEQMAP(11,38),ISPC,IEQN,I
      REAL VN,VM,VMAX,D,H,X,RIC,RSI,VI,VMR,VU
      REAL BBFV
      LOGICAL CTKFLG,BTKFLG
      REAL BN(10),B0(10),B1(10),B2(10),F0(10),F1(10),
     &   F2(10),F3(10),E0(10),E1(10),E2(10),E3(10),A0(10),A1(10)
C
C  LOCAL VARIABLES
C
C     IEQMAP -- ARRAY CONTAINING EQUATION NUMBERS FOR R3 H&B VOLUMES
C               1ST DIMENSION = R3 FOREST, 2ND DIMENSION=SPECIES
C----------
C  VARIABLE IEQMAP IS USED FOR VOLUME METHOD 8 R3 H&B VOLUMES
C  GLOBAL VALUES ARE SET HERE, SOME ARE MODIFIED IN **SITSET**
C  DEPENDING ON MODEL TYPE AND FOREST CODE.
C  COLUMNS IN THE FOLLOWING ARRAY CORRESPOND TO A REGION 3 FOREST.
C  1=301, 2=302 ... 11=312
C  ROWS CORRESPOND SPECIES: ROW 1=AF, 2=CB, ... , 38=OH
C----------
      DATA (IEQMAP(I, 1),I=1,11)/ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2/
      DATA (IEQMAP(I, 2),I=1,11)/ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2/
      DATA (IEQMAP(I, 3),I=1,11)/ 6, 7, 7, 7, 7, 7, 7, 6, 7, 7, 7/
      DATA (IEQMAP(I, 4),I=1,11)/ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2/
      DATA (IEQMAP(I, 5),I=1,11)/ 9,10,10,10,10,10,10, 9,10,10,10/
      DATA (IEQMAP(I, 6),I=1,11)/ 9,10,10,10,10,10,10, 9,10,10,10/
      DATA (IEQMAP(I, 7),I=1,11)/ 9,10,10,10,10,10,10, 9,10,10,10/
      DATA (IEQMAP(I, 8),I=1,11)/ 9,10,10,10,10,10,10, 9,10,10,10/
      DATA (IEQMAP(I, 9),I=1,11)/ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1/
      DATA (IEQMAP(I,10),I=1,11)/ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1/
      DATA (IEQMAP(I,11),I=1,11)/ 6, 7, 7, 7, 7, 7, 7, 6, 7, 7, 7/
      DATA (IEQMAP(I,12),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,13),I=1,11)/ 4, 5, 4, 4, 4, 4, 4, 4, 4, 5, 4/
      DATA (IEQMAP(I,14),I=1,11)/ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1/
      DATA (IEQMAP(I,15),I=1,11)/ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1/
      DATA (IEQMAP(I,16),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,17),I=1,11)/ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2/
      DATA (IEQMAP(I,18),I=1,11)/ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2/
      DATA (IEQMAP(I,19),I=1,11)/ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2/
      DATA (IEQMAP(I,20),I=1,11)/ 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8/
      DATA (IEQMAP(I,21),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,22),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,23),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,24),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,25),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,26),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,27),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,28),I=1,11)/ 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8/
      DATA (IEQMAP(I,29),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,30),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,31),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,32),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,33),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,34),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,35),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,36),I=1,11)/ 4, 5, 4, 4, 4, 4, 4, 4, 4, 5, 4/
      DATA (IEQMAP(I,37),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
      DATA (IEQMAP(I,38),I=1,11)/-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1/
C
C  DATA FROM R2-CR VARIANT BRUCE AND DEMAR'S EQS.
C
      DATA A0/0.16089,0.22547,0.23720,0.08107,0.04831,0.43837,0.34113,
     &0.03270,0.21090,0.15778/
      DATA A1/0.0020325,0.0021697,0.0022112,0.0019835,0.0020497,
     &0.0017564,0.0019180,0.0023112,0.0018400,0.0020091/
C----------
C GROSS M.C.F. C.F. TABLE 4, PG. 7
C----------
      DATA BN/1.5,1.5,1.0,1.5,1.5,1.0,1.5,1.5,1.0,1.5/
      DATA B0/-0.21301,-0.26648,0.01855,-0.12535,-0.13397,-0.08315,
     &-0.18763,-0.23643,-0.18270,-0.18756/
      DATA B1/0.0049121,0.0061290,0.0007882,0.0036042,0.0065017,
     &0.0012190,0.0067187,0.0058021,0.0012482,0.0063265/
      DATA B2/0.0060606,0.0074311,0.0050551,0.0054063,0.0049022,
     &0.0054174,0.0053645,0.0060804,0.0062448,0.0060413/
C----------
C GROSS BD.FT. INT. C.F. TABLE 7, PG. 11
C----------
      DATA F0/6.69197,5.98736,7.10051,6.84752,7.58122,6.58735,6.59717,
     &6.68808,6.24688,5.73645/
      DATA F1/7.52011,9.84792,7.97922,7.69491,8.51941,0.89272,0.89405,
     &-1.27685,7.01994,1.72093/
      DATA F2/216.34837,-300.81281,229.55650,221.37723,245.09754,
     &243.51491,243.87797,-4.50480,201.95873,74.57379/
      DATA F3/0.0,2855.34246,0.0,0.0,0.0,0.0,0.0,1423.98524,0.0,0.0/
C----------
C GROSS BD. FT. SCR. C.F. TABLE 9, PG. 13
C----------
      DATA E0/1.00609,0.87845,0.98210,0.96579,0.99399,1.00090,0.87026,
     &0.88789,1.0,1.01725/
      DATA E1/2.38466,0.0,0.92603,0.40579,1.46349,0.0,0.0,0.0,1.88814,
     &1.87057/
      DATA E2/0.0,0.0,0.0,0.0,0.0,4.10007,0.0,0.0,0.0,0.0/
      DATA E3/0.0,15.99846,14.49444,16.93678,12.40585,0.0,19.49594,
     &17.19374,8.85145,8.51445/
C
C----------
C  USE CIBOLA COEFFICIENTS FOR R2 FORESTS
C----------
      IF(IFOR .LT. IGFOR) THEN
        IEQN=IEQMAP(     3,ISPC)
      ELSE
        IEQN=IEQMAP(IFOR-12,ISPC)
      ENDIF
C----------
C  SET INITIAL VALUES. IF DIAMETER LIMITS NOT MET THEN RETURN.
C----------
      VN=0.
      VM=0.
      IF (D .LT. 1.0 .OR. H .LT. 1.0) GO TO 400
      IF (IEQN .LT. 1 .OR. IEQN .GT. 10) GO TO 300
C----------
C COMPUTE TOTAL STEM GROSS CUBIC FOOT VOLUME - UNFORKED TREES
C----------
      VN=A0(IEQN)+(A1(IEQN)*D*D*H)
      IF(VN .LE. 0.0) VN=0.
C----------
C   COMPUTE MERCH CUBIC FOOT VOLUME. IF DIAMETER LIMITS NOT MET
C   THEN BYPASS THIS CALCULATION.
C----------
      IF (D .LT. DBHMIN(ISPC) .OR. D .LE. TOPD(ISPC)) GO TO 400
C----------
C COMPUTE MERCHANTABLE GROSS CUBIC FOOT VOLUME- UNFORKED TREES, TOP
C DIAMETER (TOPD) 3 TO 8 IN. I.B.
C----------
      VU=B0(IEQN)+(B1(IEQN)*((TOPD(ISPC)**3)*H)/(D**BN(IEQN)))
     & +(B2(IEQN)*D*D)
      IF(VU .GT. VN) GO TO 400
      VM = VN - VU
      GO TO 400
C----------
C PINYON AND JUNIPER EQUATIONS
C CHOJNACKY & OTT  RES. NOTE INT-363  NOV 1986
C OAK FROM DAVE WILSON (ALSO A CHOJNACKY EQN)
C SET MERCH CUBIC = TOTAL SINCE THESE ARE FIREWOOD SPECIES
C----------
  300 CONTINUE
      X=D*D*H/1000.
      IF(ISPC .EQ. 12) THEN
        IF(X .LE. 5) THEN
          VN = -0.07 + 2.51*X + 0.098*X*X
        ELSE
          VN = 7.29 + 2.51*X - 24.53/X
        ENDIF
      ELSEIF (ISPC .EQ. 16) THEN
        IF(X .LE. 5) THEN
          VN = -0.05 + 2.48*X + 0.057*X*X
        ELSE
          VN = 4.24 + 2.48*X - 14.29/X
        ENDIF
      ELSEIF (ISPC .EQ. 22) THEN
        IF(X .LE. 5) THEN
          VN = -0.068 + 2.4048*X + 0.1383*X*X
        ELSE
          VN = 6.571 + 2.4048*X - 17.704/X
        ENDIF
      ENDIF
      IF(VN .LT. 0.) VN=0.
      IF(D .LT. DBHMIN(ISPC))THEN
        VM = 0.
      ELSE
        VM=VN
      ENDIF
C
  400 CONTINUE
      VMAX=VN
      CTKFLG = .TRUE.
      RETURN
C----------
C  ENTER ANY OTHER BOARD HERE
C----------
      ENTRY HANNBAREBF (BBFV,ISPC,D,H,VMAX,BTKFLG)
C----------
C  USE CIBOLA COEFFICIENTS FOR R2 FORESTS
C----------
      IF(IFOR .LT. IGFOR) THEN
        IEQN=IEQMAP(     3,ISPC)
      ELSE
        IEQN=IEQMAP(IFOR-12,ISPC)
      ENDIF
      BBFV=0.
      BTKFLG=.FALSE.
C----------
C  IF NON-COMMERCIAL SPECIES, RETURN 0 BOARD FOOT VOLUME.
C----------
      IF(IEQN .LT. 1) RETURN
C----------
C   IF DIAMETER LIMITS NOT MET THEN RETURN.
C----------
      IF (D .LT. BFMIND(ISPC) .OR. D .LT. BFTOPD(ISPC)) RETURN
C----------
C CALCULATE M.C.F. FOR DTOPB INCH TOP
C----------
      VU=B0(IEQN)+(B1(IEQN)*((BFTOPD(ISPC)**3)*H)/(D**BN(IEQN)))
     & +(B2(IEQN)*D*D)
      IF(VU .GT. VMAX) GO TO 600
      VMR = VMAX - VU
C----------
C CALCULATE B.F.I. USING M.C.F. TO DTOPB INCH TOP
C----------
      RIC=F0(IEQN)-(F1(IEQN)/D)-(F2(IEQN)/(D**2))-(F3(IEQN)/(D**3))
      IF(RIC .LT. 0.0) GO TO 600
      VI = VMR * RIC
C----------
C CALCULATE B.F.S. USING B.F.I.
C----------
      RSI=E0(IEQN)-(E1(IEQN)/D)-(E2(IEQN)/(D**1.177748))-(E3(IEQN)/
     & (D**2))
      IF(RSI .LT. 0.0) GO TO 600
      BBFV = VI * RSI
C
  600 CONTINUE
      BTKFLG = .TRUE.
      RETURN
      END      