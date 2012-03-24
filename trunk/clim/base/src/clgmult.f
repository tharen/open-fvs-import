      SUBROUTINE CLGMULT(TREEMULT)
      IMPLICIT NONE
C----------
C  **CLGMULT CLIMATE--DATE OF LAST REVISION:  03/23/2012
C----------
C
C     CLIMATE EXTENSION -- COMUTES TREE-LEVEL GROWTH MULTIPLIER
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
      INTEGER I,I1,I2
      REAL TREEMULT(MAXTRE),THISYR,ALGSLP,BIRTHYR,GROW_TD0,GROW_TD1,
     >     XINVYR,D100_BIRTH,D100_NOW,D100_INVYR,MTCM_BIRTH,MTCM_NOW,
     >     MTCM_INVYR,MTCM_TD,SMI_NOW,SMI_INVYR,SMI_BIRTH,SMI_TD,
     >     MMIN_NOW,MMIN_INVYR,MMIN_BIRTH,MMIN_TD,DD0_NOW,DD0_INVYR,
     >     PSITE_NOW,PSITE_INVYR,DD0_BIRTH,MAT_BIRTH,XDF,XWL,XPP,
     >     XRELGR,XGSITE,VSCORE(MAXSP),PS,SPWTS(MAXSP),XWT
      LOGICAL DEBUG

      CALL DBCHK (DEBUG,'CLGMULT',7,ICYC)

      IF (DEBUG) WRITE (JOSTND,1) LCLIMATE
    1 FORMAT (' IN CLGMULT, LCLIMATE=',L2)

C     INSURE THE MULTIPLIER, AND THE REPORTED SPECIES AVERAGE ARE 
C     INITIALLY 1.0 (NO CLIMATE EFFECT).

      TREEMULT(1:ITRN)=1.
      SPGMULT = 0.
      SPVIAB = 1.     
      
      IF (.NOT.LCLIMATE) RETURN

      IF (DEBUG) WRITE (JOSTND,2) ICYC,IY(ICYC),IXMTCM,IXMAT,
     >           IXDD5,IXGSP,IXD100,IXMMIN,IXDD0,IXPSITE
    2 FORMAT (' IN CLGMULT, ICYC,IY(ICYC)=',2I5,' IXMTCM,' 
     >  'IXDD5,IXMAT=',3I4,' IXGSP,IXD100,IXMMIN,IXDD0,IXPSITE=',5I4)

      IF (IXMTCM*IXDD5*IXMAT*IXGSP*IXD100*IXMMIN*IXDD0.EQ.0) 
     >    RETURN

