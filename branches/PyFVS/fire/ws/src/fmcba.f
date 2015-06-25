      SUBROUTINE FMCBA (IYR,ISWTCH)
      IMPLICIT NONE
C----------
C  **FMCBA   FIRE-WS-DATE OF LAST REVISION: 12/29/14
C----------
C     SINGLE-STAND VERSION
C     CALLED FROM: FMMAIN

*  Purpose:
*     Find the dominant species (by basal area). Set the initial live
*     and dead fuel values as well. The dead fuels are only initialized
*     in the first year, but COVTYP and the live fuels must be done
*     each year.
*----------------------------------------------------------------------
*
*  Local variable definitions:
*     BAMOST:  The highest basal area in a single species
*     CAREA:   The area covered by the crown at its widest point (sqft)
*     COVINI:  The seral cover type to be used for initiating fuels in
*              bare stands
*     CRL:     Crown length
*     CWIDTH:  The maximum width of the crowns (ft)
*     FUINIE:  The initial fuel loadings for established stands (from JBrown)
*     FUINII:  The initial fuel loadings for initiating stands (from JBrown)
*     FULIVE:  The herb/shrub/regen for established stands (from JBrown)
*     FULIVI:  The herb/shrub/regen for initiating stands (from JBrown)
*     ISWTCH:  =1 if called by SVSTART
*              =0 if called by any other subroutine (FMMAIN, FMPPHV)
*     TOTBA:   The total basal area in the stand (used in the fuels calcs)
*     TOTCRA:  The sum of the area of the crowns, per acre (sqft)
*
*  Common block variables and parameters:
*
***********************************************************************
C----------
COMMONS
C     Parameter statements.

C     Parameter include files.

      INCLUDE 'PRGPRM.F77'
      INCLUDE 'FMPARM.F77'

C     Common include files.

      INCLUDE 'CONTRL.F77'
      INCLUDE 'ARRAYS.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'FMCOM.F77'
      INCLUDE 'FMFCOM.F77'
C
COMMONS
C----------
C     Variable declarations.

C     MAXIMUM NUMBER OF VEGETATION CODES; MUST MATCH THE
C     DIMENSION OF THE VEGETATION CODE ARRAY IN WS **HABTYP**

      INTEGER    MXVCODE
      PARAMETER (MXVCODE = 406)

      LOGICAL DEBUG
      INTEGER MYACT(3)
      INTEGER*2 COVINI(MXVCODE)
      INTEGER IYR,KSP,I,ISZ,J,NPRM,IACTK,ISWTCH,JYR,IDC
      INTEGER IXS(8),COVCA(2),ICT(MAXSP)
      REAL      TOTCRA, CWIDTH, OPERCOV, X
      REAL FULIVE(2,MAXSP), FULIVI(2,MAXSP)
      REAL FUINIE(MXFLCL,MAXSP), FUINII(MXFLCL,MAXSP)
      REAL STFUEL(MXFLCL,2),XCOV(2),YLOAD(2), FOTOVAL(MXFLCL)
      REAL PRMS(12), FOTOVALS(9)
      REAL    BIGDBH,TOTBA,XX,CAREA,ALGSLP,PRCL,ADD
      REAL    XD(8),YD(8),XS(8),YS(8),XSR(8),YSR(8),DCYMLT
      REAL    COVCAWT(2),TEMSI
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
C----------
C     XD, YD: BREAKPOINTS FOR DUNNING VALUES (XD) AND DECAY RATE MULTIPLIER (Y)
C     YS    : BREAKPOINTS FOR SITE INDEX VALUES FOR DUNNING VALUES (YS);
C             XS IS RETURNED BY **GETDUNN** (ENTRY POINT DUNN)
C     XSR,YSR: LOWEST-FIRST SORTED XS AND YS

      DATA XD /0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0/
      DATA YD /1.5,1.5,1.0,1.0,1.0,0.5,0.5,0.5/

      DATA YS /0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0/

C     BREAKPOINTS (% CC) OF INTERPOLATION FUNCTION TO PROVIDE WEIGHTED
C     ESTIMATE OF LIVE (EVERY TIMESTEP) AND DEAD (INITIAL) FUEL

      DATA XCOV / 10.0, 60.0 /

C     INITIAL LIVE FUEL LOADING FOR 'ESTABLISHED' STANDS WITH 60% COVER

C                  herbs, shrubs
      DATA FULIVE /
     &             0.20, 0.10, ! sugar pine use lodgepole pine NI
     &             0.20, 0.20, ! Douglas-fir
     &             0.15, 0.10, ! white fir
     &             0.20, 0.20, ! giant sequoia use Douglas-fir
     &             0.20, 0.20, ! incense cedar use Douglas-fir
     &             0.20, 0.10, ! Jeffrey pine use sugar pine
     &             0.15, 0.10, ! red fir use white fir
     &             0.20, 0.25, ! ponderosa pine
     &             0.20, 0.10, ! lodgepole pine
     &             0.20, 0.10, ! whitebark pine use CA whitebark pine
     &             0.15, 0.10, ! western white pine use CA western white pine
     &             0.04, 0.05, ! singleleaf pinyon use UT singleleaf pinyon
     &             0.15, 0.10, ! Pacific silver fir use white fir
     &             0.20, 0.10, ! knobcone pine use CA lodgepole pine
     &             0.20, 0.10, ! foxtail pine use CA knobcone pine
     &             0.20, 0.10, ! Coulter pine use CA Coulter pine
     &             0.20, 0.10, ! limber pine use CA limber pine
     &             0.20, 0.20, ! Monterey pine use CA Monterey pine
     &             0.23, 0.22, ! gray or CA foothill pine use CA gray pine
     &             0.20, 0.10, ! washoe pine use CA knobcone pine
     &             0.04, 0.05, ! GB bristlecone pine - use CR BC
     &             0.20, 0.20, ! bigcone Douglas-fir use Douglas-fir
     &             0.20, 0.20, ! redwood use giant sequoia
     &             0.15, 0.20, ! mountain hemlock use CA mountain hemlock
     &             0.14, 0.35, ! western juniper use CA western juniper
     &             0.14, 0.35, ! Utah juniper use CA western juniper
     &             0.14, 0.35, ! California juniper CA western juniper
     &             0.23, 0.22, ! California live oak use CA California live oak
     &             0.25, 0.25, ! canyon live oak - use QA Ottmar and others 2000b
     &             0.23, 0.22, ! blue oak use CA blue oak
     &             0.23, 0.22, ! California black oak - Gambel oak - Ottmar
     &             0.23, 0.22, ! California white / valley oak use 
