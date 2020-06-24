      SUBROUTINE HTGF
      IMPLICIT NONE
C----------
C CA $Id$
C----------
C  THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT
C  INCREMENT FOR EACH CYCLE AND LOADS IT INTO THE ARRAY HTG.
C  HEIGHT INCREMENT IS PREDICTED FROM SPECIES, HABITAT TYPE,
C  HEIGHT, DBH, AND PREDICTED DBH INCREMENT.  THIS ROUTINE
C  IS CALLED FROM **TREGRO** DURING REGULAR CYCLING.  ENTRY
C  **HTCONS** IS CALLED FROM **RCON** TO LOAD SITE DEPENDENT
C  CONSTANTS THAT NEED ONLY BE RESOLVED ONCE.
C----------
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
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
COMMONS
C
      LOGICAL DEBUG
      INTEGER I,ISPC,I1,I2,I3,ITFN
      REAL AGP10,HGUESS,SCALE,XHT,SINDX,AGMAX,H,POTHTG,XMOD,CRATIO
      REAL RELHT,CRMOD,RHMOD,TEMHTG,PBAL
      REAL SITAGE,SITHT,HTMAX,HTMAX2,D1,D2
      REAL MISHGF
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE HTGF CYCLE =',I5)
C
      SCALE=FINT/YR
C----------
C  GET THE HEIGHT GROWTH MULTIPLIERS.
C----------
      CALL MULTS (2,IY(ICYC),XHMULT)
      IF(DEBUG)WRITE(JOSTND,*)'HTGF- IY(ICYC),XHMULT= ',
     & IY(ICYC), XHMULT
C----------
C   BEGIN SPECIES LOOP:
C----------
      DO 40 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 40
      I2 = ISCT(ISPC,2)
      XHT=XHMULT(ISPC)
      SINDX = SITEAR(ISPC)
C-----------
C   BEGIN TREE LOOP WITHIN SPECIES LOOP
C-----------
      DO 30 I3 = I1,I2
      I=IND1(I3)
      HTG(I)=0.
      IF (PROB(I).LE.0.0) GO TO 161
      H=HT(I)
      AGP10 = 0.0
      HGUESS = 0.0
C
      SITAGE = 0.0
      SITHT = 0.0
      AGMAX = 0.0
      HTMAX = 0.0
      HTMAX2 = 0.0
      D1 = DBH(I)
      D2 = 0.0
      
      PBAL=PTBAA(ITRE(I))*(1.0-(PCT(I)/100.))
      CALL FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,DEBUG)
C
C----------
C  NORMAL HEIGHT INCREMENT CALCULATON BASED ON INCOMMING TREE AGE
C  FIRST CHECK FOR MAX, ASMYPTOTIC HEIGHT
C----------
      IF (SITAGE .GT. AGMAX) THEN
        POTHTG = 0.10
        GO TO 1320
      ELSE
        AGP10= SITAGE + 10.0
      ENDIF
C----------
C R5 USE DUNNING/LEVITAN SITE CURVE.
C R6 USE VARIOUS SPECIES SITE CURVES.
C SPECIES DIFFERENCES ARE ARE ACCOUNTED FOR BY THE SPECIES
C SPECIFIC SITE INDEX VALUES WHICH ARE SET AFTER KEYWORD PROCESSING.
C----------
      CALL HTCALC(IFOR,SINDX,ISPC,AGP10,HGUESS,JOSTND,DEBUG)
C
      POTHTG= HGUESS - SITHT
C
      IF(DEBUG)WRITE(JOSTND,91200)I,ISPC,AGP10,HGUESS,H
91200 FORMAT(' IN GUESS AN AGE--I,ISPC,AGEP10,HGUESS,H ',2I5,3F10.2)
C----------
C ASSIGN A POTENTIAL HTG FOR THE ASYMPTOTIC AGE
C----------
 1320 CONTINUE
      XMOD=1.0
      CRATIO=ICR(I)/100.0
      RELHT=H/AVH
      IF(RELHT .GT. 1.0)RELHT=1.0
      IF(PCCF(ITRE(I)) .LT. 100.0)RELHT=1.0
C--------
C  THE TREE HEIGHT GROWTH MODIFIER (SMHMOD) IS BASED ON THE RITCHIE &
C  HANN WORK (FOR.ECOL.&MGMT. 1986. 15:135-145).  THE ORIGINAL COEFF.
C  (1.117148) IS CHANGED TO 1.016605 TO MAKE THE SMALL TREE HEIGHTS
C  CLOSE TO THE SITE INDEX CURVE.  THE MODIFIER HAS TWO PARTS, ONE
C  (CRMOD) FOR TREE VIGOR USING CROWN RATIO AS A SURROGATE; OTHER
C  (RHMOD) FOR COMPETITION FROM NEIGHBORING TREES USING RELATIVE TREE
C  HEIGHT AS A SURROGATE.
C----------
      CRMOD=(1.0-EXP(-4.26558*CRATIO))
      RHMOD=(EXP(2.54119*(RELHT**0.250537-1.0)))
      XMOD= 1.016605*CRMOD*RHMOD
      
