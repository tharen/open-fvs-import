      FUNCTION ALGSLP (XX,X,Y,N)
      IMPLICIT NONE
C----------
C  $Id: algslp.f 767 2013-04-10 22:29:22Z rhavis@msn.com $
C----------
C
C     PART OF THE PROGNOSIS MODEL FOR STAND DEVELOPMENT.
C     N.L. CROOKSTON--INTERMOUNTAIN RESEARCH STATION--MOSCOW--AUG 1988
C
C     THIS IS A LINEAR INTERPOLATION FUNCTION
C
C     THE FUNCTION RETURNS THE VALUE OF A LINEAR SEGMENTED FUNCTION
C     DEFINED BY THE PAIRS X(I), Y(I) EVALUATED AT X=XX FOR X
C     INCLUDED IN THE INTERVAL {X(1),X(N)} IF XX < X(1), ALGSLP=X(1)
C     AND IF XX >= X(N), ALGSLP=X(NN).
C
C     XX = POINT AT WHICH THE FUNCTION IS TO BE EVALUATED.
C     X  = ARRAY OF X(I), SEGMENT ENDPOINTS FOR X
C     Y  = ARRAY OF Y(I), SEGMENT ENDPOINTS FOR Y
C     N  = ARRAY SIZE OF X AND Y.
C     ALGSLP=FUNCTION EVALUATED AT XX.
C
      REAL XX,ALGSLP
      INTEGER N,NN,I
      REAL X(N),Y(N)
C
      IF (XX.LT.X(1)) THEN
         ALGSLP=Y(1)
      ELSE
         IF (XX.GE.X(N)) THEN
            ALGSLP=Y(N)
         ELSE
            NN=N-1
            DO 30 I=1,NN
            IF  (XX.GE.X(I+1)) GOTO 30
            ALGSLP = Y(I)+((Y(I+1)-Y(I))/(X(I+1)-X(I)))*(XX-X(I))
            GOTO 50
   30       CONTINUE
   50       CONTINUE
         ENDIF
      ENDIF
      RETURN
      END
