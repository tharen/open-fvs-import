      SUBROUTINE FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX1,HTMAX1,
     &                  HTMAX2,DEBUG)
      IMPLICIT NONE
C----------
C AK $Id$
C----------
C  THIS ROUTINE FINDS EFFECTIVE TREE AGE BASED ON INPUT VARIABLE(S)
C  CALLED FROM **COMCUP
C  CALLED FROM **CRATET
C  CALLED FROM **HTGF
C----------
C  VARIABLE DEFINITIONS:
C----------
C  INCRNG = HAS A VALUE OF 1 WHEN THE SITE CURVE HAS BEEN MONOTONICALLY
C           INCREASING IN PREVIOUS ITERATIONS.
C   OLDHG = HEIGHT GUESS FROM PREVIOUS ITERATION.
C  SITAGE = LOADED WITH EFECTIVE AGE BASED ON CURRENT H
C   SITHT = LOADED WITH POTENTIAL HEIGHT CORRESPONDING TO
C           AGE IN SITAGE ARRAY
C  AGMAX1 = RETURN VARIABLE TO PASS AGMAX ARRAY BACK TO HTGF ROUTINE
C----------
C
C  COMMONS
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
      INCLUDE 'PLOT.F77'
C
COMMONS
C
C----------
C  VARIABLE DECLARATIONS:
C----------
C
      LOGICAL DEBUG
C
      INTEGER I,INCRNG,ISPC
C
      REAL AG,AGMAX1,D1,D2,DIFF,H,HGUESS,HTMAX1,HTMAX2,OLDHG,POTHTG
      REAL RDANUW,SITAGE,SITHT,TOLER,XSITE
C
      REAL AGMAX(MAXSP)
C
C----------
C  DATA STATEMENTS:
C----------
      DATA AGMAX/ MAXSP*200. /
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = D1
      RDANUW = D2
      RDANUW = HTMAX1
      RDANUW = HTMAX2
C----------
C  INITIALIZATIONS
C----------
      TOLER = 2.0
      AG = 2.0
      AGMAX1=AGMAX(ISPC)
      XSITE = SITEAR(ISPC)
C
      SELECT CASE (ISPC)
C
      CASE(15,20)
C----------
C  RED ALDER AND BLACK COTTONWOOD LOGIC FROM PN (WC) VARIANT.
C  BEGIN TREE LOOP WITHIN SPECIES LOOP
C-----------
      INCRNG = 0
      HGUESS = 0.
   75 CONTINUE
      OLDHG = HGUESS
C----------
C   CALL HTCALC TO CALCULATE HT GROWTH
C----------
        CALL HTCALC(I,ISPC,XSITE,AG,HGUESS,POTHTG)
C
        IF(DEBUG)WRITE(JOSTND,91200)I,AG,HGUESS,H
91200   FORMAT(' IN GUESS AN AGE--I,AGE,HGUESS,H ',I5,3F10.2)
C----------
C  AVOID NEGATIVE PREDICTED HEIGHTS AT SMALL AGES FROM SOME SI CURVES
C  GED 4/20/18
C----------
      IF(HGUESS .LT. 1.)GO TO 175
C
        DIFF=ABS(HGUESS-H)
        IF(DIFF .LE. TOLER .OR. H .LT. HGUESS)THEN
          SITAGE = AG
          SITHT = HGUESS
          IF(DEBUG)THEN
            WRITE(JOSTND, *)' DIFF,TOLER,H,HGUESS,AG,SITAGE,SITHT= ',
     &      DIFF,TOLER,H,HGUESS,AG,SITAGE,SITHT
          ENDIF
          GO TO 30
        END IF
C----------
C  SOME SITE CURVES DECREASE AT THE START BEFORE INCREASING. IF DECREASING,
C  KEEP GOING; IF SITE CURVE WAS INCREASING, BUT NOW HAS FLATTENED OFF, STOP 
C  THE ITERATION GED 04/19/18
C----------
      DIFF = (HGUESS-OLDHG)
      IF(OLDHG.NE.0.0 .AND. DIFF.GE.0.05) INCRNG=1
      IF(DEBUG)WRITE(JOSTND,*)' IN FINDAG OLDHG,DIFF,INCRNG= ',
     &OLDHG,DIFF,INCRNG 
      IF(INCRNG.EQ.1 .AND. DIFF .LT. 0.05)THEN
        SITAGE = AG
        SITHT = HGUESS
        IF(DEBUG)THEN
          WRITE(JOSTND, *)' SITE CURVE FLAT OLDHG,AG,HGUESS,SITAGE,',
     &    'SITHT= ',OLDHG,AG,HGUESS,SITAGE,SITHT
        ENDIF
        GO TO 30
      END IF
C
  175 CONTINUE
      AG = AG + 2.0
C
      IF(AG .GT. AGMAX1) THEN
C----------
C MAX AGE IS EXCEEDED
C----------
        SITAGE = AGMAX1
        SITHT = H
        GO TO 30
      ELSE
        GO TO 75
      ENDIF
C----------
C   END OF TREE LOOP.
C----------
   30 CONTINUE
C
      END SELECT
C
      IF(DEBUG)WRITE(JOSTND,50)I,SITAGE,SITHT
   50 FORMAT(' LEAVING SUBROUTINE FINDAG  I,SITAGE,SITHT =',
     &I5,2F10.3)
C
      RETURN
      END
C**END OF CODE SEGMENT