        SUBROUTINE VARVOL
        IMPLICIT NONE
C----------
C  **VARVOL--NI23    DATE OF LAST REVISION:   09/28/12
C----------
C
C  THIS SUBROUTINE CALLS THE APPROPRIATE VOLUME CALCULATION ROUTINE
C  FROM THE NATIONAL CRUISE SYSTEM VOLUME LIBRARY FOR METHB OR METHC
C  EQUAL TO 6.  IT ALSO CONTAINS ANY OTHER SPECIAL VOLUME CALCULATION
C  METHOD SPECIFIC TO A VARIANT (METHB OR METHC = 8)
C----------
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
      INCLUDE 'VOLSTD.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C
C----------
      CHARACTER CTYPE*1,FORST*2,HTTYPE,PROD*2,LIVE*1
      REAL SCALEN(20),BOLHT(21),LOGLEN(20),TVOL(15)
      REAL NLOGS
      REAL NLOGMS,NLOGTW
      REAL VMAX,BARK,H,D,BBFV,VM,VN,DBT,TOPDIB,X01,X02,X03,X04,X05
      REAL X06,X07,X08,X09,X010,X011,X012,DRC,FC,TVOL1,TVOL4,TOP,TDIB
      REAL DBTBH,X0,TDIBB,TDIBC,ERRFLAG,BRATIO
      INTEGER IT,ITRNC,ISPC,INTFOR,IERR,IZERO,I01,I02,I03,I04,I05
      INTEGER I1,IREGN,JFOR,IFC,IFIASP,IR,LOGST
      LOGICAL DEBUG,TKILL,CTKFLG,BTKFLG,LCONE
      CHARACTER*10 EQNC,EQNB
C
C WB IS USED FOR WB
C LM IS USED FOR LM
C AF IS USED FOR LL
C PI IS USED FOR PI,JU
C PY IS USED FOR PY
C AS IS USED FOR AS,MM,OH
C CO IS USED FOR CO
C PB IS USED FOR PB
C WH IS USED FOR OS
C NON-COMMERCIAL EQN USED FOR JU,PY
C POPULUS EQN USED FOR CO,MM,PB,OH
C----------
C SPECIES ORDER:    1   2   3   4   5   6   7   8   9  10  11
C                  WP  WL  DF  GF  WH  RC  LP  ES  AF  PP  MH
C
C SPECIES ORDER:   12  13  14  15  16  17  18  19  20  21  22  23
C                  WB  LM  LL  PI  JU  PY  AS  CO  MM  PB  OH  OS
C
C
C----------
C  NATIONAL CRUISE SYSTEM ROUTINES (METHOD = 6)
C----------
      ENTRY NATCRS (VN,VM,BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,
     1              CTKFLG,BTKFLG,IT)
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'VARVOL',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE VARVOL CYCLE =',I5)
C----------
C  SET PARAMETERS
C----------
      INTFOR = KODFOR - (KODFOR/100)*100
      WRITE(FORST,'(I2)')INTFOR
      IF(INTFOR.LT.10)FORST(1:1)='0'
      HTTYPE='F'
      IERR=0
      DBT = D*(1-BARK)
C----------
C  BRANCH TO R6 LOGIC FOR COLVILLE NATIONAL FOREST,
C  OR FOR PACIFIC YEW.
C----------
      IF(IFOR.EQ.5 .OR. ISPC.EQ.17) GO TO 100
C
C
C
C----------
C  REGION 1 NATCRS SEQUENCE
C----------
      DO 10 IZERO=1,15
      TVOL(IZERO)=0.
   10 CONTINUE
      TOPDIB=TOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
      I01=0
      I02=0
      I03=0
      I04=0
      I05=0
C----------
C  CONSTANT REAL ZERO ARGUMENTS
C----------
      X01=0.
      X02=0.
      X03=0.
      X04=0.
      X05=0.
      X06=0.
      X07=0.
      X08=0.
      X09=0.
      X010=0.
      X011=0.
      X012=0.
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
      CTYPE=' '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
      I1= 1
      IREGN= 1
      PROD='01'
      LIVE='L'
