      SUBROUTINE CUTQFA(VALMIN,VALMAX,ISPCUT,LZEIDE,ICFLAG,
     &                  CTPA,CBA,CSDI,QFATAR,QFAC,DIACW,
     &                  JOSTND1,DEBUG1,LDELQFA,LQFA)
      IMPLICIT NONE
C----------
C BASE $Id:
C----------
C  THIS SUBROUTINE IS CALLED FROM CUTS TO CALCULATE THE RESIDUAL
C  IN EACH DIAMATER CLASS FOR THE INDIVIDUAL TREE SELECTION MANAGEMENT
C  ACTION. THE ENTRY **CYCQFA** IS CALLED TO PASS THE DIAMETER CLASS
C  RESIDUALS TO CUTS DURING PROCESSING.
C
C  LQFA = LOGICAL RETURN VARIABLE FROM CUTQFA
C         .FALSE. LAST DIAMETER CLASS TO BE PROCESSED
C         .TRUE. MORE DIAMETER CLASSES TO BE PROCESSED
C  DINOM = VALUE OF DINOMINATOR IN Q-FACTOR EQUATION
C  ICFLAG= DEDRIVITIVE OF ACTIVITY NUMBER USED IN CUTS
C          17= BA TARGET
C          18= SDI TARGET
C  VALMIN= LOWER DIAMETER LIMIT FOR ENTIRE DIAMETER RANGE TO BE THINNED
C  VALMAX= UPPER DIAMETER LIMIT FOR ENTIRE DIAMETER RANGE TO BE THINNED
C  ISPCUT= INDEX FOR SPECIES PREFERENCE
C  CBA   = RESIDUAL BA TARGET
C  CSDI  = RESIDUAL SDI TARGET
C  QFAC  = Q FACTOR
C  DIACW = DIAMETER CLASS WIDTH
C  LZEIDE= LOGICAL VARIABLE SETTING SDI TO ZEIDE METHOD IF .TRUE.    
C LDELQFA= LOGICAL TO DELETE THINQFA ACTIVITY IF TARGET .GT. STOCKING
C          SET IN **CUTQFA** AND EXECUTED IN CUTS
C  QFATAR= SETS TARGET TYPE 1=BA, 2=TPA, 3=SDI
C
C  DCLS(30)             = MIDPOINT OF DIAMETER CLASS
C  TPACLS(30,4) = (..,1)= ACTUAL TPA IN EACH DIAMETER CLASS
C                 (..,2)= THEORETICAL TPA IN EACH DIAMETER CLASS
C                 (..,3)= EXCESS/DEFICIT TPA IN EACH DIAMETER CLASS
C                 (..,4)= TEMPORATY TPA IN DIAMETER CLASSES
C  CLSTAR(30,2) = (..,1)= ACTUAL AVERAGE TARGET PER TREE IN DIAMETER CLASS
C                 (..,2)= TARGET BA/SDI FOR DIAMETER CLASS
C
      REAL CLS,REMAIN,CLSTAR(30,2),CSTOCK,TPACLS(30,4),DCLS(30)
      REAL VALMIN,VALMAX,DIACW,QFAC,CBA,CSDI,SDIC,SDIC2,A,B
      REAL TPA1,DINOM,SUMTAR,CTAR,SUM,EXCESS1,CTPA,SUMINV,CSTOCKTPA
      LOGICAL LQFA,LZEIDE,DEBUG1,LDELQFA
      INTEGER NDCLS,ICFLAG,ICOUNT,ISPCUT,I,J,K,NFILL,JOSTND1,NDEF,QFATAR
C
      COMMON /QFACOM/ICOUNT,CLSTAR,DCLS,NDCLS,TPACLS
C
      IF(DEBUG1)WRITE(JOSTND1,*)' ENTERING CUTQFA'
      IF(DEBUG1)WRITE(JOSTND1,*)',VALMIN,VALMAX,ISPCUT,CTPA,CBA',
     &',CSDI,QFATAR,QFAC,DIACW,LZEIDE= ',VALMIN,VALMAX,ISPCUT,CTPA,CBA,
     &CSDI,QFATAR,QFAC,DIACW,LZEIDE
C
C  INITIALIZE VARIABLES
C
      DO I=1,30
      DCLS(I)=0.
      DO J=1,4
      TPACLS(I,J)=0.
      ENDDO
      DO J=1,2
      CLSTAR(I,J)=0.
      ENDDO
      ENDDO
      LQFA=.TRUE.
      CSTOCKTPA=0.
