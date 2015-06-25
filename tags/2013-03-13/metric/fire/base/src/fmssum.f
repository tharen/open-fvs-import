      SUBROUTINE FMSSUM (IYR)
      IMPLICIT NONE
C----------
C  **FMSSUM  DATE OF LAST REVISION:  12/16/04
C----------
C
C  Purpose:
C     Reports a summary of snag statistics for all years that
C     coinside with a FVS cycle boundary.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'FMPARM.F77'
      INCLUDE 'FMCOM.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'METRIC.F77'
C
C
COMMONS
C
      INTEGER I, II, JOUT, K
      REAL    THD(6),TSF(6)
      INTEGER IYR, DBSKODE

      IF (ISNGSM .EQ. -1 .OR. IYR.NE.IFMYR1) RETURN

      DO I=1,6
         THD(I)=0.
         TSF(I)=0.
      ENDDO

      DO II=1,NSNAG
         DO I=1,6
            IF (DBHS(II).GE.SNPRCL(I)) THEN
               TSF(I)=TSF(I)+DENIS(II)
               IF (HARD(II)) THEN
                  THD(I)=THD(I)+DENIH(II)
               ELSE
                  TSF(I)=TSF(I)+DENIH(II)  ! adding DENIH is CORRECT
               ENDIF
            ENDIF
         ENDDO
      ENDDO

	DO I = 1,6
	  TSF(I) = TSF(I) / ACRtoHA
	  THD(I) = THD(I) / ACRtoHA
	ENDDO

C
C     CALL THE DBS MODULE TO OUTPUT SUMMARY SNAG REPORT TO A DATABASE
C
      DBSKODE = 1
      CALL DBSFMSSNAG(IYR,NPLT,
     &  THD(1),THD(2),THD(3),THD(4),THD(5),THD(6),
     &  TSF(1),TSF(2),TSF(3),TSF(4),TSF(5),TSF(6),DBSKODE)
      IF(DBSKODE.EQ.0) RETURN

      CALL GETLUN (JOUT)

      IF (ISNGSM .EQ. 0) THEN
         CALL GETID (ISNGSM)
         WRITE (JOUT,10) ISNGSM,NPLT,MGMID,
     >                   ((INT(SNPRCL(I)*INtoCM),I=1,6),K=1,2)
 10      FORMAT (/I6,' $#*%'//38('-'),' SNAG SUMMARY REPORT ',30('-')/,
     >        ' STAND ID: ',A26,4X,'MGMT ID: ',A4/
     >        6X,13('-'),' HARD SNAGS/HA ',13('-'),
     >        1X,13('-'),' SOFT SNAGS/HA ',13('-')/
     >        'YEAR ',12(' >=',I2.2,'cm')/'---- ',12(' ------')/
     >        '$#*%')
      ENDIF

      WRITE (JOUT,20) ISNGSM,IYR,(THD(I),I=1,6),
     &      (TSF(I),I=1,6)
 20   FORMAT (1X,I5,1X,I4,1X,12(1X,F6.1))

      RETURN
      END