      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C WS $Id$
C----------
C
C     TRANSTLATES FOREST CODE INTO A SUBSCRIPT, IFOR, AND IF
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
C  503 = ELDORADO
C  511 = PLUMAS
C  513 = SEQUOIA
C  515 = SIERRA
C  516 = STANISLAUS
C  517 = TAHOE
C  501 = ANGELES (MAPPED TO SEQUOIA)
C  502 = CLEVELAND (MAPPED TO SEQUOIA)
C  504 = INYO (MAPPED TO SEQUOIA)
C  507 = LOS PADRES (MAPPED TO SEQUOIA)
C  512 = SAN BERNADINO (MAPPED TO SEQUOIA)
C  519 = LAKE TAHOE BASIN MGMT UNIT (MAPPED TO ELDORADO)
C  417 = TOIYABE (MAPPED TO STANISLAUS)
C  ------------------------
C  RESERVATION PSUEDO CODES:
C  7712 = Pyramid Lake Paiute Res.     (MAPPED TO 417 Toiyabe)
C  7713 = Reno-Sparks Indian Colony    (MAPPED TO 417 Toiyabe)
C  7715 = Walker River Res.            (MAPPED TO 417 Toiyabe)
C  7801 = Berry Creek Rancheria        (MAPPED TO 511 Plumas)
C  7808 = Enterprise Rancheria         (MAPPED TO 511 Plumas)
C  7814 = Fort Independence Res.       (MAPPED TO 504 Inyo)
C  7817 = North Fork Off-Res. TL       (MAPPED TO 515 Sierra)
C  7825 = Bishop Res.                  (MAPPED TO 504 Inyo)
C  7827 = Tule River Res.              (MAPPED TO 513 Sequoia)
C  7828 = Lone Pine Res.               (MAPPED TO 504 Inyo)
C  7832 = Tuolumne Rancheria           (MAPPED TO 516 Stanislaus)
C  7835 = Timbi-Sha Shoshone Res.      (MAPPED TO 504 Inyo)
C  7847 = Agua Caliente Indian Res.    (MAPPED TO 512 San Bernardino)
C  7849 = Cahuilla Res.                (MAPPED TO 512 San Bernardino)
C  7850 = Campo Indian Res.            (MAPPED TO 502 Cleveland)
C  7851 = Capitan Grande Res.          (MAPPED TO 502 Cleveland)
C  7852 = Barona Res.                  (MAPPED TO 502 Cleveland)
C  7853 = Ewiiaapaayp Res.             (MAPPED TO 502 Cleveland)
C  7854 = Inaja and Cosmit Res.        (MAPPED TO 502 Cleveland)
C  7855 = La Jolla Res.                (MAPPED TO 502 Cleveland)
C  7856 = Los Coyotes Res.             (MAPPED TO 502 Cleveland)
C  7857 = Manzanita Res.               (MAPPED TO 502 Cleveland)
C  7858 = Mesa Grande Res.             (MAPPED TO 502 Cleveland)
C  7859 = Morongo Res.                 (MAPPED TO 512 San Bernardino)
C  7860 = Pala Res.                    (MAPPED TO 502 Cleveland)
C  7861 = Pauma and Yuima Res.         (MAPPED TO 502 Cleveland)
C  7862 = Pechanga Res.                (MAPPED TO 502 Cleveland)
C  7863 = Santa Rosa Res.              (MAPPED TO 512 San Bernardino)
C  7865 = Santa Ysabel Res.            (MAPPED TO 502 Cleveland)
C  7866 = Soboba Res.                  (MAPPED TO 512 San Bernardino)
C  7867 = Viejas Res.                  (MAPPED TO 502 Cleveland)
C  ------------------------

      INTEGER JFOR(13),KFOR(13),NUMFOR,I,KFOR1,KDIS
C----------
C  DATA STATEMENTS:
C     KFOR IS USED IN THIS VARIANT TO SEND A GEOGRAPHIC LOCATOR TO
C     **DGF** FOR SETTING THE FORCON VARIABLE FOR THE ANGELES NF
C     THIS GETS SET AFTER 30 CONTINUE
C----------
      DATA JFOR/503,511,513,515,516,517,501,502,504,507,512,519,417/
      DATA NUMFOR/13/
      DATA KFOR/13*1/
      LOGICAL FORFOUND/.FALSE./,USEIGL/.TRUE./


      SELECT CASE (KODFOR)

