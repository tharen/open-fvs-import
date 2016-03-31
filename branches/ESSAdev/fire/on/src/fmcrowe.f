      SUBROUTINE FMCROWE (SPIE,SPIW,ISEFOR,KODIST,D,H,IC,SG,XV)
      IMPLICIT NONE

C   **FMCROWE  FIRE-BASE DATE OF LAST REVISION:  04/10/12

CCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C     THIS IS A PLACEHOLDER FOR FUTURE IMPLEMENTATION OF A FFE VARIANT
C     FOR FVS-ONTARIO. DR; 13 July 2012
C
CCCCCCCCCCCCCCCCCCCCCCCCCCC

C     CALLED FROM: FMSDIT, FMPRUN
C     CALLS: HTDBH, FMSVL2, SEVLHT

C  PURPOSE:
C     THIS SUBROUTINE CALCULATES CROWNW(TREE,SIZE), THE WEIGHT OF
C     VARIOUS SIZES OF CROWN MATERIAL THAT IS ASSOCIATED WITH EACH TREE
C     RECORD IN THE CURRENT STAND.  THESE WEIGHTS COME FROM:
C     1-FACTORS AND EQUATIONS TO ESTIMATE FOREST BIOMASS IN THE NORTH
C     CENTRAL REGION BY W. BRAD SMITH (RES. PAP. NC-168)
C     2-ESTIMATING ASPEN CROWN FUELS IN NORTHEASTERN MINNESOTA, BY R.M.
C     LOOMIS AND P.J. ROUSSOPOULOS (RES. PAP. NC-156)
C     3-ESTIMATING NORTHERN RED OAK CROWN COMPONENT WEIGHTS IN THE
C     NORTHEASTERN UNITED STATES, BY R.M. LOOMIS AND R.W. BLANK
C     (RES. PAP. NC-194)
C     4-ESTIMATING FOLIAGE AND BRANCHWOOD QUANTITIES IN SHORTLEAF PINE
C     BY R.M. LOOMIS, R.E. PHARES, AND J.S. CROSBY (FOREST SCIENCE,
C     VOL 12, ISSUE 1, 1966)
C     5-NATIONAL-SCALE ESTIMATORS FOR UNITED STATES TREE SPECIES, BY
C     JENKINS ET. AL. (FOR. SCI. 2003 49(1))
C     6-PREDICTING CROWN WEIGHT AND BOLE VOLUME OF FIVE WESTERN
C     HARDWOODS BY J.A. KENDALL SNELL AND SUSAN N. LITTLE
C     (RES. PAP. PNW-151, MARCH 1983)
C     THE SMITH CROWN BIOMASS EQUATIONS PREDICT TOTAL BIOMASS NOT
C     INCLUDING FOLIAGE.  THE CROWN INCLUDES STUFF ABOVE 4 INCH TOP(DOB).

C  LOCAL VARIABLE DEFINITIONS:

C     SPI1 = SPECIES NUMBER IN THE SN VARIANT
C     SPI2 = SPECIES NUMBER IN THE WESTERN VARIANT
C     ISEFOR = FOREST CODE
C     D = DBH
C     H = HEIGHT
C     C = CROWN RATIO EXPRESSED AS A PERCENT
C     VT = BOLE WOOD VOLUME
C     BOLEBV = BOLE BARK VOLUME
C     BOLEWW = BOLE WOOD WEIGHT
C     BOLEBW = BOLE BARK WEIGHT
C     TBOLEW = TOTAL BOLE WEIGHT (WOOD + BARK)
C     BRKPCT = BARK PERCENTAGES
C     BKPPCF = BARK POUNDS PER CUFT CONVERSION FACTOR
C     STMPCOEF = STUMP REGRESSION COEFFICIENT FROM SMITH
C     STUMPV = STUMP VOLUME
C     STUMPB = STUMP BIOMASS
C     LILPCE = BIOMASS OF THE SMALL PIECE MISSING SINCE VOLUME
C            EQUATIONS GO TO 4" DIB AND CROWN EQUATIONS START AT 4" DOB
C     HTLP = HT CALC NEEDED TO ESTIMATE LILPCE.  HT AT 4" DOB.
C     DIB  = DIB VALUE THAT CORRESPONDS TO 4" DOB.
C     TTOPW  = TOTAL TOP WEIGHT
C     FOL    = FOLIAGE BIOMASS
C     P1 - P3 = PROPORTIONS OF CROWN MATERIAL IN DIFFERENT SIZE CLASSES
C     F1 - F4 = PROPORTIONS USED IN CALCULATING MAPLE BIOMASS (SLIGHTLY
C              DIFFERENT THEN P1-P3, MATCH SNELL AND LITTLE NOTATION)
C     IGAC, SNSP, PULPVO, SWVOL = USED TO CALCULATE HT AT 4 INCH TOP
C               DIAMETER.  SEE VARVOL AND SEVLHT FOR MORE INFO.
C     HTF     = HEIGHT TO A FOUR INCH TOP DIAMETER (IB)
C     UMBTW   = UNMERCHANTABLE BOLE TIP WEIGHT BY SIZE CLASS.
C              (1 = 0-.25, 2 = 0-1, 3 = 0-3, 4 = 0 - 4)
C     ANGLE, TEMPHT, DBRK  = USED IN CALCULATING UMBTW
C     TOTABV = TOTAL ABOVE GROUND BIOMASS (AS PER JENKINS ET. AL.)

