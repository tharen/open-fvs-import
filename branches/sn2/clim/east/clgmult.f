      SUBROUTINE CLGMULT(TREEMULT)
      IMPLICIT NONE
C----------
C  $Id: clgmult.f 1004 2013-08-01 16:04:44Z rhavis@msn.com $
C----------
C
C     CLIMATE EXTENSION -- COMPUTES TREE-LEVEL GROWTH MULTIPLIER
C
COMMONS
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'ARRAYS.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'CLIMATE.F77'
C
COMMONS
C

C --- PJR
C --- NEED TO REPLACE BIRTHYR WITH BASEYR IN clgmult.f and clmorts.f

      INTEGER I,I1,I2
      REAL TREEMULT(MAXTRE),THISYR,ALGSLP,BIRTHYR,GROW_TD0,GROW_TD1,
     >     XINVYR,D100_BIRTH,D100_NOW,D100_INVYR,MTCM_BIRTH,MTCM_NOW,
     >     MTCM_INVYR,MTCM_TD,SMI_NOW,SMI_INVYR,SMI_BIRTH,SMI_TD,
     >     MMIN_NOW,MMIN_INVYR,MMIN_BIRTH,MMIN_TD,DD0_NOW,DD0_INVYR,
     >     PSITE_NOW,PSITE_INVYR,DD0_BIRTH,MAT_BIRTH,XDF,XWL,XPP,
     >     XRELGR,VSCORE(MAXSP),PS,SPWTS(MAXSP),XWT,XGSITE,XR,
     >     D100_BASE,MTCM_BASE,SMI_BASE,MMIN_BASE,DD0_BASE,MAT_BASE
      LOGICAL DEBUG
      
C-----DATA FOR CLIMATE VIABILITY (MORTALITY) THRESHOLDS 
      DATA Q01/
     &  0, 0, 0, 0, .0155, .0256, 0, .0581, 0, 0,
     &  .0246, 0, 0.0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0/

      DATA Q10/
     &  0, 0, 0, 0, .0992, .1473, 0, .2036, 0, 0,
     &  .1681, 0, .1370, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0,
     &  0, 0, 0, 0, 5, 6, 0, 0, 0, 0/
C----------
      

      CALL DBCHK (DEBUG,'CLGMULT',7,ICYC) 
      IF (DEBUG) WRITE (JOSTND,1) LCLIMATE
    1 FORMAT ('IN CLGMULT, LCLIMATE=',L2)

C     INSURE THE MULTIPLIER, AND THE REPORTED SPECIES AVERAGE ARE 
C     INITIALLY 1.0 (NO CLIMATE EFFECT).

      TREEMULT(1:ITRN)=1.
      SPGMULT = 0.
      SPVIAB = 1.     
      SPSITGM = 1.
      
      IF (.NOT.LCLIMATE) RETURN

      IF (DEBUG) WRITE (JOSTND,2) ICYC,IY(ICYC),IXMTCM,IXMAT,
     >           IXDD5,IXGSP,IXD100,IXMMIN,IXDD0,IXPSITE
    2 FORMAT ('IN CLGMULT, ICYC,IY(ICYC)=',2I5,' IXMTCM,' 
     >  'IXDD5,IXMAT=',3I4,' IXGSP,IXD100,IXMMIN,IXDD0,IXPSITE=',5I4)

      IF (IXMTCM*IXDD5*IXMAT*IXGSP*IXD100*IXMMIN*IXDD0.EQ.0) 
     >    RETURN

C     LOAD THE CLIMATE DATA FOR THIS YEAR.

      XINVYR=FLOAT(IY(1))
      
C      WRITE (JOSTND,3) XINVYR, FLOAT(YEARS) , ATTRS(1:4,IXMTCM),
C     >  FLOAT(NYEARS)
C    3 FORMAT('IN GCMULT, line 59 XINVYR = ',F5.0,' YEARS= ',4F6.0,
C     >  ' ATTRS(1:4,IXMTCM)= ',4F5.2,' NYEARS= ',F5.0)
C      WRITE (JOSTND,'(T12,"SITEAR = ",F5.1)') SITEAR(ISISP)