C                                            CA California white / valley oak
     &             0.23, 0.22, ! interior live oak use CA interior live oak
     &             0.25, 0.25, ! tanoak - use QA Ottmar and others 2000b
     &             0.25, 0.25, ! giant chinkapin - use QA Ottmar and others 2000b
     &             0.25, 0.25, ! quaking aspen - Ottmar and others 2000b
     &             0.20, 0.20, ! California-laurel use CA California-laurel
     &             0.20, 0.20, ! Pacific madrone use CA Pacific madrone
     &             0.20, 0.20, ! Pacific dogwood use CA Pacific dogwood
     &             0.20, 0.20, ! bigleaf maple use CA bigleaf maple
     &             0.25, 0.25, ! curlleaf mtn-mahogany - use QA Ottmar and others 2000b
     &             0.20, 0.10, ! other softwoods use lodgepole pine NI
     &             0.23, 0.22/ ! other hardwoods use California black oak

C     INITIAL LIVE FUEL LOADING FOR 'INTIALIZING STANDS WITH 10% COVER

C                  herbs, shrubs
      DATA FULIVI /
     &             0.40, 1.00,  ! sugar pine use lodgepole pine NI
     &             0.40, 2.00,  ! Douglas-fir
     &             0.30, 2.00,  ! white fir
     &             0.40, 2.00,  ! giant sequoia use Douglas-fir
     &             0.40, 2.00,  ! incense cedar use Douglas-fir
     &             0.40, 1.00,  ! Jeffrey pine use sugar pine
     &             0.30, 2.00,  ! red fir use white fir
     &             0.25, 1.00,  ! ponderosa pine
     &             0.40, 1.00,  ! lodgepole pine
     &             0.40, 1.00,  ! whitebark pine use CA whitebark pine
     &             0.30, 2.00,  ! western white pine use CA western white pine
     &             0.13, 1.63,  ! singleleaf pinyon use UT singleleaf pinyon
     &             0.30, 2.00,  ! Pacific silver fir use white fir
     &             0.40, 1.00,  ! knobcone pine use CA knobcone pine
     &             0.40, 1.00,  ! foxtail pine use CA knobcone pine
     &             0.40, 1.00,  ! Coulter pine use CA Coulter pine
     &             0.40, 1.00,  ! limber pine use CA limber pine
     &             0.40, 2.00,  ! Monterey pine use CA Monterey pine
     &             0.55, 0.35,  ! gray/CA foothill pine use CA gray pine
     &             0.40, 1.00,  ! washoe pine use CA knobcone pine
     &             0.13, 1.63,  ! GB bristlecone pine use CR BC
     &             0.40, 2.00,  ! bigcone Douglas-fir use Douglas-fir
     &             0.40, 2.00,  ! redwood use giant sequoia
     &             0.30, 2.00,  ! mountain hemlock use CA mountain hemlock
     &             0.10, 2.06,  ! western juniper use CA western juniper
     &             0.10, 2.06,  ! Utah juniper use CA western juniper
     &             0.10, 2.06,  ! California juniper use CA western juniper
     &             0.55, 0.35,  ! California live oak use CA California live oak
     &             0.18, 2.00,  ! canyon live oak use QA Ottmar and others 2000b, modified.
     &             0.55, 0.35,  ! blue oak use CA blue oak
     &             0.55, 0.35,  ! California black oak
     &             0.55, 0.35,  ! California white/valley oak use 
C                                             CA California white / valley oak
     &             0.55, 0.35,  ! interior live oak use CA interior live oak
     &             0.18, 2.00,  ! tanoak - use QA Ottmar and others 2000b, modified.
     &             0.18, 2.00,  ! giant chinkapin - use QA Ottmar and others 2000b, modified.
     &             0.18, 1.32,  ! quaking aspen - Ottmar and others 2000b
     &             0.40, 2.00,  ! California-laurel use CA California-laurel
     &             0.40, 2.00,  ! Pacific madrone use CA Pacific madrone
     &             0.40, 2.00,  ! Pacific dogwood use CA Pacific dogwood
     &             0.40, 2.00,  ! bigleaf maple use CA bigleaf maple
     &             0.18, 1.32,  ! curlleaf mtn-mahogany - use QA Ottmar and others 2000b
     &             0.40, 1.00,  ! other softwoods use lodgepole pine NI
     &             0.55, 0.35/  ! other hardwoods use California black oak

C     INITIAL FUEL LOADING FOR 'ESTABLISHED' STANDS WITH 60% COVER
C     THIS CAN BE MODIFIED BY THE *FUELINIT** KEYWORD