COMMONS

      INCLUDE 'PRGPRM.F77'
      INCLUDE 'FMPARM.F77'

      INCLUDE 'CONTRL.F77'
      INCLUDE 'COEFFS.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'VARCOM.F77'

C  VARIABLE DECLARATIONS

      LOGICAL LMERCH,LHTDBH
      REAL    D,H,SG,XV(0:5)
      INTEGER SPIE,SPIW,ISEFOR,KODIST,IC

      INTEGER J, K, IGAC
      INTEGER IALGA(7),IGAGA(8),ITNGA(6),IFLGA(6),IMSGA(17),INCGA(11),
     &        ISCGA(5),IARGA(12),IOZGA(7),IDBGA(7),IKIGA(5),IGWGA(16),
     &        ITXGA(8)
      REAL C, XNEG1, VT, BOLEBV, BOLEWW, BOLEBW, TBOLEW, ANGLE
      REAL BRKPCT(90), BKPPCF(90), TTOPW, FOL, DBRK(0:3), TOTABV
      REAL P1, P2, P3, TEMP, F1, F2, F3, F4, HTF, TEMPHT, MYPI, UMBTW(4)
      REAL STUMPV, STUMPB, LILPCE, DIB
      REAL REALTOPD, HTLP, TEMPD, BRATIO, DBHCUT, DCTLOW, DCTHGH
      REAL SMWGT, XVAL(3), YVAL(3), ALGSLP
      REAL AX,DX,HX
      LOGICAL DEBUG, PULPVO, SWVOL
      CHARACTER SNSP*3, VVER*7
      DIMENSION SNSP(90)

      DATA YVAL   / 1.0, 0.5, 0.0 /
      DATA DBRK   / 0.0, 0.25, 1.0, 3.0 /

      DATA BRKPCT /0.15,0.12,0.14,0.15,0.15,0.15,0.15,0.15,0.15,0.15,
     &             0.15,0.16,0.15,0.15,0.13,0.13,0.21,0.12,0.12,0.12,
     &             0.12,0.12,0.15,0.12,0.12,0.15,0.13,0.15,0.15,0.15,
     &             0.15,0.15,0.07,0.16,0.16,0.14,0.16,0.15,0.15,0.15,
     &             0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,
     &             0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.08,0.15,
     &             0.18,0.1, 0.18,0.14,0.14,0.14,0.14,0.14,0.18,0.14,
     &             0.18,0.18,0.14,0.18,0.14,0.14,0.18,0.14,0.18,0.15,
     &             0.16,0.15,0.16,0.14,0.14,0.14,0.14,0.13,0.15,0.15/

      DATA BKPPCF /24,25,24,25,20,20,25,20,25,25,
     &             25,31,20,25,25,25,25,34,32,32,
     &             32,34,26,35,35,26,37,26,31,26,
     &             26,26,35,21,21,28,21,26,26,26,
     &             26,25,17,29,25,26,26,26,26,26,
     &             26,26,29,29,29,26,26,26,28,27,
     &             31,30,33,41,41,41,41,41,33,41,
     &             33,33,41,33,41,41,33,41,33,26,
     &             27,26,28,17,17,17,17,28,26,26/

      DATA SNSP/
     &'261','100','115','132','110','111','115','121','126','126',
     &'128','129','131','132','221','222','261','500','500','316',
     &'300','500','330','370','370','370','400','300','460','300',
     &'300','500','531','541','541','300','544','500','300','300',
     &'300','500','500','611','621','652','300','652','653','300',
     &'300','300','300','693','694','500','300','300','731','300',
     &'300','300','802','806','812','813','800','800','822','800',
     &'800','800','827','832','833','800','835','800','835','901',
     &'300','300','300','970','970','970','970','132','300','300'/

      DATA IALGA/40,2*10,4*40/,IDBGA/7*30/,IGAGA/7*30,20/,
     &     ITNGA/6*30/,IFLGA/6*10/,IKIGA/5*50/,IMSGA/5*50,70,11*40/,
     &     IGWGA/16*30/,IARGA/12*60/,IOZGA/2*60,10,3*60,70/,
     &     INCGA/11*30/,ISCGA/20,30,20,20,10/,ITXGA/8*50/

