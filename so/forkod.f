      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C SO $Id$
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
C  601 = DESCHUTES
C  602 = FREMONT
C  620 = WINEMA
C  505 = KLAMATH
C  506 = LASSEN
C  509 = MODOC
C  511 = PLUMAS
C  701 = INDUSTRY LANDS
C  702 = INDUSTRY LANDS
C         **702 is new code introduced to eliminate
C           REDUNDANCY ACROSS VARIANTS. 702 WILL BE
C           MAPPED TO 701 FOR PROCESSING
C  514 = SHASTA-TRINITY (MAPPED TO KLAMATH)
C  799 = WARM SPRINGS INDIAN RESERVATION
C  ------------------------
C  RESERVATION PSUEDO CODES:
C  7711 = FORT MCDERMITT RESERVATION  (MAPPED TO 602 FREMONT)
C  7836 = FORT BIDWELL RESERVATION    (MAPPED TO 509 MODOC)
C  7838 = SUSANVILLE INDIAN RANCHERIA (MAPPED TO 506 LASSEN)
C  7844 = CEDARVILLE RANCHERIA        (MAPPED TO 509 MODOC)
C  ------------------------
      INTEGER JFOR(11),KFOR(11),NUMFOR,I
      DATA JFOR/601,602,620,505,506,509,511,701,514,799,
     &          702/
      DATA NUMFOR /11/
      DATA KFOR/11*1/
      LOGICAL FORFOUND/.FALSE./,USEIGL/.TRUE./

      SELECT CASE (KODFOR)
C       CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE
        CASE (7711)
          WRITE(JOSTND,61)
   61     FORMAT(T12,'FORT MCDERMITT RESERVATION (7711) BEING ',
     &    'MAPPED TO FREMONT (602) FOR FURTHER PROCESSING.')
          IFOR = 2
        CASE (7836)
          WRITE(JOSTND,62)
   62     FORMAT(T12,'FORT BIDWELL RESERVATION (7836) BEING MAPPED ',
     &    'TO MODOC (509) FOR FURTHER PROCESSING.')
          IFOR = 6
        CASE (7838)
          WRITE(JOSTND,63)
   63     FORMAT(T12,'SUSANVILLE INDIAN RANCHERIA (7838) BEING ',
     &    'MAPPED TO LASSEN (506) FOR FURTHER PROCESSING.')
          IFOR = 5
        CASE (7844)
          WRITE(JOSTND,64)
   64     FORMAT(T12,'CEDARVILLE RANCHERIA (7844) BEING MAPPED ',
     &    'TO MODOC (509) FOR FURTHER PROCESSING.')
          IFOR = 6
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
        CASE (9)
          WRITE(JOSTND,21)
   21     FORMAT(T12,'SHASTA NF (514) BEING MAPPED TO KLAMATH ',
     &    '(505) FOR FURTHER PROCESSING.')
          IFOR = 4
        CASE (11)
          WRITE(JOSTND,22)
   22     FORMAT(T12,'INDUSTRY LANDS (702) IS BEING MAPPED TO ',
     &    '(701) FOR FURTHER PROCESSING.')
          IFOR = 8
      END SELECT

C     SET THE IGL VARIABLE ONLY IF DEFAULT FOREST IS USED
C     GEOGRAPHIC LOCATION CODE: 1=NORTH, 2=CENTRAL, 3=SOUTH
C     USED TO SET SOME EQUATIONS IN REGENERATION AND PERHAPS
C     HEIGHT-DIAMETER IN DIFFERENT VARIANTS.
      IF (USEIGL) IGL = KFOR(IFOR)

      KODFOR=JFOR(IFOR)
      RETURN
      END
