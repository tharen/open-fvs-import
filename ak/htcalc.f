      SUBROUTINE HTCALC(I,ISPC,XSITE,POTHTG)
      IMPLICIT NONE
C----------
C AK $Id$
C----------
C   THIS SUBROUTINE COMPUTES THE HEIGHT INCREMENT GIVEN TREE-SPECIFIC
C   INDEPENDENT VARIABLES SUCH AS DBH, DG AGE ...
C   CALLED FROM **HTGF**
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
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
COMMONS
C------------
C  VARIABLE DECLARATIONS:
C----------
C
      LOGICAL DEBUG
C
      INTEGER I,ISPC,ISPEC,IWHO,I1,PI2,RDZ1
C
      REAL POTHTG,XSITE,RDZ,ZRD(MAXPLT),CRAT,ELEVATN,XMAX
      REAL DLO,DHI,SDIC,SDIC2,A,B,AX,BX,CX,DX,EX,FX,PBAL
      REAL GX,HX,IX,AX1,BX1,CX1,DX1,EX1,FX1,GX1,HX1,IX1
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HTCALC',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE HTCALC  CYCLE =',I5)

C  CALL SDICAL TO LOAD THE POINT MAX SDI WEIGHTED BY SPECIES ARRAY XMAXPT()
C  RECENT DEAD ARE NOT INCLUDED. IF THEY NEED TO BE, SDICAL.F NEEDS MODIFIED
C  TO DO SO. IWHO PARAMETER HAS NO AFFECT ON XMAXPT ARRAY VALUES.
C
      IWHO = 2
      CALL SDICAL (IWHO, XMAX)
C
C  COMPUTE RELATIVE DENSITY (ZEIDI) FOR INDIVIDUAL POINTS.
C  ALL SPECIES AND ALL SIZES INCLUDED FOR THIS CALCULATION.
C
      DLO = 0.0
      DHI = 500.0
      ISPEC = 0
      IWHO = 1
      PI2=INT(PI)
cld      DO I1 = I, PI2
      DO I1 = 1, PI2
         CALL SDICLS (ISPEC,DLO,DHI,IWHO,SDIC,SDIC2,A,B,I1)
         ZRD(I1) = SDIC2
      END DO
C
      POTHTG = 0.
      SELECT CASE(ISPC)
C----------
C  CALCULATE HIEGHT GROWTH FOR BOREAL SPECIES WITH AND WITHOUT PERMAFROST
C----------
      CASE(4:7,13,16:23)
        IF(LPERM) THEN
          IF((HT(I) - 4.5) .LE. 0.0)GO TO 900
          PBAL=PTBALT(I)
          RDZ1=ITRE(I)
          RDZ=ZRD(RDZ1)/XMAXPT(RDZ1)
          CRAT=ICR(I)
          ELEVATN=ELEV*100
          AX1=PERMH1(ISPC)
          BX1=PERMH2(ISPC)
          CX1=PERMH3(ISPC)
          DX1=PERMH4(ISPC)
          EX1=PERMH5(ISPC)
          FX1=PERMH6(ISPC)
          GX1=PERMH7(ISPC)
          HX1=PERMH8(ISPC)
          IX1=PERMH9(ISPC)
          POTHTG=EXP(AX1 + BX1 +CX1*(HT(I))**2 + DX1*LOG(HT(I)) +
     &           EX1*PBAL + FX1*LOG(RDZ) + GX1*LOG(CRAT) +
     &           HX1*ELEVATN + IX1*RDZ)*FINT
        ELSE
          IF((HT(I) - 4.5) .LE. 0.0)GO TO 900
          PBAL=PTBALT(I)
          RDZ1=ITRE(I)
          RDZ=ZRD(RDZ1)/XMAXPT(RDZ1)
          CRAT=ICR(I)
          ELEVATN=ELEV*100
          AX=NOPERMH1(ISPC)
          BX=NOPERMH2(ISPC)
          CX=NOPERMH3(ISPC)
          DX=NOPERMH4(ISPC)
          EX=NOPERMH5(ISPC)
          FX=NOPERMH6(ISPC)
          GX=NOPERMH7(ISPC)
          HX=NOPERMH8(ISPC)
          IX=NOPERMH9(ISPC)
          POTHTG=EXP(AX + BX*(HT(I))**2 + CX*LOG(HT(I)) + DX*PBAL +
     &           EX*LOG(RDZ) + FX*LOG(CRAT) + GX*ELEVATN +
     &           HX*RDZ + IX*LOG(XSITE))*FINT
        ENDIF
C----------
C  CALCULATE HIEGHT GROWTH FOR COASTAL SPECIES
C----------
      CASE(1:3,8:12,14,15)
        IF((HT(I) - 4.5) .LE. 0.0)GO TO 900
        PBAL=PTBALT(I)
        RDZ1=ITRE(I)
        RDZ=ZRD(RDZ1)/XMAXPT(RDZ1)
        CRAT=ICR(I)
        ELEVATN=ELEV*100
        AX=NOPERMH1(ISPC)
        BX=NOPERMH2(ISPC)
        CX=NOPERMH3(ISPC)
        DX=NOPERMH4(ISPC)
        EX=NOPERMH5(ISPC)
        FX=NOPERMH6(ISPC)
        GX=NOPERMH7(ISPC)
        HX=NOPERMH8(ISPC)
        IX=NOPERMH9(ISPC)
        POTHTG=EXP(AX + BX*(HT(I))**2 + CX*LOG(HT(I)) + DX*PBAL +
     &         EX*LOG(RDZ) + FX*LOG(CRAT) + GX*ELEVATN +
     &         HX*RDZ + IX*LOG(XSITE))*FINT
C----------
C  SPACE FOR OTHER SPECIES
C---------
      CASE DEFAULT
        POTHTG = 0.
C
      END SELECT
C
  900 CONTINUE

      IF(DEBUG) WRITE(JOSTND,9)
     & I, ISPC, DBH(I), HT(I), POTHTG, PBAL, RDZ, CRAT, ELEVATN 
    9 FORMAT(' IN HTCALC: I=',I5,' ISPC=',I5,' DBH=',F7.4,' HT=',F8.4,
     & ' POTHTG=',F8.4,' PBAL=',F10.5,' RDZ=',F7.4,' CRAT=',F7.4,
     & ' ELEVATN=',F7.2)
C
      RETURN
      END