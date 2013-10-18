      SUBROUTINE SITSET
      IMPLICIT NONE
C----------
C  **SITSET--WC   DATE OF LAST REVISION:  05/11/11
C----------
C
C THIS SUBROUTINE LOADS THE SITEAR ARRAY WITH A SITE INDEX FOR EACH
C SPECIES, GIVEN A SITE INDEX AND SITE SPECIES, AND LOADS THE SDIDEF
C ARRAY WITH SDI MAXIMUMS FOR SPECIES WHICH WERE NOT ASSIGNED A VALUE
C USING THE SDIMAX KEYWORD.
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
COMMONS
C
      LOGICAL DEBUG
      CHARACTER FORST*2,DIST*2,PROD*2,VAR*2,VOLEQ*10
      CHARACTER*4 ASPEC
      INTEGER IFIASP, ERRFLAG
      INTEGER NSISET,NSDSET,I,JSISP,INDEX,KNTECO,NTOHI,ISEQ,NUM,ISFLAG
      INTEGER ITOHI,ISPC,J,JJ,K,INTFOR,IREGN
      REAL SIAGE(MAXSP),FMSDI(10)
      REAL FORMAX,RSI,RSDI,AG,SINDX,SI
C----------
C  DATA STATEMENTS
C----------
      DATA FMSDI/950.,950.,900.,850.,825.,870.,885.,870.,825.,850./
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'SITSET',6,ICYC)
C
      FORMAX=FMSDI(IFOR)
C----------
C  DETERMINE HOW MANY SITE VALUES AND SDI VALUES WERE SET VIA KEYWORD.
C----------
      NSISET=0
      NSDSET=0
      DO 5 I=1,MAXSP
      IF(SITEAR(I) .GT. 0.) NSISET=NSISET+1
      IF(SDIDEF(I) .GT. 0.) NSDSET=NSDSET+1
    5 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)'ENTERING SITSET, SITE VALUES SET = ',
     &NSISET,'  SDI VALUES SET = ',NSDSET
C----------
C  SET SITE SPECIES AND SITE INDEX IF NOT SET BY KEYWORD.
C  FOR REGION 6 FORESTS SET SDI DEFAULTS HERE ALSO.
C----------
C     REGION 6 FOREST --- CALL **ECOCLS** WITH THE ECOCLASS CODE,
C     AND GET BACK THE DEFAULT SITE SPECIES, ALL SITE INDICIES,
C     AND DEFAULT SDI MAXIMUMS ASSOCIATED WITH THE ECOCLASS
C----------
      JSISP=0
      INDEX=0
      KNTECO=0
      NTOHI=0
   10 CALL ECOCLS (PCOM,ASPEC,RSDI,RSI,ISFLAG,NUM,INDEX,ISEQ)
      KNTECO=KNTECO+1
      IF(DEBUG)WRITE(JOSTND,*)'AFTER ECOCLS,PCOM,ASPEC,RSDI,RSI,',
     &'ISFLAG,NUM,INDEX,ISEQ = ',PCOM,ASPEC,RSDI,RSI,ISFLAG,
     &NUM,INDEX,ISEQ
C----------
C IF DEFAULT SDI IS OUT OF BOUNDS, RESET IT.
C----------
        ITOHI=0
        IF(RSDI .GT. FORMAX)THEN
          RSDI=FORMAX
          ITOHI=1
        ENDIF
C
      IF(ISEQ .EQ. 0) GO TO 25
      IF(JSISP.EQ.0 .AND. ISFLAG.EQ.1) JSISP=ISEQ
      IF(ISISP.LE.0 .AND. ISFLAG.EQ.1) ISISP=ISEQ
      IF(SITEAR(ISEQ).LE.0. .AND. NSISET.EQ.0) SITEAR(ISEQ)=RSI
      IF(SDIDEF(ISEQ) .LE. 0.) THEN
        SDIDEF(ISEQ)=RSDI
        IF(ITOHI .GT. 0) NTOHI=NTOHI+1
      ENDIF
      IF(ISISP.GT.0 .AND. ISFLAG.EQ.1) THEN
        IF(SDIDEF(ISISP) .LE. 0.) THEN
          SDIDEF(ISISP)=RSDI
          IF(ITOHI .GT. 0) NTOHI=NTOHI+1
        ENDIF
      ENDIF
   25 CONTINUE
      IF(NUM.GT.1 .AND. KNTECO.LT.NUM) THEN
        INDEX=INDEX+1
        GO TO 10
      ENDIF