C     LOAD THE CLIMATE DATA FOR THIS YEAR.

      XINVYR=FLOAT(IY(1))

      MTCM_INVYR= ALGSLP (XINVYR, FLOAT(YEARS), ATTRS(1,IXMTCM),NYEARS)
      D100_INVYR= ALGSLP (XINVYR, FLOAT(YEARS), ATTRS(1,IXD100),NYEARS)
      MMIN_INVYR= ALGSLP (XINVYR, FLOAT(YEARS), ATTRS(1,IXMMIN),NYEARS)
      DD0_INVYR = ALGSLP (XINVYR, FLOAT(YEARS), ATTRS(1,IXDD0), NYEARS)
      SMI_INVYR = ALGSLP (XINVYR, FLOAT(YEARS), ATTRS(1,IXDD5), NYEARS)/
     >            ALGSLP (XINVYR, FLOAT(YEARS), ATTRS(1,IXGSP), NYEARS)

      THISYR=FLOAT(IY(ICYC))+(FINT/2)

      MTCM_NOW = ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXMTCM),NYEARS) 
      D100_NOW = ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXD100),NYEARS)
      MMIN_NOW = ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXMMIN),NYEARS)
      DD0_NOW  = ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXDD0), NYEARS)
      SMI_NOW  = ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXDD5), NYEARS)/
     >           ALGSLP (THISYR, FLOAT(YEARS), ATTRS(1,IXGSP), NYEARS)

      IF (IXPSITE.EQ.0) THEN
        PSITE_INVYR=1.0
        PSITE_NOW=1.0
        XGSITE=1.0
      ELSE
        PSITE_INVYR=ALGSLP(XINVYR,FLOAT(YEARS),ATTRS(1,IXPSITE),NYEARS)
        PSITE_NOW= ALGSLP (THISYR,FLOAT(YEARS),ATTRS(1,IXPSITE),NYEARS)
        IF (PSITE_INVYR.LE. .001) THEN
          XGSITE = 2.
        ELSE IF (ABS(PSITE_NOW-PSITE_INVYR) .LT. .001) THEN
          XGSITE=1.0
        ELSE
          XGSITE = PSITE_NOW/PSITE_INVYR
          XGSITE = 1.5819767*(1.-(EXP(-XGSITE)))
          IF (ABS(XGSITE-1.0).LT. .01) XGSITE=1.0
        ENDIF
      ENDIF
      IF (DEBUG) WRITE (JOSTND,5) MTCM_INVYR,D100_INVYR,MMIN_INVYR,
     >   SMI_INVYR,PSITE_INVYR,PSITE_NOW,XGSITE
    5 FORMAT (' IN CLGMULT,MTCM_INVYR,D100_INVYR,MMIN_INVYR,',
     >        ' SMI_INVYR=',4F10.4,' PSITE_INVYR,NOW,XGSITE=',3F10.4)

      VSCORE=1.0    
      DO I=1,MAXSP
        I2 = INDXSPECIES(I)          
        IF (I2.GT.0) THEN
          VSCORE(I) = ALGSLP (THISYR,FLOAT(YEARS),ATTRS(1,I2),NYEARS)
          SPVIAB(I) = VSCORE(I)  ! used in the report generation
          IF (VSCORE(I).GT. 0.5) THEN
            VSCORE(I) = 1.            
          ELSE 
            VSCORE(I)=-.66666667 + VSCORE(I)*3.3333333
          ENDIF
          IF (VSCORE(I).LT. 0.2) VSCORE(I) = 0.2
          IF (DEBUG) WRITE (JOSTND,7) JSP(I),VSCORE(I)
    7     FORMAT (' IN CLGMULT, SP=',A2,' VSCORE= ',F13.5)
        ENDIF  
      ENDDO

      DO I=1,ITRN
        IF (PLNJSP(ISP(I)).EQ.'PSME'  .OR.
     >      PLNJSP(ISP(I)).EQ.'LAOC'  .OR.
     >      PLNJSP(ISP(I)).EQ.'PIPO'  .OR.
     >      PLNJSP(ISP(I)).EQ.'PICO'  .OR.
     >      PLNJSP(ISP(I)).EQ.'PIMO3' .OR.
     >      PLNJSP(ISP(I)).EQ.'PIEN'  .OR.
     >      PLNJSP(ISP(I)).EQ.'TSHE' ) THEN
      
C         ABIRTH IS AGE, NOT YEAR OF BIRTH.  COMPUTE BIRTH YEAR:
          
          BIRTHYR   = THISYR-ABIRTH(I)
          
          MTCM_BIRTH= ALGSLP (BIRTHYR,FLOAT(YEARS),ATTRS(1,IXMTCM), 
     >                        NYEARS)
          MAT_BIRTH = ALGSLP (BIRTHYR,FLOAT(YEARS),ATTRS(1,IXMAT), 
     >                        NYEARS)
          MMIN_BIRTH= ALGSLP (BIRTHYR,FLOAT(YEARS),ATTRS(1,IXMMIN), 
     >                        NYEARS)
          DD0_BIRTH = ALGSLP (BIRTHYR,FLOAT(YEARS),ATTRS(1,IXDD0),  
     >                        NYEARS)
          D100_BIRTH= ALGSLP (BIRTHYR,FLOAT(YEARS),ATTRS(1,IXD100), 
     >                        NYEARS)
          SMI_BIRTH = ALGSLP (BIRTHYR,FLOAT(YEARS),ATTRS(1,IXDD5),  
     >                        NYEARS)   /
     >                ALGSLP (BIRTHYR,FLOAT(YEARS),ATTRS(1,IXGSP), 
     >                        NYEARS)
          
C         FROM LEITES CHAPETER 3 FOR DOUGLAS FIR:
C         b0 (intercept)  172.70
C         b1 (MTCM_TD)     1.545  
C         b2 (MTCM_TD^2)  -2.253
C         b3 (MAT)         2.646
C         b4 (MTCM_TD*MAT)-1.379
          
