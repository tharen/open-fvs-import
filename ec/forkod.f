      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C EC $Id$
C----------
C     TRANSLATES FOREST CODE INTO A SUBSCRIPT, IFOR, AND IF
C     KODFOR IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C----------
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
C  ------------------------
C  NATIONAL FORESTS:
C  606 = MT HOOD
C  608 = OKANOGAN
C  617 = WENATCHEE
C  699 = OKANOGAN (TONASKET RD)
C  603 = GIFFORD PINCHOT (MAPPED TO WENATCHEE)
C        GP WAS IN THE AREA OF INTEREST BUT NO DATA WERE AVAILABLE;
C        THUS IT IS MAPPED TO THE WENATCHEE FOR PROCESSING.
C  613 = MT BAKER - SNOQUALMIE (MAPPED TO WENATCHEE)
C
C  NOTE: GIFFORD PINCHOT GETS IGL=2 AND MT BAKER/SNOQUALMIE GETS IGL=3.
C        THIS IS SO FOREST SPECIFIC HT-DBH EQNS CAN BE INDEXED IN
C        SUBROUTINE **HTDBH**.
C  ------------------------
C  RESERVATION PSUEDO CODES:

C  8106 = COLVILLE RESERVATION      (MAPPED TO 608 OKANOGAN)
C  8117 = UMATILLA RESERVATION      (MAPPED TO 606 MT. HOOD)
C  8130 = YAKAMA NATION RESERVATION (MAPPED TO 613 SNOQUALMIE)
C  8131 = SPOKANE RESERVATION       (MAPPED TO 617 WENATCHEE)

      INTEGER JFOR(7),KFOR(7),NUMFOR,I
      DATA JFOR/606,608,617,699,603,613, 0 /, NUMFOR /6/
      DATA KFOR/4*1,2,3,1/
      LOGICAL USEIGL, FORFOUND
      USEIGL = .TRUE.
      FORFOUND = .FALSE.
      

      SELECT CASE (KODFOR)

C       CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE
        CASE (8106)
          WRITE(JOSTND,60)
   60     FORMAT(/,'********',T12,'COLVILLE RESERVATION (8106) ',
     &    'BEING MAPPED TO OKANOGAN NF (608) FOR FURTHER PROCESSING.')
          IFOR = 2
        CASE (8117)
          WRITE(JOSTND,61)
   61     FORMAT(/,'********',T12,'UMATILLA RESERVATION (8117) ',
     &    'BEING MAPPED TO MT. HOOD NF (606) FOR FURTHER PROCESSING.')
          IFOR = 1
        CASE (8130)
          WRITE(JOSTND,63)
   63     FORMAT(/,'********',T12,'YAKAMA NATION RESERVATION ',
     &    '(8130) BEING MAPPED TO SNOQUALMIE NF (613) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 6
        CASE (8131)
          WRITE(JOSTND,64)
   64     FORMAT(/,'********',T12,'SPOKANE RESERVATION (8131) BEING',
     &    ' MAPPED TO WENATCHEE NF (617) FOR FURTHER PROCESSING.')
          IFOR = 3
C       END CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE

        CASE DEFAULT
        
C         CONFIRMS THAT KODFOR IS AN ACCEPTED FVS LOCATION CODE
C         FOR THIS VARIANT FOUND IN DATA ARRAY JFOR
          DO 10 I=1,NUMFOR
            IF (KODFOR .EQ. JFOR(I)) THEN
              IFOR = I
              FORFOUND = .TRUE.
              EXIT
            ENDIF
   10     CONTINUE        
          
C         LOCATION CODE ERROR TRAP       
          IF (.NOT. FORFOUND) THEN
            CALL ERRGRO (.TRUE.,3)
            WRITE(JOSTND,11) JFOR(IFOR)
   11       FORMAT(/,'********',T12,'FOREST CODE USED IN THIS ',
     &      'PROJECTION IS',I4)
            USEIGL = .FALSE.
          ENDIF

      END SELECT

C     FOREST MAPPING CORRECTION
      SELECT CASE (IFOR)
        CASE (5)
          WRITE(JOSTND,21)
   21     FORMAT(/,'********',T12,'GIFFORD PINCHOT NF (603) BEING ',
     &    'MAPPED TO WENATCHEE (617) FOR FURTHER PROCESSING.')
          I=3
          IFOR=3
          IGL=2
          USEIGL = .FALSE.
        CASE (6)
          WRITE(JOSTND,22)
   22     FORMAT(/,'********',T12,'MT BAKER-SNOQUALMIE NF (613) BEING ',
     &    'MAPPED TO WENATCHEE (617) FOR FURTHER PROCESSING.')
          IFOR=3
          IGL=3
          USEIGL = .FALSE.
      END SELECT


C     SET THE IGL VARIABLE ONLY IF DEFAULT FOREST IS USED
C     GEOGRAPHIC LOCATION CODE: 1=NORTH, 2=CENTRAL, 3=SOUTH
C     USED TO SET SOME EQUATIONS IN REGENERATION AND PERHAPS
C     HEIGHT-DIAMETER IN DIFFERENT VARIANTS.
      IF (USEIGL) IGL = KFOR(IFOR)

      KODFOR=JFOR(IFOR)
      RETURN
      END