C ---- 	INTERPOLATE CLIMATE ATTRIBUTES TO XINVYR AND THISYR (NOW)
      MTCM_INVYR= ALGSLP (XINVYR, FLOAT(YEARS), ATTRS(1,IXMTCM),NYEARS)
      D100_INVYR= ALGSLP (XINVYR, FLOAT(YEARS), ATTRS(1,IXD100),NYEARS)
      MMIN_INVYR= ALGSLP (XINVYR, FLOAT(YEARS), ATTRS(1,IXMMIN),NYEARS)
      DD0_INVYR = ALGSLP (XINVYR, FLOAT(YEARS), ATTRS(1,IXDD0), NYEARS)
      SMI_INVYR = ALGSLP (XINVYR, FLOAT(YEARS), ATTRS(1,IXDD5), NYEARS)/
     >            ALGSLP (XINVYR, FLOAT(YEARS), ATTRS(1,IXGSP), NYEARS)

      THISYR=FLOAT(IY(ICYC))+(FINT/2)  ! (decimal) midpoint year of growth/inventory  cycle

      MTCM_NOW = ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXMTCM),NYEARS) 
      D100_NOW = ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXD100),NYEARS)
      MMIN_NOW = ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXMMIN),NYEARS)
      DD0_NOW  = ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXDD0), NYEARS)
      SMI_NOW  = ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXDD5), NYEARS)/
     >           ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXGSP), NYEARS)
C      WRITE (JOSTND,4) ATTRS(1,IXPSITE)

C ----INTERPOLATE SITE INDEX TO XINVYEAR AND THISYEAR
C     CHECKING/ADJUSTING FOR VALUES CLOSE TO ZERO
C     NOT SURE WHEN IXPSITE (ATTR NUMBER FOR SI) WOULD EVER BE ZERO (PJR)
      IF (IXPSITE.EQ.0) THEN
        PSITE_INVYR=1.0
        PSITE_NOW=1.0
        XGSITE=1.0
      ELSE
        PSITE_INVYR=ALGSLP(XINVYR,FLOAT(YEARS),ATTRS(1,IXPSITE),NYEARS) ! not needed in southern variant
        PSITE_NOW= ALGSLP (THISYR,FLOAT(YEARS),ATTRS(1,IXPSITE),NYEARS)

        SITEAR(ISISP) = PSITE_NOW
C        WRITE(JOSTND,*)'CLGMULT IXPSITE= ',IXPSITE
      ENDIF

C      WRITE (JOSTND,4) FLOAT(IXPSITE)
C    4 FORMAT('IN CLGMULT, line 119 VSCORE(I) = ',F7.2)


      IF (DEBUG) WRITE (JOSTND,5) MTCM_INVYR,D100_INVYR,MMIN_INVYR,
     >   SMI_INVYR,PSITE_INVYR,PSITE_NOW,XGSITE
    5 FORMAT ('IN CLGMULT,MTCM_INVYR,D100_INVYR,MMIN_INVYR,',
     >        ' SMI_INVYR=',4F10.4,'PSITE_INVYR,NOW,XGSITE=',3F10.4)

C --- VIABILITY SCORES
      VSCORE=1.0    
      DO I=1,MAXSP
        I2 = INDXSPECIES(I)          
        IF (I2.GT.0) THEN
          VSCORE(I) = ALGSLP (THISYR,FLOAT(YEARS),ATTRS(1,I2),NYEARS)
          SPVIAB(I) = VSCORE(I)  ! used in the report generation
          IF (VSCORE(I).GT. Q10(I)) THEN
            VSCORE(I) = 1.            
          ELSE 
            IF (VSCORE(I) .LT. Q01(I)) THEN
              VSCORE(I) = 0.0
            ELSE
              VSCORE(I)= (VSCORE(I) - Q01(I))/(Q10(I) - Q01(I))
            ENDIF
          ENDIF
C          IF (DEBUG) WRITE (JOSTND,7) JSP(I),VSCORE(I),Q01(I),Q10(I)
          IF (DEBUG) WRITE (JOSTND,7) JSP(I),VSCORE(I)
    7     FORMAT ('IN CLGMULT, SP=',A2,' VSCORE= ',F13.5)
        ENDIF  
      ENDDO
c---- APPLY GROWTH MULTIPLIERS FROM PROVENANCE STUDY MODELS
      DO I=1,ITRN  ! LOOP THROUGH TREE RECORDS (ITRN)
      
C       ABIRTH IS AGE, NOT YEAR OF BIRTH.  COMPUTE BIRTH YEAR:
        
        BASEYR   = 1990
        ! TEMPERATURE RESPONSE FUNCTION BASE YEAR 1990
        ! TRANSFER DISTANCE CALCULATED FROM MTCM (MTCM_INVYR, MTCM_NOW)
        MTCM_BASE = ATTRS(1,IXMTCM)
        
        
