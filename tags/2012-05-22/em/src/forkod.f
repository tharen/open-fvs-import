      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C  **FORKOD--EM  DATE OF LAST REVISION   03/26/09
C----------
C
C     TRANSLATES FOREST CODE INTO A SUBSCRIPT, IFOR, AND IF
C     KODFOR IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
COMMONS
C
C----------
C  NATIONAL FORESTS:
C  102 = BEAVERHEAD
C  108 = CUSTER
C  109 = DEERLODGE
C  111 = GALLATIN
C  112 = HELENA
C  115 = LEWIS AND CLARK
C
C  FOR THE GEOGRAPHIC LOCATOR (NI KFOR VALUE):
C  MAP THE HELENA, AND LEWIS AND CLARK, TO THE LOLO NF 
C  MAP ALL THE OTHERS TO THE BITTERROOT NF
C----------
      INTEGER JFOR(11),KFOR(11),NUMFOR,I
C----------
C  SPECIES ORDER:
C   1=WB,  2=WL,  3=DF,  4=LM,  5=LL,  6=RM,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=GA, 12=AS, 13=CW, 14=BA, 15=PW, 16=NC,
C  17=PB, 18=OS, 19=OH
C
C  SPECIES EXPANSION
C  LM USES IE LM (ORIGINALLY FROM TT VARIANT)
C  LL USES IE AF (ORIGINALLY FROM NI VARIANT)
C  RM USES IE JU (ORIGINALLY FROM UT VARIANT)
C  AS,PB USE IE AS (ORIGINALLY FROM UT VARIANT)
C  GA,CW,BA,PW,NC,OH USE IE CO (ORIGINALLY FROM CR VARIANT)
C----------
      DATA JFOR/102,108,109,111,112,115,5*0/, NUMFOR /6/
      DATA KFOR/1,1,1,1,1,1,5*1 /
C
      IF (KODFOR .EQ. 0) GOTO 30
      DO 10 I=1,NUMFOR
      IF (KODFOR .EQ. JFOR(I)) GOTO 20
   10 CONTINUE
      CALL ERRGRO (.TRUE.,3)
      WRITE(JOSTND,11) JFOR(IFOR)
   11 FORMAT(T13,'FOREST CODE USED FOR THIS PROJECTION IS',I4)
      GOTO 30
   20 CONTINUE
      IFOR=I
      IGL=KFOR(I)
C     IF(IFOR .EQ. 6) IFOR = 3
   30 CONTINUE
      KODFOR=JFOR(IFOR)
      RETURN
      END