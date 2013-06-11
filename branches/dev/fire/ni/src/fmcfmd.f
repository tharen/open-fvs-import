      SUBROUTINE FMCFMD (IYR, FMD)
      IMPLICIT NONE
C----------
C   **FMCFMD FIRE-NI-DATE OF LAST REVISION: 07/15/03
C----------
*     SINGLE-STAND VERSION
*     CALLED FROM: FMBURN
*  PURPOSE:
*     THIS SUBROUTINE RETURNS TWO TYPES OF INFORMATION: THE FUEL MODEL
*     THAT WOULD BE USED IF THE STATIC FUEL MODEL OPTION IS SELECTED
*     (STORED AS IFMD(1), WITH A WEIGTH OF FWT(1)=1.0 AND THE CLOSEST
*     THE CLOSEST FUEL MODELS (UP TO 4) AND THEIR WEIGHTINGS FOR USE
*     BY THE DYNAMIC FUEL MODEL
*----------------------------------------------------------------------
*
*  CALL LIST DEFINITIONS:
*     FMD:     FUEL MODEL NUMBER
*
*
*  COMMON BLOCK VARIABLES AND PARAMETERS:
*     SMALL:   SMALL FUELS FROM DYNAMIC FUEL MODEL
*     LARGE:   LARGE FUELS FROM DYNAMIC FUEL MODEL
*
***********************************************************************
C
C.... PARAMETER INCLUDE FILES.
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'FMPARM.F77'
C
C.... COMMON INCLUDE FILES.
C
      INCLUDE 'FMFCOM.F77'
      INCLUDE 'FMCOM.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'ARRAYS.F77'
C
C     LOCAL VARIABLE DECLARATIONS
C
      INTEGER ICLSS
      PARAMETER(ICLSS = 14)

      INTEGER  IYR,FMD
      INTEGER  IPTR(ICLSS), ITYP(ICLSS)
      INTEGER  I,J,IDRY

      REAL     X(2), Y(2), ALGSLP, WT1(2)
      REAL     XPTS(ICLSS,2),EQWT(ICLSS),AFWT
      LOGICAL  DEBUG
C
C     FIXED VALUES FOR INTERPOLATION FUNCTION
C
      DATA     Y / 0.0, 1.0 /
C
C     THESE ARE THE INTEGER TAGS ASSOCIATED WITH EACH FIRE MODEL
C     CLASS. THEY ARE RETURNED WITH THE WEIGHT
C
      DATA IPTR / 1,2,3,4,5,6,7,8,9,10,11,12,13,14 /
C
C     THESE ARE 0 FOR REGULAR LINES, -1 FOR HORIZONTAL AND 1 FOR
C     VERTICAL LINES. IF ANY OF THE LINES DEFINED BY XPTS() ARE OF
C     AN UNUSUAL VARIETY, THIS MUST BE ENTERED HERE SO THAT
C     SPECIAL LOGIC CAN BE INVOKED.  IN THIS CASE, ALL THE LINE
C     SEGMENTS HAVE A |SLOPE| THAT IS > 0 AND LESS THAN INIF.
C
      DATA ITYP / ICLSS * 0 /
C
C     XPTS: FIRST COLUMN ARE THE SMALL FUEL VALUES FOR EACH FIRE MODEL
C       WHEN LARGE FUEL= 0 (I.E. THE X-INTERCEPT OF THE LINE). SECOND
C       COLUMN CONTAINS THE LARGE FUEL VALUE FOR EACH FIRE MODEL WHEN
C       SMALL FUEL=0 (I.E. THE Y-INTERCEPT OF THE LINE).
C
      DATA ((XPTS(I,J), J=1,2), I=1,ICLSS) /
     >   5., 15.,   ! FMD   1
     >   5., 15.,   ! FMD   2
     >   5., 15.,   ! FMD   3
     >   5., 15.,   ! FMD   4
     >   5., 15.,   ! FMD   5
     >   5., 15.,   ! FMD   6
     >   5., 15.,   ! FMD   7
     >   5., 15.,   ! FMD   8
     >   5., 15.,   ! FMD   9
     >  15., 30.,   ! FMD  10 ! shares with 11
     >  15., 30.,   ! FMD  11
     >  30., 60.,   ! FMD  12 ! shares with 14
     >  45.,100.,   ! FMD  13
     >  30., 60./   ! FMD  14
C
C     INITIALLY SET ALL MODELS OFF; NO TWO CANDIDATE MODELS ARE
C     COLINEAR, AND COLINEARITY WEIGHTS ARE ZERO. IF TWO CANDIDATE
C     MODELS ARE COLINEAR, THE WEIGHTS MUST BE SET, AND
C     MUST SUM TO 1, WRT EACH OTHER
C
      DO I = 1,ICLSS
        EQWT(I)  = 0.0
      ENDDO

C     BEGIN ROUTINE
C
      CALL DBCHK (DEBUG,'FMCFMD',6,ICYC)

      IF (DEBUG) WRITE(JOSTND,1) ICYC,IYR,LUSRFM
    1 FORMAT(' FMCFMD CYCLE= ',I2,' IYR=',I5,' LUSRFM=',L5)

C     IF USER-SPECIFIED FM DEFINITIONS, THEN WE ARE DONE.

      IF (LUSRFM) RETURN

      IF (DEBUG) WRITE(JOSTND,7) ICYC,IYR,HARVYR,LDYNFM,PERCOV,FMKOD,
     >           SMALL,LARGE
    7 FORMAT(' FMCFMD CYCLE= ',I2,' IYR=',I5,' HARVYR=',I5,
     >       ' LDYNFM=',L2,' PERCOV=',F7.2,' FMKOD=',I4,
     >       ' SMALL=',F7.2,' LARGE=',F7.2)
C
C     SEE WHICH FUEL MODELS ARE ACTIVE. THE AMOUNT OF SMALL AND LARGE FUEL
C     PRESENT CAN MODIFY THE CHOICE OF MODEL, AS CAN THE HABITAT TYPE OR
C     WHEN THE LAST HARVEST ACTIVITY WAS DONE.
C     FROM FAX FROM ELIZABETH REINHARDT
C
C     THE ORIGINAL RULE FROM J.BROWN WAS:
C       FMD = 9
C       IF (PERCOV .LE. 40.0) FMD = 1
C     HOWEVER, IT HAS BEEN ENHANCED WITH THE FOLLOWING CODE:
C
      IDRY = 0
      CALL NIFMHAB(IDRY)

      SELECT CASE (IDRY)

        CASE (1)        ! DRY GRASSY HABITAT CODES

          X(1) =  30.0
          X(2) =  50.0
          J = 2

          WT1(J)   = ALGSLP(PERCOV,X,Y,2)
          WT1(J-1) = 1.0 - WT1(J)

          EQWT(1) = WT1(1)
          EQWT(9) = WT1(2)

        CASE (2)        ! DRY SHRUBBY HABITAT CODES

          X(1) =  30.0
          X(2) =  50.0
          J = 2

          WT1(J)   = ALGSLP(PERCOV,X,Y,2)
          WT1(J-1) = 1.0 - WT1(J)

          EQWT(2) = WT1(1)
          EQWT(9) = WT1(2)

        CASE DEFAULT    ! ALL OTHER HABITAT CODES

          EQWT(8) = 1.0

      END SELECT
C
C     END OF DETAILED LOW FUEL MODEL SELECTION
C
C     DURING THE 5 YEARS AFTER AN ENTRY, AND ASSUMING THAT SMALL+LARGE
C     ACTIVIVITY FUELS HAVE JUMPED BY 10%, THEN MODEL 11 AND 14 ARE
C     CANDIDATE MODELS, SHARING WITH 10 AND 12 RESPECTIVELY. THE
C     WEIGHT OF THE SHARED RELATIONSHIP DECLINES FROM PURE 11 INITIALLY,
C     TO PURE 10 AFTER THE PERIOD EXPIRES. SIMILARLY, COMPUTE WEIGHT FOR
C     MODEL 14 ACTIVITY FUELS, SHARED WITH CURRENT MODEL 12. THE
C     RELATIONSHIP CHANGES IN THE SAME WAS AS THE 10/11 FUELS.
C
      AFWT = MAX(0.0, 1.0 - (IYR - HARVYR) / 5.0)
      IF (SLCHNG .GE. SLCRIT .OR. LATFUEL) THEN
        LATFUEL  = .TRUE.
        EQWT(11) = AFWT
        EQWT(14) = AFWT
        IF (AFWT .LE. 0.0) LATFUEL = .FALSE.
      ENDIF
      IF (.NOT. LATFUEL) AFWT = 0.0
C
C     MODELS 10,12,13 ARE ALWAYS CANDIDATE MODELS FOR NATURAL FUELS
C     OTHER MODELS ARE ALSO CANDIDATES, DEPENDING ON COVER TYPE, ETC
C
      EQWT(10)  = 1.0 - AFWT
      EQWT(12)  = 1.0 - AFWT
      EQWT(13)  = 1.0
C
C     CALL FMDYN TO RESOLVE WEIGHTS, SORT THE WEIGHTED FUEL MODELS
C     FROM THE HIGHEST TO LOWEST, SET FMD (UGING THE HIGHEST WEIGHT)
C
      CALL FMDYN(SMALL,LARGE,ITYP,XPTS,EQWT,IPTR,ICLSS,LDYNFM,FMD)

      IF (DEBUG) WRITE (JOSTND,8) SLCHNG,FMD,LDYNFM
    8 FORMAT (' FMCFMD, SLCHNG=', F5.1, ' FMD=',I4,' LDYNFM=',L2)

      RETURN
      END