C  CALCULATE HTG FOR REDWOOD AND GIANT SEQUIOA USING DIFFERENT FUNCTIONAL FORM
      IF(ISPC .EQ. 23 .OR. ISPC .EQ. 50) THEN
        HTG(I)=EXP(-1.614631 - 0.000035*H**2 + 0.325206*LOG(H) 
     & - 0.001741*PBAL + 0.197669*LOG(CRATIO * 100) + 
     &   0.515935*LOG(SINDX) - 0.001741*SLOPE*100 - 
     &   0.001886*(SLOPE*100)*COS(ASPECT))

C     MARK CASTLE: DEBUG
        IF(DEBUG)WRITE(JOSTND,*)' H=',H,' PBAL=',PBAL,' CR=',CRATIO,
     &  ' SI=',SINDX,' SLP=',SLOPE*100, ' ASP=',ASPECT,
     &  ' HTG=',HTG(I)
     
C  CALCULATE HTG FOR ALL OTHER SPECIES
      ELSE
        HTG(I) = POTHTG * XMOD
      ENDIF

C  ENFORCE MINIMUM HEIGHT GROWTH
      IF(HTG(I) .LT. 0.1) HTG(I)=0.1
C
      IF(DEBUG)    WRITE(JOSTND,901)ICR(I),PCT(I),BA,DG(I),HT(I),
     & POTHTG,AVH,HTG(I),DBH(I),RMAI,HGUESS,AGP10,XMOD,ABIRTH(I)
  901 FORMAT(' HTGF',I5,14F9.2)
C----------
C  HTG IS MULTIPLIED BY SCALE TO CHANGE FROM A YR  PERIOD TO FINT AND
C  MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
C----------
      HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
C
      IF(DEBUG)WRITE(JOSTND,*)' I=',I,
     &          ' D=',DBH(I),' DG=',DG(I),' H=',H,' HTG=',HTG(I)
C
  161 CONTINUE
C----------
C    APPLY DWARF MISTLETOE HEIGHT GROWTH IMPACT HERE,
C    INSTEAD OF AT EACH FUNCTION IF SPECIAL CASES EXIST.
C----------
      HTG(I)=HTG(I)*MISHGF(I,ISPC)
      TEMHTG=HTG(I)
      
      IF(DEBUG)WRITE(JOSTND,*)' TEMHTG=',TEMHTG
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(I)+HTG(I)).GT.SIZCAP(ISPC,4))THEN
        HTG(I)=SIZCAP(ISPC,4)-HT(I)
        IF(HTG(I) .LT. 0.1) HTG(I)=0.1
      ENDIF
       
      IF(DEBUG)WRITE(JOSTND,*)' HTG(I)=',HTG(I)
C
      IF(.NOT.LTRIP) GO TO 30
      ITFN=ITRN+2*I-1
      HTG(ITFN)=TEMHTG
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN)+HTG(ITFN)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN)=SIZCAP(ISPC,4)-HT(ITFN)
        IF(HTG(ITFN) .LT. 0.1) HTG(ITFN)=0.1
      ENDIF
C
      HTG(ITFN+1)=TEMHTG
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN+1)+HTG(ITFN+1)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN+1)=SIZCAP(ISPC,4)-HT(ITFN+1)
        IF(HTG(ITFN+1) .LT. 0.1) HTG(ITFN+1)=0.1
      ENDIF
C
      IF(DEBUG) WRITE(JOSTND,9001) HTG(ITFN),HTG(ITFN+1)
 9001 FORMAT( ' UPPER HTG =',F8.4,' LOWER HTG =',F8.4)

C----------
C   END OF TREE LOOP
C----------
   30 CONTINUE
C----------
C   END OF SPECIES LOOP
C----------
   40 CONTINUE
      IF(DEBUG)WRITE(JOSTND,60)ICYC
   60 FORMAT(' LEAVING SUBROUTINE HTGF   CYCLE =',I5)
      RETURN
C
      ENTRY HTCONS
C----------
C  ENTRY POINT FOR LOADING HEIGHT INCREMENT MODEL COEFFICIENTS THAT
C  ARE SITE DEPENDENT AND REQUIRE ONE-TIME RESOLUTION.  HGHC
C  CONTAINS HABITAT TYPE INTERCEPTS, HGLDD CONTAINS HABITAT
C  DEPENDENT COEFFICIENTS FOR THE DIAMETER INCREMENT TERM, HGH2
C  CONTAINS HABITAT DEPENDENT COEFFICIENTS FOR THE HEIGHT-SQUARED
C  TERM, AND HGHC CONTAINS SPECIES DEPENDENT INTERCEPTS.  HABITAT
C  TYPE IS INDEXED BY ITYPE (SEE /PLOT/ COMMON AREA).
C----------
C  LOAD OVERALL INTERCEPT FOR EACH SPECIES.
C----------
      DO 50 ISPC=1,MAXSP
      HTCON(ISPC)=0.0
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)=
     &    HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE
      RETURN
      END
