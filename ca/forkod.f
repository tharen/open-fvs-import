      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C CA $Id$
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
      INTEGER JFOR(11),KFOR(11),NUMFOR
C  ------------------------
C  FORESTS IN THIS VARIANT:
C  505 = KLAMATH
C  506 = LASSEN
C  508 = MENDOCINO
C  511 = PLUMAS
C  514 = SHASTA-TRINITY
C  610 = ROGUE RIVER
C  611 = SISKIYOU
C  710 = ROSEBURG
C  711 = MEDFORD
C  712 = COOS BAY
C  518 = TRINITY (MAPPED TO SHASTA-TRINITY)
C  ------------------------
C  RESERVATION PSUEDO CODES:
C  7801 = BERRY CREEK OFF-RES. TRUST LAND    (MAPPED TO 511 PLUMAS)
C  7803 = COLD SPRINGS RANCHERIA             (MAPPED TO 511 PLUMAS)
C  7804 = COLUSA RANCHERIA                   (MAPPED TO 508 MENDOCINO)
C  7805 = CORTINA INDIAN RANCHERIA           (MAPPED TO 508 MENDOCINO)
C  7809 = GRINDSTONE INDIAN RANCHERIA        (MAPPED TO 508 MENDOCINO)
C  7811 = JACKSON RANCHERIA                  (MAPPED TO 511 PLUMAS)
C  7812 = CHICKEN RANCH OFF-RES. TRUST LAND  (MAPPED TO 511 PLUMAS)
C  7818 = PICAYUNE OFF-RES. TRUST LAND       (MAPPED TO 511 PLUMAS)
C  7822 = RUMSEY INDIAN RANCHERIA            (MAPPED TO 508 MENDOCINO)
C  7823 = SHINGLE SPRINGS RANCHERIA          (MAPPED TO 511 PLUMAS)
C  7826 = TABLE MOUNTAIN RANCHERIA           (MAPPED TO 511 PLUMAS)
C  7827 = TULE RIVER RESERVATION             (MAPPED TO 511 PLUMAS)
C  7829 = MOORETOWN OFF-RES. TRUST LAND      (MAPPED TO 511 PLUMAS)
C  7837 = PIT RIVER TRUST LAND               (MAPPED TO 506 LASSEN)
C  7842 = QUARTZ VALLEY RESERVATION          (MAPPED TO 505 KLAMATH)
C  7846 = KARUK OFF-RES. TRUST LAND          (MAPPED TO 505 KLAMATH)
C  7864 = SANTA ROSA RANCHERIA               (MAPPED TO 511 PLUMAS)
C  8104 = COW CREEK RESERVATION              (MAPPED TO 611 SISKIYOU)
C  ------------------------
      INTEGER I
      DATA JFOR/505,506,508,511,514,610,611,710,711,712,518/,NUMFOR /11/
      DATA KFOR/11*1/
      LOGICAL USEIGL, FORFOUND
      USEIGL = .TRUE.
      FORFOUND = .FALSE.


      SELECT CASE (KODFOR)