C      DATA STMPCOEF/0.009967,0.008877,0.008877,0.007176,0.007176,
C     &              0.007176,0.007176,0.007176,0.007176,0.007176,
C     &              0.007176,0.008269,0.007176,0.007176,0.008269,
C     &              0.008269,0.008579,0.008894,0.008476,0.008476,
C     &              0.008476,0.008894,0.00898,0.009968,0.009968,
C     &              0.00898,0.00898,0.00898,0.010422,0.00898,
C     &              0.00898,0.00898,0.010202,0.008728,0.008728,
C     &              0.011016,0.008728,0.00898,0.00898,0.00898,
C     &              0.00898,0.00898,0.00898,0.00898,0.00898,
C     &              0.00898,0.00898,0.00898,0.00898,0.00898,
C     &              0.00898,0.00898,0.00898,0.00898,0.00898,
C     &              0.00898,0.00898,0.00898,0.00898,0.011145,
C     &              0.007369,0.00898,0.009727,0.008908,0.008908,
C     &              0.008908,0.008908,0.008908,0.009727,0.008908,
C     &              0.009727,0.009727,0.008908,0.009727,0.008908,
C     &              0.008908,0.009727,0.008908,0.009727,0.00898,
C     &              0.011145,0.00898,0.009639,0.010422,0.010422,
C     &              0.010422,0.010422,0.008877,0.00898,0.00898/

      DATA MYPI/3.14159/

      CALL DBCHK (DEBUG,'FMCROWE',7,ICYC)
      IF (DEBUG) WRITE(JOSTND,'('' ENTERING FMCROWE'')')

C     FIND VARIANT - ROUTINES VARY FOR HT/DBH AND HT-AT-DIAMETER CALCULATIONS

      CALL VARVER(VVER)

C     GET SOME VARIABLES YOU'LL NEED.

      DX = D            ! STORE ORIGINAL D, H
      HX = H
      C  = REAL(IC)
      PULPVO = .TRUE.
      SWVOL  = .FALSE.

C  INITIALIZE ALL THE CANOPY COMPONENTS TO ZERO, AND SKIP THE REST
C  OF THIS LOOP IF THE TREE HAS NO DIAMETER, OR HEIGHT.

      DO J = 0,5
        XV(J) = 0.0
        IF (J.GT.0 .AND. J.LT.5) UMBTW(J) = 0
      ENDDO
      FOL    = 0.0
      TTOPW  = 0.0
      STUMPV = 0.0
      STUMPB = 0.0
      LILPCE = 0.0

      IF ((D .EQ. 0.0) .OR. (H .EQ. 0.0)) GOTO 999