C      <.25   to1   1-3   3-6  6-12 12-20 20-35 35-50   >50   Lit  Duf
      DATA FUINIE /
     &  0.9,  0.9,  1.2,  7.0,  8.0,  0.0,  0.0,  0.0,  0.0,  0.6, 15.0, ! sugar pine use lodgepole pine NI
     &  0.9,  0.9,  1.6,  3.5,  3.5,  0.0,  0.0,  0.0,  0.0,  0.6, 10.0, ! Douglas-fir
     &  0.7,  0.7,  3.0,  7.0,  7.0,  0.0,  0.0,  0.0,  0.0,  0.6, 25.0, ! white fir
     &  0.9,  0.9,  1.6,  3.5,  3.5,  0.0,  0.0,  0.0,  0.0,  0.6, 10.0, ! giant sequoia use Douglas-fir
     &  0.9,  0.9,  1.6,  3.5,  3.5,  0.0,  0.0,  0.0,  0.0,  0.6, 10.0, ! incense cedar use Douglas-fir
     &  0.9,  0.9,  1.2,  7.0,  8.0,  0.0,  0.0,  0.0,  0.0,  0.6, 15.0, ! Jeffrey pine use sugar pine
     &  0.7,  0.7,  3.0,  7.0,  7.0,  0.0,  0.0,  0.0,  0.0,  0.6, 25.0, ! red fir use white fir
     &  0.9,  0.9,  1.2,  7.0,  8.0,  0.0,  0.0,  0.0,  0.0,  0.6, 15.0, ! ponderosa pine use Jeffrey pine
     &  0.7,  0.7,  1.6,  2.5,  2.5,  0.0,  0.0,  0.0,  0.0,  1.4,  5.0, ! lodgepole pine
     &  0.7,  0.7,  1.6,  2.5,  2.5,  0.0,  0.0,  0.0,  0.0,  1.4,  5.0, ! whitebark pine use lodgepole pine
     &  1.0,  1.0,  1.6, 10.0, 10.0, 10.0,  0.0,  0.0,  0.0,  0.8, 30.0, ! western white pine use CA WP
     &  0.2,  0.8,  2.3,  1.4,  3.0,  0.0,  0.0,  0.0,  0.0,  0.5,  0.0, ! singleleaf pinyon use UT singleleaf pinyon
     &  0.7,  0.7,  3.0,  7.0,  7.0,  0.0,  0.0,  0.0,  0.0,  0.6, 25.0, ! Pacific silver fir use white fir
     &  0.7,  0.7,  1.6,  2.5,  2.5,  0.0,  0.0,  0.0,  0.0,  1.4,  5.0, ! knobcone pine use CA knobcone pine
     &  0.7,  0.7,  1.6,  2.5,  2.5,  0.0,  0.0,  0.0,  0.0,  1.4,  5.0, ! foxtail pine use CA knobcone pine
     &  0.7,  0.7,  1.6,  2.5,  2.5,  0.0,  0.0,  0.0,  0.0,  1.4,  5.0, ! Coulter pine use CA Coulter pine
     &  0.7,  0.7,  1.6,  2.5,  2.5,  0.0,  0.0,  0.0,  0.0,  1.4,  5.0, ! limber pine use CA limber pine
     &  0.9,  0.9,  1.6,  3.5,  3.5,  0.0,  0.0,  0.0,  0.0,  0.6, 10.0, ! Monterey pine use CA Monterey pine
     &  0.3,  0.7,  1.4,  0.2,  0.1,  0.0,  0.0,  0.0,  0.0,  3.9,  0.0, ! gray/CA foothill pine use CA gray pine
     &  0.7,  0.7,  1.6,  2.5,  2.5,  0.0,  0.0,  0.0,  0.0,  1.4,  5.0, ! washoe pine use CA knobcone pine
     &  0.2,  0.8,  2.3,  1.4,  3.0,  0.0,  0.0,  0.0,  0.0,  0.5,  0.0, ! GB bristlecone pine use CR BC
     &  0.9,  0.9,  1.6,  3.5,  3.5,  0.0,  0.0,  0.0,  0.0,  0.6, 10.0, ! bigcone Douglas-fir use Douglas-fir
     &  0.9,  0.9,  1.6,  3.5,  3.5,  0.0,  0.0,  0.0,  0.0,  0.6, 10.0, ! redwood use giant sequoia
     &  1.1,  1.1,  2.2, 10.0, 10.0,  0.0,  0.0,  0.0,  0.0,  0.6, 30.0, ! mountain hemlock use CA mountain hemlock
     &  0.1,  0.2,  0.4,  0.5,  0.8,  1.0,  0.0,  0.0,  0.0,  0.1,  0.0, ! western juniper use CA western juniper
     &  0.1,  0.2,  0.4,  0.5,  0.8,  1.0,  0.0,  0.0,  0.0,  0.1,  0.0, ! Utah juniper use CA western juniper
     &  0.1,  0.2,  0.4,  0.5,  0.8,  1.0,  0.0,  0.0,  0.0,  0.1,  0.0, ! California juniper use CA western juniper
     &  0.1,  0.1,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  2.9,  0.0, ! California live oak use CA California live oak
     &  0.2,  0.6,  2.4,  3.6,  5.6,  0.0,  0.0,  0.0,  0.0,  1.4, 16.8, ! canyon live oak use CA canyon live oak
     &  0.3,  0.7,  1.4,  0.2,  0.1,  0.0,  0.0,  0.0,  0.0,  3.9,  0.0, ! blue oak use CA blue oak
     &  0.3,  0.7,  1.4,  0.2,  0.1,  0.0,  0.0,  0.0,  0.0,  3.9,  0.0, ! California black oak - Gambel oak - Ottmar
     &  0.3,  0.7,  1.4,  0.2,  0.1,  0.0,  0.0,  0.0,  0.0,  3.9,  0.0, ! CA white/valley oak use CA CA white/valley oak
     &  0.3,  0.7,  1.4,  0.2,  0.1,  0.0,  0.0,  0.0,  0.0,  3.9,  0.0, ! interior live oak use CA interior live oak
     &  0.2,  0.6,  2.4,  3.6,  5.6,  0.0,  0.0,  0.0,  0.0,  1.4, 16.8, ! tanoak - aspen - Ottmar
     &  0.2,  0.6,  2.4,  3.6,  5.6,  0.0,  0.0,  0.0,  0.0,  1.4, 16.8, ! giant chinkapin use CA giant chinkapin
     &  0.2,  0.6,  2.4,  3.6,  5.6,  0.0,  0.0,  0.0,  0.0,  1.4, 16.8, ! quaking aspen use CA quaking aspen
     &  0.9,  0.9,  1.6,  3.5,  3.5,  0.0,  0.0,  0.0,  0.0,  0.6, 10.0, ! California-laurel use CA California-laurel
     &  0.9,  0.9,  1.6,  3.5,  3.5,  0.0,  0.0,  0.0,  0.0,  0.6, 10.0, ! Pacific madrone use CA Pacific madrone
     &  0.9,  0.9,  1.6,  3.5,  3.5,  0.0,  0.0,  0.0,  0.0,  0.6, 10.0, ! Pacific dogwood use CA Pacific dogwood
     &  0.9,  0.9,  1.6,  3.5,  3.5,  0.0,  0.0,  0.0,  0.0,  0.6, 10.0, ! bigleaf maple use CA bigleaf maple
     &  0.2,  0.6,  2.4,  3.6,  5.6,  0.0,  0.0,  0.0,  0.0,  1.4, 16.8, ! curlleaf mtn-mahogany - use CR AS
     &  0.9,  0.9,  1.2,  7.0,  8.0,  0.0,  0.0,  0.0,  0.0,  0.6, 15.0, ! other softwoods use lodgepole pine NI
     &  0.3,  0.7,  1.4,  0.2,  0.1,  0.0,  0.0,  0.0,  0.0,  3.9,  0.0/ ! other hardwoods - Gambel oak - Ottmar

