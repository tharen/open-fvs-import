      SUBROUTINE SITSET
      IMPLICIT NONE
C----------
C  **SITSET--BM   DATE OF LAST REVISION:  05/05/09
C----------
C THIS SUBROUTINE LOADS THE SITELG ARRAY WITH A SITE INDEX FOR EACH
C SPECIES WHICH WAS NOT ASSIGNED A SITE INDEX BY KEYWORD.
C----------
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
C----------
      CHARACTER FORST*2,DIST*2,PROD*2,VAR*2,VOLEQ*10
      INTEGER IFIASP, ERRFLAG
      CHARACTER*4 ASPEC
      REAL SIAGE(MAXSP),SI(MAXSP),FORMAX,RSI,RSDI,AG,SINDX
      INTEGER NSISET,NSDSET,I,JSISP,INDEX,KNTEGO,NTOHI,ISEQ,NUM
      INTEGER ISFLAG,ITOHI,ISPC,K,INTFOR,IREGN,J,KNTECO,JJ
      REAL SILO(MAXSP),SIHI(MAXSP),TEM
      LOGICAL DEBUG
C
      DATA FORMAX/850./
C----------
C  IF THESE SITE INDEX RANGES CHANGE, ALSO CHANGE THEM IN **REGENT**,
C  AND **HTGF**
C----------
      DATA SILO/
     &  20.,  50.,  50.,  50.,  15.,   5.,  30.,  40.,  50.,  70.,
     &  20.,  20.,   5.,  50.,  30.,  10.,  70.,   5./
C
      DATA SIHI/
     &  80., 110., 110., 110.,  30.,  40.,  70., 120., 150., 140.,
     &  65.,  50.,  75., 110.,  66., 191., 140., 125./
C----------
C  SPECIES ORDER:
C   1=WP,  2=WL,  3=DF,  4=GF,  5=MH,  6=WJ,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=WB, 12=LM, 13=PY, 14=YC, 15=AS, 16=CW,
C  17=OS, 18=OH
C----------
C  SPECIES EXPANSION:
C  WJ USES SO JU (ORIGINALLY FROM UT VARIANT; REALLY PP FROM CR VARIANT)
C  WB USES SO WB (ORIGINALLY FROM TT VARIANT)
C  LM USES UT LM
C  PY USES SO PY (ORIGINALLY FROM WC VARIANT)
C  YC USES WC YC
C  AS USES SO AS (ORIGINALLY FROM UT VARIANT)
C  CW USES SO CW (ORIGINALLY FROM WC VARIANT)
C  OS USES BM PP BARK COEFFICIENT
C  OH USES SO OH (ORIGINALLY FROM WC VARIANT)
C
C----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'SITSET',6,ICYC)
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
C
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
     & 'ISFLAG,NUM,INDEX,ISEQ = ',PCOM,ASPEC,RSDI,RSI,ISFLAG,
     & NUM,INDEX,ISEQ
C----------
C IF DEFAULT SDI IS OUT OF BOUNDS, RESET IT.
C----------
      ITOHI=0
      IF(RSDI .GT. FORMAX)THEN
        RSDI=FORMAX
        ITOHI=1
      ENDIF
C----------
C     LOOP THROUGH JSP ARRAY AND DETERMINE FVS SEQUENCE NUMBER FOR
C     THIS SPECIES
C----------
      IF(ISEQ .EQ. 0) GO TO 25
      IF(JSISP.EQ.0 .AND. ISFLAG.EQ.1) JSISP=ISEQ
      IF(ISISP.LE.0 .AND. ISFLAG.EQ.1) ISISP=ISEQ
      IF(SITEAR(ISEQ).LE.0. .AND. NSISET.EQ.0) SITEAR(ISEQ)=RSI
      IF(SDIDEF(ISEQ) .LE. 0.) THEN
        SDIDEF(ISEQ)=RSDI
        IF(ITOHI .GT. 0) NTOHI=NTOHI+1
      ENDIF
      IF(ISISP.GT.0 .AND. ISFLAG.EQ.1) THEN
        IF((RSDI.LE.0.).AND.(SDIDEF(ISISP).LE.0.)) THEN
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
C TRANSLATE THE SITES AND KEEP
C
C  IF THE SITE SPECIES IS ONE FROM THE UT OR TT VARIANTS, USE AN
C  ALTERNATE METHOD OF TRANSLATING SITE INDEX VALUES
C----------
      IF(ISISP.EQ.6 .OR. ISISP.EQ.11 .OR. ISISP.EQ.12 .OR. ISISP.EQ.15)
     &THEN
        TEM = 30.
        IF(ISISP .GT. 0 .AND. SITEAR(ISISP) .GT. 0.0)TEM=SITEAR(ISISP)
        IF(TEM.LT.SILO(ISISP))TEM=SILO(ISISP)
        DO 20 I=1,MAXSP
        SI(I)=SILO(I)+(TEM-SILO(ISISP))/(SIHI(ISISP)-SILO(ISISP))
     &  *(SIHI(I)-SILO(I))
        IF(I .EQ. 5 )THEN
          SI(I)=SI(I)/3.281
          IF(SI(I).GT.28.)SI(I)=28.
        ENDIF
   20   CONTINUE
        GO TO 32
      ELSE
        CALL SICHG(ISISP,SITEAR(ISISP),SIAGE)
      ENDIF
