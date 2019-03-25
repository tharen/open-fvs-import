      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C WC $Id$
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
C  ------------------------
C  NATIONAL FORESTS:
C  603 = GIFFORD PINCHOT
C  605 = MT BAKER - SNOQUALMIE
C  606 = MT HOOD
C  610 = ROGUE RIVER
C  615 = UMPQUA
C  618 = WILLAMETTE
C  708 = BLM SALEM ADU
C  709 = BLM EUGENE ADU
C  710 = BLM ROSEBURG ADU
C  711 = BLM MEDFORD ADU
C  613 = MT BAKER-SNOQUALMIE (MAP TO MT BAKER-SNOQUALMIE)
C  ------------------------
C  RESERVATION PSUEDO CODES:
C  8118 = WARM SPRINGS RESERVATION  (MAPPED TO 606 MT. HOOD)
C  8124 = SAUK-SUIATTLE RESERVATION (MAPPED TO 605 MT. BAKER)
C  8130 = YAKAMA NATION RESERVATION (MAPPED TO 603 GIFFORD PINCHOT)
C  ------------------------

      INTEGER JFOR(11),KFOR(11),NUMFOR,I
      DATA JFOR/603,605,606,610,615,618,708,709,710,711,613/, NUMFOR/11/
      DATA KFOR/ 11*1 /
      LOGICAL FORFOUND/.FALSE./,USEIGL/.TRUE./


      SELECT CASE (KODFOR)

C       CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE
        CASE (8118)
          WRITE(JOSTND,61)
   61     FORMAT(T12,'WARM SPRINGS RESERVATION (8118) BEING ',
     &    'MAPPED TO MT. HOOD NF (606) FOR FURTHER PROCESSING.')
          IFOR = 3
        CASE (8124)
          WRITE(JOSTND,62)
   62     FORMAT(T12,'SAUK-SUIATTLE RESERVATION (8124) BEING ',
     &    'MAPPED TO MT. BAKER NF (605) FOR FURTHER PROCESSING.')
          IFOR = 2
        CASE (8130)
          WRITE(JOSTND,63)
   63     FORMAT(T12,'YAKAMA NATION RESERVATION (8130) BEING MAPPED ',
     &    'TO GIFFORD PINCHOT NF (603) FOR FURTHER PROCESSING.')
          IFOR = 1
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
   11       FORMAT(T12,'FOREST CODE USED IN THIS PROJECTION IS',I4)
            USEIGL = .FALSE.
          ENDIF

      END SELECT


C     FOREST MAPPING CORRECTION
      SELECT CASE (IFOR)
        CASE (11)
          WRITE(JOSTND,21)
   21     FORMAT(T12,'MT BAKER-SNOQUALMIE NF (613) BEING MAPPED TO ',
     &    'MT BAKER-SNOQUALMIE (605) FOR FURTHER PROCESSING.')
          IFOR = 2
      END SELECT

C     SET THE IGL VARIABLE ONLY IF DEFAULT FOREST IS USED
C     GEOGRAPHIC LOCATION CODE: 1=NORTH, 2=CENTRAL, 3=SOUTH
C     USED TO SET SOME EQUATIONS IN REGENERATION AND PERHAPS
C     HEIGHT-DIAMETER IN DIFFERENT VARIANTS.
      IF (USEIGL) IGL = KFOR(IFOR)

      KODFOR=JFOR(IFOR)
      RETURN
      END