C  SET SOME STUFF UP SO THAT FOR TREES NEAR THE DBH BREAKPOINT (4")
C  A WEIGHTED AVERAGE OF THE SMALL AND LARGE TREE EQUATIONS ARE USED
C  TO PREDICT TTOPW.

      DBHCUT = 4.0
      DCTLOW = 3.0
      DCTHGH = 5.0

C  SET WEIGHTS BETWEEN LG. AND SM. MODELS FOR TTOPW.

      XVAL(1) = DCTLOW
      XVAL(2) = DBHCUT
      XVAL(3) = DCTHGH
      SMWGT   = ALGSLP(D,XVAL,YVAL,3)

C       FIRST WE GET THE TOTAL BIOMASS OF AN INDIVIDUAL CROWN. THESE
C       ESTIMATES ARE FROM SMITH (RES. PAP. NC-268). OR TREES LESS THAN 5
C       INCHES DBH, WE SCALE BACK THE ESTIMATE OF A 5 INCH TREE BY HT.

C       HTDBH IS CALLED FOR CA,SN,PN,WC,WS(SOME SPECIES) -FFE;
C       STRAIGHT DUBBING IS USED FOR CR-, UT-, TT-FFE, WS(SOME SPECIES)

      IF (D .LT. 5.0) THEN
        D = 5.0
        LHTDBH=.FALSE.
        IF(VVER(1:2) .EQ. 'WS')THEN
          SELECT CASE (SPIW)
          CASE(9:10,14:17,19:20,25:27,41)
            IF(IABFLG(SPIW).EQ.1)THEN
              LHTDBH=.TRUE.
            ENDIF
          END SELECT
        ENDIF
        IF (VVER(1:2) .EQ. 'CA' .OR.
     >      VVER(1:2) .EQ. 'EC' .OR.
     >      VVER(1:2) .EQ. 'SN' .OR.
     >      VVER(1:2) .EQ. 'PN' .OR.
     >      VVER(1:2) .EQ. 'WC' .OR.
     >      VVER(1:2) .EQ. 'SO' .OR.
     >     (VVER(1:2) .EQ. 'WS' .AND. LHTDBH)) THEN
          ! CALL HTDBH(IFOR,IGL,SPIW,D,H,0) - needs to be reconciled
        ELSE
          IF(IABFLG(SPIW).EQ.1) THEN
            AX = HT1(SPIW)
          ELSE
            AX = AA(SPIW)
          ENDIF
          H = EXP(AX + HT2(SPIW)/(D + 1.0)) + 4.5
        ENDIF
      ENDIF

      XNEG1  = -1.0
      LMERCH = .FALSE.
      CALL FMSVL2(SPIW,D,H,XNEG1,VT,LMERCH,DEBUG,JOSTND)
      BOLEWW = (SG * VT / P2T)
      BOLEBV = VT * BRKPCT(SPIE)
      BOLEBW = BOLEBV * BKPPCF(SPIE)
      TBOLEW = BOLEWW + BOLEBW

      SELECT CASE (SPIE)

C       pines
        CASE (4:14)
          TTOPW = (0.092 + (1.0/D**1.628)) * TBOLEW

C       other softwoods
        CASE (1:3,15:17,88)
          TTOPW = (0.061 + (1.0/D**0.659)) * TBOLEW

C       aspen
        CASE (61)
          TTOPW = (0.106 + (1.0/D**0.832)) * TBOLEW

C       other hardwoods
        CASE (18:60,62:87,89,90)
          TTOPW = (1.0/D**0.471) * TBOLEW

      END SELECT

C       RESET DIAMETER AND HEIGHT

      IF (DX .LT. 5.0) THEN
        TTOPW = HX / H * TTOPW
        D = DX
        H = HX
      ENDIF
      IF (DEBUG) WRITE(JOSTND,*) 'D = ',D,'H = ',H,'TTOPW = ',TTOPW

C  NOW LETS GET FOLIAGE ESTIMATES FROM JENKINS ET. AL. (FOR. SCI. 49(1))
C  FOR TREES LESS THAN 1 INCH, GET THE 1 INCH ESTIMATE AND SCALE BACK

      IF (DEBUG) WRITE(JOSTND,*) 'ABOUT TO CALC FOLIAGE'
      IF (D .LT. 1.0) THEN
        D = 1.0
      ENDIF
      SELECT CASE (SPIE)

C       aspen/alder/cottonwood/willow
        CASE (60,61,81)
          TOTABV = EXP(-2.2094 + 2.3867*LOG(D*2.54))

C       soft maple/birch
        CASE (19:21,24,25)
          TOTABV = EXP(-1.9123 + 2.3651*LOG(D*2.54))

C       mixed hardwood
        CASE (23,26,28:32,34:59,62,80,82:87,89,90)
          TOTABV = EXP(-2.4800 + 2.4835*LOG(D*2.54))

C       hard maple/oak/hickory/beech
        CASE (18,22,27,33,63:79)
          TOTABV = EXP(-2.0127 + 2.4342*LOG(D*2.54))

C       cedar/larch (taxodiaceae is put here)
        CASE (2,15,16)
          TOTABV = EXP(-2.0336 + 2.2592*LOG(D*2.54))

C       true fir/hemlock
        CASE (1,17)
          TOTABV = EXP(-2.5384 + 2.4814*LOG(D*2.54))

C       pine
        CASE (4:14,88)
          TOTABV = EXP(-2.5356 + 2.4349*LOG(D*2.54))

C       spruce
        CASE (3)
          TOTABV = EXP(-2.0773 + 2.3323*LOG(D*2.54))

      END SELECT

      SELECT CASE (SPIE)

C       hardwoods
        CASE (18:87,89,90)
          FOL = EXP(-4.0813 + 5.8816/(D*2.54))

C       softwoods
        CASE (1:17,88)
          FOL = EXP(-2.9584 + 4.4766/(D*2.54))

      END SELECT

C     RESET D

      FOL = FOL * TOTABV * 2.2046
      IF (DX .LT. 1.0) THEN
        D = DX
        FOL = D * FOL
      ENDIF

C     FOR SMALL TREES (< 4 INCH) WE WANT TO USE JENKIN'S ABOVE GROUND
C     BIOMASS EQUATIONS INSTEAD.  SINCE SMALL TREES ARE UNMERCHANTABLE, THE
C     "CROWN" IS REALY THE WHOLE TREE.  SCALE BACK ESTIMATE OF 1 INCH TREE
C     FOR TREES LESS THAN 1 INCH, LIKE IS DONE WITH FOLIAGE.  WE USE
C     JENKINS HERE, INSTEAD OF SCALING BACK THE SMITH EQUATIONS, BECAUSE
C     IT IS NOT CLEAR WHAT WE WOULD ACTUALLY BE CALCULATING BY SCALING BACK
C     SMITHS EQUATIONS.  FOR TREES CLOSE TO THE 4 INCH BREAKPOINT, WE USE A
C     WEIGHTED AVERAGE TO SMOOTH THE TRANSITION AND MINIMIZE JUMPINESS WHEN
C     GOING FROM ONE EQUATION TO THE NEXT.

      TEMP = TOTABV * 2.2046
      IF (D .LT. 1.0) TEMP = D * TOTABV * 2.2046
      TTOPW = TTOPW * (1.0 - SMWGT) + TEMP * SMWGT

      IF (DEBUG) WRITE(JOSTND,*) 'D = ',D,'H = ',H,'FOL = ',FOL

C     NOW WE NEED TO ALLOCATE THE CROWN BIOMASS TO DIFFERENT SIZE CLASSES.
C     EACH SPECIES IS MAPPED TO EITHER SHORTLEAF PINE, ASPEN, RED OAK, OR
C     MAPLE, SINCE THESE ARE THE SPECIES WE HAVE SOME SORT OF SIZE
C     BREAKDOWN FOR.  REFERENCES ARE 1)LOOMIS AND BLANK, 2) LOOMIS, PHARES,
C     AND CROSBY, 3) LOOMIS AND ROUSSOPOULOS AND 4) SNELL AND LITTLE