C
C  CALCULATE THE NUMBER OF DIAMETER CLASSES
C  IF THE NUMBER DOES NOT WORK OUT EVENLY,THEN
C  TRUNCATE THE SMALLEST CLASS AND WRITE A WARNING
C  MESSAGE
C
      NDCLS= INT((VALMAX-VALMIN)/DIACW)
C
C  IF THE NUMBER OF DIAMETER CLASSES IS GREATER THAT THE MAX ALLOWABLE,
C  (>30) THEN CANCEL THE ACTIVITY
C
      IF(NDCLS.GT.30)THEN
        LDELQFA=.TRUE.
        GOTO 500
      ENDIF
      CLS=(VALMAX-VALMIN)/DIACW
      REMAIN=MOD(CLS,FLOAT(NDCLS))
      IF(REMAIN.GT.0.01)WRITE(JOSTND1,1000)
 1000 FORMAT('******THINQFA KEYWORD DIAMETER ',
     &'CLASSES NOT EQUAL, SMALLEST DIAMETER CLASS REMOVED')
      IF(DEBUG1)WRITE(JOSTND1,*)' NDCLS= ',NDCLS
C
C  CALCULATE THE MIDPOINT OF EACH DIAMETER CLASS AND STORE IN
C  DCLS(I)
C
      DCLS(NDCLS)=VALMAX-DIACW/2.
      DO I=NDCLS-1,1,-1
      DCLS(I)=DCLS(I+1)-DIACW
      ENDDO
      IF(DEBUG1)WRITE(JOSTND1,*)'NDCLS,DCLS(I)= ',
     &NDCLS,(DCLS(I),I=1,NDCLS)
C
      DO I=1,NDCLS
C
      CALL CLSSTK (CSTOCK,1,ISPCUT,DCLS(I)-DIACW/2.,
     &               DCLS(I)+DIACW/2.,0,999.,0)
         TPACLS(I,1)=CSTOCK
         CSTOCKTPA=CSTOCK
C
C  BA
C
      IF(QFATAR.LE.0)THEN
        CALL CLSSTK (CSTOCK,2,ISPCUT,DCLS(I)-DIACW/2.,
     &               DCLS(I)+DIACW/2.,0,999.,0)
        IF(TPACLS(I,1).GT.0)THEN
          CLSTAR(I,1)=CSTOCK/TPACLS(I,1)
        ELSE
          CLSTAR(I,1)=0.
        ENDIF
C
C  TPA
C
      ELSEIF(QFATAR.LE.1)THEN
        IF(TPACLS(I,1).GT.0.)THEN
          CLSTAR(I,1)=CSTOCKTPA/TPACLS(I,1)
        ELSE
          CLSTAR(I,1)=0.
        ENDIF
C
C  SDI
C
      ELSE
        CALL SDICLS (ISPCUT,DCLS(I)-DIACW/2.,DCLS(I)+DIACW/2.,
     &               1,SDIC,SDIC2,A,B,0)
        IF(LZEIDE)THEN
          IF(TPACLS(I,1).GT.0)THEN
            CLSTAR(I,1)=SDIC2/TPACLS(I,1)
          ELSE
            CLSTAR(I,1)=0.
          ENDIF
        ELSE
          IF(TPACLS(I,1).GT.0)THEN
            CLSTAR(I,1)=SDIC/TPACLS(I,1)
          ELSE
            CLSTAR(I,1)=0.
          ENDIF
        ENDIF
      ENDIF
C
      ENDDO
C
      IF(DEBUG1)WRITE(JOSTND1,*)'INITIAL TPA-TPACLS(J,1)= ',
     & (TPACLS(J,1),J=1,NDCLS)
      IF(DEBUG1)WRITE(JOSTND1,*)'INITIAL BA OR SDI/TREE-CLSTAR(J,1)= ',
     & (CLSTAR(J,1),J=1,NDCLS)
      IF(DEBUG1)WRITE(JOSTND1,*)'INITIAL DEN-CLSTAR(J,1)*TPACLS(J,1)= ',
     & (CLSTAR(J,1)*TPACLS(J,1),J=1,NDCLS)
