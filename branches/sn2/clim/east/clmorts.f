      SUBROUTINE CLMORTS
      IMPLICIT NONE
C----------
C  $Id: clmorts.f 933 2013-06-11 15:19:27Z rhavis@msn.com $
C----------
C
C     CLIMATE EXTENSION - COMPUTES CLIMATE-CAUSED MORTALITY
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
      INTEGER I,I2
      REAL THISYR,ALGSLP,X,XV,FYRMORT(MAXSP),CTHISYR(6),
     >     CBIRTH(6),DTV(6),DMORT,BIRTHYR,SPWTS(MAXSP),
     >     VS(2),SR(2)
      LOGICAL DEBUG,LDMORT
      DATA VS/.2,.5/,SR/0.,1./

      CALL DBCHK (DEBUG,'CLMORTS',7,ICYC)   

      IF (DEBUG) WRITE (JOSTND,1) LCLIMATE,ICYC
    2 FORMAT ('IN CLMORTS, THISYR=',F8.2)
    1 FORMAT ('IN CLMORTS, LCLIMATE=',L2,' ICYC=',I3)
                                                               
      IF (.NOT.LCLIMATE) RETURN

C     IF THIS IS THE FIRST CYCLE, THEN SET THE SPECIES PRESENCE CALIBRATION. 
      
      IF (ICYC.EQ. 1) THEN
        THISYR=FLOAT(IY(ICYC)) ! START OF THE CYCLE
        DO I=1,MAXSP
          IF (INDXSPECIES(I).EQ.0) CYCLE         
          I2 = INDXSPECIES(I) 
          IF (ISCT(I,1) .GT. 0) THEN  ! THE SPECIES IS PRESENT (THIS IS A FACT).
            ! PJR REMOVED THE 0.9 MULTIPLIER ON SPCALIB
            SPCALIB(I) = 
     >         ALGSLP (THISYR,FLOAT(YEARS),ATTRS(1,I2),NYEARS) ! REMOVED *0.9
          ELSE                                  
            SPCALIB(I) = -1. ! SIGNAL SPECIES WAS NOT PRESENT.
          ENDIF          
          IF (DEBUG) WRITE (JOSTND,5) I,JSP(I)(1:2),
     >               SPCALIB(I)
    5     FORMAT ('IN CLMORTS, I=',I3,' SP=',A2,' SPCALIB=',F10.4)
        ENDDO
      ENDIF

      SPMORT1=0.
      FYRMORT=0.      
      THISYR=FLOAT(IY(ICYC))+(FINT/2)
C      IF (DEBUG) WRITE (JOSTND,2) THISYR
      DO I=1,MAXSP 
        IF (INDXSPECIES(I).EQ.0) CYCLE         
        I2 = INDXSPECIES(I) 
        
C       X IS THE SPECIES VIABILITY SCORE.
        
        XV = ALGSLP (THISYR,FLOAT(YEARS),ATTRS(1,I2),NYEARS)  
C        WRITE(JOSTND,'(T12,"XV = ",F8.5)') XV
C        WRITE (JOSTND,'(T12,"Q10(I) = ",F8.5)') Q10(I)

C       CONVERT XV TO A 5-YR SURVIVAL RATE. IF THE SPCALIB VALUE
C       IS -1 (SPECIES WAS NOT IN ORIGINAL DATA), OR IF THE VALUE
C       IS > Q10 (PRESENT AND CONSISTENT WITH VIABLILITY SCORES), THEN
C       SIMPLY USE THE BASIC SURVIVAL FUNCTION.

C ----- SPECIES-SPECIFIC VIABILITY THRESHOLDS

          IF (XV .GT. Q10(I)) THEN
            X = 1.            
          ELSE 
            IF (XV .LT. Q01(I)) THEN
              X = 0.0
            ELSE
              X= (XV - Q01(I))/(Q10(I) - Q01(I))
            ENDIF
          ENDIF

C        IF (SPCALIB(I).EQ.-1. .OR. SPCALIB(I) .GT. .5) THEN
C          X = ALGSLP (XV,VS,SR,2)
C        ELSE
C          X = SPCALIB(I)
C          IF (X.LT. .1) X = .1
C          X = ALGSLP (XV,VS * X * 2.,SR,2)
C        ENDIF

