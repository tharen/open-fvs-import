      SUBROUTINE RDPSRT(N,A,INDEX,LSEQ)
      IMPLICIT NONE
C----------
C  $Id: rdpsrt.f 767 2013-04-10 22:29:22Z rhavis@msn.com $
C----------
C  THE VECTOR INDEX IS INITIALLY LOADED WITH VALUES FROM 1 TO N
C  INCLUSIVE.  **RDPSRT** REARRANGES THE ELEMENTS OF INDEX SO THAT
C  INDEX(1) IS THE SUBSCRIPT OF THE LARGEST ELEMENT IN THE VECTOR A,
C  INDEX(2) IS THE SUBSCRIPT OF THE SECOND LARGEST ELEMENT IN A,...,
C  AND INDEX(N) IS THE SUBSCRIPT OF THE SMALLEST ELEMENT IN A.  THE
C  PHYSICAL ARRANGEMENT OF THE VECTOR A IS NOT ALTERED.  THIS
C  ALGORITHM IS AN ADAPTATION OF THE TECHNIQUE DESCRIBED IN:
C
C       SCOWEN, R.A. 1965. ALGORITHM 271; QUICKERSORT. COMM ACM.
C                    8(11) 669-670.
C
C----------
C  DECLARATIONS:
C----------
      LOGICAL LSEQ
      INTEGER INDEX,IPUSH,IL,IP,IU,INDIL,INDIP,INDIU,INDKL,INDKU,
     &          ITOP,JL,JU,KL,KU
      INTEGER N,I
      REAL A,T
C----------
C  DIMENSIONS:
C----------
      DIMENSION INDEX(N),A(*),IPUSH(33)
C----------
C  IF LSEQ IS FALSE, ASSUME THAT A IS PARTIALLY
C  SORTED.  OTHERWISE, LOAD IND WITH VALUES FROM 1 TO N.
C----------
      IF(.NOT.LSEQ) GO TO 20
      DO 10 I=1,N
   10 INDEX(I)=I
   20 CONTINUE
C----------
C  RETURN IF FEWER THAN TWO ELEMENTS IN ARRAY A.
C----------
      IF(N.LT.2) GOTO 9999
C----------
C  BEGIN THE SORT.
C----------
      ITOP=0
      IL=1
      IU=N
   30 CONTINUE
      IF(IU.LE.IL) GO TO 40
      INDIL=INDEX(IL)
      INDIU=INDEX(IU)
      IF(IU.GT.IL+1) GO TO 50
      IF(A(INDIL).GE.A(INDIU)) GO TO 40
      INDEX(IL)=INDIU
      INDEX(IU)=INDIL
   40 CONTINUE
      IF(ITOP.EQ.0) GOTO 9999
      IL=IPUSH(ITOP-1)
      IU=IPUSH(ITOP)
      ITOP=ITOP-2
      GO TO 30
   50 CONTINUE
      IP=(IL+IU)/2
      INDIP=INDEX(IP)
      T=A(INDIP)
      INDEX(IP)=INDIL
      KL=IL
      KU=IU
   60 CONTINUE
      KL=KL+1
      IF(KL.GT.KU) GO TO 90
      INDKL=INDEX(KL)
      IF(A(INDKL).GE.T) GO TO 60
   70 CONTINUE
      INDKU=INDEX(KU)
      IF(KU.LT.KL) GO TO 100
      IF(A(INDKU).GT.T) GO TO 80
      KU=KU-1
      GO TO 70
   80 CONTINUE
      INDEX(KL)=INDKU
      INDEX(KU)=INDKL
      KU=KU-1
      GO TO 60
   90 CONTINUE
      INDKU=INDEX(KU)
  100 CONTINUE
      INDEX(IL)=INDKU
      INDEX(KU)=INDIP
      IF(KU.LE.IP) GO TO 110
      JL=IL
      JU=KU-1
      IL=KU+1
      GO TO 120
  110 CONTINUE
      JL=KU+1
      JU=IU
      IU=KU-1
  120 CONTINUE
      ITOP=ITOP+2
      IPUSH(ITOP-1)=JL
      IPUSH(ITOP)=JU
      GO TO 30
 9999 CONTINUE
      RETURN
      END
