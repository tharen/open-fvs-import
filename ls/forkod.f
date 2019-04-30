      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C LS $Id$
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
C  902 = CHEQUAMEGON
C  903 = CHIPPEWA
C  904 = HURON-MANISTEE
C  906 = NICOLET
C  907 = OTTAWA
C  909 = SUPERIOR
C  910 = HIAWATHA
C  913 = CHEQUAMEGON-NICOLET
C  924 = MANISTEE (MAP TO HURON-MANISTEE)
C  ------------------------                                            
C  RESERVATION PSUEDO CODES:
C  7107 = LAKE TRAVERSE RESERVATION       (MAPPED TO 903 CHIPPEWA)
C  7109 = TURTLE MOUNTAIN OFF-RES. TL     (MAPPED TO 903 CHIPPEWA)
C  7501 = UPPER SIOUX COMMUNITY           (MAPPED TO 903 CHIPPEWA)
C  7502 = LOWER SIOUX INDIAN COMMUNITY    (MAPPED TO 903 CHIPPEWA)
C  7506 = PRAIRIE ISLAND OFF-RES. TL      (MAPPED TO 902 CHEQUAMEGON)
C  7507 = SHAKOPEE MDEWAKANTON SIOUX      (MAPPED TO 903 CHIPPEWA)
C  7508 = MENOMINEE RESERVATION           (MAPPED TO 906 NICOLET)
C  7510 = RED LAKE RESERVATION            (MAPPED TO 903 CHIPPEWA)
C  7511 = BOIS FORTE RESERVATION          (MAPPED TO 909 SUPERIOR)
C  7512 = FOND DU LAC RESERVATION         (MAPPED TO 909 SUPERIOR)
C  7513 = GRAND PORTAGE RESERVATION       (MAPPED TO 909 SUPERIOR)
C  7514 = LEECH LAKE RESERVATION          (MAPPED TO 903 CHIPPEWA)
C  7515 = WHITE EARTH RESERVATION         (MAPPED TO 903 CHIPPEWA)
C  7516 = MILLE LACS RESERVATION          (MAPPED TO 903 CHIPPEWA)
C  7517 = BAD RIVER RESERVATION           (MAPPED TO 902 CHEQUAMEGON)
C  7518 = LAC COURTE OREILLES RES.        (MAPPED TO 902 CHEQUAMEGON)
C  7519 = LAC DU FLAMBEAU RESERVATION     (MAPPED TO 902 CHEQUAMEGON)
C  7520 = ONEIDA (WI) RESERVATION         (MAPPED TO 906 NICOLET)
C  7521 = FOREST COUNTY POTAWATOMI COMM.  (MAPPED TO 906 NICOLET)
C  7522 = POTOWATOMI  * mystery 0F50495 * (MAPPED TO 906 NICOLET)
C  7523 = RED CLIFF RESERVATION           (MAPPED TO 902 CHEQUAMEGON)
C  7524 = ST. CROIX RESERVATION           (MAPPED TO 902 CHEQUAMEGON)
C  7525 = SOKAOGON CHIPPEWA (MOLE LAKE)   (MAPPED TO 906 NICOLET)
C  7526 = STOCKBRIDGE MUNSEE COMMUNITY    (MAPPED TO 906 NICOLET)
C  7527 = GRAND TRAVERSE OFF-RES. TL      (MAPPED TO 924 MANISTEE)
C  7528 = SAULT STE. MARIE OFF-RES. TL    (MAPPED TO 910 HIAWATHA)
C  7529 = BAY MILLS RESERVATION           (MAPPED TO 910 HIAWATHA)
C  7530 = HANNAHVILLE INDIAN COMMUNITY    (MAPPED TO 910 HIAWATHA)
C  7531 = ISABELLA RESERVATION            (MAPPED TO 924 MANISTEE)
C  7532 = L'ANSE RESERVATION              (MAPPED TO 907 OTTAWA)
C  7533 = ONTONAGON RESERVATION           (MAPPED TO 907 OTTAWA)
C  7534 = LAC VIEUX DESERT RESERVATION    (MAPPED TO 907 OTTAWA)
C  7535 = HURON POTAWATOMI                (MAPPED TO 924 MANISTEE)
C  7536 = LITTLE RIVER OFF-RES. TL        (MAPPED TO 924 MANISTEE)
C  7537 = LITTLE TRAVERSE BAY RESERVATION (MAPPED TO 910 HIAWATHA)

      INTEGER JFOR(9),KFOR(9),NUMFOR,I
      DATA JFOR/902,903,904,906,907,909,910,913,924/
      DATA NUMFOR/9/
      DATA KFOR/9*1/
      LOGICAL FORFOUND/.FALSE./,USEIGL/.TRUE./


      SELECT CASE (KODFOR)
        