C     P1 = PROPORTION IN 0-.25 INCH CLASS
C     P2 = PROPORTION IN 0-1 INCH CLASS
C     P3 = PROPORTION IN 0-3 INCH CLASS

C     SNELL AND LITTLE DO IT A LITTLE DIFFERENTLY.  FOR MAPLE,
C     F1 = PROPORTION OF FOLIAGE
C     F2 = PROPORTION OF FOLIAGE + 0-.25
C     F3 = PROPORTION OF FOLIAGE + 0-1 INCH
C     F4 = PROPORTION OF FOLIAGE + 0-3 INCH

      IF (DEBUG) WRITE(JOSTND,*) 'ABOUT TO CALC PROPORTIONS'
      IF (DEBUG) WRITE(JOSTND,*) 'SPIE = ',SPIE, 'SPIW = ', SPIW,
     >  'D = ',D, 'C = ',C

      P1 = 0.0
      P2 = 0.0
      P3 = 0.0
      F1 = 0.0
      F2 = 0.0
      F3 = 0.0
      F4 = 0.0

      SELECT CASE (SPIE)

C       red oak
        CASE (23,27:50,52:55,57:59,63:80,82,83,89,90)
          P1 =  6.4735*(D**(-1.1313))*(C**(-0.5777))
          P2 = 36.8351*(D**(-0.9345))*(C**(-0.7014))
          P3 = 28.2916*(D**(-0.8658))*(C**(-0.4084))

C       shortleaf pine
        CASE (1:17,88)
          P1 = 3.525*(D**(-0.778))*(C**(-0.412))
          P2 = 5.989*(D**(-0.565))*(C**(-0.346))
          P3 = 8.585*(D**(-0.517))*(C**(-0.223))
          IF (D .LE. 1.5) P1 = 0.5
          IF (D .LE. 1.5) P2 = 1.0
          IF ((D .LE. 10.5) .OR. (C .LE. 35)) P3 = 1

C       aspen
        CASE (24:26,51,56,60:62,81,84:87)
          P1 = 1.856*(D*2.54)**(-0.773)
          P2 = 5.317*(D*2.54)**(-0.718)
          P3 = 1.793*(D*2.54)**(-0.185)

C       maple
        CASE (18:22)
          F1 = 1.0/(4.6762 + 0.1091*D**2.0390)
          F2 = 1.0/(3.3212 + 0.0777*D**2.0496)
          F3 = 1.0/(0.9341 + 0.0158*D**2.1627)
          F4 = 1.0/(0.8625 + 0.0093*D**1.7070)
          IF (D .LT. 1.9) F3 = 1.0
          IF (D .LT. 4.8) F4 = 1.0

      END SELECT

