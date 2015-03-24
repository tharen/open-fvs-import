      SUBROUTINE HTDBH (IFOR,ISPC,D,H,MODE)
      IMPLICIT NONE
C----------
C  **HTDBH--NC    DATE OF LAST REVISION:  02/17/09
C----------
C  THIS SUBROUTINE CONTAINS THE DEFAULT HEIGHT-DIAMETER RELATIONSHIPS
C  FROM THE INVENTORY DATA.  IT IS CALLED FROM CRATET TO DUB MISSING
C  HEIGHTS, AND FROM REGENT TO ESTIMATE DIAMETERS (PROVIDED IN BOTH
C  CASES THAT LHTDRG IS SET TO .TRUE.).
C
C  DEFINITION OF VARIABLES:
C         D = DIAMETER AT BREAST HEIGHT
C         H = TOTAL TREE HEIGHT (STUMP TO TIP)
C      IFOR = FOREST CODE
C             1 IS KLAMATH (505)
C             2 IS SIX RIVERS (510)
C             3 IS TRINITY (514)
C             4 IS SISKIYOU (611)
C             5 IS HOOPA INDIAN RESERVATION (705)
C             6 IS SIMPSON TIMBER (800)
C             7 IS BLM COOS BAY ADMIN UNIT (712)
C      MODE = MODE OF OPERATING THIS SUBROUTINE
C             0 IF DIAMETER IS PROVIDED AND HEIGHT IS DESIRED
C             1 IF HEIGHT IS PROVIDED AND DIAMETER IS DESIRED
C----------
C
      REAL SISKIY(11,3),D,H,P2,P3,P4,HAT3
      INTEGER MODE,ISPC,IFOR
C
C SPECIES ORDER IN NC VARIANT:
C    1 =          OTHER CONIFERS            USE DOUGLAS-FIR
C    2 = PILA     SUGAR PINE                PINUS LAMBERTIANA
C    3 = PSME     DOUGLAS-FIR               PSEUDOTSUGA MENZIESII
C    4 = ABCO     WHITE FIR                 ABIES CONCOLOR
C    5 = ARME     MADRONE                   ARBUTUS MENZIESII
C    6 = LIDE     INCENSE CEDAR             LIBOCEDRUS DECURRENS
C    7 = QUKE     BLACK OAK                 QUERQUS KELOGGII
C    8 = LIDE3    TANOAK                    LITHOCARPUS DENSIFLORUS
C    9 = ABMA     RED FIR                   ABIES MAGNIFICA
C   10 = PIPO     PONDEROSA PINE            PINUS PONDEROSA
C   11 =          OTHER HARDWOODS           USE TANOAK
C----------
C
C  SISKIYOU
C
      DATA SISKIY /
     &  523.0987,  819.8690,  523.0987,  604.8450,  160.6821,
     & 1530.3300,   48.6795,  679.1972,  202.8860, 1348.0419,
     &  679.1972,
C
     &    5.7243,    6.4531,    5.7243,    5.9835,    4.1677,
     &    7.0811,    8.9420,    5.5698,    8.7469,    7.0463,
     &    5.5698,
C
     &   -0.4109,   -0.3434,   -0.4109,   -0.3789,   -0.4954,
     &   -0.2544,   -1.4832,   -0.3074,   -0.8317,   -0.3076,
     &   -0.3074 /
C----------
C  SET EQUATION PARAMETERS ACCORDING TO FOREST AND SPECIES.
C  SISKIYOU EQNS ARE USED FOR ALL FOREST CODES.
C----------
      P2 = SISKIY(ISPC,1)
      P3 = SISKIY(ISPC,2)
      P4 = SISKIY(ISPC,3)
      IF(MODE .EQ. 0) H=0.
      IF(MODE .EQ. 1) D=0.
C----------
C  PROCESS ACCORDING TO MODE
C----------
      IF(MODE .EQ. 0) THEN
        IF(D .GE. 3.) THEN
          H = 4.5 + P2 * EXP(-1.*P3*D**P4)
        ELSE
          H = ((4.5+P2*EXP(-1.*P3*(3.**P4))-4.51)*(D-0.3)/2.7)+4.51
        ENDIF
      ELSE
        HAT3 = 4.5 + P2 * EXP(-1.*P3*3.0**P4)
        IF(H .GE. HAT3) THEN
          D = EXP( ALOG((ALOG(H-4.5)-ALOG(P2))/(-1.*P3)) * 1./P4)
        ELSE
          D = (((H-4.51)*2.7)/(4.5+P2*EXP(-1.*P3*(3.**P4))-4.51))+0.3
        ENDIF
      ENDIF
C
      RETURN
      END
