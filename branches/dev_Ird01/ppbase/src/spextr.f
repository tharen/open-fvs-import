      SUBROUTINE SPEXTR (CIDS,NCIDS,ISRT,IORD,MXSTND,NRECS,CDAIDS,IRC)
      IMPLICIT NONE
C----------
C  **SPEXTR--PPBASE   DATE OF LAST REVISION:  07/31/08
C----------
C     EXTRACTS, OR MAKES READY, THE LOCATION/AREA OR ROAD DISTANCE
C     DATA SO THAT IT CAN BE EFFECTIENTLY ACCESSED.
C
C     CIDS  = A LIST OF IDS FOR WHICH AREALOCS DATA WILL BE EXTRACTED.
C             CALLS TO SPNBBD WILL BE MADE USING SUBSCRIPS OF CIDS.
C     NCIDS = THE LENGTH OF CIDS AND ISRT.
C     ISRT  = AN INTEGER SORT OVER CIDS IN ASCENDING ORDER.
C     IORD  = ACCESS KEY TO DATA...SET BY THIS ROUTINE.
C     MXSTND= MAX NUMBER OF RECORDS.
C     NRECS = NUMBER OF RECORDS.
C     CDAIDS= STAND IDS FOR RECORDS.
C     IRC   = RETURN CODE, 0=OK, 1=SOME OF THE STANDS HAVE NO LOCATION
C             OR AREA RECORDS, 2=THERE IS NO LOCATION DATA, 3=THERE ARE
C             NO ENTRIES IN CIDS.
C
C
      CHARACTER*26 CIDS(NCIDS),CDAIDS(MXSTND)
      INTEGER ISRT(NCIDS),IORD(MXSTND),IRC,NRECS,NCIDS,MXSTND,I,IP,K
C
C     IF THERE ARE NO DATA, THEN RETURN.
C
      IF (NRECS.LE.0) THEN
         IRC=2
      ELSE
         IF (NCIDS.LE.0) THEN
            IRC=3
         ELSE
C
C           ZERO OUT THE IORD
C
            DO 10 I=1,MXSTND
            IORD(I)=0
   10       CONTINUE
C
C           DO OVER THE LIST OF IDS (CDAIDS'S)
C
            IRC=0
            DO 60 I=1,NRECS
            CALL SPBSRX (NCIDS,CIDS,ISRT,CDAIDS(I),IP)
            IF (IP.GT.0) THEN
               IORD(ISRT(IP))=I
C
C              SET UP THE POINTERS FOR DUPLICATE ENTRIES IN CIDS.
C
               IF (IP.GT.1) THEN
                  DO 20 K=(IP-1),1,-1
                  IF (CIDS(ISRT(K)).NE.CDAIDS(I)) GOTO 30
                  IORD(ISRT(K))=I
   20             CONTINUE
   30             CONTINUE
               ENDIF
               IF (IP.LT.NCIDS) THEN
                  DO 40 K=(IP+1),NCIDS
                  IF (CIDS(ISRT(K)).NE.CDAIDS(I)) GOTO 50
                  IORD(ISRT(K))=I
   40             CONTINUE
   50             CONTINUE
               ENDIF
            ENDIF
   60       CONTINUE
            DO 70 I=1,NCIDS
            IF (IORD(I).EQ.0) THEN
               IRC=1
               GOTO 80
            ENDIF
   70       CONTINUE
   80       CONTINUE
         ENDIF
      ENDIF
      RETURN
      END