C       ACCOUNT FOR REGION/FOREST/DISTRICT TO BE INPUT
        CASE (40000:)
          KFOR1=INT(REAL(KODFOR)/100.0)
          KDIS=KODFOR-KFOR1*100

          SELECT CASE (KFOR1)
            CASE (501,502,504,507,512,519,417)
              IFOR = MINLOC(ABS(JFOR - KFOR1), 1)
            CASE (503)
              IFOR = MINLOC(ABS(JFOR - KFOR1), 1)
              TLAT = 38.
              IF(KDIS .EQ. 53) TLAT=39.
            CASE (511)
              IFOR = MINLOC(ABS(JFOR - KFOR1), 1)
              TLAT = 39.
              IF(KDIS .LE. 52) TLAT=40.
            CASE (513)
              IFOR = MINLOC(ABS(JFOR - KFOR1), 1)
              TLAT = 35.
              IF(KDIS .LE. 52) TLAT=36.
            CASE (515)
              IFOR = MINLOC(ABS(JFOR - KFOR1), 1)
              TLAT = 37.
              IF(KDIS .EQ. 54) TLAT=36.
            CASE (516)
              IFOR = MINLOC(ABS(JFOR - KFOR1), 1)
              TLAT = 38.
              IF(KDIS .EQ. 54) TLAT=37.
            CASE (517)
              IFOR = MINLOC(ABS(JFOR - KFOR1), 1)
              TLAT = 39.
            CASE DEFAULT
              CALL ERRGRO (.TRUE.,3)
              WRITE(JOSTND,11) JFOR(IFOR)
   11         FORMAT(T12,'FOREST CODE USED IN THIS PROJECTION IS',I4)
              USEIGL = .FALSE.
          END SELECT

