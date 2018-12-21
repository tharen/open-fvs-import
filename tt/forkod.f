      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C TT $Id$
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
C  403 = BRIDGER
C  405 = CARIBOU
C  415 = TARGHEE
C  416 = TETON
C  ------------------------
C  7306 = WIND RIVER RESERVATION  (MAPPED TO 403 BRIDGER)
C  8107 = FORT HALL RESERVATION   (MAPPED TO 405 CARIBOU)
C  ------------------------

      INTEGER JFOR(4),KFOR(4),NUMFOR,I
      DATA JFOR/403,405,415,416/,NUMFOR/4/
      LOGICAL FORFOUND/.FALSE./,USEIGL/.TRUE./


      SELECT CASE (KODFOR)
C       CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE
        CASE (7306)
          WRITE(JOSTND,61)
   61     FORMAT(T12,'WIND RIVER RESERVATION (7306) BEING ',
     &    'MAPPED TO BRIDGER NF (403) FOR FURTHER PROCESSING.')
          IFOR = 1
        CASE (8107)
          WRITE(JOSTND,62)
   62     FORMAT(T12,'FORT HALL RESERVATION (8107) BEING ',
     &    'MAPPED TO CARIBOU NF (405) FOR FURTHER PROCESSING.')
          IFOR = 2
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
      
C     FOREST MAPPING CORRECTION  {N/A FOR THIS VARIANT}
C      SELECT CASE (IFOR)
C      END SELECT

C     SET THE IGL VARIABLE ONLY IF DEFAULT FOREST IS USED
C     GEOGRAPHIC LOCATION CODE: 1=NORTH, 2=CENTRAL, 3=SOUTH
C     USED TO SET SOME EQUATIONS IN REGENERATION AND PERHAPS
C     HEIGHT-DIAMETER IN DIFFERENT VARIANTS.
      IF (USEIGL) IGL = KFOR(IFOR)

      KODFOR=JFOR(IFOR)
      RETURN
      END
