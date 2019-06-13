      SUBROUTINE LOGS(DBH,HT,IBCD,BDMIN,ISP,STMP,BV)
      IMPLICIT NONE
C----------
C AK $Id$
C----------
C  REGION 5 BOARD FOOT VOLUME MODELS.
C  TAPER EQUATIONS BY G.S.BIGING
C  BY K.STUMPF, ADAPTED BY B.KRUMLAND, P.J.DAUGHERTY
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
COMMONS
C
C----------
C  VARIABLE DECLARATIONS:
C----------

      INTEGER IBCD,IDU,ISP,ITEM,J,JSP,N,NLOGS

      INTEGER IMAP(MAXSP)

      REAL AH,B1,B2,BDMIN,BV,BVL,D,DBH,DIBAHI,DTOP,DU,FRAC,HI,HT
      REAL HTM,QTLN,S1,SLN,STMP,TBV,TRIM,X,Z1

      REAL SF(4,2),TPCF1(6),TPCF2(6),XPS(6)

C----------
C  DATA STATEMENTS:
C----------
      DATA TPCF1/
     & 1.01959, 1.06932, 1.07134, 1.02929, 1.09262, 1.07588/

      DATA TPCF2/
     & 0.33567, 0.41563, 0.47216, 0.33401, 0.36530, 0.35378/

      DATA XPS/
     & 0.95204, 0.92368, 0.89659, 0.95411, 0.94976, 0.95222/

C     MAPPING OF SPECIES TO ABOVE COEFFICIENTS
C     SPECIES ORDER:
C                 1   2   3   4   5   6   7   8   9   10  11  12
C                 SF  AF  YC  TA  WS  LS  BE  SS  LP  RC  WH  MH
C
C                 13  14  15  16  17  18  19  20  21  22  23
C                 OS  AD  RA  PB  AB  BA  AS  CW  WI  SU  OH
      DATA IMAP / 4,  6,  3,  1,  1,  1,  1,  1,  1,   2,  1,  5,
     &            3,  1,  1,  1,  1,  1,  1,  1,  1,   1,  1 /
C----------
C  DEFINE NOMINAL SCALING STANDARDS: SLN=STANDARD LOG LENGTH;
C  TRIM=KERF.  
C----------
      DATA SLN,TRIM/16.3,0.3/
C----------
C  SCRIBNER VOL. FACTORS FOR SMALL LOGS
C----------
      DATA SF/1.249,1.608,1.854,2.410,1.160,1.400,1.501,2.084/
C----------
C  STATEMENT FUNCTION TO CALC. DIB AT H(I)
C----------
      DIBAHI(HI,HT,B1,B2,D,X)=D*(B1+B2*ALOG(1.-X*(HI/HT)**(1./3.)))
C----------
C  INITIALIZE VOLUME ESTIMATE.
C----------
      BV=0.0
C----------
C   VOLUMES FOR SPECIES (AK OLD: 5 AND 7) ARE CALCULATED FROM FORMULA.
C                       (AK NEW: 11 AND 9)
C----------
      IF (ISP .EQ. 11) THEN
C----------
C       GIANT SEQUOIA FROM WENSEL AND SCHOENHEIDE
C----------
        BVL=-5.66831 + 2.21035*ALOG(DBH) + 0.91921*ALOG(HT)
        BV=EXP(BVL)
        RETURN
      ENDIF
      IF (ISP .EQ. 9) THEN
C----------
C       BLACK OAK EQ FROM PNW 414
C       EQN IS IN CUBIC FEET, APPLY BF/CF RATIO   R.JOHNSON
C----------
        BV = .00124 * DBH**2.68 * HT**0.424
        BV = BV * 5.0
        RETURN
      ENDIF 
C----------
C  VOLUME FOR OTHER SPECIES IS COMPUTED FROM LOG RULE.  JSP MAPS 
C  SPECIES ONTO A TAPER MODEL.
C----------
      JSP=IMAP(ISP)
      DTOP=IBCD
C----------
C  CHECK FOR MERCHANTABILITY LIMITS.
C---------- 
      IF(DBH.LE.DTOP .OR. DBH.LT.BDMIN) GO TO 100
      Z1= EXP((DTOP/DBH - TPCF1(JSP))/TPCF2(JSP)) - 1.
C----------
C  HTM IS TOTAL MERCHANTABLE LENGTH ADJUSTED FOR STUMP HEIGHT.
C  RETURN IF LESS THAN 1/2 LOG.
C----------
      HTM = (Z1/(-XPS(JSP)))**3*HT - STMP
      IF(HTM.LE.(.5*SLN)) GO TO 100
C----------
C  NLOGS IS THE TOTAL NUMBER OF LOGS EXCLUDING THE TOP FULL LOG AND ANY 
C  PARTIAL LOG ABOVE IT.
C----------
      NLOGS = INT(HTM/SLN -1)
      IF(NLOGS.LE.0) GO TO 80
      S1=SLN
      AH=0.0
      BV=0.0
      N=0
      IDU=0
      ITEM=1
   60 CONTINUE  
      DO 70 J=1,NLOGS
        HI = REAL(J)*S1+AH
        DU = DIBAHI(HI,HT,TPCF1(JSP),TPCF2(JSP),DBH,XPS(JSP))
        FRAC=((S1-TRIM)/16.0)
        IF(DU.LE.9.0) THEN
          IDU = INT(DU + .5 - 5.)
          IF(IDU.LE.0) IDU=1
          N = 1
          IF(S1.LT.SLN)N=2
          TBV = SF(IDU,N) * S1
        ELSE
          TBV=((.79*DU -2.0)*DU -4.)*FRAC
        ENDIF
        TBV = INT(TBV/10. + .5) * 10.
        BV=BV+TBV
   70 CONTINUE
      IF(ITEM.EQ.2) GO TO 100
C----------
C  RETURN TO STATEMENT 60 TO COMPUTE VOLUME FOR TOP LOGS.
C----------
   80 ITEM=2
      AH=NLOGS*SLN
      IF(AH.LE.0)AH=0.0
      QTLN= HTM-AH
      NLOGS=2
      IF(QTLN.LT.(1.5*SLN))NLOGS=1
      S1=QTLN/REAL(NLOGS)
      GO TO 60
  100 CONTINUE
      RETURN
      END