C
      IF(VEQNNC(ISPC)(4:4).EQ.'F')THEN
        IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE CF ISPC,ARGS = ',
     &  ISPC,IREGN,FORST,VEQNNC(ISPC),TOPD(ISPC),STMP(ISPC),D,H,
     &  DBT,BARK
C
        CALL PROFILE (IREGN,FORST,VEQNNC(ISPC),TOPDIB,X01,STMP(ISPC),D,
     &  HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,X09,I02,DBT,BARK*100.,
     &  LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,I03,X010,X011,I1,I1,I1,I04,
     &  I05,X012,CTYPE,I01,PROD,IERR)
C
        IF(D.GE.BFMIND(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,1)=X02
        ELSE
          IF(IT.GT.0)HT2TD(IT,1)=0.
        ENDIF
        IF(D.GE.DBHMIN(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,2)=X02
        ELSE
          IF(IT.GT.0)HT2TD(IT,2)=0.
        ENDIF        
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE CF TVOL= ',TVOL
      ELSE
        JFOR=5
        DRC=0.
        CALL FORMCL(ISPC,JFOR,D,FC)
        IFC=IFIX(FC)
        IF(DEBUG)WRITE(JOSTND,*)' CALLING DVEST CF ISPC,ARGS = ',
     &  ISPC,VEQNNC(ISPC),D,H,TOPDIB,IFC,FORST,BARK,HTTYPE
C
        CALL DVEST(VEQNNC(ISPC),D,DRC,H,TOPDIB,IFC,I01,X01,X02,
     &  FORST,BARK*100.,TVOL,I1,I1,I1,I02,I03,
     &  PROD,HTTYPE,I04,X09,LIVE,NINT(BA),NINT(SITEAR(ISPC)),
     &  CTYPE,IERR)
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER DVEST CF TVOL= ',TVOL
      ENDIF
C----------
C  IF TOP DIAMETER IS DIFFERENT FOR BF CALCULATIONS, STORE APPROPRIATE
C  VOLUMES AND CALL PROFILE AGAIN.
C----------
      IF(BFTOPD(ISPC).NE.TOPD(ISPC) .OR.
     &   BFSTMP(ISPC).NE.STMP(ISPC)) THEN
        TVOL1=TVOL(1)
        TVOL4=TVOL(4)
        DO 20 IZERO=1,15
        TVOL(IZERO)=0.
   20   CONTINUE
        TOPDIB=BFTOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
        I01=0
        I02=0
        I03=0
        I04=0
        I05=0
C----------
C  CONSTANT REAL ZERO ARGUMENTS
C----------
        X01=0.
        X02=0.
        X03=0.
        X04=0.
        X05=0.
        X06=0.
        X07=0.
        X08=0.
        X09=0.
        X010=0.
        X011=0.
        X012=0.
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
        CTYPE=' '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
        I1= 1
        IREGN= 1
        PROD='01'
        LIVE='L'
C
        IF(VEQNNB(ISPC)(4:4).EQ.'F')THEN
          IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE BF ISPC,ARGS = ',
     &    ISPC,IREGN,FORST,VEQNNB(ISPC),BFSTMP(ISPC),D,H,DBT,BARK
C
          CALL PROFILE (IREGN,FORST,VEQNNB(ISPC),TOPDIB,X01,
     &    BFSTMP(ISPC),D,HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,
     &    X09,I02,DBT,BARK*100.,LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,
     &    I03,X010,X011,I1,I1,I1,I04,I05,X012,CTYPE,I01,PROD,IERR)
C
          IF(D.GE.BFMIND(ISPC))THEN
            IF(IT.GT.0)HT2TD(IT,1)=X02
          ELSE
            IF(IT.GT.0)HT2TD(IT,1)=0.
          ENDIF
C
          IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE BF TVOL= ',TVOL
        ELSE
          IF(DEBUG)WRITE(JOSTND,*)' CALLING DVEST BF ISPC,ARGS = ',
     &    ISPC,VEQNNB(ISPC),D,H,TOPDIB,IFC,FORST,BARK,HTTYPE
C
          DRC=0.
          CALL DVEST(VEQNNB(ISPC),D,DRC,H,TOPDIB,IFC,I01,X01,X02,
     &    FORST,BARK*100.,TVOL,I1,I1,I1,I02,I03,
     &    PROD,HTTYPE,I04,X09,LIVE,NINT(BA),NINT(SITEAR(ISPC)),
     &    CTYPE,IERR)
C
          IF(DEBUG)WRITE(JOSTND,*)' AFTER DVEST BF TVOL= ',TVOL
        ENDIF
        TVOL(1)=TVOL1
        TVOL(4)=TVOL4
      ENDIF
C----------
C  SET RETURN VALUES.
C----------
      VN=TVOL(1)
      IF(VN.LT.0.)VN=0.
      VMAX=VN
      IF(D .LT. DBHMIN(ISPC))THEN
        VM = 0.
      ELSE
        VM=TVOL(4)
        IF(VM.LT.0.)VM=0.
      ENDIF
      IF(D.LT.BFMIND(ISPC))THEN
        BBFV=0.
      ELSE
        IF(METHB(ISPC).EQ.9) THEN
          BBFV=TVOL(10)
        ELSE
          BBFV=TVOL(2)
        ENDIF
        IF(BBFV.LT.0.)BBFV=0.
      ENDIF
      CTKFLG = .TRUE.
      BTKFLG = .TRUE.
      RETURN
C
C
C
C----------
C  REGION 6 NATCRS SEQUENCE
C----------
  100 CONTINUE
C----------
C  BRANCH TO EITHER THE PROFILE EQN OR OLD R6 FORM CLASS EQN
C----------
      IF(VEQNNC(ISPC)(4:4).EQ.'F')THEN
        DO 110 IZERO=1,15
        TVOL(IZERO)=0.
  110   CONTINUE
        TOPDIB=TOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
        I01=0
        I02=0
        I03=0
        I04=0
        I05=0
C----------
C  CONSTANT REAL ZERO ARGUMENTS
C----------
        X01=0.
        X02=0.
        X03=0.
        X04=0.
        X05=0.
        X06=0.
        X07=0.
        X08=0.
        X09=0.
        X010=0.
        X011=0.
        X012=0.
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
        CTYPE=' '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
        I1= 1
        IREGN= 6
C
        IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE CF ISPC,ARGS = ',
     &    ISPC,IREGN,FORST,VEQNNC(ISPC),TOPD(ISPC),STMP(ISPC),D,H,
     &    DBT,BARK
C
        CALL PROFILE (IREGN,FORST,VEQNNC(ISPC),TOPDIB,X01,STMP(ISPC),D,
     &  HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,X09,I02,DBT,BARK*100.,
     &  LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,I03,X010,X011,I1,I1,I1,I04,
     &  I05,X012,CTYPE,I01,PROD,IERR)
C
        IF(D.GE.BFMIND(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,1)=X02
        ELSE
          IF(IT.GT.0)HT2TD(IT,1)=0.
        ENDIF
        IF(D.GE.DBHMIN(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,2)=X02
        ELSE
          IF(IT.GT.0)HT2TD(IT,2)=0.
        ENDIF        
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE CF TVOL= ',TVOL
C----------
C  IF TOP DIAMETER IS DIFFERENT FOR BF CALCULATIONS, STORE APPROPRIATE
C  VOLUMES AND CALL PROFILE AGAIN.
C----------
        IF(BFTOPD(ISPC).NE.TOPD(ISPC) .OR.
     &     BFSTMP(ISPC).NE.STMP(ISPC)) THEN
          TVOL1=TVOL(1)
          TVOL4=TVOL(4)
          DO 120 IZERO=1,15
          TVOL(IZERO)=0.
  120     CONTINUE
          TOPDIB=BFTOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
          I01=0
          I02=0
          I03=0
          I04=0
          I05=0
C----------
C  CONSTANT REAL ZERO ARGUMENTS
C----------
          X01=0.
          X02=0.
          X03=0.
          X04=0.
          X05=0.
          X06=0.
          X07=0.
          X08=0.
          X09=0.
          X010=0.
          X011=0.
          X012=0.
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
          CTYPE=' '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
          I1= 1
          IREGN= 6
C
          IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE BF ISPC,ARGS = ',
     &    ISPC,IREGN,FORST,VEQNNB(ISPC),BFTOPD(ISPC),BFSTMP(ISPC),D,H,
     &    DBT,BARK
C
          CALL PROFILE (IREGN,FORST,VEQNNB(ISPC),TOPDIB,X01,
     &    BFSTMP(ISPC),D,HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,X09,
     &    I02,DBT,BARK*100.,LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,I03,X010,
     &    X011,I1,I1,I1,I04,I05,X012,CTYPE,I01,PROD,IERR)
C
          IF(D.GE.BFMIND(ISPC))THEN
            IF(IT.GT.0)HT2TD(IT,1)=X02
          ELSE
            IF(IT.GT.0)HT2TD(IT,1)=0.
          ENDIF
C
          IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE BF TVOL= ',TVOL
          TVOL(1)=TVOL1
          TVOL(4)=TVOL4
        ENDIF
C----------
C  SET RETURN VALUES.
C----------
        VN=TVOL(1)
        IF(VN.LT.0.)VN=0.
        VMAX=VN
        IF(D .LT. DBHMIN(ISPC))THEN
          VM = 0.
        ELSE
          VM=TVOL(4)
          IF(VM.LT.0.)VM=0.
        ENDIF
        IF(D.LT.BFMIND(ISPC))THEN
          BBFV=0.
        ELSE
          IF(METHB(ISPC).EQ.9) THEN
            BBFV=TVOL(10)
          ELSE
            BBFV=TVOL(2)
          ENDIF
          IF(BBFV.LT.0.)BBFV=0.
        ENDIF
        CTKFLG = .TRUE.
        BTKFLG = .TRUE.
C
C
C
      ELSE
C----------
C  OLD R6 FORM CLASS SECTION
C
C  GET FORM CLASS FOR THIS TREE.
C----------
        JFOR=5
        IREGN= 6
        CALL FORMCL(ISPC,JFOR,D,FC)
        IFC=IFIX(FC)
C----------
C  SET R6VOL PARAMETERS FOR CUBIC VOLUME
C----------
        TOP = TOPD(ISPC)
        TDIB = TOP*BARK
        NLOGS = 0.
        NLOGMS = 0.
        NLOGTW = 0.
        DBTBH = D-D*BARK
        IERR=0
        DO 130 IZERO=1,15
        TVOL(IZERO)=0.
  130   CONTINUE
        CTYPE=' '
        X0=0.
C----------
C  CALL R6VOL/BLMVOL TO COMPUTE CUBIC VOLUME.
C----------
        IF((VEQNNC(ISPC)(1:3).EQ.'616').OR.
     &    (VEQNNC(ISPC)(1:3).EQ.'632')) THEN
          CALL R6VOL(VEQNNC(ISPC),FORST,D,BARK*100.,IFC,TDIB,H,'F',TVOL,
     &             LOGVOL,NLOGS,LOGDIA,SCALEN,DBTBH,X0,CTYPE,IERR)
          IF(DEBUG)WRITE(16,*)' AFTER R6VOL-VEQNNC(ISPC),FORST,D',
     &    ',BARK*100.,IFC,TOPDIB,H,TVOL,LOGVOL,NLOGS,LOGDIA,',
     &     'SCALEN,DBTBH,X01,CTYPE,IERR= ',VEQNNC(ISPC),FORST,D,
     &     BARK*100.,IFC,TOPDIB,H,TVOL,LOGVOL,NLOGS,LOGDIA,
     &     SCALEN,DBTBH,X01,CTYPE,IERR
        ELSE
          IF(DEBUG)WRITE(16,*)' before BLMVOL-TOPD(ISPC),BARK= ',
     &                          TOPD(ISPC),BARK
          CALL BLMVOL(VEQNNC(ISPC),TOPD(ISPC),H,X01,D,'F',IFC,TVOL,
     &           LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW,1,1,IERR)
          IF(DEBUG)WRITE(16,*)' AFTER BLMVOL-VEQNNC(ISPC),TOPD(ISPC),',
     &    'H,X01,D,IFC,TVOL,LOGDIA, LOGLEN,LOGVOL,LOGST,NLOGMS,',
     &    'NLOGTW,IERR= ',VEQNNB(ISPC),TOPD(ISPC),H,X01,D,'F',IFC,TVOL,
     &               LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW
        ENDIF
C----------
C  SET RETURN VARIABLES.
C----------
        VN=TVOL(1)
        IF(VN.LT.0.)VN=0.
        VMAX=VN
        IF(D.LT.DBHMIN(ISPC) .OR. D.LT.TOPD(ISPC))THEN
          VM=0.
        ELSE
          VM=TVOL(4)
          IF(VM.LT.0.)VM=0.
        ENDIF
C----------
C  IF BF TOP IS DIFFERENT THAN CF TOP SET PARAMETERS FOR
C  BOARD FOOT VOLUME.
C----------
        IF(BFTOPD(ISPC) .NE. TOPD(ISPC)) THEN
          TOP = BFTOPD(ISPC)
          TDIB = TOP*BARK
          NLOGS = 0.
          DBTBH = D-D*BARK
          IERR=0
          DO 140 IZERO=1,15
          TVOL(IZERO)=0.
  140     CONTINUE
          CTYPE=' '
          X0=0.
C----------
C  CALL R6VOL TO COMPUTE BOARD VOLUME.
C----------
          CALL R6VOL(VEQNNB(ISPC),FORST,D,BARK*100.,IFC,TDIB,H,'F',
     &           TVOL,LOGVOL,NLOGS,LOGDIA,SCALEN,DBTBH,X0,CTYPE,IERR)
        ENDIF
        IF(D.LT.BFMIND(ISPC))THEN
          BBFV=0.
        ELSE
          IF(METHB(ISPC).EQ.9) THEN
            BBFV=TVOL(10)
          ELSE
            BBFV=TVOL(2)
          ENDIF
          IF(BBFV.LT.0.)BBFV=0.
        ENDIF
        CTKFLG = .TRUE.
        BTKFLG = .TRUE.
      ENDIF
C
      IF(VN.LE.0.) THEN
        VM=0.
        BBFV=0.
        CTKFLG = .FALSE.
        BTKFLG = .FALSE.
      ENDIF
      RETURN
C
C
C
C----------
C  ENTER ANY OTHER CUBIC HERE
C----------
      ENTRY OCFVOL (VN,VM,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     1              CTKFLG,IT)
      VN=0.
      VMAX=0.
      VM=0.
      CTKFLG = .FALSE.
      RETURN
C
C
C----------
C  ENTER ANY OTHER BOARD HERE
C----------
      ENTRY OBFVOL (BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     1              BTKFLG,IT)
C----------
C  SET RETURN VALUES.
C----------
      BBFV=0.
      BTKFLG = .FALSE.
      RETURN
C
C
C----------
C  ENTRY POINT FOR SENDING VOLUME EQN NUMBER TO THE FVS-TO-NATCRZ ROUTINE
C----------
      ENTRY GETEQN(ISPC,D,H,EQNC,EQNB,TDIBC,TDIBB)
      EQNC=VEQNNC(ISPC)
      EQNB=VEQNNB(ISPC)
      TDIBC=TOPD(ISPC)*BRATIO(ISPC,D,H)
      TDIBB=BFTOPD(ISPC)*BRATIO(ISPC,D,H)
      RETURN
C
      END