C
C  CALCULATE THEORETICAL TPA IN DIA CLASS 1
C  TPA1=TARGET/(R1 + R2/Q + R3/Q**2 + ... + NN/Q(NDCLS-1))
C
      IF(QFATAR.LE.0)THEN
        CTAR=CBA
      ELSEIF(QFATAR.LE.1)THEN
        CTAR=CTPA
      ELSE
        CTAR=CSDI
      ENDIF
C
C  CHECK TO SEE IF THERE IS ENOUGH INVENTORY TO SATISFY THE
C  TARGET. IF NOT, THEN CANCEL THE ACTIVITY.
C
      SUMINV=0.
      DO I=1,NDCLS
      SUMINV=SUMINV+CLSTAR(I,1)*TPACLS(I,1)
      ENDDO
      IF(DEBUG1)WRITE(JOSTND1,*)' SUMINV,CTAR,LDELQFA= ',
     &SUMINV,CTAR,LDELQFA
      IF(SUMINV.LT.CTAR)THEN
        LDELQFA=.TRUE.
        GOTO 500
      ENDIF
C
C  SUM DENOMINATOR TERMS AND SET TEMPORATY TPAs
C
      DINOM=0.
      DO I=1,NDCLS
      DINOM=DINOM+CLSTAR(I,1)/QFAC**(I-1)
      TPACLS(I,4)=TPACLS(I,1)
      ENDDO
C
C  CALCULATE THE THEORETICAL NUMBER OF TREES IN DIAMETER CLASS 1
C
        TPA1=CTAR/DINOM
C
  200 CONTINUE
      IF(DEBUG1)WRITE(JOSTND1,*)' ****************AFTER STATEMENT 200'
      IF(DEBUG1)WRITE(JOSTND1,*)' TPA1,DINOM,CTAR= ',TPA1,DINOM,CTAR
C
C  CALCULATE THE THEORETICAL NUMBER OF TREES IN ALL OTHER DIAMETER CLASSES
C  AND THE EXCESS OR DEFICITS IN EACH CLASS
C
      DO I=1,NDCLS
        TPACLS(I,2)=TPA1/QFAC**(I-1)        ! THEORETICAL
        TPACLS(I,3)=TPACLS(I,4)-TPACLS(I,2) ! NEG=DEFICIT, POS=EXCESS
      ENDDO
C
      IF(DEBUG1)WRITE(JOSTND1,*)'THEORETICAL TPA TPA-TPACLS(J,2)= ',
     & (TPACLS(J,2),J=1,NDCLS)
      IF(DEBUG1)WRITE(JOSTND1,*)'THEORETICAL DENSITY-',
     &'TPACLS(J,2)*CLSTAR(J,1)= ',(TPACLS(J,2)*
     &CLSTAR(J,1),J=1,NDCLS)
C
C  SUM TARGET UNDER CURVE
C
      SUMTAR=0.
      DO I=1,NDCLS
      IF(TPACLS(I,3).LE.0.)THEN
        SUMTAR=SUMTAR+TPACLS(I,4)*CLSTAR(I,1)
      ELSE
        SUMTAR=SUMTAR+TPACLS(I,2)*CLSTAR(I,1)
      ENDIF
      ENDDO
C
      IF(DEBUG1)WRITE(JOSTND1,*)'TPA1,SUMTAR,TPACLS(J,2)= ',
     &TPA1,SUMTAR,(TPACLS(J,2),J=1,NDCLS)
      IF(DEBUG1)WRITE(JOSTND1,*)'CURRENT EXESS/DEF-TPACLS(J,3)= ',
     &(TPACLS(J,3),J=1,NDCLS)
C
C  CALCUALTE DATA FOR THEORETICAL CURVE BASED ON EXCESS THEN
C  SUM DINOMINATOR TERMS
C
      DINOM=0.
      DO I=1,NDCLS
      IF(TPACLS(I,3).GT.0)THEN
        DINOM=DINOM+CLSTAR(I,1)/QFAC**(I-1)
C
C  SET NEW EXISTING EXCESS TPA BASED ON NEW CURVE
C
        TPACLS(I,4)=TPACLS(I,3)
      ELSE
        TPACLS(I,4)=0.
      ENDIF
      ENDDO
C
      IF(DEBUG1)WRITE(JOSTND1,*)'DINOM,SUMTAR,TPACLS(I,3)= ',
     &DINOM,SUMTAR,(TPACLS(J,3),J=1,NDCLS)
