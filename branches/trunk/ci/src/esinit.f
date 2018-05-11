      SUBROUTINE ESINIT
      IMPLICIT NONE
C----------
C   **ESINIT--CI DATE OF LAST REVISION:   02/16/12
C----------
C     CALLED FROM INITRE, ONLY ONCE, TO INITIALIZE REGEN. MODEL.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'ESPARM.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C
C
      INCLUDE 'ESHAP.F77'
C
C
      INCLUDE 'ESHAP2.F77'
C
C
      INCLUDE 'ESRNCM.F77'
C
C
      INCLUDE 'ESWSBW.F77'
C
C
COMMONS
C----------
      EQUIVALENCE (NSTK,SUMPRB)
      LOGICAL LTEMP,LKECHO
      CHARACTER*40 CNAME
      INTEGER NSTK,I,KODE,JSTND
      REAL X
C----------
C     SPECIES LIST FOR CENTRAL IDAHO VARIANT.
C
C     1 = WESTERN WHITE PINE (WP)          PINUS MONTICOLA
C     2 = WESTERN LARCH (WL)               LARIX OCCIDENTALIS
C     3 = DOUGLAS-FIR (DF)                 PSEUDOTSUGA MENZIESII
C     4 = GRAND FIR (GF)                   ABIES GRANDIS
C     5 = WESTERN HEMLOCK (WH)             TSUGA HETEROPHYLLA
C     6 = WESTERN REDCEDAR (RC)            THUJA PLICATA
C     7 = LODGEPOLE PINE (LP)              PINUS CONTORTA
C     8 = ENGLEMANN SPRUCE (ES)            PICEA ENGELMANNII
C     9 = SUBALPINE FIR (AF)               ABIES LASIOCARPA
C    10 = PONDEROSA PINE (PP)              PINUS PONDEROSA
C    11 = WHITEBARK PINE (WB)              PINUS ALBICAULIS
C    12 = PACIFIC YEW (PY)                 TAXUS BREVIFOLIA
C    13 = QUAKING ASPEN (AS)               POPULUS TREMULOIDES
C    14 = WESTERN JUNIPER (WJ)             JUNIPERUS OCCIDENTALIS
C    15 = CURLLEAF MOUNTAIN-MAHOGANY (MC)  CERCOCARPUS LEDIFOLIUS
C    16 = LIMBER PINE (LM)                 PINUS FLEXILIS
C    17 = BLACK COTTONWOOD (CW)            POPULUS BALSAMIFERA VAR. TRICHOCARPA
C    18 = OTHER SOFTWOODS (OS)
C    19 = OTHER HARDWOODS (OH)
C----------
      CALL PPEATV (LTEMP)
      DO 10 I=1,MAXSP
      HTADJ(I)=0.0
      XESMLT(I)=1.0
   10 CONTINUE
      ITRNRM=0
      NSTK=0
      NBWHST=0
      STOADJ=0.0
      CONFID=5.0
      LINGRW=.FALSE.
      LAUTAL=.FALSE.
      LSPRUT=.TRUE.
      IPRINT=1
      IF(LTEMP) IPRINT=0
      INADV=0
      LOAD=0
      IBLK=0
      MINREP=50
      KDTOLD=-99
      IPINFO=0
      NTALLY=0
      IDSDAT=-9999
      IYRLRM=-9999
      XTES=0.0
      THRES1=0.10
      THRES2=0.30
      CALL ESRNSD (.FALSE.,X)
      NPTIDS=0
      INQUIRE (UNIT=JOREGT,OPENED=LTEMP)
      IF(.NOT.LTEMP) THEN
        CNAME=TRIM(KWDFIL)//'_RegenRpt.txt'
C        CALL MYOPEN (JOREGT,CNAME,4,133, 0,1,1,0,KODE)
        CALL MYOPEN (JOREGT,CNAME,1,133, 0,1,1,0,KODE)
        IF(KODE.GT.0) WRITE(*,'('' OPEN FAILED FOR '',I4)') JOREGT
      ENDIF
      RETURN
C
C
C----------
C     CALLED FROM INITRE WHEN NOTREES KEYWORD IS ENTERED.
C----------
      ENTRY ESEZCR (JSTND,LKECHO)
      INADV=1
      IF(LKECHO)WRITE(JSTND,30)
   30 FORMAT(T12,'(EZCRUISE OPTION IN REGENERATION ESTABLISHMENT ',
     &  'MODEL IS AUTOMATICALLY INVOKED.)'  )
C
      RETURN
      END
