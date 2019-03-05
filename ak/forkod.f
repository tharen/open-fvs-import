      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C AK $ID: FORKOD.F 2495 2018-09-13 14:44:54Z LANCEDAVID $
C----------
C
C     TRANSLATES FOREST CODE INTO A SUBSCRIPT, IFOR, AND IF
C     KODFOR IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
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
COMMONS
C
C----------
C  NATIONAL FORESTS:
C  1003 = TONGASS: CHATHAM AREA
C  1002 = TONGASS: STIKINE AREA
C  1005 = TONGASS: KETCHIKAN AREA
C   701 = BRITISH COLUMBIA / MAKAH INDIAN RESERVATION
C   703 = BRITISH COLUMBIA / MAKAH INDIAN RESERVATION
C         **703 IS NEW CODE INTRODUCED TO ELIMINATE
C           REDUNDANCY ACROSS VARIANTS. 703 WILL BE
C           MAPPED TO 701 FOR PROCESSING
C  1004 = CHUGACH
C  ------------------------
C  RESERVATION PSUEDO CODES:
C  7401 = ARCTIC VILLAGE ANVSA (MAPPED TO 1004 CHUGACH)
C  7402 = AHTNA                (MAPPED TO 1004 CHUGACH)
C  7403 = CHUGACH              (MAPPED TO 1004 CHUGACH)
C  7404 = COOK INLET           (MAPPED TO 1004 CHUGACH)
C  7405 = DOYON                (MAPPED TO 1004 CHUGACH)
C  7406 = KONGIGANAK ANVSA     (MAPPED TO 1004 CHUGACH)
C  7407 = NANWALEK ANVSA       (MAPPED TO 1004 CHUGACH)
C  7408 = SELAWIK ANVSA        (MAPPED TO 1004 CHUGACH)
C
C  8134 = ANNETTE ISLAND       (MAPPED TO 1002 TONGASS - STIKINE AREA)
C  8135 = MAKAH INDIAN RES.    (MAPPED TO 701  MAKAH INDIAN RES.)
C  8112 = QUILEUTE RES.        (MAPPED TO 701  MAKAH RESERVATION)

C----------
C  VARIABLE DECLARATIONS:
C----------
C
      INTEGER I,NUMFOR
C
      INTEGER JFOR(8),KFOR(8)
C
C----------
C  DATA STATEMENTS:
C----------
      DATA JFOR/1003,1002,1005,701,1004,703,2*0/, NUMFOR/6/
      DATA KFOR/1,1,1,1,1,1,1,1 /
      LOGICAL FORFOUND/.FALSE./,USEIGL/.TRUE./


      SELECT CASE (KODFOR)
C       CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE
        CASE (7401)
          WRITE(JOSTND,61)
   61     FORMAT(T12,'ARCTIC VILLAGE ANVSA (7401) BEING MAPPED TO ',
     &    'MAPPED TO CHUGACH (1004) FOR FURTHER PROCESSING.')
          IFOR = 5
        CASE (7402)
          WRITE(JOSTND,62)
   62     FORMAT(T12,'AHTNA (7402) BEING MAPPED TO ',
     &    'MAPPED TO CHUGACH (1004) FOR FURTHER PROCESSING.')
          IFOR = 5
        CASE (7403)
          WRITE(JOSTND,63)
   63     FORMAT(T12,'CHUGACH RES. (7403) BEING MAPPED TO ',
     &    'MAPPED TO CHUGACH (1004) FOR FURTHER PROCESSING.')
          IFOR = 5
        CASE (7404)
          WRITE(JOSTND,64)
   64     FORMAT(T12,'COOK INLET (7404) BEING ',
     &    'MAPPED TO CHUGACH (1004) FOR FURTHER PROCESSING.')
          IFOR = 5
        CASE (7405)
          WRITE(JOSTND,65)
   65     FORMAT(T12,'DOYON (7405) BEING ',
     &    'MAPPED TO CHUGACH (1004) FOR FURTHER PROCESSING.')
          IFOR = 5
        CASE (7406)
          WRITE(JOSTND,66)
   66     FORMAT(T12,'KONGIGANAK ANVSA (7406) BEING ',
     &    'MAPPED TO CHUGACH (1004) FOR FURTHER PROCESSING.')
          IFOR = 5
        CASE (7407)
          WRITE(JOSTND,67)
   67     FORMAT(T12,'NANWALEK ANVSA (7407) BEING ',
     &    'MAPPED TO CHUGACH (1004) FOR FURTHER PROCESSING.')
          IFOR = 5
        CASE (7408)
          WRITE(JOSTND,68)
   68     FORMAT(T12,'Selawik ANVSA (SEALASKA) (7408) BEING ',
     &    'MAPPED TO CHUGACH (1004) FOR FURTHER PROCESSING.')
          IFOR = 5
        CASE (8134)
          WRITE(JOSTND,70)
   70     FORMAT(T12,'ANNETTE ISLAND (8134) BEING MAPPED TO ',
     &    'TONGASS-STIKINE AREA (1002) FOR FURTHER PROCESSING.')
          IFOR = 5
        CASE (8135)
          WRITE(JOSTND,71)
   71     FORMAT(T12,'MAKAH INDIAN RES (8135) BEING MAPPED TO ',
     &    'MAKAH INDIAN RES (701) FOR FURTHER PROCESSING.')
          IFOR = 5
        CASE (8112)
          WRITE(JOSTND,72)
   72     FORMAT(T12,'QUILEUTE RES (8112) BEING MAPPED TO ',
     &    'MAKAH INDIAN RES (701) FOR FURTHER PROCESSING.')
          IFOR = 5

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
   11       FORMAT(T12,'FOREST CODE USED IN THIS PROJECTION IS ',I4)
            USEIGL = .FALSE.
          ENDIF

      END SELECT

C     FOREST MAPPING CORRECTION
      SELECT CASE (IFOR)

        CASE(5)
          WRITE(JOSTND,22)
   22     FORMAT(T12,'FOREST CODE 1004 BEING MAPPED TO 1003 FOR ',
     &    'THE GROWTH RELATIONSHIPS USED IN THIS PROJECTION')
          IFOR = 1
        CASE(6)
          WRITE(JOSTND,23)
   23     FORMAT(T12,'FOREST CODE 703 BEING MAPPED TO 701 FOR ',
     &    'THE GROWTH RELATIONSHIPS USED IN THIS PROJECTION')
          IFOR = 4


      END SELECT

C     SET THE IGL VARIABLE ONLY IF DEFAULT FOREST IS USED
C     GEOGRAPHIC LOCATION CODE: 1=NORTH, 2=CENTRAL, 3=SOUTH
C     USED TO SET SOME EQUATIONS IN REGENERATION AND PERHAPS
C     HEIGHT-DIAMETER IN DIFFERENT VARIANTS.
      IF (USEIGL) IGL = KFOR(IFOR)

      KODFOR=JFOR(IFOR)
      RETURN
      END