C       CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE
        CASE (7712)
          WRITE(JOSTND,61)
   61     FORMAT(T12,'PYRAMID LAKE PAIUTE RES. (7712) BEING ',
     &    'MAPPED TO TOIYABE NF (417) FOR FURTHER PROCESSING.')
          IFOR = 13
        CASE (7713)
          WRITE(JOSTND,62)
   62     FORMAT(T12,'RENO-SPARKS INDIAN COLONY (7713) BEING ',
     &    'MAPPED TO TOIYABE NF (417) FOR FURTHER PROCESSING.')
          IFOR = 13
        CASE (7715)
          WRITE(JOSTND,63)
   63     FORMAT(T12,'WALKER RIVER RES. (7715) BEING ',
     &    'MAPPED TO TOIYABE NF (417) FOR FURTHER PROCESSING.')
          IFOR = 13
        CASE (7801)
          WRITE(JOSTND,64)
   64     FORMAT(T12,'BERRY CREEK RANCHERIA (7801) BEING ',
     &    'MAPPED TO PLUMAS NF (511) FOR FURTHER PROCESSING.')
          IFOR = 2
        CASE (7808)
          WRITE(JOSTND,65)
   65     FORMAT(T12,'ENTERPRISE RANCHERIA (7808) BEING ',
     &    'MAPPED TO PLUMAS NF (511) FOR FURTHER PROCESSING.')
          IFOR = 2
        CASE (7814)
          WRITE(JOSTND,66)
   66     FORMAT(T12,'FORT INDEPENDENCE RES. (7814) BEING ',
     &    'MAPPED TO INYO NF (504) FOR FURTHER PROCESSING.')
          IFOR = 9
        CASE (7817)
          WRITE(JOSTND,67)
   67     FORMAT(T12,'NORTH FORK OFF-RES. TL (7817) BEING ',
     &    'MAPPED TO SIERRA NF (515) FOR FURTHER PROCESSING.')
          IFOR = 4
        CASE (7825)
          WRITE(JOSTND,68)
   68     FORMAT(T12,'BISHOP RES. (7825) BEING ',
     &    'MAPPED TO INYO NF (504) FOR FURTHER PROCESSING.')
          IFOR = 9
        CASE (7827)
          WRITE(JOSTND,69)
   69     FORMAT(T12,'TULE RIVER RES. (7827) BEING ',
     &    'MAPPED TO SEQUOIA NF (513) FOR FURTHER PROCESSING.')
          IFOR = 3
        CASE (7828)
          WRITE(JOSTND,70)
   70     FORMAT(T12,'LONE PINE RES. (7828) BEING ',
     &    'MAPPED TO INYO NF (504) FOR FURTHER PROCESSING.')
          IFOR = 9
        CASE (7832)
          WRITE(JOSTND,71)
   71     FORMAT(T12,'TUOLUMNE RANCHERIA (7832) BEING ',
     &    'MAPPED TO STANISLAUS NF (516) FOR FURTHER PROCESSING.')
          IFOR = 5
        CASE (7835)
          WRITE(JOSTND,72)
   72     FORMAT(T12,'TIMBI-SHA SHOSHONE RES. (7835) BEING ',
     &    'MAPPED TO INYO NF (504) FOR FURTHER PROCESSING.')
          IFOR = 9
        CASE (7847)
          WRITE(JOSTND,73)
   73     FORMAT(T12,'AGUA CALIENTE INDIAN RES. (7847) BEING ',
     &    'MAPPED TO SAN BERNARDINO NF (512) FOR FURTHER PROCESSING.')
          IFOR = 11
        CASE (7849)
          WRITE(JOSTND,74)
   74     FORMAT(T12,'CAHUILLA RES. (7849) BEING ',
     &    'MAPPED TO SAN BERNARDINO NF (512) FOR FURTHER PROCESSING.')
          IFOR = 11
        CASE (7850)
          WRITE(JOSTND,75)
   75     FORMAT(T12,'CAMPO INDIAN RES. (7850) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7851)
          WRITE(JOSTND,76)
   76     FORMAT(T12,'CAPITAN GRANDE RES. (7851) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7852)
          WRITE(JOSTND,77)
   77     FORMAT(T12,'BARONA RES. (7852) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7853)
          WRITE(JOSTND,78)
   78     FORMAT(T12,'EWIIAAPAAYP RES. (7853) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7854)
          WRITE(JOSTND,79)
   79     FORMAT(T12,'INAJA AND COSMIT RES. (7854) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7855)
          WRITE(JOSTND,80)
   80     FORMAT(T12,'LA JOLLA RES. (7855) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7856)
          WRITE(JOSTND,81)
   81     FORMAT(T12,'LOS COYOTES RES. (7856) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7857)
          WRITE(JOSTND,82)
   82     FORMAT(T12,'MANZANITA RES. (7857) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7858)
          WRITE(JOSTND,83)
   83     FORMAT(T12,'MESA GRANDE RES. (7858) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7859)
          WRITE(JOSTND,84)
   84     FORMAT(T12,'MORONGO RES. (7859) BEING MAPPED ',
     &    'TO SAN BERNARDINO NF (512) FOR FURTHER PROCESSING.')
          IFOR = 11
        CASE (7860)
          WRITE(JOSTND,85)
   85     FORMAT(T12,'PALA RES. (7860) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7861)
          WRITE(JOSTND,86)
   86     FORMAT(T12,'PAUMA AND YUIMA RES. (7861) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7862)
          WRITE(JOSTND,87)
   87     FORMAT(T12,'PECHANGA RES. (7862) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7863)
          WRITE(JOSTND,88)
   88     FORMAT(T12,'SANTA ROSA RES. (7863) BEING MAPPED ',
     &    'TO SAN BERNARDINO NF (512) FOR FURTHER PROCESSING.')
          IFOR = 11
        CASE (7865)
          WRITE(JOSTND,89)
   89     FORMAT(T12,'SANTA YSABEL RES. (7865) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
        CASE (7866)
          WRITE(JOSTND,90)
   90     FORMAT(T12,'SOBOBA RES. (7866) BEING MAPPED ',
     &    'TO SAN BERNARDINO NF (512) FOR FURTHER PROCESSING.')
          IFOR = 11
        CASE (7867)
          WRITE(JOSTND,91)
   91     FORMAT(T12,'VIEJAS RES. (7867) BEING ',
     &    'MAPPED TO CLEVELAND NF (502) FOR FURTHER PROCESSING.')
          IFOR = 8
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
            WRITE(JOSTND,13) JFOR(IFOR)
   13       FORMAT(T12,'FOREST CODE USED IN THIS PROJECTION IS',I4)
            USEIGL = .FALSE.
          ENDIF

      END SELECT


C     FOREST MAPPING CORRECTION
      SELECT CASE (IFOR)
        CASE (7)
          WRITE(JOSTND,21)
   21     FORMAT(T12,'ANGELES NF (501) BEING MAPPED TO SEQUOIA ',
     &    '(513) FOR FURTHER PROCESSING.')
          IFOR = 3
        CASE (8)
          WRITE(JOSTND,22)
   22     FORMAT(T12,'CLEVELAND NF (502) BEING MAPPED TO SEQUOIA ',
     &    '(513) FOR FURTHER PROCESSING.')
          IFOR = 3
        CASE (9)
          WRITE(JOSTND,23)
   23     FORMAT(T12,'INYO NF (504) BEING MAPPED TO SEQUOIA ',
     &    '(513) FOR FURTHER PROCESSING.')
          IFOR = 3
        CASE (10)
          WRITE(JOSTND,24)
   24     FORMAT(T12,'LOS PADRES NF (507) BEING MAPPED TO SEQUOIA ',
     &    '(513) FOR FURTHER PROCESSING.')
          IFOR = 3
        CASE (11)
          WRITE(JOSTND,25)
   25     FORMAT(T12,'SAN BERNARDINO NF (512) BEING MAPPED TO ',
     &    'SEQUOIA (513) FOR FURTHER PROCESSING.')
          IFOR = 3
        CASE (12)
          WRITE(JOSTND,26)
   26     FORMAT(T12,'LAKE TAHOE BASIN MGMT UNIT (519) BEING ',
     &    'MAPPED TO ELDORADO (503) FOR FURTHER PROCESSING.')
          IFOR = 1
        CASE (13)
          WRITE(JOSTND,27)
   27     FORMAT(T12,'TOIYABE NF (417) BEING MAPPED TO STANISLAUS ',
     &    '(516) FOR FURTHER PROCESSING.')
          IFOR = 5
      END SELECT

C     SET THE IGL VARIABLE ONLY IF DEFAULT FOREST IS USED
C     GEOGRAPHIC LOCATION CODE: 1=NORTH, 2=CENTRAL, 3=SOUTH
C     USED TO SET SOME EQUATIONS IN REGENERATION AND PERHAPS
C     HEIGHT-DIAMETER IN DIFFERENT VARIANTS.
      IF (USEIGL .AND. IFOR .EQ. 7) THEN
        IGL = 2
      ELSEIF (USEIGL) THEN
        IGL = KFOR(IFOR)
      ENDIF

      KODFOR=JFOR(IFOR)
      RETURN
      END