C     BECAUSE THE ABOVE EQUATIONS THAT PREDICT PROPORTIONS IN EACH SIZE
C     CLASS ARE BASED ON DIFFERENT TOP ASSUMPTIONS, WE NEED TO GET THE
C     BIOMASS IN THE UNMERCH. TIP (BOLEWOOD ABOVE 4 INCH TOP DIAM) TO
C     REALIGN THE PROPORTIONS.  FIRST, WE GET THE HEIGHT AT A 4 IN TOP
C     DIAMETER.  ASSUMING A CONE, WE CAN GET VOLUME, CONVERT TO BIOMASS AND
C     ALSO BREAK THE CONE UP INTO PIECES TO FIGURE OUT WHAT GOES IN EACH
C     SIZE CLASS.

C     TO GET THE HEIGHT AT A 4 INCH TOP, WE NEED TO FIRST DO SOME CALCS,
C     LIKE IN SN\VARVOL.F

C     ASSIGN GEOGRAPHIC VARIANT AND GROUPING CODE BASED ON FOREST AND
C     DISTRICT.  THIS DETERMINES WHICH EQUATION R8VOL USES.

      IF (DEBUG) WRITE(JOSTND,*) 'ABOUT TO CALC BOLE TIP'

      J = KODIST
      IF(ISEFOR .EQ. 801) THEN
        IGAC = IALGA(J)
      ELSEIF(ISEFOR .EQ. 802)THEN
        IGAC=IDBGA(J-10)
      ELSEIF(ISEFOR .EQ. 803)THEN
        IGAC=IGAGA(J)
      ELSEIF(ISEFOR .EQ. 804)THEN
        IGAC=ITNGA(J)
      ELSEIF(ISEFOR .EQ. 805)THEN
        IGAC=IFLGA(J)
      ELSEIF(ISEFOR .EQ. 806)THEN
        IGAC=IKIGA(J)
      ELSEIF(ISEFOR .EQ. 807)THEN
        IGAC=IMSGA(J)
      ELSEIF(ISEFOR .EQ. 808)THEN
        IGAC=IGWGA(J)
      ELSEIF(ISEFOR .EQ. 809)THEN
        IGAC=IARGA(J)
      ELSEIF(ISEFOR .EQ. 810)THEN
        IGAC=IOZGA(J)
      ELSEIF(ISEFOR .EQ. 811)THEN
        IGAC=INCGA(J)
      ELSEIF(ISEFOR .EQ. 812)THEN
        IGAC = ISCGA(J)
      ELSE
        IGAC = ITXGA(J)
      ENDIF

C     NOW GET THE HEIGHT (HTF) AT A 4 INCH TOP DIAM (IB)

      IF (D .GT. 4.0) THEN

        IF (VVER(1:2) .EQ. 'SN') THEN
! FFE-On not yet implemented. This need checking.
!          CALL SEVLHT(D,H,PULPVO,SWVOL,HTF,SPIE,DEBUG,IGAC,SNSP(SPIE))
! 
        ELSE
          HTF = H * (((BHAT*4.0)/D)/(1.0 - (AHAT*4.0/D))) ! FROM **R1D2H**
        ENDIF

C       CALCULATE TOTAL VOLUME OF UNMERCH TIP

        TEMP = (H - HTF)*4*4*MYPI/12/12/12
        UMBTW(4)=(SG * TEMP / P2T)

C       CALCULATE AMOUNT IN DIFFERENT SIZE CLASSES
C       UMBTW = UNMERCHANTABLE BOLE TIP WEIGHT BY SIZE CLASS.
C       (1 = 0-.25, 2 = 0-1, 3 = 0-3, 4 = 0 - 4)
        ANGLE = ATAN((H - HTF)/2.0)

        DO J = 1,3
          TEMPHT = DBRK(J)/2*TAN(ANGLE)
          TEMP = (TEMPHT)*DBRK(J)*DBRK(J)*MYPI/12/12/12
          UMBTW(J) = (SG * TEMP / P2T)
        ENDDO

C       CALCULATE THE AMOUNT IN THE LITTLE MISSING PIECE, I.E. THE AMOUNT
C       MISSING DUE TO THE FACT THAT THE VOLUME EQUATIONS GO TO 4 INCHES DIB
C       AND THE CROWN EQUATIONS START AT 4 INCHES DOB.
C       THIS ENTAILS USING BRATIO TO GET THE DIB THAT CORRESPONDS TO 4 IN DOB
C       AND GETTING THE HEIGHT AT THIS DIAMETER.  THIS DIB VALUE WILL BE
C       BETWEEN 3.2 & 4 INCHES. TO GET THE HT AT THIS DIB, MUST TRICK SEVLHT.
C       THIS LILPCE NEEDS TO BE SUBRACTED FROM UMBTW, SINCE THIS PIECE
C       IS NOT INCLUDED IN SMITH'S CROWN BIOMASS PREDICTIONS.  LATER IT WILL
C       BE ADDED BACK INTO CROWNW, SO THE PIECE IS NOT EXCLUDED.

        IF (VVER(1:2) .EQ. 'SN') THEN
          DIB = 4 * BRATIO(SPIW,D,H)
          REALTOPD = TOPD(SPIW)
          TOPD(SPIW) = DIB