C     INITIAL FUEL LOADING FOR 'INITIALIZING' STANDS WITH 10% COVER
C     THIS CAN BE MODIFIED BY THE *FUELINIT** KEYWORD

C      <.25   to1   1-3   3-6  6-12 12-20 20-35 35-50   >50   Lit  Duf
      DATA FUINII /
     &  0.6,  0.7,  0.8,  2.8,  3.2,  0.0,  0.0,  0.0,  0.0,  0.3,  7.0, ! sugar pine use lodgepole pine NI
     &  0.5,  0.5,  1.0,  1.4,  1.4,  0.0,  0.0,  0.0,  0.0,  0.3,  5.0, ! Douglas-fir
     &  0.5,  0.5,  2.0,  2.8,  2.8,  0.0,  0.0,  0.0,  0.0,  0.3, 12.0, ! white fir
     &  0.5,  0.5,  1.0,  1.4,  1.4,  0.0,  0.0,  0.0,  0.0,  0.3,  5.0, ! giant sequoia use Douglas-fir
     &  0.5,  0.5,  1.0,  1.4,  1.4,  0.0,  0.0,  0.0,  0.0,  0.3,  5.0, ! incense cedar use Douglas-fir
     &  0.6,  0.7,  0.8,  2.8,  3.2,  0.0,  0.0,  0.0,  0.0,  0.3,  7.0, ! Jeffrey pine use sugar pine
     &  0.5,  0.5,  2.0,  2.8,  2.8,  0.0,  0.0,  0.0,  0.0,  0.3, 12.0, ! red fir use white fir
     &  0.6,  0.7,  0.8,  2.8,  3.2,  0.0,  0.0,  0.0,  0.0,  0.3,  7.0, ! ponderosa pine use Jeffrey pine
     &  0.1,  0.1,  0.2,  0.5,  0.5,  0.0,  0.0,  0.0,  0.0,  0.5,  0.8, ! lodgepole pine
     &  0.1,  0.1,  0.2,  0.5,  0.5,  0.0,  0.0,  0.0,  0.0,  0.5,  0.8, ! whitebark pine use lodgepole pine
     &  0.6,  0.6,  0.8,  6.0,  6.0,  6.0,  0.0,  0.0,  0.0,  0.4, 12.0, ! western white pine use CA WP
     &  0.0,  0.1,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.3,  0.0, ! singleleaf pinyon use UT singleleaf pinyon
     &  0.5,  0.5,  2.0,  2.8,  2.8,  0.0,  0.0,  0.0,  0.0,  0.3, 12.0, ! Pacific silver fir use white fir
     &  0.1,  0.1,  0.2,  0.5,  0.5,  0.0,  0.0,  0.0,  0.0,  0.5,  0.8, ! knobcone pine use CA knobcone pine
     &  0.1,  0.1,  0.2,  0.5,  0.5,  0.0,  0.0,  0.0,  0.0,  0.5,  0.8, ! foxtail pine use CA knobcone pine
     &  0.1,  0.1,  0.2,  0.5,  0.5,  0.0,  0.0,  0.0,  0.0,  0.5,  0.8, ! Coulter pine use CA Coulter pine
     &  0.1,  0.1,  0.2,  0.5,  0.5,  0.0,  0.0,  0.0,  0.0,  0.5,  0.8, ! limber pine use CA limber pine
     &  0.5,  0.5,  1.0,  1.4,  1.4,  0.0,  0.0,  0.0,  0.0,  0.3,  5.0, ! Monterey pine use CA Monterey pine
     &  0.1,  0.1,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  2.9,  0.0, ! gray/CA foothill pine use CA gray pine
     &  0.1,  0.1,  0.2,  0.5,  0.5,  0.0,  0.0,  0.0,  0.0,  0.5,  0.8, ! washoe pine use CA knobcone pine
     &  0.0,  0.1,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.3,  0.0, ! GB bristlecone pine use CR BC
     &  0.5,  0.5,  1.0,  1.4,  1.4,  0.0,  0.0,  0.0,  0.0,  0.3,  5.0, ! bigcone Douglas-fir use Douglas-fir
     &  0.5,  0.5,  1.0,  1.4,  1.4,  0.0,  0.0,  0.0,  0.0,  0.3,  5.0, ! redwood use giant sequoia
     &  0.7,  0.7,  1.6,  4.0,  4.0,  0.0,  0.0,  0.0,  0.0,  0.3, 12.0, ! mountain hemlock use CA mountain hemlock
     &  0.2,  0.4,  0.2,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.2,  0.0, ! western juniper use CA western juniper
     &  0.2,  0.4,  0.2,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.2,  0.0, ! Utah juniper use CA western juniper
     &  0.2,  0.4,  0.2,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.2,  0.0, ! California juniper use CA western juniper
     &  0.1,  0.1,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  2.9,  0.0, ! California live oak use CA California live oak
     &  0.1,  0.4,  5.0,  2.2,  2.3,  0.0,  0.0,  0.0,  0.0,  0.8,  5.6, ! canyon live oak use CA canyon live oak
     &  0.1,  0.1,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  2.9,  0.0, ! blue oak use CA blue oak
     &  0.1,  0.1,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  2.9,  0.0, ! California black oak - Gambel oak - Ottmar
     &  0.1,  0.1,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  2.9,  0.0, ! CA white/valley oak use CA CA white/valley oak
     &  0.1,  0.1,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  2.9,  0.0, ! interior live oak use CA interior live oak
     &  0.1,  0.4,  5.0,  2.2,  2.3,  0.0,  0.0,  0.0,  0.0,  0.8,  5.6, ! tanoak - aspen - Ottmar
     &  0.1,  0.4,  5.0,  2.2,  2.3,  0.0,  0.0,  0.0,  0.0,  0.8,  5.6, ! giant chinkapin use CA giant chinkapin
     &  0.1,  0.4,  5.0,  2.2,  2.3,  0.0,  0.0,  0.0,  0.0,  0.8,  5.6, ! quaking aspen use CA quaking aspen
     &  0.5,  0.5,  1.0,  1.4,  1.4,  0.0,  0.0,  0.0,  0.0,  0.3,  5.0, ! California-laurel use CA California-laurel
     &  0.5,  0.5,  1.0,  1.4,  1.4,  0.0,  0.0,  0.0,  0.0,  0.3,  5.0, ! Pacific madrone use CA Pacific madrone
     &  0.5,  0.5,  1.0,  1.4,  1.4,  0.0,  0.0,  0.0,  0.0,  0.3,  5.0, ! Pacific dogwood use CA Pacific dogwood
     &  0.5,  0.5,  1.0,  1.4,  1.4,  0.0,  0.0,  0.0,  0.0,  0.3,  5.0, ! bigleaf maple use CA bigleaf maple
     &  0.1,  0.4,  5.0,  2.2,  2.3,  0.0,  0.0,  0.0,  0.0,  0.8,  5.6, ! curlleaf mtn-mahogany use CR AS
     &  0.6,  0.7,  0.8,  2.8,  3.2,  0.0,  0.0,  0.0,  0.0,  0.3,  7.0, ! other softwoods use lodgepole pine NI
     &  0.1,  0.1,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  2.9,  0.0/ ! other hardwoods - Gambel oak - Ottmar

