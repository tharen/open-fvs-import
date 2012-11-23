      SUBROUTINE VOLS
      IMPLICIT NONE
C----------
C  **VOLS--SEI    DATE OF LAST REVISION:    05/11/11
C----------
C
C  THIS SUBROUTINE CALCULATES TREE VOLUMES TO THREE MERCHANTABILITY
C  STANDARDS, AND COMPUTES DISTRIBUTION AND COMPOSITION VECTORS FOR
C  TOTAL CUBIC VOLUME AND ACCRETION.  TOTAL CUBIC FOOT VOLUME AND
C  MERCHANTABLE CUBIC FOOT VOLUME ARE COMPUTED IN **CFVOL**,
C  **NATCRS**, OR **OCFVOL**.  BOARD FOOT VOLUME IS COMPUTED IN
C  **BFVOL**, **NATCRS**, OR **OBFVOL**.  ADJUSTMENTS ARE MADE FOR
C  TOP DAMAGE AS APPROPRIATE.  ALL VOLUMES ARE THEN ADJUSTED FOR
C  DEFECT.
C
C  NATCRS, OCFVOL, AND OBFVOL ARE ENTRY POINTS IN SUBROUTINE
C  **VARVOL**, WHICH IS VARIANT SPECIFIC.
C
C----------
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
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
      INCLUDE 'GGCOM.F77'
C
C
COMMONS
C
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES.
C
C  SPCCC -- TOTAL CUBIC VOLUME BY SPECIES AND TREE CLASS.
C  SPCAC -- TOTAL CUBIC VOLUME ACCRETION BY SPECIES AND TREE CLASS.
C  SPCMC -- MERCH CUBIC VOLUME BY SPECIES AND TREE CLASS.
C  SPCBV -- MERCH BOARD VOLUME BY SPECIES AND TREE CLASS.
C
C  THESE VALUES DO NOT INCLUDE CYCLE 0 DEAD TREES.
C  IPASS=1 FOR LIVE TREES;  IPASS=2 FOR CYCLE 0 DEAD TREES.
C
C  BTKFLG - LOGICAL VARIABLES TO INDICATE WHETHER THE VOLUME ESTIMATE
C  CTKFLG   NEEDS TO BE ADJUSTED FOR TOPKILL OR NOT.
C           BTKFLG FOR BOARD FOOT VOLUME
C           CTKFLG FOR CUBIC FOOT VOLUME
C           .TRUE.  = ADJUST ESTIMATE FOR TOPKILL
C           .FALSE. = NO ADJUSTMENT NEEDED (ALREADY ACCOUNTED FOR).
C----------
      INTEGER DLIEQN,DLLMOD
      LOGICAL DEBUG
      REAL SPCCC(MAXSP,3),SPCAC(MAXSP,3),SPCBV(MAXSP,3),SPCMC(MAXSP,3)
      REAL DBHCLS(9),P,D,H,BARK,BRATIO
      REAL D2H,VM,VN,VMAX,ALGSLP,VOLCOR
      INTEGER I,J,IPASS,ILOW,IHI,ISPC,IT,IM,ICDF
      LOGICAL TKILL,LCONE,CTKFLG
C----------
C  INITIALIZE DBH CLASSES.
C----------
      DATA DBHCLS/0.0,5.0,10.0,15.0,20.0,25.0,30.0,35.0,40.0/
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'VOLS',4,ICYC)
      DO J=1,2
      DO I=1,MAXTRE
      HT2TD(I,J)=0.
      ENDDO
      ENDDO
      IF (ITRN.LE.0) GOTO 2
      DO 1 I=1,MAXSP
      DO 1 J=1,3
      SPCCC(I,J)=0.0
      SPCAC(I,J)=0.0
      SPCMC(I,J)=0.0
      SPCBV(I,J)=0.0
    1 CONTINUE
    2 CONTINUE
      IPASS=1
      ILOW=1
      IHI=ITRN
C----------
C  CALL VOLKEY TO PROCESS KEYWORDS USED TO CHANGE VOLUME STANDARDS AND
C  EQUATIONS.
C----------
      CALL VOLKEY (DEBUG)

      DO J=1,MAXSP
      IF(BFMIND(J).LT.2.0) BFMIND(J)=2.0
      IF(BFTOPD(J).LT.2.0) BFTOPD(J)=2.0
      ENDDO
C
      IF (ITRN.LE.0) GOTO 205      
