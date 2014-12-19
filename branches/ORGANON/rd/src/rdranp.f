      REAL FUNCTION RDRANP(PROP)
      IMPLICIT NONE
C----------
C  **RDRANP  DATE OF LAST REVISION:   09/09/14
C----------
C
C  THIS FUNCTION WILL RETURN A PROPORTION BASED ON A RANDOM DRAW GIVEN
C  A MEAN PROPORTION.  IT IS BASED ON A BINOMIAL PROBABILITY
C  DENSITY FUNCTION. IT IS THE SAME AS THE RRDPRP FUNCTION USED BY THE
C  WESTERN ROOT DISEASE MODEL EXCEPT THAT IT CALLS THE ROOT DISEASE RANDOM
C  NUMBER GENERATOR INSTEAD.
C
C  CALLED BY :
C     RDINF   [ROOT DISEASE]
C     RDSETP  [ROOT DISEASE]
C
C  CALLS :
C     RDRANN  (FUNCTION)   [ROOT DISEASE]
C
C  PARAMETERS :
C     PROP     - PROPORTION THAT IS TO BE RANDOMIZED
C
C  LOCAL VARIABLES :
C     CDF      - ARRAY THAT HOLDS THE VALUES FROM THE CUMULATIVE
C                DISTRIBUTION FUNCTION
C     EXPROP   - THE EXPECTED PROPORTION
C     INTNUM   - NUMBER OF ITERATIONS TO RUN THE FUNCTION
C     K        - COUNTER FOR ITERATION CODE
C     L        - COUNTER FOR EXPECTED PORPORTION LOOP
C     LREV     - LOGICAL VARIABLE THAT IS SET TO .TRUE. IF PROPIN > 0.5
C                AND 1-PROPIN IS USED FOR THE CALCULATIONS.
C     OLDPRP   - PROPIN FROM THE PREVIOUS CALL TO THIS FUNCTION
C                (OLD PROPIN)
C     PDF      - TEMPORARY VARIABLE THAT HOLDS THE VALUE FROM THE
C                PROBABILITY DENSITY FUNCTION
C     PROPIN   - PROPORTION THAT IS TO BE RANDOMIZED. SET TO PROP AT
C                THE BEGINNING OF THE ROUTINE
C     RANNUM   - RANDOM NUMBER RETURNED FROM THE RANDOM NUMBER
C                GENERATOR
C
C  REVISION HISTORY:
C    09/04/92
C    01/28/09 - Lance R. David
C      Common block array CDF was moved to its own common due to compiler
C      complaint (mixed variable types in common) reported by Don Robinson
C      (ESSA).
C   09/09/14 Lance R. David (FMSC)
C     Added implicit none and declared variables.
C     Changed array CDF to REAL, double precision was not necessary.
C     Moved local commons PRPDAT and PRPDATD to RDCOM.F77 file.
C----------------------------------------------------------------------

C.... PARAMETER INCLUDE FILES

      INCLUDE 'PRGPRM.F77'
      INCLUDE 'RDPARM.F77'

C.... COMMON INCLUDE FILES

      INCLUDE 'RDCOM.F77'

      LOGICAL LREV
      INTEGER INTNUM, K, L
      REAL    EXPROP, PROP, PROPIN, RANNUM, RDRANN
      REAL    PDF
C
C     OLDPRP AND CDF WERE PUT IN A COMMON BLOCKS SO THAT THEY WOULD BE
C     SAVED BETWEEN CALLS TO THIS FUNCTION
C     The variable declatations (REAL OLDPRP, DOUBLE PRECISSION CDF(1001))
C     and common block specifications were moved to the RDCOM.F77 file 
C     and then the RDCOM.F77 included in this routine.
C
c      COMMON  /PRPDAT/ OLDPRP
c      COMMON  /PRPDATD/ CDF

C
C     INITIALIZE L AND LREV, SET PROPIN TO PROP
C
      L = 0
      LREV   = .FALSE.
      PROPIN = PROP

C
C     INTNUM (N) IS  EQUAL TO 5 / PROPIN.
C
      INTNUM = NINT(5 / PROPIN)

      IF (INTNUM .GT. 100) INTNUM = 100
      IF (INTNUM .LT. 10)  INTNUM = 10

