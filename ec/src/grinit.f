      SUBROUTINE GRINIT
      IMPLICIT NONE
C----------
C EC $Id: grinit.f 1930 2017-04-03 19:53:50Z mshettles521 $
C----------
C
C  INITIALIZE PROGNOSIS MODEL VARIABLES
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
      INCLUDE 'WORKCM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'ECON.F77'
C
C
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'SUMTAB.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
      INCLUDE 'CWDCOM.F77'
C
C
      INCLUDE 'CALCOM.F77'
C
C
COMMONS
C----------
      INTEGER I,J,K
      CHARACTER*26 DBLK
      CHARACTER*4 NONE
      CHARACTER*2 ANINDEX
C----------
C  SPECIES LIST FOR EAST CASCADES VARIANT.
C
C   1 = WESTERN WHITE PINE      (WP)    PINUS MONTICOLA
C   2 = WESTERN LARCH           (WL)    LARIX OCCIDENTALIS
C   3 = DOUGLAS-FIR             (DF)    PSEUDOTSUGA MENZIESII
C   4 = PACIFIC SILVER FIR      (SF)    ABIES AMABILIS
C   5 = WESTERN REDCEDAR        (RC)    THUJA PLICATA
C   6 = GRAND FIR               (GF)    ABIES GRANDIS
C   7 = LODGEPOLE PINE          (LP)    PINUS CONTORTA
C   8 = ENGELMANN SPRUCE        (ES)    PICEA ENGELMANNII
C   9 = SUBALPINE FIR           (AF)    ABIES LASIOCARPA
C  10 = PONDEROSA PINE          (PP)    PINUS PONDEROSA
C  11 = WESTERN HEMLOCK         (WH)    TSUGA HETEROPHYLLA
C  12 = MOUNTAIN HEMLOCK        (MH)    TSUGA MERTENSIANA
C  13 = PACIFIC YEW             (PY)    TAXUS BREVIFOLIA
C  14 = WHITEBARK PINE          (WB)    PINUS ALBICAULIS
C  15 = NOBLE FIR               (NF)    ABIES PROCERA
C  16 = WHITE FIR               (WF)    ABIES CONCOLOR
C  17 = SUBALPINE LARCH         (LL)    LARIX LYALLII
C  18 = ALASKA CEDAR            (YC)    CALLITROPSIS NOOTKATENSIS
C  19 = WESTERN JUNIPER         (WJ)    JUNIPERUS OCCIDENTALIS
C  20 = BIGLEAF MAPLE           (BM)    ACER MACROPHYLLUM
C  21 = VINE MAPLE              (VN)    ACER CIRCINATUM
C  22 = RED ALDER               (RA)    ALNUS RUBRA
C  23 = PAPER BIRCH             (PB)    BETULA PAPYRIFERA
C  24 = GIANT CHINQUAPIN        (GC)    CHRYSOLEPIS CHRYSOPHYLLA
C  25 = PACIFIC DOGWOOD         (DG)    CORNUS NUTTALLII
C  26 = QUAKING ASPEN           (AS)    POPULUS TREMULOIDES
C  27 = BLACK COTTONWOOD        (CW)    POPULUS BALSAMIFERA var. TRICHOCARPA
C  28 = OREGON WHITE OAK        (WO)    QUERCUS GARRYANA
C  29 = CHERRY AND PLUM SPECIES (PL)    PRUNUS sp.
C  30 = WILLOW SPECIES          (WI)    SALIX sp.
C  31 = OTHER SOFTWOODS         (OS)
C  32 = OTHER HARDWOODS         (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C  FROM THE EC VARIANT:
C      USE 6(GF) FOR 16(WF)
C      USE OLD 11(OT) FOR NEW 12(MH) AND 31(OS)
C
C  FROM THE WC VARIANT:
C      USE 19(WH) FOR 11(WH)
C      USE 33(PY) FOR 13(PY)
C      USE 31(WB) FOR 14(WB)
C      USE  7(NF) FOR 15(NF)
C      USE 30(LL) FOR 17(LL)
C      USE  8(YC) FOR 18(YC)
C      USE 29(WJ) FOR 19(WJ)
C      USE 21(BM) FOR 20(BM) AND 21(VN)
C      USE 22(RA) FOR 22(RA)
C      USE 24(PB) FOR 23(PB)
C      USE 25(GC) FOR 24(GC)
C      USE 34(DG) FOR 25(DG)
C      USE 26(AS) FOR 26(AS) AND 32(OH)
C      USE 27(CW) FOR 27(CW)
C      USE 28(WO) FOR 28(WO)
C      USE 36(CH) FOR 29(PL)
C      USE 37(WI) FOR 30(WI)
C----------
      DATA DBLK/'                          '/
      DATA NONE/'NONE'/
C----------
      CALL LNKINT
      DO 5 I=1,MAXSP
      SDIDEF(I) = 0.0
      IORDER(I) = 0
      COR(I) = 0.0
      XDMULT(I) = 1.
      XHMULT(I) = 1.
      XRDMLT(I) = 1.
      XRHMLT(I) = 1.
      XMMULT(I) = 1.
      XMDIA1(I) = 0.
      XMDIA2(I) = 99999.
      VEQNNB(I) = '          '
      VEQNNC(I) = '          '
      STMP(I) = 1.0
      TOPD(I) = 4.5
      DBHMIN(I) = 7.0
      FRMCLS(I) = 0.0
      METHB(I) = 6
      METHC(I) = 6
      BFSTMP(I) = 1.0
      BFTOPD(I) = 4.5
      BFMIND(I) = 7.0
      BFLA0(I) = 0.0
      BFLA1(I) = 1.0
      CFLA0(I) = 0.0
      CFLA1(I) = 1.0
      LDGCAL(I) = .TRUE.
      LHTCAL(I) = .TRUE.
      LHTDRG(I) = .FALSE.
      BARANK(I) = 0.0
      MAXSDI(I) = 0
      SITEAR(I) = 0.0
      IABFLG(I) = 1
      LSPCWE(I) = .FALSE.
      CWDS0(I) = 0.
      CWDS1(I) = 0.
      CWDS2(I) = 0.
      CWDS3(I) = 2.
      CWDL0(I) = 0.
      CWDL1(I) = 0.
      CWDL2(I) = 0.
      CWDL3(I) = 2.
      CWTDBH(I) = 0.
      SIZCAP(I,1) = 999.
      SIZCAP(I,2) = 1.
      SIZCAP(I,3) = 0.
      SIZCAP(I,4) = 999.
      JSPIN(I)=3
      LEAVESP(I)=.FALSE.
   5  CONTINUE
      LFLAGV = .FALSE.
      LBAMAX = .FALSE.
      LZEIDE = .TRUE.
      DBHMIN(7) = 6.0
      BFMIND(7) = 6.0
      CFMIN = 0.
      TCFMIN = 0.
      BFMIN = 0.
      BAMIN = 0.
      TCWT = 0.
      SPCLWT = 0.
      PBAWT = 0.
      PCCFWT = 0.
      PTPAWT = 0.
      IREC1 = 0
      RMAI = 50.0
      IREC2 = MAXTP1
      ITHNPI = 1
      ITHNPN = -1
      ITHNPA = 0
C----------
      DO 10 I=1,MAXCYC
      IY(I) = -1
   10 CONTINUE
      DO 11 K=1,7
      ITABLE(K) = 0
   11 CONTINUE
C----------
      MANAGD = 0
      ALPHA = 0.05
      BJPHI = 0.74
      BJTHET = 0.42
      ASPECT = 0.
      LAUTON = .FALSE.
      LFIA = .FALSE.
      AUTMAX = 60.0
      AUTMIN = 45.0
      BAF = 40.
      BAMAX = 0.0
      BRK = 5.0
      DGSD = 1.7
      EFF = 1.0
      ELEV = 45.
      FINT = 10.
      FINTH = 5.
      FINTM = 5.0
      FPA = 300.
      IAGE = 0
      IWORK1(1) = 0
C----------
C  ICL4 IS USED TO IMPLEMENT A NEW OPTION WHICH ALLOWS THE USER TO
C  CONTROL THE NUMBER OF CYCLES A STAND WILL BE TRIPLED.
C  ICL5 IS USED TO CARRY THE ACTUAL INPUT HABITAT CODE.
C----------
      ICL4 = 2
      ICL5 = 999
      ICL6 = 0
      IDG = 0
      IFINT = 10
      IFINTH = 5
      IFOR = 1
      KODFOR = 0
      IFST = 1
      IGL = 1
      IHTG = 0
      IPTINV = -9999
      ITYPE = 0
      KODTYP = 0
      CPVREF='          '
      PCOMX='        '
      IY(1) = 0
      IY(MAXCY1) = -1
      LDCOR2 = .FALSE.
      LDUBDG = .FALSE.
      LEVUSE = .TRUE.
      LFIXSD = .FALSE.
      LHCOR2 = .FALSE.
      LRCOR2 = .FALSE.
      LSUMRY = .FALSE.
      MGMID = NONE
      MORDAT = .FALSE.
      LSTATS = .FALSE.
      LMORT = .FALSE.
      LBVOLS = .FALSE.
      LCVOLS = .FALSE.
      LFIRE = .FALSE.
      LSITE = .FALSE.
      JOCALB = 0
      GROSPC = -1.0
      NCYC = 0
      NONSTK = -9999
      NOTRIP = .FALSE.
      NPLT = DBLK
      DBCN = ' '
      SAMWT = -1E25
      SLOPE = 5.0
      TLAT = 47.
      TLONG = 121.
      ISTATE = 0
      ICNTY = 0
      TFPA = 0.0
      TRM = 1.
      LBKDEN = .FALSE.
      RELDM1 = 0.
      OLDBA = 0.
      ATAVH = 0.
      ATBA = 0.
      ATCCF = 0.
      ORMSQD = 0.
      SDIMAX = 0.0
      SDIBC = 0.
      SDIAC = 0.
      ISISP = 0
      PMSDIL = 55.
      PMSDIU = 85.
      SLPMRT = 0.0
      CEPMRT = 0.0
      IBASP = 0
      IMODTY = 0
      IPHREG = 0
      IFORTP = 0
      FNMIN = 5.
      NCALHT = 5
      ISILFT = 0
      QMDMSB=999.
      SLPMSB=0.
      CEPMSB=0.
      EFFMSB=0.90
      DLOMSB=0.
      DHIMSB=999.
      MFLMSB=1
      DBHZEIDE=0.
      DBHSTAGE=0.
      DR016=0.
      DBHSDI=0.
      JSPINDEF=0
      GLOCCC=0
      CCCOEF=0.01 
C
      DO 30 J=1,9
      DO 20 K=1,MAXSP
      BFDEFT(J,K) = 0.0
      CFDEFT(J,K) = 0.0
   20 CONTINUE
   30 CONTINUE
      DO 40 I=1,21
      DO 35 J=1,3
      LOGDIA(I,J) = 0.
   35 CONTINUE
   40 CONTINUE
      DO 50 I=1,7
      DO 45 J=1,20
      LOGVOL(I,J) = 0.
   45 CONTINUE
   50 CONTINUE
C----------
C  INITIALIZE ECONOMIC VARIABLES.
C----------
      LECBUG = .FALSE.
      LECON  = .FALSE.
C----------
C     INITIALIZE SUBROUTINE SPECIFIC DEBUG.
C----------
      CALL DBINIT
C----------
C  INITIALIZE SUMTAB COMMON VARIABLES
C----------
      MAIFLG = 0
      NEWSTD = 0
      TOTREM = 0.
      AGELST = 0.
      DO 60 I=1,MAXCY1
      BCYMAI(I) = 0.
   60 CONTINUE
C----------
C     INITIALIZE SPECIES AND POINT GROUPS VARIABLES.
C----------
      NPTGRP = 0
      NSPGRP = 0
      DO 70 I=1,30
      DO 65 J=1,52
      ISPGRP(I,J)=0
      IPTGRP(I,J)=0
   65 CONTINUE
   70 CONTINUE
      DO I=1,30
      WRITE(ANINDEX,'(I2)') I
      NAMGRP(I) ='GROUP'//TRIM(ADJUSTL(ANINDEX))
      PTGNAME(I) ='PTGROUP'//TRIM(ADJUSTL(ANINDEX))
      ENDDO
C----------
C     INITIALIZE SITE TREE ARRAY AND COUNT
C----------
      NSITET = 0
      DO 75 I=1,MAXSTR
      DO 74 J=1,6
      SITETR(I,J)=0.
   74 CONTINUE
   75 CONTINUE
C
      RETURN
      END