C----------
C SI IS A VECTOR * MAXSP GIVING EQUIVALENT SITES FOR EACH SPECIES
C----------
      IF (DEBUG) WRITE(JOSTND,9003)ISISP,SITEAR(ISISP),SIAGE
 9003 FORMAT('MAIN REF SPECIES ',I5,' SITE INDEX ',F10.1/
     &  5X,11F6.1/5X,7F6.1)
      DO 30 ISPC=1,MAXSP
      AG=SIAGE(ISPC)
      SINDX=SITEAR(ISISP)
      CALL HTCALC(SINDX,ISISP,AG,SI(ISPC),JOSTND,DEBUG)
C----------
C CHANGE THE SITE INDEX OF HEMLOCK TO METRIC
C DELETED A REFERENCE TO SPECIES 6 AS WELL AS 5 SO HTCALC IS CONSISTENT
C WITH THE NEED TO DEMETRIC THE HEMLOCK SITE.  RALPH 1/24/89
C----------
      IF(ISPC .EQ. 5 )THEN
        SI(ISPC)=SI(ISPC)/3.281
        IF(SI(ISPC).GT.28.)SI(ISPC)=28.
      ENDIF
      IF(ISPC.EQ.6 .OR. ISPC.EQ.11 .OR. ISPC.EQ.12 .OR. ISPC.EQ.15)THEN
        TEM=SITEAR(ISISP)
        IF(TEM.LT.SILO(ISISP))TEM=SILO(ISISP)
        IF(SITEAR(ISPC).LE.0.0)
     &  SI(ISPC)=SILO(ISPC)+(TEM-SILO(ISISP))/(SIHI(ISISP)-SILO(ISISP))
     &  *(SIHI(ISPC)-SILO(ISPC))
      ENDIF
   30 CONTINUE
      IF (DEBUG) WRITE(JOSTND,9025) SINDX,ISISP,SI
 9025 FORMAT('SINDX ',F10.2,'SITE SP ',I5/' TRANSLATED SITES ',11F6.1/
     &18X,7F6.1)
C----------
C IF SITEAR() HAS NOT BEEN SET WITH SITECODE KEYWORD, LOAD
C IT WITH SITE VALUES TRANSLATED FROM SITE INDEX OF SITE SPECIES.
C----------
   32 CONTINUE
      DO 35 I=1,MAXSP
      IF(SITEAR(I) .EQ. 0.0) SITEAR(I)=SI(I)
   35 CONTINUE
C----------
C LOAD THE SDIDEF ARRAY
C----------
      K=ISISP
      IF(SDIDEF(K) .LE. 0.) K=JSISP
      DO 40 I=1,MAXSP
        IF(SDIDEF(I) .GT. 0.0) GO TO 40
        IF(BAMAX .GT. 0.) THEN
          SDIDEF(I)=BAMAX/(0.5454154*(PMSDIU/100.))
        ELSE
          SDIDEF(I) = SDIDEF(K)
        ENDIF
        IF(SDIDEF(I) .GT. FORMAX)THEN
          SDIDEF(I)=FORMAX
          NTOHI=NTOHI+1
        ENDIF
   40 CONTINUE
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
C  LOAD VOLUME EQUATION ARRAYS FOR ALL SPECIES
C----------
      INTFOR = KODFOR - (KODFOR/100)*100
      WRITE(FORST,'(I2)')INTFOR
      IF(INTFOR.LT.10)FORST(1:1)='0'
      IREGN = KODFOR/100
      DIST='  '
      PROD='  '
      VAR='BM'
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