C       CONVERT TO A MORTALITY RATE AND APPLY MULTIPLIER.
C       SAVE THIS VERSION FOR REPORTING (5 YR).
        
        SPMORT1(I)=(1.-X)*CLMRTMLT1(I)
        
C       CONVERT TO A FINT-YR SURVIVAL RATE.

C       ASSUME VIABILITY SCORE IS P(SURV | 5-YEAR CYCLE)
C       PJR CONSIDER P(SURV | 7-YEAR?) AVERAGE FIA REMPER
        IF (X.GT. 1E-5) THEN  ! VERY LOW SURVIVAL SET TO 0
          X=EXP(LOG(X)/5.)**FINT
          IF (X.LT.0) THEN
            X=0.
          ELSE IF (X.GT.1.0) THEN
            X=1.0
          ENDIF
        ELSE
          X=0.
        ENDIF
C        WRITE(JOSTND,'(T12,"SPMORT1 = ",F8.5)') CLMRTMLT1(I)
         
C       CONVERT TO A MORTALITY RATE AND APPLY MULTIPLIER.

        FYRMORT(I)=(1.-X)*CLMRTMLT1(I)

        IF (DEBUG) WRITE (JOSTND,10) IFIX(THISYR),I,JSP(I)(1:2),XV,X,
     >             CLMRTMLT1(I),CLMRTMLT2(I),SPMORT1(I),FYRMORT(I)
   10   FORMAT ('IN CLMORTS, THISYR=',I5,' I=',I3,1X,A3,' XVia=',
     >          2F10.4,' CLMRTMLT1&2=',2F10.4,' MORT=',2F10.4)
      ENDDO
      
C     COMPUTE MORTALITY BASED ON CLIMATE TRANSFER DISTANCE. FIRST
C     COMPUTE THE CLIMATE METRICS FOR "THIS" YEAR. THE SECOND
C     PART IS FOR THE BIRTH YEAR, AND IT MUST BE DONE WITHIN THE
C     TREE LOOP.

      LDMORT = IDEmtwm.GT.0 .AND. IDEmtcm.GT.0 .AND. 
     >         IDEdd5.GT.0 .AND. IDEsdi.GT.0 .AND. 
     >         IDEdd0.GT.0 .AND. IDEmapdd5.GT.0 .AND. 
     >         IXMTWM.GT.0 .AND. IXMTCM.GT.0 .AND. 
     >         IXDD5.GT.0 .AND. IXDD0.GT.0 .AND. 
     >         IXMAP.GT.0 .AND. IXGSP.GT.0 .AND. IXGSDD5.GT.0
C     NO ELEVATION LAPSE RATES FOR CLIMATE VARIABLES IN SOUTHERN VARIANT
      LDMORT = .FALSE.

      IF (DEBUG) WRITE (JOSTND,11) LDMORT,IDEmtwm,IDEmtcm,
     >         IDEdd5,IDEsdi,IDEdd0,IDEmapdd5,
     >         IXMTWM,IXMTCM,IXDD5,IXDD0,IXMAP,IXGSP,IXGSDD5
   11 FORMAT ('IN CLMORTS, LDMORT=',L2,13I3)


      SPMORT2=0.
      SPWTS  =0.
      DO I=1,ITRN
C        WRITE(JOSTND,'(T12,"THISYR, ABIRTH(I) = ",2F8.3)') THISYR,
C     >                       ABIRTH(I)
        DMORT = 0.
        IF (LDMORT) THEN          
C -----   START: UNREACHABLE CODE IN THE SOUTHERN VARIANT
          BIRTHYR   = THISYR-ABIRTH(I)
          CBIRTH(1) = ALGSLP(BIRTHYR,FLOAT(YEARS),ATTRS(1,IXMTWM),
     >                        NYEARS)                    
          CBIRTH(2) = ALGSLP(BIRTHYR,FLOAT(YEARS),ATTRS(1,IXMTCM),
     >                        NYEARS)                    
          CBIRTH(3) = ALGSLP(BIRTHYR,FLOAT(YEARS),ATTRS(1,IXDD5),
     >                        NYEARS)                    
C         Definition: sdi=sqrt(gsdd5)/gsp
          CBIRTH(4) = SQRT(ALGSLP(BIRTHYR,FLOAT(YEARS),
     >                            ATTRS(1,IXGSDD5),NYEARS))/
     >                     ALGSLP(BIRTHYR,FLOAT(YEARS),
     >                            ATTRS(1,IXGSP),NYEARS)
          CBIRTH(5) = ALGSLP(BIRTHYR,FLOAT(YEARS),ATTRS(1,IXDD0),
     >                       NYEARS)                    