C
C     ADJUST PROPIN TO ACCOUNT FOR THE SHORTENING OF RANGE FROM
C     0 <= X <= 1  TO  0 < X <= 1 .
C
C     WHEN THE RANGE IS 0 < X <= 1 THE EXPECTED MEAN PROPORTION IS:
C     E = P / (1 - (1-P)**n)
C
  100 CONTINUE
      EXPROP = PROPIN / (1.0 - (1.0 - PROPIN)**INTNUM)
      IF (ABS(PROPIN - EXPROP) .GT. (1.0 / REAL(INTNUM)) .AND.
     &   L .LT. 10) THEN
         PROPIN = PROPIN - (0.5 * (PROPIN - EXPROP))
         L = L + 1
         GOTO 100
      ENDIF

C
C     CHECK TO SEE IF PROPIN > 0.5
C     IF PROPIN > 0.5 THEN SET PROPIN TO 1-PROPIN AND SET LREV TO .TRUE.
C
C     IF THE PROPORTION IS GREATER THAN 0.5 THEN USE THE CURVE FROM 0.0
C     TO 0.5 AND SET THE PROPORTION BASED ON 1-(THE MEAN PROPORTION)
C     AFTER THE RANDOM PROPORTION IS CALCULATED THEN THE PROPORTION IS
C     REVERSED AGAIN PROPIN = 1-(RANDOM PROPORTION CALCULATED)
C
      IF (PROPIN .GT. 0.5) THEN
         PROPIN = 1.0 - PROPIN
         LREV = .TRUE.
      ENDIF

C
C     THIS SECTION OF CODE ONLY NEEDS TO BE EXECUTED IF THE PROPORTION
C     READ IN HAS CHANGED SINCE THE LAST TIME THIS FUNCTION WAS CALLED
C
      IF (PROPIN .NE. OLDPRP) THEN
C
C        SET OLDPRP TO PROPIN TO SAVE PROPIN
C
         OLDPRP = PROPIN

C
C        SET PDF AND CDF FOR FIRST ITERATION
C
         PDF = (1.0 - PROPIN)**INTNUM
         CDF(1) = PDF
cccc         write(*,*) 'cdf 1 = ', pdf

C
C        CALCULATE PDF FOR ALL ITERATIONS AND SET CDF
C
C        PDF(K|P,N) = PDF(K-1|P,N) * (P/(1-P)) * (N-K+1) / K
C
         DO 200 K = 1,INTNUM
            PDF = PDF * (PROPIN / (1.0-PROPIN) *
     &            REAL(INTNUM - K + 1)) / REAL(K)
C
C           ADJUST CDF VALUE TO ACCOUNT FOR THE TRUNCATED RANGE
C           0 < X <= 1
C
            CDF(K+1) = CDF(K) + (PDF / (1.0 - CDF(1)))
cccc         write(*,*) 'cdf x = ', cdf(k+1)
  200    CONTINUE
      ENDIF

C
C     LOOP TO GET RANDOM NUMBER THAT IS GREATER THAN ZERO
C
  300 RANNUM = RDRANN(0)
      IF (RANNUM .EQ. 0.0) THEN
         GOTO 300
      ENDIF

C
C     INITIALIZE RDRANP AND K
C
      RDRANP = 0.7 * (1.0 / REAL(INTNUM))
      K = 1

C
C     LOOP THROUGH THE CURVE CDF(K+1) UNTIL THE RANDOM NUMBER FITS
C     THE CURVE
C
  400 CONTINUE
      IF (RANNUM .GE. CDF(K+1) .AND. K .LE. INTNUM) THEN
         RDRANP = REAL(K+1) / REAL(INTNUM)
         K = K + 1
         GOTO 400
      ENDIF

C
C     IF PROPIN WAS > 0.5 THEN RESET RDRANP TO 1.0-RDRANP
C     BECAUSE PROPIN WAS SET TO 1.0-PROPIN
C
      IF (LREV) THEN
         RDRANP = 1.0 - RDRANP
      ENDIF

cccc      write (*,*) 'oldprp = ', oldprp
cccc      write (*,*) 'cdf = ', cdf
      
      RETURN
      END