C       CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE
        CASE (7801)
          WRITE(JOSTND,70)
   70     FORMAT(/,'********',T12,'BERRY CREEK OFF-RES. TRUST LAND ',
     &    'RESERVATION (7801) BEING MAPPED TO PLUMAS NF (511) FOR ',
     &    'FURTHER PROCESSING.')
          IFOR = 4

        CASE (7803)
          WRITE(JOSTND,71)
   71     FORMAT(/,'********',T12,'COLD SPRINGS RANCHERIA (7803) ',
     &    'BEING MAPPED TO PLUMAS NF (511) FOR FURTHER PROCESSING.')
          IFOR = 4

        CASE (7804)
          WRITE(JOSTND,72)
   72     FORMAT(/,'********',T12,'COLUSA RANCHERIA (7804) BEING ',
     &    'MAPPED TO MENDOCINO NF (508) FOR FURTHER PROCESSING.')
          IFOR = 3

        CASE (7805)
          WRITE(JOSTND,73)
   73     FORMAT(/,'********',T12,'CORTINA INDIAN RANCHERIA (7805)',
     &    ' BEING MAPPED TO MENDOCINO NF (508) FOR FURTHER',
     &    ' PROCESSING.')
          IFOR = 3

        CASE (7809)
          WRITE(JOSTND,74)
   74     FORMAT(/,'********',T12,'GRINDSTONE INDIAN RANCHERIA ',
     &    '(7809) BEING MAPPED TO MENDOCINO NF (508) FOR ',
     &    'FURTHER PROCESSING.')
          IFOR = 3

        CASE (7811)
          WRITE(JOSTND,75)
   75     FORMAT(/,'********',T12,'JACKSON RANCHERIA (7811) BEING ',
     &    'MAPPED TO PLUMAS NF (511) FOR FURTHER PROCESSING.')
          IFOR = 4

        CASE (7812)
          WRITE(JOSTND,76)
   76     FORMAT(/,'********',T12,'CHICKEN RANCH OFF-RES. TRUST ',
     &    'LAND (7812) BEING MAPPED TO PLUMAS NF (511) FOR ',
     &    'FURTHER PROCESSING.')
          IFOR = 4

        CASE (7818)
          WRITE(JOSTND,77)
   77     FORMAT(/,'********',T12,'PICAYUNE OFF-RES. TRUST LAND ',
     &    '(7818) BEING MAPPED TO PLUMAS NF (511) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 4

        CASE (7822)
          WRITE(JOSTND,78)
   78     FORMAT(/,'********',T12,'RUMSEY INDIAN RANCHERIA (7822) ',
     &    'BEING MAPPEDTO MENDOCINO NF (508) FOR FURTHER PROCESSING.')
          IFOR = 3

        CASE (7823)
          WRITE(JOSTND,79)
   79     FORMAT(/,'********',T12,'SHINGLE SPRINGS RANCHERIA ',
     &    '(7823) BEING MAPPED TO PLUMAS NF (511) FOR FURTHER ',
     &    ' PROCESSING.')
          IFOR = 4

        CASE (7826)
          WRITE(JOSTND,80)
   80     FORMAT(/,'********',T12,'TABLE MOUNTAIN RANCHERIA (7826)',
     &    ' BEING MAPPED TO PLUMAS NF (511) FOR FURTHER PROCESSING.')
          IFOR = 4

        CASE (7827)
          WRITE(JOSTND,81)
   81     FORMAT(/,'********',T12,'TULE RIVER RESERVATION (7827) ',
     &    'BEING MAPPED TO PLUMAS NF (511) FOR FURTHER PROCESSING.')
          IFOR = 4

        CASE (7829)
          WRITE(JOSTND,82)
   82     FORMAT(/,'********',T12,'MOORETOWN OFF-RES. TRUST LAND ',
     &    '(7829) BEING MAPPED TO PLUMAS NF (511) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 4

        CASE (7837)
          WRITE(JOSTND,83)
   83     FORMAT(/,'********',T12,'PIT RIVER TRUST LAND (7837) ',
     &    'BEING MAPPED TO LASSEN NF (506) FOR FURTHER PROCESSING.')
          IFOR = 2

        CASE (7842)
          WRITE(JOSTND,84)
   84     FORMAT(/,'********',T12,'QUARTZ VALLEY RESERVATION ',
     &    '(7842) BEING MAPPED TO KLAMATH NF (505) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 1

        CASE (7846)
          WRITE(JOSTND,85)
   85     FORMAT(/,'********',T12,'KARUK OFF-RES. TRUST LAND ',
     &    '(7846) BEING MAPPED TO KLAMATH NF (505) FOR FURTHER ',
     &    'PROCESSING.')
          IFOR = 1

        CASE (7864)
          WRITE(JOSTND,86)
   86     FORMAT(/,'********',T12,'SANTA ROSA RANCHERIA (7864) ',
     &    'BEING MAPPED TO PLUMAS NF (511) FOR FURTHER PROCESSING.')
          IFOR = 4

        CASE (8104)
          WRITE(JOSTND,87)
   87     FORMAT(/,'********',T12,'COW CREEK RESERVATION (8104) ',
     &    'BEING MAPPED TO SISKIYOU NF (611) FOR FURTHER PROCESSING.')
          IFOR = 7
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
        CASE (11)
          WRITE(JOSTND,21)
   21     FORMAT(/,'********',T12,'TRINITY NF (518) BEING MAPPED TO ',
     &    'SHASTA-TRINITY (514) FOR FURTHER PROCESSING.')
          IFOR = 5
      END SELECT

C     SET THE IGL VARIABLE ONLY IF DEFAULT FOREST IS USED.
C     GEOGRAPHIC LOCATION CODE: 1=NORTH, 2=CENTRAL, 3=SOUTH
C     USED TO SET SOME EQUATIONS IN REGENERATION AND PERHAPS
C     HEIGHT-DIAMETER IN DIFFERENT VARIANTS.
      IF (USEIGL)IGL = KFOR(IFOR)

      KODFOR=JFOR(IFOR)
      RETURN
      END