C         NOTE THAT MTCM_TD IS ACTUALLY THE DIFFERENCE BETWEEN TWO PLACES, HERE
C         WE SUBSTITUE TIME FOR SPACE. MAT IS THE TEMPERATURE AT THE SEED
C         SOURCE...WE USE IT HERE AS "BIRTH YEAR".
          
          MTCM_TD = MTCM_NOW - MTCM_INVYR
          GROW_TD0 = 172.70 + 2.646*MAT_BIRTH 
          GROW_TD1 = 172.70  + 1.545*MTCM_TD - 2.253*MTCM_TD**2 + 
     >                 2.646 * MAT_BIRTH     - 1.379*MAT_BIRTH*MTCM_TD
          XDF = GROW_TD1/GROW_TD0
          
C         FROM LEITES FINAL LARCH MODEL     
C         b0 (intercept)     542.20
C         b1 (mmin.trds)     17.50
C         b2 (mmin.trds2)    -1.215
C         b3 (dd0)           -0.1468
C         b4 (mmin.trds*dd0) -0.0187
          
          MMIN_TD = MMIN_NOW - MMIN_INVYR            
          GROW_TD0= 542.20 - 0.1468*DD0_BIRTH
          GROW_TD1= 542.20 + 17.50*MMIN_TD - 1.215*MMIN_TD**2
     >            - 0.1468*DD0_BIRTH - 0.0187*MMIN_TD*DD0_BIRTH
          XWL = GROW_TD1/GROW_TD0
          
C         FROM LEITES PRELIMINARY PONDEROSA PINE MODEL
C         (Intercept)     551.20221
C         smi.trds        -14.88483
C         I(smi.trds^2)   -0.58027 
C         d100            -2.02135 
C         smi.trds:d100    0.15582 
          
          SMI_TD = SMI_NOW - SMI_INVYR
          GROW_TD0= 551.20221 - 2.02135*D100_BIRTH
          GROW_TD1= 551.20221 -14.88483*SMI_TD -0.58027*SMI_TD**2
     >             -2.02135*D100_BIRTH + 0.15582*SMI_TD*D100_BIRTH
          XPP = GROW_TD1/GROW_TD0
                  
          IF     (PLNJSP(ISP(I)).EQ.'PSME') THEN
            XRELGR=XDF
          ELSEIF (PLNJSP(ISP(I)).EQ.'PICO') THEN
            XRELGR=XDF
          ELSEIF (PLNJSP(ISP(I)).EQ.'PIPO') THEN
            XRELGR=XPP
          ELSEIF (PLNJSP(ISP(I)).EQ.'LAOC') THEN
            XRELGR=XWL
          ELSEIF (PLNJSP(ISP(I)).EQ.'PIMO3') THEN
            XRELGR=XWL
          ELSEIF (PLNJSP(ISP(I)).EQ.'PIEN') THEN
            XRELGR=XWL
          ELSEIF (PLNJSP(ISP(I)).EQ.'TSHE') THEN
            XRELGR=XWL
          ELSE 
            XRELGR = 1.
          ENDIF
        
          IF (ABS(XRELGR-1.0).LT. .015) XRELGR=1.0
          PS = MIN(XGSITE,XRELGR,VSCORE(ISP(I)))
          IF (PS.GT. 0.99) PS=MAX(XGSITE,XRELGR,VSCORE(ISP(I)))
          TREEMULT(I)=1.- ( (1.-PS)*CLGROWMULT(ISP(I)) )
          IF (DEBUG) WRITE (JOSTND,10) I,JSP(ISP(I)),BIRTHYR,
     >               XRELGR,TREEMULT(I)
   10     FORMAT (' IN CLGMULT, I=',I5,' SP=',A2,' BIRTHYR=',F7.1,
     >            ' XRELGR=',F10.3,' TREEMULT=',F10.3)
          
        ENDIF
      ENDDO
      
C     CREATE THE REPORTED AVERAGE SCORE. 

      SPWTS = 0.
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
          IF (SPWTS(I).GT.0.) WRITE (JOSTND,20) I,JSP(I),SPVIAB(I),
     >            SPGMULT(I),SPWTS(I)
   20     FORMAT (' IN CLGMULT, I=',I5,' SP=',A2,' SPVIAB=',F7.3,
     >            ' SPGMULT=',F10.3,' SPWTS=',F13.2)
        ENDDO
      ENDIF
      
      RETURN
      END