C     DOMINANT SPECIES FOR EACH (OPTIONAL) VEGETATION CODE.
C     DERIVED FROM R5 VEG CODES AND WS **HABTYP**

      DATA (COVINI(I), I=   1,  50) /
     & 42, 42, 42, 42,  9, 36, 36, 36, 36, 36,
     & 36, 36, 43, 43, 43, 43, 43, 43, 43, 43,
     & 43, 43, 43, 43, 43, 43, 43, 43, 43, 43,
     & 43, 43, 43, 43, 43, 43, 43, 43, 43, 43,
     & 43, 43, 43, 43, 43, 43, 43, 43, 43, 43/
      DATA (COVINI(I), I=  51, 100) /
     & 43, 43, 43,  0,  0,  0,  0,  0,  0,  0,
     &  0,  0,  0,  0,  0,  0,  0,  0,  0, 42,
     & 42, 42, 42, 11,  3,  3,  3,  3,  3,  3,
     &  7,  2,  5,  2,  2,  2,  2,  2,  2,  2,
     &  2,  2,  2,  2,  2,  2,  2,  2,  2,  2/
      DATA (COVINI(I), I= 101, 150) /
     &  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,
     &  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,
     &  2,  2,  2,  2,  6,  6,  6,  6,  6,  6,
     &  6,  6,  6,  6,  6,  6,  9,  9,  9,  9,
     &  9,  9,  1,  1,  1,  1,  1,  1,  1,  1/
      DATA (COVINI(I), I= 151, 200) /
     & 11, 11, 11, 11, 11, 11, 11, 11, 11, 34,
     & 34, 34, 34, 34, 34, 34, 34, 34, 34, 34,
     & 34, 34, 34, 34, 34, 34, 34, 34, 34, 34,
     & 34, 34, 34, 34, 34, 34, 34, 34, 34, 34,
     & 34, 34, 34, 34, 34, 34, 34, 34, 34, 34/
      DATA (COVINI(I), I= 201, 250) /
     & 34, 34, 34, 34, 34, 34, 34, 34, 34, 34,
     &  5,  6,  8,  8,  8,  6,  6,  6,  6,  8,
     &  8,  8,  8,  8,  8,  8,  8,  6,  8,  8,
     &  8,  6,  8,  6, 20, 20,  8,  8,  8,  8,
     &  8,  8,  8,  8,  8,  8,  8,  8,  8,  8/
      DATA (COVINI(I), I= 251, 300) /
     &  8,  8,  8,  8,  8,  2,  2,  2,  2,  2,
     &  8,  1,  3,  3,  3,  3,  3,  3,  3,  2,
     &  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,
     &  6,  6,  6,  6,  6,  3,  2,  2, 42, 42,
     &  8,  3,  8,  3,  2,  3,  2, 43,  2,  2/
      DATA (COVINI(I), I= 301, 350) /
     &  2, 29,  8,  8,  2, 34,  2,  2,  2,  2,
     & 42, 42,  2,  0,  3,  3,  8,  8,  2,  2,
     &  3,  3,  0,  8,  8,  3, 42,  2,  7,  3,
     & 25, 25, 24,  6,  6,  6, 36, 36,  7,  7,
     &  7, 11, 11, 11,  9,  9,  9,  7,  7,  7/
      DATA (COVINI(I), I= 351, 400) /
     &  3,  3,  2, 23, 23, 23, 23, 23, 23, 23,
     &  8, 30, 30, 30, 30, 30, 30, 30, 30, 30,
     & 30, 30, 30, 30, 30, 30, 30,  0,  0,  0,
     &  0,  0,  0,  0,  0,  0,  0, 43,  0,  0,
     &  0, 29, 33, 33, 33, 33, 43, 43, 43, 43/
      DATA (COVINI(I), I= 401, 406) /
     & 43,  0,  0,  0,  0,  0/

      DATA MYACT / 2521, 2548, 2553 /