C---------
C  ON THE CHANCE THAT A SITE SPECIES WAS NOT ENCOUNTERED IN **ECOCLS**
C  PROVIDE A REGION 6 GLOBAL DEFAULT.
C----------
      IF(ISISP .LE. 0) ISISP = 10
      IF(SITEAR(ISISP) .LE. 0.0) SITEAR(ISISP) = 70.
C----------
C TRANSLATE SITE INDEX TO A REFERENCE AGE FOR EACH SPECIES.
C----------
      CALL SICHG(ISISP,SITEAR(ISISP),SIAGE)
C----------
C IF SITEAR HAS NOT BEEN SET WITH SITECODE KEYWORD,
C LOAD IT WITH SITE VALUES CALCULATED HERE.
C----------
      DO 30 ISPC=1,MAXSP
      IF(DEBUG)WRITE(JOSTND,*)'IN SITSET ISISP,ISPC,SITEAR =',
     &ISISP,ISPC,SITEAR(ISISP)
      IF(SITEAR(ISPC) .GT. 0.0) GO TO 30
      AG=SIAGE(ISPC)
      SINDX=SITEAR(ISISP)
      IF(DEBUG)WRITE(JOSTND,*)'CALLING HTCALC SINDX,ISISP,AG,SI=',
     &SINDX,ISISP,AG,SI
      SI = 0.
      CALL HTCALC(SINDX,ISISP,AG,SI,JOSTND,DEBUG)
      IF(DEBUG)WRITE(JOSTND,*)'RETURN FROM HTCALC,SINDX,ISISP,AG,SI=',
     &SINDX,ISISP,AG,SI
      IF(ISPC.EQ.20 .AND. ISISP.NE.20)THEN
        SI=SI/3.281
        IF(SI.GT.28.)SI=28.
      ENDIF
C----------
C MISC. HARDWOODS USE CURTIS SI CURVE CREATED FOR DF. THE
C FOLLOWING EQUATIONS ARE USED TO REDUCE THEIR GROWTH UNTIL
C SI CURVES ARE FOUND FOR THESE SPECIES. 4/26/01 EES.
C----------
      IF(ISPC.EQ.21 .AND. ISISP.NE.21)SI=SI*.75
      IF(ISPC.EQ.23 .AND. ISISP.NE.23)SI=SI*.65
      IF(ISPC.EQ.24 .AND. ISISP.NE.24)SI=SI*1.5
      IF(ISPC.EQ.25 .AND. ISISP.NE.25)SI=SI*.70
      IF(ISPC.EQ.26 .AND. ISISP.NE.26)SI=SI*.75
      IF(ISPC.EQ.27 .AND. ISISP.NE.27)SI=SI*.85
      IF(ISPC.EQ.29 .AND. ISISP.NE.29)SI=SI*.23
      IF(ISPC.EQ.31 .AND. ISISP.NE.31)SI=SI*.70
      IF(ISPC.EQ.33 .AND. ISISP.NE.33)SI=SI*.25
      IF(ISPC.EQ.34 .AND. ISISP.NE.34)SI=SI*.60
      IF(ISPC.EQ.35 .AND. ISISP.NE.35)SI=SI*.25
      IF(ISPC.EQ.36 .AND. ISISP.NE.36)SI=SI*.50
      IF(ISPC.EQ.37 .AND. ISISP.NE.37)SI=SI*.50
C----------
C FOR WHITE OAK USE METHOD DERIVED BY GOULD TO GET ESTIMATE OF MAXIMUM
C HEIGHT (THINK OF AS A BASE AGE 300) FROM DF, FROM KING CURVE (BASE AGE 50).
C----------
      IF(ISPC.EQ.28 .AND. ISISP.NE.28)SI=114.2*(1-EXP(-0.0266*SI))**2.26
C----------
      SITEAR(ISPC) = SI
   30 CONTINUE
C----------
C LOAD THE SDIDEF ARRAY
C----------
      DO 80 I=1,MAXSP
        IF(SDIDEF(I) .EQ. 0.0) SDIDEF(I) = SDIDEF(ISISP)
   80 CONTINUE
      IF(BAMAX.LE.0) BAMAX=SDIDEF(ISISP)*(PMSDIU/100.)*0.54542