! FFE-On not yet implemented. This need checking.
!          CALL SEVLHT(D,H,PULPVO,SWVOL,HTLP,SPIE,DEBUG,IGAC,
!     &                                             SNSP(SPIE))
! 
          TOPD(SPIW) = REALTOPD
          LILPCE = MYPI*(HTLP - HTF)/12/12/12*(4*4 + 4*DIB + DIB*DIB)
          LILPCE = LILPCE * SG/P2T
          UMBTW(4) = UMBTW(4) - LILPCE
        ENDIF

      ELSE

C       IF TREE IS LESS THAN 4" DBH, DO THE SAME THING
C       FIRST CALCULATE TOTAL BIOMASS OF STEMWOOD ABOVE BREAST HEIGHT

        IF (H .GT. 4.5) THEN
          TEMP = (H - 4.5)*D*D*MYPI/12/12/12
          UMBTW(4)=(SG * TEMP / P2T)

C         CALCULATE AMOUNT IN DIFFERENT SIZE CLASSES
C         (1 = 0-.25, 2 = 0-1, 3 = 0-3, 4 = 0 - 4)

          ANGLE = ATAN((H - 4.5)/(D/2.0))
          DO J = 1,3
            IF ((J .EQ. 1) .OR.
     &           (J .GT. 1 .AND. D .GT. DBRK(J-1))) THEN
              TEMPD = MIN(DBRK(J), D)
              TEMPHT = TEMPD/2*TAN(ANGLE)
              TEMP = (TEMPHT)*TEMPD*TEMPD*MYPI/12/12/12
              UMBTW(J) = (SG * TEMP / P2T)
            ENDIF
          ENDDO
        ENDIF

C       NOW ADD STEM MATERIAL LESS THAN 4.5 FT IN HEIGHT.  ASSUME A CYLINDER.

        TEMP = MYPI*D*D/4/12/12*MIN(4.5,H)
        IF (D .LE. 0.25) THEN
          K = 1
        ELSEIF (D .LE. 1.0) THEN
          K = 2
        ELSEIF (D .LE. 3.0) THEN
          K = 3
        ELSE
          K = 4
        ENDIF
        DO J = K,4
          UMBTW(J) = UMBTW(J) + TEMP
        ENDDO
      ENDIF

C     CALCULATE THE AMOUNT IN THE STUMP (AS IN SMITH(NC-168)).  THIS IS
C     CURRENTLY COMMENTED OUT, SINCE WE ARE NOT SURE WHERE TO PUT STUMP
C     BIOMASS.  THIS MAY CHANGE IN THE FUTURE.

C        STUMPV = STMPCOEF(ISPEC)*D*D
C        STUMPB = V2T(ISPEC)/P2T*STUMPV +
C     &             BRKPCT(ISPEC)*STUMPV*BKPPCF(ISPEC)

      IF (TTOPW .LT. 0) TTOPW = 0
      IF (STUMPB .LT. 0) STUMPB = 0
      IF (LILPCE .LT. 0) LILPCE = 0
      IF (FOL .LT. 0)    FOL = 0
      IF (P1 .LT. 0.0)   P1 = 0.0
      IF (P2 .LT. 0.0)   P2 = 0.0
      IF (P3 .LT. 0.0)   P3 = 0.0
      IF (P1 .GT. 1.0)   P1 = 1.0
      IF (P2 .GT. 1.0)   P2 = 1.0
      IF (P3 .GT. 1.0)   P3 = 1.0
      IF (P2 .LT. P1)    P2 = P1
      IF (P3 .LT. P2)    P3 = P2
      IF (F1 .LT. 0.0)   F1 = 0.0
      IF (F2 .LT. 0.0)   F2 = 0.0
      IF (F3 .LT. 0.0)   F3 = 0.0
      IF (F4 .LT. 0.0)   F4 = 0.0
      IF (F1 .GT. 1.0)   F1 = 1.0
      IF (F2 .GT. 1.0)   F2 = 1.0
      IF (F3 .GT. 1.0)   F3 = 1.0
      IF (F4 .GT. 1.0)   F4 = 1.0
      IF (F2 .LT. F1)    F2 = F1
      IF (F3 .LT. F2)    F3 = F2
      IF (F4 .LT. F3)    F4 = F3
      IF (UMBTW(1) .LT. 0) UMBTW(1) = 0
      IF (UMBTW(2) .LT. 0) UMBTW(2) = 0
      IF (UMBTW(3) .LT. 0) UMBTW(3) = 0
      IF (UMBTW(4) .LT. 0) UMBTW(4) = 0
      IF (UMBTW(2) .LT. UMBTW(1)) UMBTW(2) = UMBTW(1)
      IF (UMBTW(3) .LT. UMBTW(2)) UMBTW(3) = UMBTW(2)
      IF (UMBTW(4) .LT. UMBTW(3)) UMBTW(4) = UMBTW(3)