C     CHECK FOR DEBUG.

      CALL DBCHK (DEBUG,'FMCBA',5,ICYC)
      IF (DEBUG) WRITE(JOSTND,7) ICYC
    7 FORMAT(' ENTERING FMCBA CYCLE = ',I2)

C     BEGIN ROUTINE. ZERO OUT THE CUMMULATIVE VARIABLES

      COVTYP = 0

C     CA VARIANTS USE TOP 2 SPP FOR LIVE FUELS AND INITIAL
C     CWD INTERPOLATION

      DO I = 1,2
        COVCA(I)   = 0
        COVCAWT(I) = 0.0
      ENDDO
      OPERCOV = PERCOV

      PERCOV = 0.0
      BIGDBH = 0.0
      TOTBA  = 0.0

C     LOOP THROUGH THE TREE LIST

      IF (ITRN .GT. 0) THEN

C       ZERO OUT THE CUMMULATIVE VARIABLES

        TOTCRA = 0.0

        DO KSP = 1,MAXSP
          FMTBA(KSP) = 0.0
        ENDDO

        DO I = 1,ITRN
          IF (FMPROB(I) .GT. 0.0) THEN

            KSP = ISP(I)

            FMTBA(KSP) = FMTBA(KSP) +
     &                   FMPROB(I) * DBH(I) * DBH(I) * 0.0054542

            IF (DBH(I) .GT. BIGDBH) BIGDBH = DBH(I)

C           CALCULATE THE CROWN WIDTH OF THE TREE AND TOTAL THE AREA
C           ENCOMPASSED BY ALL TREES

            CWIDTH=CRWDTH(I)

            CAREA = 3.1415927*CWIDTH*CWIDTH/4.0
            TOTCRA = TOTCRA + CAREA*FMPROB(I)
          ENDIF

C         USE THIS LOOP TO ZERO THIS VARIABLE, FOR LACK OF A BETTER PLACE.

          CURKIL(I) = 0.0

        ENDDO

C       CALCULATE TOTAL COVER TYPE

        DO KSP = 1,MAXSP
          TOTBA = TOTBA + FMTBA(KSP)
        ENDDO

C       DETERMINE WHICH SPECIES HAS THE MOST BASAL AREA
C       COVTYP    - FFE-WIDE DOMINANT
C       COVCA(2)  - CA-FFE VARIANTS ONLY: PRIMARY & SECONDARY BA

        CALL RDPSRT(MAXSP,FMTBA,ICT,.TRUE.)
        IF (FMTBA(ICT(1)) .GT. 0.001) COVTYP = ICT(1)

        XX = 0.0
        DO I = 1,2
          IF (FMTBA(ICT(I)) .GT. 0.0) XX = XX + FMTBA(ICT(I))
        ENDDO
        IF (XX .GT. 0.001) THEN
          DO I = 1,2
            COVCA(I)   = ICT(I)
            COVCAWT(I) = FMTBA(ICT(I))/XX
          ENDDO
        ENDIF

C       Use the crown width information to determine the percent cover
C       of the stand. Use the equation sent by Nick which assumes that
C       crowns are randomly distrubuted in the stand:

C       PerCov = 100*(1-exp(-total crown areas per acre / sqft in an acre))

        PERCOV = 100. * (1.0 - EXP(-TOTCRA/43560.))

      ENDIF

C     COMPUTE % CHANGE (DROP) IN %CC FOR SHRUB MODEL **FMSHRUB**

      X = OPERCOV
      IF (X .GT. 1.0) THEN
        CCCHNG = -100.0 * (PERCOV - X) / X
      ELSE
        CCCHNG = 0.0
      ENDIF

C     IF THERE ARE NO TREES (COVTYP=0) IN CYCLE 1, USE THE OPTIONAL ITYPE
C     IF IT IS VALID. OTHERWISE ISSUE A WARNING AND USE A DEFAULT PP COVER.
C     AFTER THE FIRST CYCLE, USE THE PREVIOUS COVER TYPE IF NO COVER IS
C     PRESENT. ALSO SET CA-SPECIFIC COVCA(-) AND COVCAWT(-)

      IF (COVTYP .EQ. 0) THEN
        IF (IYR .EQ. IY(1)) THEN
          IF (ITYPE .GE. 1 .AND. ITYPE .LE. MXVCODE)
     &      COVTYP = COVINI(ITYPE)
          IF (COVTYP .EQ. 0) THEN
             WRITE (JOSTND,"(/1X,'*** FFE MODEL WARNING: NO INITIAL ',
     &       'BASAL AREA AND NO VALID HABITAT INFORMATION:',
     &       /1X,'*** COVER TYPE SET TO PONDEROSA PINE',/1X)")
            CALL RCDSET (2,.TRUE.)
            COVTYP = 10
          ENDIF
        ELSE
          COVTYP = OLDCOVTYP
        ENDIF
        COVCA(1)   = COVTYP
        COVCAWT(1) = 1.0
      ENDIF
      OLDCOVTYP = COVTYP