C
      DO 92 I=1,15
      J=(I-1)*10 + 1
      JJ=J+9
      IF(JJ.GT.MAXSP)JJ=MAXSP
      WRITE(JOSTND,90)(NSP(K,1)(1:2),K=J,JJ)
   90 FORMAT(/'SPECIES ',5X,10(A2,6X))
      WRITE(JOSTND,91)(SDIDEF(K),K=J,JJ )
   91 FORMAT('SDI MAX ',   10F8.0)
      IF(JJ .EQ. MAXSP)GO TO 93
   92 CONTINUE
   93 CONTINUE
      IF(NTOHI .GT. 0)WRITE(JOSTND,102)FORMAX
  102 FORMAT(/'*NOTE -- AT LEAST ONE DEFAULT MAXIMUM SDI EXCEEDED THE FO
     &REST DEFAULT MAXIMUM. FOREST DEFAULT MAXIMUM OF ',F5.0,' USED.',/
     &,'          YOU MAY NEED TO SPECIFICALLY RESET VALUES FOR THESE SP
     &ECIES USING THE SDIMAX KEYWORD.')
C----------
C  LOAD VOLUME DEFAULT MERCH. SPECS.
C----------
      SELECT CASE(IFOR)
      CASE(7,8,9,10)
        DO I=1,MAXSP
        IF(DBHMIN(I) .LE. 0.) DBHMIN(I) = 7.0
        IF(TOPD(I) .LE. 0.) TOPD(I) = 5.0
        IF(BFTOPD(I) .LE. 0.) BFTOPD(I) = 5.0
        IF(BFMIND(I) .LE. 0.) BFMIND(I) = 7.0
        END DO
      CASE DEFAULT
        DO I=1,MAXSP
        IF((DBHMIN(I) .LE. 0.).AND.(I.EQ.11)) DBHMIN(I) = 6.0
        IF((BFMIND(I) .LE. 0.).AND.(I.EQ.11)) BFMIND(I) = 6.0
        IF(DBHMIN(I) .LE. 0.) DBHMIN(I) = 7.0
        IF(TOPD(I) .LE. 0.) TOPD(I) = 4.5
        IF(BFTOPD(I) .LE. 0.) BFTOPD(I) = 4.5
        IF(BFMIND(I) .LE. 0.) BFMIND(I) = 7.0
        END DO
      END SELECT
C----------
C  LOAD VOLUME EQUATION ARRAYS FOR ALL SPECIES
C----------
      INTFOR = KODFOR - (KODFOR/100)*100
      WRITE(FORST,'(I2)')INTFOR
      IF(INTFOR.LT.10)FORST(1:1)='0'
      IREGN = KODFOR/100
      DIST='  '
      PROD='  '
      VAR='WC'
C
      DO ISPC=1,MAXSP
      READ(FIAJSP(ISPC),'(I4)')IFIASP
      IF(((METHC(ISPC).EQ.6).OR.(METHC(ISPC).EQ.9)).AND.
     &     (VEQNNC(ISPC).EQ.'          '))THEN
        CALL VOLEQDEF(VAR,IREGN,FORST,DIST,IFIASP,PROD,VOLEQ,ERRFLAG)
        VEQNNC(ISPC)=VOLEQ
      ENDIF
      IF(((METHB(ISPC).EQ.6).OR.(METHB(ISPC).EQ.9)).AND.
     &     (VEQNNB(ISPC).EQ.'          '))THEN
        CALL VOLEQDEF(VAR,IREGN,FORST,DIST,IFIASP,PROD,VOLEQ,ERRFLAG)
        VEQNNB(ISPC)=VOLEQ
      ENDIF
      ENDDO
C----------
C  IF FIA CODES WERE IN INPUT DATA, WRITE TRANSLATION TABLE
C---------
      IF(LFIA) THEN
        CALL FIAHEAD(JOSTND)
        WRITE(JOSTND,211) (NSP(I,1)(1:2),FIAJSP(I),I=1,MAXSP)
 211    FORMAT ((T12,8(A3,'=',A6,:,'; '),A,'=',A6))
      ENDIF
C----------
C  WRITE VOLUME EQUATION NUMBER TABLE
C----------
      CALL VOLEQHEAD(JOSTND)
      WRITE(JOSTND,230)(NSP(J,1)(1:2),VEQNNC(J),VEQNNB(J),J=1,MAXSP)
 230  FORMAT(4(2X,A2,4X,A10,1X,A10,1X))
C
      RETURN
      END