C       CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE
        CASE (7107)          
          WRITE(JOSTND,55)  
   55     FORMAT(/,'********',T12,'LAKE TRAVERSE RESERVATION (7107) ',     
     &    'BEING MAPPED TO CHIPPEWA NF (903) FOR FURTHER PROCESSING.')          
          IFOR = 2           
        CASE (7109)          
          WRITE(JOSTND,56)   
   56     FORMAT(/,'********',T12,'TURTLE MOUNTAIN OFF-RES. TL ',     
     &    '(7109) BEING MAPPED TO CHIPPEWA NF (903) FOR FURTHER ',
     &    'PROCESSING.')  
          IFOR = 2           
        CASE (7501)
          WRITE(JOSTND,57)   
   57     FORMAT(/,'********',T12,'UPPER SIOUX COMMUNITY (7501) ',     
     &    'BEING MAPPED TO CHIPPEWA (903) FOR FURTHER PROCESSING.')
          IFOR = 2           
        CASE (7502)
          WRITE(JOSTND,58)   
   58     FORMAT(/,'********',T12,'LOWER SIOUX INDIAN COMMUNITY ',     
     &    '(7502) BEING MAPPED TO CHIPPEWA NF (903) FOR FURTHER ',
     &    'PROCESSING.')          
          IFOR = 2           
        CASE (7506)
          WRITE(JOSTND,59)   
   59     FORMAT(/,'********',T12,'PRAIRIE ISLAND OFF-RES. TL ',     
     &    '(7506) BEING MAPPED TO CHEQUAMEGON (902) FOR FURTHER ',
     &    'PROCESSING.')          
          IFOR = 1           
        CASE (7507)
          WRITE(JOSTND,60)   
   60     FORMAT(/,'********',T12,'SHAKOPEE MDEWAKANTON SIOUX (7507) ',     
     &    'BEING MAPPED TO CHIPPEWA NF (903) FOR FURTHER PROCESSING.')          
          IFOR = 2       
        CASE (7508)
          WRITE(JOSTND,61)   
   61     FORMAT(/,'********',T12,'MENOMINEE RESERVATION (7508) BEING ',     
     &    'MAPPED TO NICOLET NF (906) FOR FURTHER PROCESSING.')
          IFOR = 4        
        CASE (7510)
          WRITE(JOSTND,62)   
   62     FORMAT(/,'********',T12,'RED LAKE RESERVATION (7510) BEING ',     
     &    'MAPPED TO CHIPPEWA NF (903) FOR FURTHER PROCESSING.')          
          IFOR = 2       
        CASE (7511)
          WRITE(JOSTND,63)   
   63     FORMAT(/,'********',T12,'BOIS FORTE RESERVATION (7511) BEING',     
     &    ' MAPPED TO SUPERIOR NF (909) FOR FURTHER PROCESSING.')           
          IFOR = 6       
        CASE (7512)
          WRITE(JOSTND,64)   
   64     FORMAT(/,'********',T12,'FOND DU LAC RESERVATION (7512) ',     
     &    'BEING MAPPED TO SUPERIOR NF (909) FOR FURTHER PROCESSING.')          
          IFOR = 6       
        CASE (7513)
          WRITE(JOSTND,65)   
   65     FORMAT(/,'********',T12,'GRAND PORTAGE RESERVATION (7513) ',     
     &    ' BEING MAPPED TO SUPERIOR NF (909) FOR FURTHER PROCESSING.')          
          IFOR = 6       
        CASE (7514)
          WRITE(JOSTND,66)   
   66     FORMAT(/,'********',T12,'LEECH LAKE RESERVATION (7514) BEING',     
     &    ' MAPPED TO CHIPPEWA NF (903) FOR FURTHER PROCESSING.')          
          IFOR = 2       
        CASE (7515)
          WRITE(JOSTND,67)   
   67     FORMAT(/,'********',T12,'WHITE EARTH RESERVATION (7515) ',     
     &    'BEING MAPPED TO CHIPPEWA NF (903) FOR FURTHER PROCESSING.')          
          IFOR = 2       
        CASE (7516)
          WRITE(JOSTND,68)   
   68     FORMAT(/,'********',T12,'MILLE LACS RESERVATION (7516) BEING',     
     &    ' MAPPED TO CHIPPEWA NF (903) FOR FURTHER PROCESSING.')          
          IFOR = 2       
        CASE (7517)
          WRITE(JOSTND,69)   
   69     FORMAT(/,'********',T12,'BAD RIVER RESERVATION (7517) BEING ',     
     &    'MAPPED TO CHEQUAMEGON NF (902) FOR FURTHER PROCESSING.')          
          IFOR = 1    
        CASE (7518)
          WRITE(JOSTND,70)   
   70     FORMAT(/,'********',T12,'LAC COURTE OREILLES RES. (7518) ',     
     &    'BEING MAPPED TO CHEQUAMEGON NF (902) FOR FURTHER ',
     &    'PROCESSING.')          
          IFOR = 1    
        CASE (7519)
          WRITE(JOSTND,71)   
   71     FORMAT(/,'********',T12,'LAC DU FLAMBEAU RESERVATION (7519) ',     
     &    'BEING MAPPED TO CHEQUAMEGON NF (902) FOR FURTHER ',
     &    'PROCESSING.')          
          IFOR = 1   
        CASE (7520)
          WRITE(JOSTND,72)   
   72     FORMAT(/,'********',T12,'ONEIDA (WI) RESERVATION (7520) ',     
     &    'BEING MAPPED TO NICOLET NF (906) FOR FURTHER PROCESSING.')          
          IFOR = 4        
        CASE (7521)
          WRITE(JOSTND,73)   
   73     FORMAT(/,'********',T12,'FOREST COUNTY POTAWATOMI COMM. ',     
     &    '(7521) BEING MAPPED TO NICOLET NF (906) FOR FURTHER ',
     &    'PROCESSING.')          
          IFOR = 4        
        CASE (7522)
          WRITE(JOSTND,89)   
   89     FORMAT(/,'********',T12,'POTAWATOMI (7522) BEING ',     
     &    'MAPPED TO NICOLET NF (906) FOR FURTHER PROCESSING.')          
          IFOR = 4
        CASE (7523)
          WRITE(JOSTND,74)   
   74     FORMAT(/,'********',T12,'RED CLIFF RESERVATION (7523) BEING ',     
     &    'MAPPED TO CHEQUAMEGON NF (902) FOR FURTHER PROCESSING.')          
          IFOR = 1    
        CASE (7524)
          WRITE(JOSTND,75)   
   75     FORMAT(/,'********',T12,'ST. CROIX RESERVATION (7524) BEING ',     
     &    'MAPPED TO CHEQUAMEGON NF (902) FOR FURTHER PROCESSING.')          
          IFOR = 1    
        CASE (7525)
          WRITE(JOSTND,76)   
   76     FORMAT(/,'********',T12,'SOKAOGON CHIPPEWA COMMUNITY (7525) ',     
     &    'MAPPED TO NICOLET NF (906) FOR FURTHER PROCESSING.')          
          IFOR = 4        
        CASE (7526)
          WRITE(JOSTND,77)   
   77     FORMAT(/,'********',T12,'STOCKBRIDGE MUNSEE COMMUNITY (7526)',     
     &    ' BEING MAPPED TO NICOLET NF (906) FOR FURTHER PROCESSING.')          
          IFOR = 4        
        CASE (7527)
          WRITE(JOSTND,78)   
   78     FORMAT(/,'********',T12,'GRAND TRAVERSE OFF-RES. TL (7527) ',     
     &    'BEING MAPPED TO MANISTEE NF (924) FOR FURTHER PROCESSING.')          
          IFOR = 9       
        CASE (7528)
          WRITE(JOSTND,79)   
   79     FORMAT(/,'********',T12,'SAULT STE. MARIE OFF-RES. TL (7528)',     
     &    ' BEING MAPPED TO HIAWATHA NF (910) FOR FURTHER PROCESSING.')          
          IFOR = 7       
        CASE (7529)
          WRITE(JOSTND,80)   
   80     FORMAT(/,'********',T12,'BAY MILLS RESERVATION (7529) BEING ',     
     &    'MAPPED TO HIAWATHA NF (910) FOR FURTHER PROCESSING.')          
          IFOR = 7       
        CASE (7530)
          WRITE(JOSTND,81)   
   81     FORMAT(/,'********',T12,'HANNAHVILLE INDIAN COMMUNITY (7530)',     
     &    ' BEING MAPPED TO HIAWATHA NF (910) FOR FURTHER PROCESSING.')          
          IFOR = 7       
        CASE (7531)
          WRITE(JOSTND,82)   
   82     FORMAT(/,'********',T12,'ISABELLA RESERVATION (7531) BEING ',     
     &    'MAPPED TO MANISTEE NF (924) FOR FURTHER PROCESSING.')          
          IFOR = 9       
        CASE (7532)
          WRITE(JOSTND,83)   
   83     FORMAT(/,'********',T12,'L''ANSE RESERVATION (7532) BEING ',     
     &    'MAPPED TO OTTAWA NF (907) FOR FURTHER PROCESSING.')          
          IFOR = 5         
        CASE (7533)
          WRITE(JOSTND,84)   
   84     FORMAT(/,'********',T12,'ONTONAGON RESERVATION (7533) ',     
     &    'BEING MAPPED TO OTTAWA NF (907) FOR FURTHER PROCESSING.')          
          IFOR = 5         
        CASE (7534)
          WRITE(JOSTND,85)   
   85     FORMAT(/,'********',T12,'LAC VIEUX DESERT RESERVATION (7534)',     
     &    ' BEING MAPPED TO OTTAWA NF (907) FOR FURTHER PROCESSING.')          
          IFOR = 5  
        CASE (7535)
          WRITE(JOSTND,86)   
   86     FORMAT(/,'********',T12,'HURON POTAWATOMI (7535) BEING ',     
     &    'MAPPED TO MANISTEE NF (924) FOR FURTHER PROCESSING.')          
          IFOR = 9            
        CASE (7536)
          WRITE(JOSTND,87)   
   87     FORMAT(/,'********',T12,'LITTLE RIVER OFF-RES. TL (7536) ',     
     &    'BEING MAPPED TO MANISTEE NF (924) FOR FURTHER PROCESSING.')          
          IFOR = 9       
        CASE (7537)
          WRITE(JOSTND,88)   
   88     FORMAT(/,'********',T12,'LITTLE TRAVERSE BAY RESERVATION ',     
     &    '(7537) BEING MAPPED TO HIAWATHA NF (910) FOR FURTHER ',
     &    'PROCESSING.')          
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