C     LOAD LIVE FUELS AS A FUNCTION OF PERCOV...ASSUME THAT THE INITIATING
C     STANDS CORRESPOND TO ABOUT 10% COVER AND ESTABLISHED ARE 60% OR MORE.
C     IN WS,NC,CA VARIANTS, THE TOP 2 SPECIES ARE USED TO INTIALIZE THE POOLS

      DO I = 1,2  ! herbs, shrub loop
        FLIVE(I) = 0.0
        DO J = 1,2  ! primary secondary cover types loop
          IF (COVCA(J) .GT. 0) THEN
            YLOAD(1) = FULIVI(I,COVCA(J)) * COVCAWT(J)
            YLOAD(2) = FULIVE(I,COVCA(J)) * COVCAWT(J)
            FLIVE(I) = FLIVE(I) + ALGSLP(PERCOV,XCOV,YLOAD,2)
          ENDIF
        ENDDO
      ENDDO

      IF (DEBUG) WRITE(JOSTND,8) COVTYP,PERCOV,FLIVE(1),FLIVE(2)
    8 FORMAT(' IN FMCBA, COVTYP=',I3,' PERCOV=',F6.2,' FLIVE(1&2)=',
     >    2F6.3)

C     INITIALIZE THE DEAD FUELS ONLY FOR THE FIRST YEAR OF THE SIMULATION

      IF (IYR .EQ. IY(1)) THEN