C----------
C  ENTER TREE BY TREE LOOP TO CALCULATE VOLUMES AND COMPILE
C  SUMMARY ARRAYS.
C
C  I -- SUBSCRIPT TO TREE RECORD.
C  P -- NUMBER OF TREES PER ACRE REPRESENTED BY TREE I.
C  D -- DIAMETER OF TREE I.
C  H -- HEIGHT OF TREE I.
C  ISPC -- SPECIES OF TREE I.
C  WK5 -- ARRAY CONTAINING TOTAL ANNUAL CUBIC VOLUME ACCRETION
C    PER ACRE FOR EACH TREE.  THIS ARRAY IS NOT LOADED
C    IF LSTART IS TRUE.
C  VN -- USED TO TEMPORARILY STORE TOTAL CUBIC VOLUME FOR TREE I.
C----------
   10 CONTINUE
      DO 200 I=ILOW,IHI
      WK5(I)=0.0
      P=PROB(I)
      IF(P.LE.0.0) GO TO 200
      ISPC=ISP(I)
      D=DBH(I)
      H = HT(I)
C----------
C  INITIALIZE TOP KILL FLAG FOR NEXT TREE; IF TOPKILLED, ASSIGN H TO 
C  NORMHT.
C----------
      TKILL = H.GE.4.5 .AND. ITRUNC(I).GT.0
      IF(TKILL) H=NORMHT(I)/100.0
C----------
C  IF NOT INITIAL SUMMARY, ADD DG TO DBH; ASSIGN D2H.
C----------
      BARK=BRATIO(ISPC,D,H)
      IF(.NOT.LSTART) D=D+DG(I)/BARK
      D2H=D*D*H
C**************************************************
C              CUBIC VOLUME SECTION               *
C**************************************************
C----------
C  INITIALIZE VOLUME ESTIMATES.
C----------
      VN=0.
      VM=0.
      VMAX=0.
      IF(DEBUG)WRITE(JOSTND,*)' CUBIC SECTION, I,ISPC,METHC= ',
     &I,ISPC,METHC(ISPC)
C----------
C  CALCULATE TOTAL CUBIC FOOT VOLUME. CORRECT FOR TOP KILL IF NEEDED.
C----------
      IT=I
      CALL CFVOL (ISPC,D,H,D2H,VN,VM,VMAX,TKILL,LCONE,BARK,ITRUNC(I),
     1              CTKFLG)
      IF(CTKFLG .AND. TKILL .AND. VMAX .GT. 0.)
     1 CALL CFTOPK (ISPC,D,H,VN,VM,VMAX,LCONE,BARK,ITRUNC(I))
C----------
C  LOAD WK1 WITH MERCH CUBIC VOLUME PER TREE.
C----------
      WK1(I)=VM
C----------
C  SUMMARIZE VOLUME BY SPECIES AND TREE CLASS.  IF LSTART IS
C  FALSE, LOAD WK5 AND SUMMARIZE ACCRETION BY SPECIES AND TREE
C  CLASS. DO NOT DO THIS FOR CYCLE 0 DEAD TREES.
C----------
      IF(IPASS .EQ. 2) GO TO 15
      IM=IMC(I)
      IF(.NOT.LSTART) THEN
        IF(CFV(I).GT.VN)THEN
          WK5(I)=0.
        ELSE
          WK5(I)=(VN-CFV(I))*P/FINT
        ENDIF
        SPCAC(ISPC,IM)=SPCAC(ISPC,IM)+WK5(I)
      ENDIF
      SPCCC(ISPC,IM)=SPCCC(ISPC,IM)+VN*P
C----------
C  LOAD CFV WITH TOTAL CUBIC VOLUME PER TREE.
C----------
   15 CONTINUE
      CFV(I)=VN
C----------
C  SEI VARIANT -- SUMMARIZE MERCH AND JUMP TO NEXT RECORD
C----------
      IF (METHC(ISPC) .EQ. 4) THEN
        SPCMC(ISPC,IM)=SPCMC(ISPC,IM)+WK1(I)*P
        GOTO 200
      ENDIF
C----------
      ICDF= DEFECT(I)/1000000
      IF(WK1(I).GT.0.0 .AND. LCVOLS) THEN