C         Definition: mapdd5 = map*dd5/1000  
          CBIRTH(6) = ALGSLP(BIRTHYR,FLOAT(YEARS),ATTRS(1,IXMAP),
     >                       NYEARS)*CBIRTH(3)/1000 
          DTV = CTHISYR - CBIRTH
          DTV(1) = DTV(1) / ATTRS(1,IDEmtwm)  
          DTV(2) = DTV(2) / ATTRS(1,IDEmtcm)  
          DTV(3) = DTV(3) / ATTRS(1,IDEdd5)   
          DTV(4) = DTV(4) / ATTRS(1,IDEsdi)   
          DTV(5) = DTV(5) / ATTRS(1,IDEdd0)   
          DTV(6) = DTV(6) / ATTRS(1,IDEmapdd5)
          DMORT = (SUM(DTV)/6.)-1.1 ! COMPUTE THE AVERAGE, THEN TRANSLATE
          IF (DMORT .LT. 0) DMORT = 0
          DMORT = .9*(1-EXP(-(DMORT)**2.5))
          X = (DBH(I)*DBH(I)*PROB(I))
          SPMORT2(ISP(I)) = SPMORT2(ISP(I))+(DMORT*CLMRTMLT2(ISP(I))*X)
          SPWTS(ISP(I))   = SPWTS(ISP(I))+X
          DMORT = 1.-DMORT !CONVERT TO A SURVIVAL RATE
          IF (DMORT.GT. 1E-5) THEN  ! VERY LOW SURVIVAL WILL BE 0
            DMORT=EXP(LOG(DMORT)/10.)**FINT
            IF (DMORT.LT.0.) THEN
              DMORT=0.
            ELSE IF (DMORT.GT.1.0) THEN
              DMORT=1.0
            ENDIF
          ELSE
            DMORT=0.
          ENDIF
          ! CONVERT BACK TO A MORTALITY RATE AND APPLY SPECIES MULT.           
          DMORT = (1.-DMORT)*CLMRTMLT2(ISP(I))
        ENDIF
C ----- END: UNREACHABLE CODE
        
        ! X IS THE FVS PERIODIC MORTALITY RATE (FINT-YEARS)...              
        ! SCALED BY PLOT SIZE FOR PER ACRE MORTALITY
        IF (PROB(I)-WK2(I) .LE. 1E-10) THEN
          X=1.
        ELSE IF (PROB(I).LT. 1E-10) THEN
          X=1.                 
        ELSE
          X = WK2(I)/PROB(I)
        ENDIF
        IF (DEBUG) WRITE (JOSTND,15) I,JSP(ISP(I))(1:2),BASEYR,X,
     >             FYRMORT(ISP(I)),DMORT,LDMORT,WK2(I),PROB(I)
   15   FORMAT ('IN CLMORTS, I=',I4,' SP=',A3,' BASEYR=',F6.0,
     >        ' FVSmort=',F10.4,' FYRMORT=',F10.4,' DMORT=',F10.4,
     >        ' LDMORT=',L2,' WK2=',F10.5,' PROB=',F10.5)    
        IF (LDMORT.AND.DEBUG) WRITE (JOSTND,16) CBIRTH,CTHISYR,DTV
   16   FORMAT ('IN CLMORTS, CBIRTH =',6F13.5/
     >          'IN CLMORTS, CTHISYR=',6F13.5/
     >          'IN CLMORTS, DTV    =',6F13.5)
        ! USE THE MAX OF THE TWO RATES.
        IF (FYRMORT(ISP(I)).GT.DMORT) DMORT=FYRMORT(ISP(I))
        IF (DMORT.GT.X) WK2(I)=PROB(I)*DMORT
      ENDDO
      
C     COMPUTE THE WEIGHTED AVERAGE MORTALITY RATE FOR CAUSE 2 
           
      DO I=1,MAXSP
        IF (SPWTS(I).GT. 0.0001) THEN
          SPMORT2(I) = SPMORT2(I)/SPWTS(I)
        ELSE
          SPMORT2(I) = 0.
        ENDIF
      ENDDO
      
      RETURN
      END
