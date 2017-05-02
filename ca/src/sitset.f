      SUBROUTINE SITSET
      IMPLICIT NONE
C----------
C CA $Id$
C----------
C THIS SUBROUTINE LOADS THE SITEAR ARRAY WITH A SITE INDEX FOR EACH
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
C
      CHARACTER FORST*2,DIST*2,PROD*2,VAR*2,VOLEQ*10
      INTEGER IFIASP, ERRFLAG
      CHARACTER*4 ASPEC
      REAL R5ADJ(MAXSP),R5SDI(MAXSP),R6ADJ(MAXSP)
      REAL FORMAX,RSI,RSDI,HGUESS,ADJFAC
      INTEGER NTOHI,NSISET,NSDSET,I,JSISP,INDEX,KNTECO,ISEQ,NUM
      INTEGER ISFLAG,ITOHI,K,J,JJ,ISPC,INTFOR,IREGN
      LOGICAL DEBUG
C
C   SPECIES ORDER
C
C  1=PC  2=IC  3=RC  4=WF  5=RF  6=SH  7=DF  8=WH  9=MH 10=WB
C 11=KP 12=LP 13=CP 14=LM 15=JP 16=SP 17=WP 18=PP 19=MP 20=GP
C 21=JU 22=BR 23=GS 24=PY 25=OS 26=LO 27=CY 28=BL 29=EO 30=WO
C 31=BO 32=VO 33=IO 34=BM 35=BU 36=RA 37=MA 38=GC 39=DG 40=FL
C 41=WN 42=TO 43=SY 44=AS 45=CW 46=WI 47=CN 48=CL 49=OH
C----------
      DATA R5SDI /
     & 592., 576., 762., 634., 768., 768., 570., 682., 687., 621.,
     & 409., 679., 409., 409., 497., 561., 272., 446., 409., 409.,
     & 272., 412., 576., 576., 497., 667., 667., 214., 214., 440.,
     & 406., 440., 667., 629., 629., 441., 515., 406., 406., 441.,
     & 283., 785., 499., 562., 452., 447., 576., 785., 629./
C----------
C  IF THESE ADJUSTMENT FACTORS CHANGE, ALSO CHANGE THEM IN DUNN.
C----------
      DATA R5ADJ/
     & 0.90, 0.76, 0.90, 1.00, 1.00, 1.00, 1.00, 0.90, 0.90, 0.90,
     & 0.90, 0.90, 0.90, 0.90, 1.00, 1.00, 0.90, 1.00, 0.90, 0.90,
     & 0.76, 0.76, 1.00, 0.76, 0.90, 0.57, 0.57, 0.57, 0.57, 0.57,
     & 0.57, 0.57, 0.57, 0.57, 0.57, 0.57, 0.57, 0.57, 0.57, 0.57,
     & 0.57, 0.57, 0.57, 0.57, 0.57, 0.57, 0.57, 0.57, 0.57/
C
C THE ADJUSTMENT FACTORS IN R6ADJ ARE RELATIVE TO HANN-SCRIVANI
C DF SITE INDEX.
C
      DATA R6ADJ/
     & 0.90, 0.70, 0.80, 1.00, 1.00, 1.00, 1.00, 0.95, 0.90, 0.90,
     & 0.90, 0.90, 0.90, 0.90, 0.94, 1.00, 0.94, 0.94, 0.90, 0.90,
     & 0.76, 0.76, 1.00, 0.40, 0.76, 0.28, 0.42, 0.34, 0.28, 0.40,
     & 0.56, 0.76, 0.28, 0.76, 0.56, 0.76, 0.76, 0.76, 0.40, 0.70,
     & 0.40, 0.76, 0.76, 0.40, 0.76, 0.25, 0.25, 0.25, 0.56/
C
      DATA FORMAX/850./
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'SITSET',6,ICYC)
C----------
C  DETERMINE HOW MANY SITE VALUES AND SDI VALUES WERE SET VIA KEYWORD.
C----------
      NTOHI=0
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
      IF(DEBUG)WRITE(JOSTND,*)'IFOR,ICL5,PCOM = ',IFOR,ICL5,PCOM
      IF(IFOR .GE. 6) THEN
C----------
C       REGION 6 FOREST --- CALL **ECOCLS** WITH THE ECOCLASS CODE,
C       AND GET BACK THE DEFAULT SITE SPECIES, ALL SITE INDICIES,
C       AND DEFAULT SDI MAXIMUMS ASSOCIATED WITH THE ECOCLASS
C       IF THE ECOCLASS CODE HASN'T BEEN DEFAULTED, DEFAULT IT HERE.
C       (MAKE SURE THIS DEFAULT MATCHES THE ONE IN HABTYP)
C----------
        IF(ICL5 .EQ. 0) THEN
          ICL5 = 452
          PCOM = 'CWC221 '
          ITYPE=46
          KODTYP=452
        ENDIF
        JSISP=0
        INDEX=0
        KNTECO=0
   10   CALL ECOCLS (PCOM,ASPEC,RSDI,RSI,ISFLAG,NUM,INDEX,ISEQ)
        KNTECO=KNTECO+1
        IF(DEBUG)WRITE(JOSTND,*)'AFTER ECOCLS,PCOM,ASPEC,RSDI,RSI,',
     &  'ISFLAG,NUM,INDEX,ISEQ = ',PCOM,ASPEC,RSDI,RSI,ISFLAG,
     &  NUM,INDEX,ISEQ
