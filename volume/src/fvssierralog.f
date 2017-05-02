      SUBROUTINE FVSSIERRALOG(VN,VM,VMAX,ISPC,D,H,BARK,LCONE,CTKFLG)
      IMPLICIT NONE
C----------
C VOLUME $Id: fvssierralog.f 1744 2016-03-28 21:01:34Z rhavis $
C----------
C  This routine 

COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      REAL VN,VM,VMAX,D,H,BARK,ALVN,BEHRE,STUMP
      REAL DMRCH,HTMRCH,S3,VOLM,VOLT
      LOGICAL LCONE,CTKFLG
      INTEGER ISPC
C
C  WESTERN SIERRA LOG RULES
C
      GO TO (801,802,803,804,805,806,807,808,809,810,811),ISPC
C----------
C  OTHER CONIFER
C----------
  801 ALVN=-6.5819 + 2.0022*ALOG(D) + 1.0598*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C  SUGAR PINE
C----------
  802 ALVN=-6.0657 + 2.1126*ALOG(D) + 0.8635*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C  DOUGLAS-FIR
C----------
  803 ALVN=-6.5807 + 1.8332*ALOG(D) + 1.1602*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C  WHITE FIR
C----------
  804 ALVN=-6.3998 + 1.9203*ALOG(D) + 1.0802*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C  MADRONE
C----------
  805 CONTINUE
      VN=0.006732  *(D**1.96628)*(H**0.83458)
      GO TO 820
C----------
C  INCENSE CEDAR
C----------
  806 ALVN=-5.8157 + 1.9023*ALOG(D) + 0.9114*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C  BLACK OAK
C----------
  807 VN = 0.00705381*(D**1.97437)*(H**0.85034)
      GO TO 820
C----------
C TANOAK
C----------
  808 CONTINUE
      VN=0.00588700*(D**1.94165)*(H**0.86562)
      GO TO 820
C----------
C RED FIR
C----------
  809 ALVN=-6.4929 + 1.9271*ALOG(D) + 1.0884*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C  PONDEROSA PINE.
C----------
  810 ALVN=-6.5819 + 2.0022*ALOG(D) + 1.0598*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C TANOAK
C----------
  811 VN=0.00588700*(D**1.94165)*(H**0.86562)
C----------
C  NEGATIVE VOLUMES ARE RESET TO ZERO.
C----------
  820 CONTINUE
      IF(VN .LT. 0.) VN = 0.0
C----------
C SET VMAX.
C----------
      VMAX=VN
C----------
C COMPUTE MERCHANTABLE CUBIC FOOT VOLUME.
C----------
      CTKFLG = .TRUE.
      IF(VN .EQ. 0.)THEN
        VM = 0.
        CTKFLG = .FALSE.
        GO TO 850
      ENDIF
      CALL BEHPRM (VMAX,D,H,BARK,LCONE)
      VOLT=BEHRE(0.0,1.0)
C----------
C  COMPUTE MERCHANTABLE CUBIC VOLUME USING TOP DIAMETER, MINIMUM
C  DBH, AND STUMP HEIGHT SPECIFIED BY THE USER.
C----------
      STUMP = 1. - (STMP(ISPC)/H)
      IF(D.LT.DBHMIN(ISPC).OR.D.LT.TOPD(ISPC)) THEN
        VM=0.0
      ELSE
        DMRCH=TOPD(ISPC)/D
        HTMRCH=((BHAT*DMRCH)/(1.0-(AHAT*DMRCH)))
        IF(.NOT.LCONE) THEN
          VOLM=BEHRE(HTMRCH,STUMP)
          VM=VMAX*VOLM/VOLT
        ELSE
C----------
C       PROCESS CONES.
C----------
            S3=STUMP**3
            VOLM=S3-HTMRCH**3
            VM=VMAX*VOLM
        ENDIF
      ENDIF
  850 CONTINUE
      RETURN
      END