      SUBROUTINE RDDST(N,RATTR,PCTWK,ODBH,INDX)
C----------
C  **RDDST       LAST REVISION:  11/06/89
C----------
C
C  THIS SUBROUTINE COMPUTES THE DIAMETERS CORRESPONDING TO THE
C  90, 70, 50, 30, AND 10 PERCENTILE POINTS IN THE DISTRIBUTION
C  OF A ROOT DISEASE STAND ATTRIBUTE.  THESE DIAMETERS ARE LOADED
C  FIRST 5 POSITIONS OF THE ARRAY RATTR.  THE SIXTH POSITION IN
C  RATTR IS LOADED WITH THE DIAMETER OF THE LARGEST TREE REPRESENTED
C  IN THE ATTRIBUTE.
C
C  CALLED BY :
C     RDDOUT  [ROOT DISEASE]
C
C  CALLS     :
C     NONE
C
C  PARAMETERS :
C     N      - NUMBER OF RECORDS.  (INPUT)
C     RATTR  - ARRAY THAT IS LOADED WITH THE DIAMETERS CORRESPONDING
C              TO THE 10TH, 30TH, 50TH, 70TH, 90TH, AND 100TH
C              PERCENTILE POINTS.  (OUTPUT)
C     PCTWK  - ARRAY OF THE PERCENTILE POINTS OF THE TREE RECORDS.
C              (INPUT)
C     ODBH   - ARRAY OF THE DBH'S OF THE TREE RECORDS.  (INPUT)
C     INDX   - INDEX ARRAY OF THE TREE RECORDS SORTED BY DBH. (INPUT)
C
COMMONS
C
C
      INCLUDE 'RDPARM.F77'
C
C
COMMONS
C

      REAL     RATTR(7), PCTWK(IRRTRE), ODBH(IRRTRE)

      INTEGER  INDX(IRRTRE)

C
C     IF THE TREE LIST IS NOT EMPTY, THEN:
C     BEGIN BINARY SEARCH FOR PERCENTILE POINTS.
C
      IF (N .EQ. 0) GOTO 60
      N1 = N + 1
      ITOP = 1
      PCTAGE = 90.0

      DO 50 I=1,5
         J = 6 - I
         IF (ITOP .EQ. N) GOTO 40
         IBOT = N1

   10    IPTR = (IBOT + ITOP) / 2
         MIDPTR = INDX(IPTR)
         IF (PCTWK(MIDPTR) .LT. PCTAGE) GOTO 20
         ITOP = IPTR
         GOTO 30

   20    IBOT = IPTR

   30    IF (ITOP + 1 .LT. IBOT) GOTO 10

C
C        PERCENTILE POINT HAS BEEN LOCATED.
C
   40    CONTINUE
         RATTR(J) = ODBH(INDX(ITOP))
         PCTAGE = PCTAGE - 20.0
   50 CONTINUE

C
C     ALL PERCENTILE POINTS HAVE BEEN LOCATED.  LOAD RATTR(6)
C
      RATTR(6) = ODBH(INDX(1))

  60  RETURN
      END
