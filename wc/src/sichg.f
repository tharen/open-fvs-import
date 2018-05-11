      SUBROUTINE SICHG(ISISP,SSITE,SIAGE)
      IMPLICIT NONE
C----------
C  **SICHG--WC   DATE OF LAST REVISION:  04/22/10
C----------
COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
COMMONS
      INTEGER DIFF,REFAGE(MAXSP)
      CHARACTER*1 ISILOC,REFLOC(MAXSP)
      REAL A(MAXSP),B(MAXSP),SIAGE(MAXSP)
      INTEGER ISISP,I
      REAL SSITE,AGE2BH
C----------
C  DATA STATEMENTS FOR A AND B CONTAIN COEFFICIENTS FOR A LINEAR
C  RELATION OF AGE TO BREAST HEIGHT AS A FUNCTION OF SITE INDEX.
C  THE LINEAR RELATION IS AN ESTIMATE FROM THE LOWER END POINT OF
C  A HEIGHT GROWTH CURVE TO THE ORIGIN (0 AGE; 0 TOT TREE HT.)
C  THESE COEFFICIENTS SHOULD BE COMPATIBLE WITH SIMILAR VALUES USED
C  IN ESSUBH AND REGSMT SUBROUTINES.
C----------
      DATA A /21.35000, 9.01840,   9.01840, 33.72545, 14.81367,
     &        14.81367, 7.938059, 11.56252,  8.00000, 33.72545,
     &        10.65724, 8.000000, 21.02281, 21.02281,  8.00000,
     &        11.56252, 11.56252, 11.56252,  6.15767, 45.24969,
     &        11.56252,  3.28241, 5*11.56252, 4.94166,11.56252,
     &         8.11668,9*11.56252/
      DATA B /-0.10290, -0.05700, -0.05700, -0.27451, -0.11174,
     &        -0.11174, -0.02873, -0.05586, -0.04286, -0.27451,
     &        -0.10667, -0.04259, -0.15978, -0.15978, -0.04286,
     &        -0.05586, -0.05586, -0.05586, -0.03596, -1.28885,
     &        -0.05586, -0.02987, 5*-0.05586,-0.02419, -0.05586,
     &        -0.05661,9*-0.05586/
      DATA REFLOC/
     & 10*'B','T',10*'B','T',17*'B'/
      DATA REFAGE/
     & 100,50,50,100,50,50,4*100,50,7*100,50,100,100,20,5*100,50,
     & 100,50,9*100/
C
C ISILOC IS THE PLACE THE AGE FOR THE SITE SPECIES.
C
      ISILOC = REFLOC(ISISP)
      DO 100 I = 1,MAXSP
C
C  SET UP THE ARRAY TO TELL WHETHER YOU NEED TO SLIDE UP OR DOWN THE SIT
C LINE TO ADJUST FOR TOTAL AGE OR BREAST HIGH AGE
C
      IF(ISILOC .EQ. 'T' .AND. REFLOC(I) .EQ. 'B')DIFF=-1
      IF(ISILOC .EQ. REFLOC(I))DIFF=0
      IF(ISILOC .EQ. 'B' .AND. REFLOC(I) .EQ. 'T')DIFF=1
      AGE2BH=0.0
      IF(DIFF .LT. 0 .OR. DIFF .GT. 0)THEN
        AGE2BH=A(I) + B(I)*SSITE
      IF(ISISP .NE. 20 .AND. I .EQ. 20)AGE2BH=A(I) + B(I)*(SSITE/3.281)
      IF(ISISP .EQ. 20 .AND. I .NE. 20)AGE2BH=A(I) + B(I)*(SSITE*3.281)
      END IF
      SIAGE(I) = REFAGE(I) + AGE2BH*DIFF
  100 CONTINUE
      RETURN
      END