C  WHEN CALCULATING CROWN BIOMASS FOR EACH SIZE CLASS, ADJUST THE VALUES
C  BASED ON THE UNMERCHANTABLE STEMWOOD.  THIS HELPS CORRECT THE PROBLEM
C  THAT THE UNMERCH. STEMWOOD WASN'T INCLUDED WHEN PREDICTING
C  PROPORTIONS IN EACH SIZE CLASS (IN LITERATURE).

      SELECT CASE (SPIE)

C       PROPORTION ESTIMATES FROM MAPLE AND SHORTLEAF PINE DID NOT SEEM
C       TO INCLUDE ANY BOLEWOOD--JUST BRANCHWOOD

        CASE (18:22) ! maple
          IF (TTOPW .LT. UMBTW(4)) TTOPW = UMBTW(4)
          XV(0)=FOL
          XV(1)=(TTOPW-UMBTW(4))*(F2-F1)+UMBTW(1)
          XV(2)=(TTOPW-UMBTW(4))*(F3-F2)+(UMBTW(2)-UMBTW(1))
          XV(3)=(TTOPW-UMBTW(4))*(F4-F3)+(UMBTW(3)-UMBTW(2))
          XV(4)=(TTOPW-UMBTW(4))*(1-F4)+(UMBTW(4)-UMBTW(3))
          XV(5)=0

        CASE (1:17,88) ! shortleaf pine
          IF (TTOPW .LT. UMBTW(4)) TTOPW = UMBTW(4)
          XV(0)=FOL
          XV(1)=(TTOPW-UMBTW(4))*P1+UMBTW(1)
          XV(2)=(TTOPW-UMBTW(4))*(P2-P1)+(UMBTW(2)-UMBTW(1))
          XV(3)=(TTOPW-UMBTW(4))*(P3-P2)+(UMBTW(3)-UMBTW(2))
          XV(4)=(TTOPW-UMBTW(4))*(1-P3)+(UMBTW(4)-UMBTW(3))
          XV(5)=0

C       ASPEN CROWN PROPORTION PAPER INCLUDES BOLEWOOD LESS THAN .25 INCHES

        CASE (24:26,51,56,60:62,81,84:87) ! aspen
          IF (TTOPW .LT. (UMBTW(4) - UMBTW(1)))
     >                        TTOPW = UMBTW(4) - UMBTW(1)
          XV(0)=FOL
          XV(1)=(TTOPW-UMBTW(4)+UMBTW(1))*P1
          XV(2)=(TTOPW-UMBTW(4)+UMBTW(1))*(P2-P1)+
     >             (UMBTW(2)-UMBTW(1))
          XV(3)=(TTOPW-UMBTW(4)+UMBTW(1))*(P3-P2)+
     >             (UMBTW(3)-UMBTW(2))
          XV(4)=(TTOPW-UMBTW(4)+UMBTW(1))*(1-P3)+
     >             (UMBTW(4)-UMBTW(3))
          XV(5)=0

C       RED OAK CROWN PROPORTION PAPER INCLUDES BOLEWOOD LESS THAN 1 INCH

        CASE (23,27:50,52:55,57:59,63:80,82,83,89,90) ! red oak
          IF (TTOPW .LT. (UMBTW(4) - UMBTW(2)))
     &                           TTOPW = UMBTW(4) - UMBTW(2)
          XV(0)=FOL
          XV(1)=(TTOPW-UMBTW(4)+UMBTW(2))*P1
          XV(2)=(TTOPW-UMBTW(4)+UMBTW(2))*(P2-P1)
          XV(3)=(TTOPW-UMBTW(4)+UMBTW(2))*(P3-P2)+
     &                (UMBTW(3)-UMBTW(2))
          XV(4)=(TTOPW-UMBTW(4)+UMBTW(2))*(1-P3)+
     &                (UMBTW(4)-UMBTW(3))
          XV(5)=0
      END SELECT

C     FOR LARGE TREES ADD THE LILPCE BACK IN TO THE RIGHT SIZE CLASS.

      IF (D .GE. 4.0) THEN
        XV(4) = XV(4) + LILPCE
      ENDIF

  999 CONTINUE

      RETURN
      END