C----------
C       COMPUTE DEFECT CORRECTION FACTOR FOR CUBIC FOOT VOLUME.
C       TAKE LARGEST OF 1) INPUT CF DEFECT PERCENT, 2) COMPUTED LINEAR
C       INTERPOLATION VALUE, OR 3) COMPUTED LOG-LINEAR MODEL VALUE.
C----------
        DLIEQN=NINT(ALGSLP(D,DBHCLS,CFDEFT(1,ISPC),9) * 100.)
        IF(DLIEQN.GT.ICDF) ICDF=DLIEQN
        IF(CFLA0(ISPC).EQ.0.0 .AND. CFLA1(ISPC).EQ.1.0) THEN
          VOLCOR=WK1(I)
        ELSE
          VOLCOR=EXP(CFLA0(ISPC)+CFLA1(ISPC)*ALOG(WK1(I)))
        ENDIF
        DLLMOD=NINT(((WK1(I)-VOLCOR)/WK1(I)) * 100.)
        IF(DLLMOD.GT.ICDF) ICDF=DLLMOD
        IF(ICDF.GT.99) ICDF=99
        IF(ICDF.LT. 0) ICDF= 0
      ENDIF
C----------
C        CORRECT MERCHANTABLE CUBIC VOLUME FOR FORM AND DEFECT.
C        CONSIDER 99% DEFECT AS 100% DEFECT.
C----------
      IF(ICDF.LT.99) THEN
        WK1(I)=WK1(I)*(1.-FLOAT(ICDF)/100.)
      ELSE
        WK1(I)=0.
      ENDIF
      IF(IPASS .EQ. 1) SPCMC(ISPC,IM)=SPCMC(ISPC,IM)+WK1(I)*P
C----------
C  CALL ECON EXTENSION TO PROCESS VOLUME INFORMATION
C----------
      IF (WK1(I) .GT. 0.0) CALL ECVOL(ISPC,IT,LOGDIA,LOGVOL,.TRUE.)
C**************************************************
C           BOARD VOLUME SECTION                  *
C**************************************************
C----------
C  RESET NEGATIVE VOLUMES TO ZERO AND COMPILE TOTAL.
C----------
      BFV(I)=0.0
  150 CONTINUE
      IF(IPASS .EQ. 1) SPCBV(ISPC,IM)=SPCBV(ISPC,IM)+BFV(I)*P
C**************************************************
C     Board feet not computed in this variant
C**************************************************

C----------
C  PRINT DEBUG OUTPUT IF DESIRED
C----------
      IF(.NOT.DEBUG) GO TO 200
      WRITE(JOSTND,9000)I,VN,WK1(I),OMCCUR(7),OBFCUR(7),WK5(I),CFV(I),
     &     SPCAC(ISPC,1),SPCAC(ISPC,2),SPCAC(ISPC,3),SPCCC(ISPC,1),
     &     SPCCC(ISPC,2),SPCCC(ISPC,3),ISPC,D,H
 9000 FORMAT(' IN VOLS, I=',I4,' VN=',E15.6,' WK1=',E15.6,' OMCCUR=',
     &  E15.6,' OBFCUR=',E15.6,/,'  WK5=',E15.6,' CFV=',E15.6,
     &  ' SPCAC=',3(E15.6,',')/'  SPCCC=',3(E15.6,','),' ISPC=',I2,
     &  ' DBH=',E11.2,' NORMAL HT=',E11.2)
C----------
C  END OF TREE LOOP.
C----------
  200 CONTINUE
  205 CONTINUE
      IF(IPASS .EQ. 2) GO TO 250
C----------
C  DETERMINE SPECIES-TREE CLASS COMPOSITION FOR ALL VOLUME STANDARDS.
C----------
      CALL COMP(OSPCV,IOSPCV,SPCCC)
      CALL COMP(OSPBV,IOSPBV,SPCBV)
      CALL COMP(OSPMC,IOSPMC,SPCMC)
C----------
C  DETERMINE SPECIES-TREE CLASS COMPOSITION AND PERCENTILE POINTS IN
C  THE DISTRIBUTION OF DIAMETERS FOR ANNUAL TOTAL CUBIC FOOT ACCRETION.
C  BYPASS IF LSTART IS TRUE.
C----------
      IF(LSTART) GO TO 210
      CALL COMP(OSPAC,IOSPAC,SPCAC)
      CALL PCTILE(ITRN,IND,WK5,WK3,OACC(7))
      CALL DIST(ITRN,OACC,WK3)
  210 CONTINUE
C----------
C  CALCULATE VOLUMES FOR CYCLE 0 DEAD TREES.
C----------
      IF(IREC2 .GT. MAXTRE) GO TO 250
      IPASS=2
      ILOW=IREC2
      IHI=MAXTRE
      GO TO 10
C----------
C  END OF VOLS.
C----------
  250 CONTINUE
      RETURN
      END