C----------
C  SET DEFAULT TLAT, TLONG, AND ELEVATION VALUES, BY FOREST
C----------
      SELECT CASE(IFOR) 
        CASE(1,4,8)
          IF(TLAT.EQ.0) TLAT=45.93
          IF(TLONG.EQ.0)TLONG=90.44
          IF(ELEV.EQ.0) ELEV=15.
        CASE(2)
          IF(TLAT.EQ.0) TLAT=47.38
          IF(TLONG.EQ.0)TLONG=94.60
          IF(ELEV.EQ.0) ELEV=13.
        CASE(3)
          IF(TLAT.EQ.0) TLAT=44.25
          IF(TLONG.EQ.0)TLONG=85.40
          IF(ELEV.EQ.0) ELEV=9.
        CASE(5)
          IF(TLAT.EQ.0) TLAT=46.45
          IF(TLONG.EQ.0)TLONG=90.17
          IF(ELEV.EQ.0) ELEV=14.
        CASE(6)
          IF(TLAT.EQ.0) TLAT=46.78
          IF(TLONG.EQ.0)TLONG=92.11
          IF(ELEV.EQ.0) ELEV=16.
        CASE(7)
          IF(TLAT.EQ.0) TLAT=45.75
          IF(TLONG.EQ.0)TLONG=87.06
          IF(ELEV.EQ.0) ELEV=8.
      END SELECT
       
C     SET THE IGL VARIABLE ONLY IF DEFAULT FOREST IS USED
C     GEOGRAPHIC LOCATION CODE: 1=NORTH, 2=CENTRAL, 3=SOUTH
C     USED TO SET SOME EQUATIONS IN REGENERATION AND PERHAPS 
C     HEIGHT-DIAMETER IN DIFFERENT VARIANTS.
			IF (USEIGL) IGL = KFOR(IFOR)

      KODFOR=JFOR(IFOR)
      RETURN
      END          
