      SUBROUTINE DBSCALIB(ICFROM,CORTEM,NUMCAL,STDRAT)
     
      IMPLICIT NONE
C
C DBSQLITE $Id$
C
C     PURPOSE: TO POPULATE A DATABASE WITH THE CALIBRATION STATS
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'COEFFS.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'CALCOM.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'DBSCOM.F77'

C     ARGUMENT LIST

      REAL STDRAT(MAXSP),CORTEM(MAXSP)
      INTEGER NUMCAL(MAXSP)
      
      integer fsql3_tableexists,fsql3_exec,fsql3_bind_int,
     >        fsql3_prepare,fsql3_bind_double,fsql3_finalize,
     >        fsql3_step,fsql3_reset,fsql3_bind_text

      INTEGER ColNumber,K,KK,ISPEC,iRet,ICFROM
      CHARACTER*2000 SQLStmtStr
      CHARACTER*2    SPEC,TSZ
      CHARACTER*8    CSP1,CSP2,CSP3

      REAL*8 DCORTEM, DSTDRAT, DWCI , RCORMULT

C     INITIALIZE VARIABLES

      IF(ICALIB.EQ.0) RETURN

C     CALL DBSCASE TO MAKE SURE WE HAVE AN UP TO DATE CASEID

      CALL DBSCASE(1)
      
      iRet = fsql3_tableexists(IoutDBref,
     >       "FVS_CalibStats"//CHAR(0))
      IF(iRet.EQ.0) THEN
          SQLStmtStr='CREATE TABLE FVS_CalibStats ('//
     -      'CaseID text not null,'//
     -      'StandID text not null,'//
     -      'TreeSize text not null,'//
     -      'SpeciesFVS    text not null,'//
     -      'SpeciesPLANTS text not null,'//
     -      'SpeciesFIA    text not null,'//
     -      'NumTrees int null,'//
     -      'ScaleFactor real null,'//
     -      'StdErrRatio real null,'//
     -      'WeightToInput real null,'//
     -      'ReadCorMult real null);'//CHAR(0)
         iRet = fsql3_exec(IoutDBref,SQLStmtStr)
         IF (iRet .NE. 0) THEN
           ICALIB = 0
           RETURN
         ENDIF
      ENDIF
      IF(ICFROM.EQ.1) THEN
        TSZ = 'LG'
      ELSE
        TSZ = 'SM'
      ENDIF
      WRITE(SQLStmtStr,*) 'INSERT INTO FVS_CalibStats ',
     - ' (CaseID,StandID,TreeSize,',
     - 'SpeciesFVS,SpeciesPLANTS,SpeciesFIA,',
     - 'NumTrees,ScaleFactor,',
     - 'StdErrRatio,WeightToInput,ReadCorMult) ',
     - " VALUES ('",CASEID,"','",TRIM(NPLT),"','",TSZ,
     - "',?,?,?,?,?,?,?,?);"
      iRet = fsql3_exec(IoutDBref,"Begin;"//CHAR(0))
      iRet = fsql3_prepare(IoutDBref, TRIM(SQLStmtStr)//CHAR(0))
      IF (iRet .NE. 0) THEN
         ICALIB = 0
         RETURN
      ENDIF

      DO K = 1,MAXSP
        IF(CORTEM(K).NE.1.0 .OR. NUMCAL(K).GE.FNMIN) THEN         
          SPEC=NSP(MAXSP,1)(1:2)
          ISPEC=MAXSP
          DO KK=1,MAXSP
            IF(K .NE. IREF(KK)) CYCLE
            ISPEC=KK
            SPEC=NSP(KK,1)(1:2)

C           ASSIGN FVS, PLANTS AND FIA SPECIES CODES
C
            CSP1 = JSP(KK)
            CSP2 = PLNJSP(KK)
            CSP3 = FIAJSP(KK)
            EXIT 
          ENDDO

C         BIND SQL STATEMENT PARAMETERS TO FORTRAN VARIABLES
          
          ColNumber=1                 ! SpeciesFVS
          iRet = fsql3_bind_text(IoutDBref,ColNumber,CSP1,
     >                                    LEN_TRIM(CSP1))

          ColNumber=ColNumber+1       ! SpeciesPLANTS
          iRet = fsql3_bind_text(IoutDBref,ColNumber,CSP2,
     >                                    LEN_TRIM(CSP2))

          ColNumber=ColNumber+1       ! SpeciesFIA
          iRet = fsql3_bind_text(IoutDBref,ColNumber,CSP3,
     >                                    LEN_TRIM(CSP3))

          ColNumber=ColNumber+1       ! NumTrees
          iRet=fsql3_bind_int(IoutDBref,ColNumber,NUMCAL(K))
          
          DCORTEM = CORTEM(K)
          ColNumber=ColNumber+1       ! ScaleFactor
          iRet=fsql3_bind_double(IoutDBref,ColNumber,DCORTEM)

          IF(ICFROM.EQ.1) THEN 
            DSTDRAT = STDRAT(K)
            ColNumber=ColNumber+1       ! StdErrRatio
            iRet=fsql3_bind_double(IoutDBref,ColNumber,DSTDRAT)
          ENDIF
            
          IF(ICFROM.EQ.1) THEN
            DWCI = WCI(K)
            ColNumber=ColNumber+1      ! WeightToInput (LG TREES ONLY)
            iRet=fsql3_bind_double(IoutDBref,ColNumber,DWCI)
          ENDIF
            
          IF(ICFROM.EQ.1)THEN
            RCORMULT=EXP(LOG(DCORTEM)/DWCI)
            ColNumber=ColNumber+1       ! ScaleFactor
          ELSE
            RCORMULT=DCORTEM
            ColNumber=ColNumber+3       ! ScaleFactor
          ENDIF
          
          iRet=fsql3_bind_double(IoutDBref,ColNumber,RCORMULT)
          
          iRet = fsql3_step(IoutDBref)
          iRet = fsql3_reset(IoutDBref)
        ENDIF
      ENDDO

      iRet = fsql3_exec(IoutDBref,"Commit;"//CHAR(0))
      iRet = fsql3_finalize(IoutDBref)
      if (iRet.ne.0) then
         ICALIB = 0
         RETURN
      ENDIF

      RETURN
      END