C----------
C IF DEFAULT SDI IS OUT OF BOUNDS, RESET IT.
C----------
        ITOHI=0
        IF(RSDI .GT. FORMAX)THEN
          RSDI=FORMAX
          ITOHI=1
        ENDIF
C
C       LOOP THROUGH JSP ARRAY AND DETERMINE FVS SEQUENCE NUMBER FOR
C       THIS SPECIES
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
   25   CONTINUE
        IF(NUM.GT.1 .AND. KNTECO.LT.NUM) THEN
          INDEX=INDEX+1
          GO TO 10
        ENDIF
      ELSE
C----------
C REGION 5 FORESTS
C----------
        IF(ISISP .LE. 0) ISISP = 7
        IF(SITEAR(ISISP) .LE. 0.0) SITEAR(ISISP) = 80.
        HGUESS = SITEAR(ISISP)
        JSISP= ISISP
      ENDIF
C---------
C  ON THE CHANCE THAT A SITE SPECIES WAS NOT ENCOUNTERED IN **ECOCLS**
C  PROVIDE A REGION 6 GLOBAL DEFAULT.
C----------
      IF(IFOR .GE. 6) THEN
        IF(ISISP .LE. 0) ISISP = 7
        IF(SITEAR(ISISP) .LE. 0.0) SITEAR(ISISP) = 80.
C----------
C COMPUTE THE HANN-SCRIVANI DF SITE INDEX.
C----------
        HGUESS=SITEAR(ISISP)/R6ADJ(ISISP)
        IF(DEBUG)WRITE(JOSTND,*)'ISISP,SITEAR,R6ADJ,HGUESS= ',
     &  ISISP,SITEAR(ISISP),R6ADJ(ISISP),HGUESS
      ENDIF
C----------
C IF SITEAR() HAS NOT BEEN SET WITH SITECODE KEYWORD, LOAD
C IT WITH SITE VALUES TRANSLATED FROM SITE INDEX OF SITE SPECIES.
C----------
      DO 35 I=1,MAXSP
      IF(IFOR .GE. 6) THEN
        ADJFAC = R6ADJ(I)
      ELSE
        ADJFAC = R5ADJ(I)
      ENDIF
      IF(SITEAR(I) .EQ. 0.0) SITEAR(I)=HGUESS*ADJFAC
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
          IF(SDIDEF(I) .GT. FORMAX)THEN
            SDIDEF(I)=FORMAX
            NTOHI=NTOHI+1
          ENDIF
        ELSEIF(IFOR .GE. 6) THEN
          SDIDEF(I) = SDIDEF(K)
          IF(SDIDEF(I) .GT. FORMAX)THEN
            SDIDEF(I)=FORMAX
            NTOHI=NTOHI+1
          ENDIF
        ELSE
          SDIDEF(I) = R5SDI(I)
        ENDIF
   40 CONTINUE
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
      CASE(6:10)
        DO I=1,MAXSP
        IF(TOPD(I) .LE. 0.) TOPD(I) = 4.5
        IF(BFTOPD(I) .LE. 0.) BFTOPD(I) = 4.5
        END DO
      CASE DEFAULT
        DO I=1,MAXSP
        IF(TOPD(I) .LE. 0.) TOPD(I) = 6.
        IF(BFTOPD(I) .LE. 0.) BFTOPD(I) = 6.
        END DO
      END SELECT
C----------
C  SET METHB & METHC DEFAULTS.  DEFAULTS ARE INITIALIZED TO 999 IN
C  **GRINIT**.  IF THEY HAVE A DIFFERENT VALUE NOW, THEY WERE CHANGED
C  BY KEYWORD IN INITRE.  ONLY CHANGE THOSE NOT SET BY KEYWORD.
C  SET DEFAULTS TO USE NATCRS EQUATIONS.
C----------
      DO 150 ISPC=1,MAXSP
      IF(METHB(ISPC).EQ.999)METHB(ISPC)=6
      IF(METHC(ISPC).EQ.999)METHC(ISPC)=6
  150 CONTINUE
C----------
C  LOAD VOLUME EQUATION ARRAYS FOR ALL SPECIES
C----------
      INTFOR = KODFOR - (KODFOR/100)*100
      WRITE(FORST,'(I2)')INTFOR
      IF(INTFOR.LT.10)FORST(1:1)='0'
      IREGN = KODFOR/100
      DIST='  '
      PROD='  '
      VAR='CA'
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
