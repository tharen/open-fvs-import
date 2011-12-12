      FUNCTION BRATIO(IS,D,H)
      IMPLICIT NONE
C----------
C  **BRATIO--WS   DATE OF LAST REVISION:  05/09/11
C----------
C
C FUNCTION TO COMPUTE BARK RATIOS AS A FUNCTION OF DIAMETER AND SPECIES.
C REPLACES ARRAY BKRAT IN BASE MODEL.  
C----------
C     SPECIES LIST FOR WESTERN SIERRAS VARIANT.
C
C     1 = SUGAR PINE (SP)                   PINUS LAMBERTIANA
C     2 = DOUGLAS-FIR (DF)                  PSEUDOTSUGA MENZIESII
C     3 = WHITE FIR (WF)                    ABIES CONCOLOR
C     4 = GIANT SEQUOIA (GS)                SEQUOIADENDRON GIGANTEAUM
C     5 = INCENSE CEDAR (IC)                LIBOCEDRUS DECURRENS
C     6 = JEFFREY PINE (JP)                 PINUS JEFFREYI
C     7 = CALIFORNIA RED FIR (RF)           ABIES MAGNIFICA
C     8 = PONDEROSA PINE (PP)               PINUS PONDEROSA
C     9 = LODGEPOLE PINE (LP)               PINUS CONTORTA
C    10 = WHITEBARK PINE (WB)               PINUS ALBICAULIS
C    11 = WESTERN WHITE PINE (WP)           PINUS MONTICOLA
C    12 = SINGLELEAF PINYON (PM)            PINUS MONOPHYLLA
C    13 = PACIFIC SILVER FIR (SF)           ABIES AMABILIS
C    14 = KNOBCONE PINE (KP)                PINUS ATTENUATA
C    15 = FOXTAIL PINE (FP)                 PINUS BALFOURIANA
C    16 = COULTER PINE (CP)                 PINUS COULTERI
C    17 = LIMBER PINE (LM)                  PINUS FLEXILIS
C    18 = MONTEREY PINE (MP)                PINUS RADIATA
C    19 = GRAY PINE (GP)                    PINUS SABINIANA
C         (OR CALIFORNIA FOOTHILL PINE)
C    20 = WASHOE PINE (WE)                  PINUS WASHOENSIS
C    21 = GREAT BASIN BRISTLECONE PINE (GB) PINUS LONGAEVA
C    22 = BIGCONE DOUGLAS-FIR (BD)          PSEUDOTSUGA MACROCARPA
C    23 = REDWOOD (RW)                      SEQUOIA SEMPERVIRENS
C    24 = MOUNTAIN HEMLOCK (MH)             TSUGA MERTENSIANA
C    25 = WESTERN JUNIPER (WJ)              JUNIPERUS OCIDENTALIS
C    26 = UTAH JUNIPER (UJ)                 JUNIPERUS OSTEOSPERMA
C    27 = CALIFORNIA JUNIPER (CJ)           JUNIPERUS CALIFORNICA
C    28 = CALIFORNIA LIVE OAK (LO)          QUERCUS AGRIFOLIA
C    29 = CANYON LIVE OAK (CY)              QUERCUS CHRYSOLEPSIS
C    30 = BLUE OAK (BL)                     QUERCUS DOUGLASII
C    31 = CALIFORNIA BLACK OAK (BO)         QUERQUS KELLOGGII
C    32 = VALLEY OAK (VO)                   QUERCUS LOBATA
C         (OR CALIFORNIA WHITE OAK)
C    33 = INTERIOR LIVE OAK (IO)            QUERCUS WISLIZENI
C    34 = TANOAK (TO)                       LITHOCARPUS DENSIFLORUS
C    35 = GIANT CHINKAPIN (GC)              CHRYSOLEPIS CHRYSOPHYLLA
C    36 = QUAKING ASPEN (AS)                POPULUS TREMULOIDES
C    37 = CALIFORNIA-LAUREL (CL)            UMBELLULARIA CALIFORNICA
C    38 = PACIFIC MADRONE (MA)              ARBUTUS MENZIESII
C    39 = PACIFIC DOGWOOD (DG)              CORNUS NUTTALLII
C    40 = BIGLEAF MAPLE (BM)                ACER MACROPHYLLUM
C    41 = CURLLEAF MOUNTAIN-MAHOGANY (MC)   CERCOCARPUS LEDIFOLIUS
C    42 = OTHER SOFTWOODS (OS)
C    43 = OTHER HARDWOODS (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C    FROM EXISTING WS EQUATIONS --
C      USE 1(SP) FOR 11(WP) AND 24(MH) 
C      USE 2(DF) FOR 22(BD)
C      USE 3(WF) FOR 13(SF)
C      USE 4(GS) FOR 23(RW)
C      USE 8(PP) FOR 18(MP)
C      USE 34(TO) FOR 35(GC), 36(AS), 37(CL), 38(MA), AND 39(DG)
C      USE 31(BO) FOR 28(LO), 29(CY), 30(BL), 32(VO), 33(IO), 40(BM), AND
C                     43(OH)
C
C    FROM CA VARIANT --
C      USE CA11(KP) FOR 12(PM), 14(KP), 15(FP), 16(CP), 17(LM), 19(GP), 20(WE), 
C                       25(WJ), 26(WJ), AND 27(CJ)
C      USE CA12(LP) FOR 9(LP) AND 10(WB)
C
C    FROM SO VARIANT --
C      USE SO30(MC) FOR 41(MC)
C
C    FROM UT VARIANT --
C      USE UT17(GB) FOR 21(GB)
C----------
      REAL BARK1(43),BARK2(43),H,D,BRATIO,TEMD
      INTEGER IMAP(43),IS,IEQN
C
      DATA BARK1/
     & 0.8863, 0.8839, 0.8911, 0.8863, 0.8374,
     & 0.8967, 0.8911, 0.8967, 0.9000, 0.9000,
     & 0.8863, 0.9329, 0.8911, 0.9329, 0.9329,
     & 0.9329, 0.9329, 0.8967, 0.9329, 0.9329,
     & 0.9625, 0.8839, 0.8863, 0.8863, 0.9329,
     & 0.9329, 0.9329, 0.8374, 0.8374, 0.8374,
     & 0.8374, 0.8374, 0.8374, 0.8374, 0.8374,
     & 0.8374, 0.8374, 0.8374, 0.8374, 0.8374,
     & 0.9000, 0.8967, 0.8374/
C
      DATA BARK2/
     &     0.,     0.,     0.,     0.,     0.,
     &     0.,     0.,     0.,     0.,     0.,
     &     0.,     0.,     0.,     0.,     0.,
     &     0.,     0.,     0.,     0.,     0.,
     &-0.1141,     0.,     0.,     0.,     0.,
     &     0.,     0.,     0.,     0.,     0.,
     &     0.,     0.,     0.,     0.,     0.,
     &     0.,     0.,     0.,     0.,     0.,
     &     0.,     0.,     0./
C
      DATA IMAP/ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
     &           1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
     &           2, 1, 1, 1, 1, 1, 1, 1, 1, 1,
     &           1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
     &           1, 1, 1/
C----------
C  PI, JU, BS, AND OA USE EQUATIONS FROM CR MODEL TYPE 3-5
C  WB, LM, LP, OT USE EQUATIONS FROM CR VARIANT
C  ES USES THE EQUATION FROM THE CR VARIANT
C  PP USES THE EQUATION FROM THE CA VARIANT
C  WF AND AF USE THE CONSTANT RATIO FROM NI VARIANT
C----------
      IEQN=IMAP(IS)
      TEMD=D
      IF(TEMD.LT.1.)TEMD=1.
C
      IF(IEQN .EQ. 1) THEN
        BRATIO=BARK1(IS)
C
      ELSEIF(IEQN .EQ. 2)THEN
        BRATIO=BARK1(IS)+BARK2(IS)*(1.0/TEMD)
        IF(BRATIO .GT. 0.99) BRATIO=0.99
        IF(BRATIO .LT. 0.80) BRATIO=0.80
      ENDIF
C
      RETURN
      END