C ----- TRANSFER FUNCTIONS
C       LONGLEAF PINE: Schmidtling and Sluder (1995) R = 1 + .00954*T - .00288*T^2      
C       SHORTLEAF PINE: Wells and Wakeley 1970, USE LONGLEAF PINE MODEL 
C       LOBLOLLY PINE: Schmidtling (1994) R = 1 + .0135*T - .0022*T^2
C       SLASH PINE: Gansel et al. 1971, USE LOBLOLLY PINE MODEL
C       POND PINE: NO REFERENCE, USE LONGLEAF PINE MODEL

        MTCM_TD = MTCM_NOW - MTCM_BASE
        XRELGR = 1.0
C       LONGLEAF & SHORTLEAF 
        XR = 1 + 0.00954*MTCM_TD - 0.00288*MTCM_TD**2
        IF     (TRIM(PLNJSP(ISP(I))).EQ.TRIM('PIPA2') .OR.
     >          TRIM(PLNJSP(ISP(I))).EQ.TRIM('PIEC2')) XRELGR=XR
C       LOBLOLLY & SLASH (& POND)
        XR = 1 + 0.0135*MTCM_TD - 0.0022*MTCM_TD**2
        IF     (TRIM(PLNJSP(ISP(I))).EQ.TRIM('PITA') .OR.
     >          TRIM(PLNJSP(ISP(I))).EQ.TRIM('PIEL') .OR.
     >          TRIM(PLNJSP(ISP(I))).EQ.TRIM('PISE')) XRELGR=XR
        IF (ABS(XRELGR-1.0).LT. .005) XRELGR=1.0 

        ! PJR dropped the MIN or MAX logic for growth modifiers
C        PS = MIN(XGSITE,XRELGR,VSCORE(ISP(I)))
        PS = XRELGR
C        IF (DEBUG) WRITE (JOSTND,9) I,PLNJSP(ISP(I)),XGSITE,
C     >             XRELGR,CLGROWMULT(ISP(I))
C    9   FORMAT ('Line 212 CLGMULT, I=',I5,' SP=',A5,' XGSITE=',F8.3,
C     >          ' XRELGR=',F8.5,' CLGROWMULT=',F8.3)
C        IF (PS.GE. 1.0) PS=MAX(XGSITE,XRELGR,VSCORE(ISP(I)))
        IF (PS .GT. 3.) PS = 3.0 
        IF (PS .LT. 0.) PS = 0.0 
        TREEMULT(I)=1.+((PS-1.)*CLGROWMULT(ISP(I)))
        IF (TREEMULT(I) .LT. 0) TREEMULT(I) = 0.
        IF (DEBUG) WRITE (JOSTND,10) I,JSP(ISP(I)),PS,
     >             XRELGR,TREEMULT(I)
   10   FORMAT ('IN CLGMULT, I=',I5,' SP=',A2,' PS=',F8.3,
     >          ' XRELGR=',F8.3,' TREEMULT=',F8.3)
      ENDDO
      ! Compute SPSITGM for reporting only (this is a vector operation).
      ! PJR commented out. XGSITE not used in southern variant
C      SPSITGM = XGSITE**CLGROWMULT
C      WRITE (JOSTND,'("SPSITGM = ",F8.3)') SPSITGM
      
C     CREATE THE REPORTED AVERAGE SCORE. 

C      WRITE (JOSTND,'("ITRN= ",I4)') ITRN
      SPWTS = 0.0
      DO I=1,ITRN
        I1 = ISP(I)
        XWT = DBH(I)*DBH(I)*PROB(I)  ! ba weighted
        SPWTS(I1) = SPWTS(I1)+XWT
        SPGMULT(I1)= SPGMULT(I1)+(TREEMULT(I)*XWT)
      ENDDO
      DO I=1,MAXSP
        IF (SPWTS(I).GT.0.) THEN
          SPGMULT(I)=SPGMULT(I)/SPWTS(I)
        ELSE
          SPGMULT(I)=1.
        ENDIF    
      ENDDO

      IF (DEBUG) THEN
        DO I=1,MAXSP
          WRITE (JOSTND,20) I,JSP(I),SPVIAB(I),
     >            SPSITGM(I),SPGMULT(I),SPWTS(I)
   20     FORMAT ('IN CLGMULT, I=',I5,' SP=',A2,' SPVIAB=',F7.3,
     >            ' SPSITGM=',F9.3,' SPGMULT=',F9.3,' SPWTS=',F13.2)
        ENDDO
      ENDIF
      
      RETURN
      END