C     ADJUST DECAY RATES (FIRST YEAR ONLY) USING  DUNNING CODE/SITE
C     INDEX CORRESPONDENCE. DUNNING-BASED SI VECTOR IS RE-SORTED SO
C     THAT XSR IS INCREASING (REQ'D BY ALGSLP); ASSUMES DUNNING
C     CODES 0-7 ONLY. DEPENDS ON **DUNN**

C       ONLY DO THIS IF DURING THE NORMAL CALL, NOT FROM SVSTART

        IF ( ISWTCH .NE. 1 ) THEN
          CALL GETDUNN(XS)
          CALL RDPSRT(8,XS,IXS,.TRUE.)
          J = 8
          DO I= 1,8
            XSR(I) = XS(IXS(J))
            YSR(I) = YS(IXS(J))
            J=J-1
          ENDDO
C----------
C  GB AND MC USE 100-YR DUNNING SITE VALUES; THE DECAY RATE MODIFIERS ARE
C  BASED ON DUNNING 50-YEAR BREAKPOINTS. IF THE SITE SPECIES IS EITHER GB OR
C  MC, THEN USE THE RF 50-YEAR SITE INDEX IN THIS CALCULATION.
C----------
          SELECT CASE (ISISP)
          CASE(21,41)
            TEMSI=SITEAR(7)
          CASE DEFAULT
            TEMSI=SITEAR(ISISP)
          END SELECT
C----------
          
          DCYMLT = ALGSLP(ALGSLP(TEMSI,XSR,YSR,8),XD,YD,8)
          
          DO I = 1,MXFLCL
            DO J = 1,4
              IF (SETDECAY(I,J) .LT. 0) THEN
                DKR(I,J) = DKR(I,J) * DCYMLT
                IF (I .LE. 10) TODUFF(I,J) = DKR(I,J) * PRDUFF(I,J) 
              ENDIF
            ENDDO
          ENDDO
        ENDIF
        
C       LOAD DEAD FUELS AS A FUNCTION OF PERCOV...ASSUME THAT THE INITIATING
C       STANDS CORRESPOND TO ABOUT 10% COVER AND ESTABLISHED ARE 60% OR MORE.
C       IN WS,NC,CA VARIANTS, THE TOP 2 SPECIES ARE USED TO INTIALIZE THE POOLS

        DO ISZ = 1,MXFLCL  ! CWD size category loop
          STFUEL(ISZ,1) = 0.0
          STFUEL(ISZ,2) = 0.0
          DO J = 1,2  ! primary secondary cover types loop
            IF (COVCA(J) .GT. 0) THEN
              YLOAD(1)=FUINII(ISZ,COVCA(J)) * COVCAWT(J)
              YLOAD(2)=FUINIE(ISZ,COVCA(J)) * COVCAWT(J)
              STFUEL(ISZ,2) = STFUEL(ISZ,2)+ALGSLP(PERCOV,XCOV,YLOAD,2)
            ENDIF
          ENDDO
        ENDDO
        
C       CHANGE THE INITIAL FUEL LEVELS BASED ON PHOTO SERIES INFO INPUT

        CALL OPFIND(1,MYACT(2),J)
        IF (J .GT. 0) THEN
          CALL OPGET(J,2,JYR,IACTK,NPRM,PRMS)
          IF ((PRMS(1) .GE. 0) .AND. (PRMS(2) .GE. 0)) THEN
            CALL FMPHOTOVAL(NINT(PRMS(1)), NINT(PRMS(2)), FOTOVAL, 
     >                      FOTOVALS)
            DO I = 1, MXFLCL
              IF (FOTOVAL(I) .GE. 0) STFUEL(I,2) = FOTOVAL(I)
              IF (I .LE. 9) STFUEL(I,1) = FOTOVALS(I)
            ENDDO                 

C           IF FOTOVAL(1) IS NEGATIVE, THEN AN INVALID CODE WAS ENTERED.
C           DON'T MARK EVENT DONE IF THIS IS A CALL FROM SVSTART--WILL
C           NEED TO REPROCESS EVENT WHEN CALLED FROM FMMAIN.

            IF (FOTOVAL(1).GE.0 .AND. ISWTCH.NE.1) CALL OPDONE(J,IYR)

          ELSE
            WRITE (JOSTND,"(/1X,'*** FFE MODEL WARNING: INCORRECT ',
     &      'PHOTO REFERENCE OR PHOTO CODE ENTERED.  BOTH FIELDS ARE ',
     &      'REQUIRED.',/1X)")
            CALL RCDSET (2,.TRUE.)
          ENDIF
        ENDIF
        
C       CHANGE THE INITIAL FUEL LEVELS BASED ON INPUT FROM THE USER
C       FIRST DO FUELHARD (FUELINIT) THEN FUELSOFT

        CALL OPFIND(1,MYACT(1),J)
        IF (J .GT. 0) THEN
          CALL OPGET(J,12,JYR,IACTK,NPRM,PRMS)
          IF (PRMS(2) .GE. 0) STFUEL(3,2) = PRMS(2)
          IF (PRMS(3) .GE. 0) STFUEL(4,2) = PRMS(3)
          IF (PRMS(4) .GE. 0) STFUEL(5,2) = PRMS(4)
          IF (PRMS(5) .GE. 0) STFUEL(6,2) = PRMS(5)
          IF (PRMS(6) .GE. 0) STFUEL(10,2) = PRMS(6)
          IF (PRMS(7) .GE. 0) STFUEL(11,2) = PRMS(7)
          IF (PRMS(8) .GE. 0) STFUEL(1,2) = PRMS(8)          
          IF (PRMS(9) .GE. 0) STFUEL(2,2) = PRMS(9)           
          IF (PRMS(1) .GE. 0) THEN
            IF ((PRMS(8) .LT. 0) .AND. (PRMS(9) .LT. 0)) THEN
              STFUEL(1,2) = PRMS(1) * 0.5
              STFUEL(2,2) = PRMS(1) * 0.5
            ENDIF                 
            IF ((PRMS(8) .LT. 0) .AND. (PRMS(9) .GE. 0)) THEN
              STFUEL(1,2) = MAX(PRMS(1) - PRMS(9),0.)
            ENDIF  
            IF ((PRMS(8) .GE. 0) .AND. (PRMS(9) .LT. 0)) THEN
              STFUEL(2,2) = MAX(PRMS(1) - PRMS(8),0.)
            ENDIF  
          ENDIF                
          IF (PRMS(10) .GE. 0) STFUEL(7,2) = PRMS(10) 
          IF (PRMS(11) .GE. 0) STFUEL(8,2) = PRMS(11) 
          IF (PRMS(12) .GE. 0) STFUEL(9,2) = PRMS(12)           

C         DON'T MARK EVENT DONE IF THIS IS A CALL FROM SVSTART--WILL
C         NEED TO REPROCESS EVENT WHEN CALLED FROM FMMAIN.

          IF ( ISWTCH .NE. 1 ) CALL OPDONE(J,IYR)

        ENDIF

        CALL OPFIND(1,MYACT(3),J)
        IF (J .GT. 0) THEN
          CALL OPGET(J,9,JYR,IACTK,NPRM,PRMS)
          IF (PRMS(1) .GE. 0) STFUEL(1,1) = PRMS(1)
          IF (PRMS(2) .GE. 0) STFUEL(2,1) = PRMS(2)
          IF (PRMS(3) .GE. 0) STFUEL(3,1) = PRMS(3)
          IF (PRMS(4) .GE. 0) STFUEL(4,1) = PRMS(4)
          IF (PRMS(5) .GE. 0) STFUEL(5,1) = PRMS(5)
          IF (PRMS(6) .GE. 0) STFUEL(6,1) = PRMS(6)
          IF (PRMS(7) .GE. 0) STFUEL(7,1) = PRMS(7)          
          IF (PRMS(8) .GE. 0) STFUEL(8,1) = PRMS(8)                           
          IF (PRMS(9) .GE. 0) STFUEL(9,1) = PRMS(9)           

C         DON'T MARK EVENT DONE IF THIS IS A CALL FROM SVSTART--WILL
C         NEED TO REPROCESS EVENT WHEN CALLED FROM FMMAIN.

          IF ( ISWTCH .NE. 1 ) CALL OPDONE(J,IYR)

        ENDIF

C       DIVIDE THE FUELS INTO DECAY CLASSES ACCORDING TO THE RELATIVE AMOUNTS
C       OF BASAL AREA IN THE STAND. ASSUME THE FUELS ARE UNPILED AND HARD.
C       THIS LAST ASSUMPTION MAY CHANGE IN THE FUTURE.

        DO ISZ = 1,MXFLCL
          IF (TOTBA .GT. 0.0) THEN
            DO KSP = 1,MAXSP
              IF (FMTBA(KSP) .GT. 0.0) THEN
                DO J = 1,2
                  PRCL = FMTBA(KSP) / TOTBA
                  IDC = DKRCLS(KSP)
                  ADD = PRCL * STFUEL(ISZ,J)
                  CWD(1,ISZ,J,IDC) = CWD(1,ISZ,J,IDC) + ADD
                ENDDO
              ENDIF
            ENDDO
          ELSE
            IDC = DKRCLS(COVTYP)
            DO J = 1,2
              CWD(1,ISZ,J,IDC) = CWD(1,ISZ,J,IDC) + STFUEL(ISZ,J)
            ENDDO
          ENDIF
        ENDDO

      ENDIF

      ENTRY SNGCOE

C     ENTRY POINT FOR SETTING SNAGFALL/DECAY PARAMETERS WHEN FFE
C     IS NOT ACTIVE. CALLED FROM SVSTART. USED ONLY FOR SO.

      RETURN
      END