C
C  TRACK DENSITY IN EACH DIAMETER CLASS IN CLSTAR(I,2)
C
      SUM=0.
      DO I=1,NDCLS
      IF(TPACLS(I,3).GT.0)THEN
        CLSTAR(I,2)= CLSTAR(I,2)+TPACLS(I,2)*CLSTAR(I,1)
      ELSE
        CLSTAR(I,2)=TPACLS(I,1)*CLSTAR(I,1)
      ENDIF
      SUM=SUM+CLSTAR(I,2)
      ENDDO
C
      IF(DEBUG1)WRITE(JOSTND1,*)'SUM,CLSTAR(I,2)= ',SUM,
     &(CLSTAR(J,2),J=1,NDCLS)

      IF(QFATAR.LE.0)THEN
        IF(ABS(CBA-SUM).LT.0.1)GOTO 500
      ELSEIF(QFATAR.LE.1)THEN
        IF(ABS(CTPA-SUM).LT.0.1)GOTO 500
      ELSE
        IF(ABS(CSDI-SUM).LT.0.1)GOTO 500
      ENDIF
C
      IF(DINOM.GT.0.)TPA1=(CTAR-SUMTAR)/DINOM
      CTAR=CTAR-SUMTAR
C
      IF(ABS(TPA1).LE.0.1)GOTO 500
      GOTO 200
  500 CONTINUE
      IF(DEBUG1)WRITE(JOSTND1,*)'***AFTER 500-TPA1=',TPA1
C
      ICOUNT=1
      RETURN
C
C     ENTRY POINT CYCQFA ***********************************************
C
      ENTRY CYCQFA(VALMIN,VALMAX,CTPA,CBA,CSDI,QFATAR,DIACW,
     &             ICFLAG,JOSTND1,DEBUG1,LQFA)
C
C  CALLED FROM CUTS TO SET PARAMETERS FOR THINNING EVERY DIAMETER CLASS
C  LQFA = LOGICAL RETURN VARIABLE FROM CUTQFA
C         .TRUE. MORE DIAMETER CLASSES TO BE PROCESSED
C         .FALSE. LAST DIAMETER CLASS TO BE PROCESSED
C
      IF(DEBUG1)WRITE(JOSTND1,*)'ENTERING CYCQFA-ICOUNT= ',ICOUNT
C
C  INITIALIZE VARIABLES
C
      CBA=0.
      CTPA=0.
      CSDI=0.
C
C  SET DIAMETER LIMITS AND TARGETS FOR EACH DIAMETER CLASS
C
  600 CONTINUE
      IF((TPACLS(ICOUNT,1)*
     &    CLSTAR(ICOUNT,1)-CLSTAR(ICOUNT,2)).GT..00001)THEN
        VALMIN=DCLS(ICOUNT)-DIACW/2.
        VALMAX=DCLS(ICOUNT)+DIACW/2.
        IF(QFATAR.LE.0)THEN
          CBA=CLSTAR(ICOUNT,2)
        ELSEIF(QFATAR.LE.1)THEN
          CTPA=CLSTAR(ICOUNT,2)
        ELSE
          CSDI=CLSTAR(ICOUNT,2)
        ENDIF
        ICOUNT=ICOUNT+1
      ELSE
        ICOUNT=ICOUNT+1
        IF(ICOUNT.GT.NDCLS)GOTO 700
        GO TO 600
      ENDIF
  700 CONTINUE
C
C  THE FOLLOWING LOOP CHECKS FOR THE LAST DIA CLASS REQUIRING
C  CUTTING
C
      LQFA=.FALSE.
      DO I=ICOUNT,NDCLS
      EXCESS1=TPACLS(I,1)*CLSTAR(I,1)-CLSTAR(I,2)
      IF(DEBUG1)WRITE(JOSTND1,*)' EXCESS1= ',EXCESS1
      IF(EXCESS1.GT..00001)LQFA=.TRUE.
      ENDDO
      IF(ICOUNT.GT.NDCLS)LQFA=.FALSE.
      IF(DEBUG1)WRITE(JOSTND1,*)'LEAVING CYCQFA-ICOUNT= ',ICOUNT
      IF(DEBUG1)WRITE(JOSTND1,*)'IN CYCQFA-VALMIN,VALMAX,CBA,',
     &'CSDI,EXCESS1,LQFA= ',VALMIN,VALMAX,CBA,CSDI,EXCESS1,LQFA
C
      RETURN
      END
