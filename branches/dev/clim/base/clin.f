      SUBROUTINE CLIN (DEBUG,LKECHO)
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C     CLIMATE EXTENSION
C
COMMONS
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'CLIMATE.F77'
C
COMMONS
C
      INTEGER    KWCNT
      PARAMETER (KWCNT = 8)

      CHARACTER*8  TABLE(KWCNT), KEYWRD, PASKEY
      CHARACTER*10 KARD(7)
      CHARACTER*2048 CHTMP,FMT
      CHARACTER*40 CSTDID
      CHARACTER*30 CCLIM,CYR
      LOGICAL      LNOTBK(7),LKECHO,DEBUG
      REAL         ARRAY(7),TMPATTRS(MXCLATTRS),PRMS(8)
      INTEGER      KODE,IPRMPT,NUMBER,I,I1,I2,IYRTMP,IUTMP,IRTNCD,
     >             IDT,IPAS

      DATA TABLE /
     >     'END','CLIMDATA','MORTMULT','AUTOESTB','GROWMULT',
     >     'MXDENMLT','CLIMREPT','SETATTR'/

C
C     **********          EXECUTION BEGINS          **********
C

C     SIGNAL THAT THE CLIMATE MODEL IS NOW ACTIVE.

   10 CONTINUE                                                                        
C
C
      CALL KEYRDR (IREAD,JOSTND,DEBUG,KEYWRD,LNOTBK,
     >             ARRAY,IRECNT,KODE,KARD,LFLAG,LKECHO)
C
C  RETURN KODES 0=NO ERROR,1=COLUMN 1 BLANK OR ANOTHER ERROR,2=EOF
C               LESS THAN ZERO...USE OF PARMS STATEMENT IS PRESENT.
C

      IF (KODE.LT.0) THEN
         IPRMPT=-KODE
      ELSE
         IPRMPT=0
      ENDIF
      IF (KODE .LE. 0) GO TO 30
      IF (KODE .EQ. 2) CALL ERRGRO(.FALSE.,2)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

      CALL ERRGRO (.TRUE.,6)
      GOTO 10
   30 CONTINUE
      CALL FNDKEY (NUMBER,KEYWRD,TABLE,KWCNT,KODE,.FALSE.,JOSTND)
C
C     RETURN KODES 0=NO ERROR,1=KEYWORD NOT FOUND,2=MISSPELLING.
C
      IF (KODE .EQ. 0) GOTO 90
      IF (KODE .EQ. 1) THEN
         CALL ERRGRO (.TRUE.,1)
         GOTO 10
      ENDIF
      GOTO 90
C
C     SPECIAL END-OF-FILE TARGET
C
   80 CONTINUE
      CALL ERRGRO(.FALSE.,2)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

   90 CONTINUE
C
C     PROCESS OPTIONS
C
      GO TO( 100, 200, 300, 400, 500, 600, 700, 800), NUMBER

  100 CONTINUE
C                        OPTION NUMBER 1 -- END

      LCLIMATE= NATTRS .GT. 0 .AND. NYEARS.GT. 0

      IF(LKECHO .AND. LCLIMATE) WRITE(JOSTND,105) KEYWRD
  105 FORMAT (/A8,'   CLIMATE EXTENSION ACTIVE, END OF OPTIONS.')
      IF(LKECHO .AND. .NOT. LCLIMATE) WRITE(JOSTND,106) KEYWRD
  106 FORMAT (/A8,'   CLIMATE EXTENSION MISSING REQUIRED DATA '
     >        'AND IS NOT ACTIVE. END OF OPTIONS.')
      RETURN

  200 CONTINUE
C                        OPTION NUMBER 2 -- CLIMDATA
      NATTRS=0
      NYEARS=0
      INDXSPECIES=0
      READ (IREAD,'(A)',END=80) CLIMATE_NAME
      IRECNT = IRECNT+1
      CLIMATE_NAME=ADJUSTL(CLIMATE_NAME)
      READ (IREAD,'(A)',END=80) CHTMP  !GET THE FILE NAME
      IRECNT = IRECNT+1
      CHTMP=ADJUSTL(CHTMP)
      IF(LKECHO)WRITE (JOSTND,210) KEYWRD,TRIM(CLIMATE_NAME),
     >       TRIM(NPLT),TRIM(CHTMP)
  210 FORMAT (/A8,T12,'READING ATTRS SCORES FOR CLIMATE=',A,
     >        ' AT STAND=',A,' FROM FILE=',A)
      IF (CHTMP.EQ."*") THEN 
        IUTMP=IREAD
      ELSE
        OPEN (NEWUNIT=IUTMP,FILE=TRIM(CHTMP),STATUS='OLD',ERR=298)
      ENDIF
      I2=0
      READ (IUTMP,'(A)',END=296) CHTMP
      I2=I2+1
      IF (CHTMP.EQ."*") GOTO 296
      READ (CHTMP,*,END=211) CSTDID,CCLIM,CYR,ATTR_LABELS  ! toss the first three
  211 CONTINUE
      CHTMP(1:5) = CSTDID(1:5)
      DO I=1,5
        CALL UPCASE(CHTMP(I:I))
      ENDDO
      IF (CHTMP(1:5) .NE. "STAND") WRITE (JOSTND,212) TRIM(CSTDID)
  212 FORMAT (T12,'ATTRS FILE CREATION TAG=',A)
      DO I=1,MXCLATTRS
        IF (ICHAR(ATTR_LABELS(I)(1:1)).EQ. 0 .OR.
     >      ATTR_LABELS(I)(1:1).EQ.' ') EXIT
        NATTRS=NATTRS+1
      ENDDO
  215 CONTINUE
      READ (IUTMP,'(A)',END=290) CHTMP
      I2=I2+1
      IF (CHTMP.EQ."*") GOTO 290
      READ (CHTMP,*) CSTDID,CCLIM
      IF (TRIM(CSTDID).NE.TRIM(NPLT)) GOTO 215
      IF (TRIM(CCLIM) .NE.TRIM(CLIMATE_NAME)) GOTO 215
      READ (CHTMP,*) CSTDID,CCLIM,IYRTMP,(TMPATTRS(I),I=1,NATTRS)
      IF (NYEARS.EQ.0) THEN
        NYEARS=1
        YEARS(1)=IYRTMP
        I1=1
      ELSE
        I1=0
        DO I=1,NYEARS
          IF (YEARS(I).NE.IYRTMP) CYCLE
          I1=I
          EXIT
        ENDDO
        IF (I1.EQ.0) THEN
          IF (NYEARS.EQ.MXCLYEARS) THEN
            WRITE (JOSTND,'(T12,"TOO MANY YEARS IN CLIMATE DATA.")')
            NATTRS=0
            NYEARS=0
            INDXSPECIES=0
            IF (IUTMP.EQ.IREAD) THEN
              IRECNT = IRECNT+I2
            ELSE
              CLOSE (UNIT=IUTMP)
            ENDIF
            CALL RCDSET (2,.TRUE.)
            GOTO 10
          ENDIF
          NYEARS=NYEARS+1
          I1=NYEARS
          YEARS(NYEARS)=IYRTMP
        ENDIF
      ENDIF
      ATTRS(I1,1:NATTRS)=TMPATTRS(1:NATTRS)
      GOTO 215          
  290 CONTINUE
      IF(LKECHO)WRITE (JOSTND,291) I2,NATTRS,NYEARS
  291 FORMAT (T12,'RECORDS READ=',I4,'; NUMBER OF ATTRIBUTES=',
     >  I4,'; NUMBER OF YEARS=',I4)
      IF (NYEARS*NATTRS.EQ.0) THEN
        WRITE (JOSTND,'(T12,"NO CLIMATE DATA FOR THIS STAND.")')
        NATTRS=0
        NYEARS=0
        INDXSPECIES=0
        IF (IUTMP.EQ.IREAD) THEN
          IRECNT = IRECNT+I2
        ELSE
          CLOSE (UNIT=IUTMP)
        ENDIF
        CALL RCDSET (2,.TRUE.)
        GOTO 10
      ENDIF
      IF (IUTMP.EQ.IREAD) THEN
        IRECNT = IRECNT+I2
      ELSE
        CLOSE (UNIT=IUTMP)
      ENDIF
      DO I1=1,NATTRS
        IF ('dd5'  .EQ.TRIM(ATTR_LABELS(I1))) IXDD5  =I1
        IF ('mat'  .EQ.TRIM(ATTR_LABELS(I1))) IXMAT  =I1
        IF ('map'  .EQ.TRIM(ATTR_LABELS(I1))) IXMAP  =I1
        IF ('mtcm' .EQ.TRIM(ATTR_LABELS(I1))) IXMTCM =I1
        IF ('mtwm' .EQ.TRIM(ATTR_LABELS(I1))) IXMTWM =I1
        IF ('gsp'  .EQ.TRIM(ATTR_LABELS(I1))) IXGSP  =I1
        IF ('d100' .EQ.TRIM(ATTR_LABELS(I1))) IXD100 =I1
        IF ('mmin' .EQ.TRIM(ATTR_LABELS(I1))) IXMMIN =I1
        IF ('dd0'  .EQ.TRIM(ATTR_LABELS(I1))) IXDD0  =I1
        IF ('gsdd5'.EQ.TRIM(ATTR_LABELS(I1))) IXGSDD5=I1
        IF ('pSite'.EQ.TRIM(ATTR_LABELS(I1))) IXPSITE=I1
        IF ('DEmtwm'  .EQ.TRIM(ATTR_LABELS(I1))) IDEmtwm  =I1
        IF ('DEmtcm'  .EQ.TRIM(ATTR_LABELS(I1))) IDEmtcm  =I1
        IF ('DEdd5'   .EQ.TRIM(ATTR_LABELS(I1))) IDEdd5   =I1
        IF ('DEsdi'   .EQ.TRIM(ATTR_LABELS(I1))) IDEsdi   =I1
        IF ('DEdd0'   .EQ.TRIM(ATTR_LABELS(I1))) IDEdd0   =I1
        IF ('DEpdd5'  .EQ.TRIM(ATTR_LABELS(I1))) IDEmapdd5=I1
        IF (      IXMTCM.GT.0 .AND. IXMAT  .GT.0
     >      .AND. IXGSP .GT.0 .AND. IXD100 .GT.0
     >      .AND. IXMMIN.GT.0 .AND. IXDD0  .GT.0
     >      .AND. IXDD5 .GT.0 .AND. IXPSITE.GT.0
     >      .AND. IXGSDD5.GT.0
     >      .AND. IDEmtwm   .GT. 0
     >      .AND. IDEmtcm   .GT. 0
     >      .AND. IDEdd5    .GT. 0
     >      .AND. IDEsdi    .GT. 0
     >      .AND. IDEdd0    .GT. 0
     >      .AND. IDEmapdd5 .GT. 0) EXIT
      ENDDO

      DO I=1,MAXSP
        DO I1=1,NATTRS
          IF (TRIM(PLNJSP(I)).EQ.TRIM(ATTR_LABELS(I1))) THEN
            INDXSPECIES(I)=I1
            EXIT
          ENDIF
        ENDDO
      ENDDO

      IF(LKECHO) THEN
        I2=1
        DO I=1,NATTRS
          CHTMP(I2:)=''
          IF (IXMTCM.EQ.I .OR. IXDD5.EQ.I   .OR. IXMAT  .EQ.I .OR.
     >       IXPSITE.EQ.I .OR. IXGSP.EQ.I   .OR. IXD100 .EQ.I .OR.
     >       IXGSDD5.EQ.I .OR. IXMMIN.EQ.I  .OR. IXDD0  .EQ.I .OR.
     >       IXMTWM .EQ.I .OR. IXMAP .EQ.I  .OR.
     >       IDEmtwm.EQ.I .OR. IDEmtcm.EQ.I .OR. IDEdd5.EQ.I  .OR.
     >       IDEdd0 .EQ.I .OR. IDEmapdd5.EQ.I.OR.IDEsdi.EQ.I )
     >        CHTMP(I2:) = ' *USED*'
          DO I1=1,MAXSP
            IF (TRIM(PLNJSP(I1)).EQ.TRIM(ATTR_LABELS(I))) THEN
              WRITE (CHTMP(I2:),'(I3,"=",A)') I1,JSP(I1)
              EXIT
            ENDIF
          ENDDO
          I2=I2+8
        ENDDO
        I2=0
        DO I=1,NATTRS,14  ! write them 14 at a time
          I2=I2+14
          IF (I2.GT.NATTRS) I2=NATTRS
          WRITE (JOSTND,292) TRIM(CHTMP(((I-1)*8)+1:(I2*8)))
  292     FORMAT (/T12,'CODES: ',A)
          WRITE (JOSTND,293) ADJUSTR(ATTR_LABELS(I:I2))
  293     FORMAT ( T12,'YEAR ',14A8)
          FMT = ' T12,I4,1X'
          DO I1=I,I2
            FMT(1:1)=ATTR_LABELS(I1)(1:1)
            CALL UPCASE(FMT(1:1))
             IF (ATTR_LABELS(I1)(1:1).EQ.FMT(1:1)) THEN
               IF (ATTR_LABELS(I1)(1:2).EQ.'DE') THEN
                 FMT=TRIM(FMT)//',F8.2'
               ELSE
                 FMT=TRIM(FMT)//',F8.3'
               ENDIF
             ELSE
               FMT=TRIM(FMT)//',F8.1'
             ENDIF
          ENDDO
          FMT(1:1)='('
          FMT = TRIM(FMT)//')'
          DO I1=1,NYEARS
            WRITE (JOSTND,FMT) YEARS(I1),ATTRS(I1,I:I2)
          ENDDO
        ENDDO
        I2=0
        DO I=1,MAXSP
          IF (INDXSPECIES(I).EQ.0) I2=I2+1
        ENDDO
        IF (I2.GT.0) THEN
          WRITE (JOSTND,'(/T12,''SPECIES WITHOUT ATTRIBUTES:'')')
          DO I=1,MAXSP
            IF (INDXSPECIES(I).EQ.0) WRITE (JOSTND,294)
     >             I,JSP(I),PLNJSP(I)
  294       FORMAT (T12,'FVS INDEX=',I3,', ALPHA CODE=',A3,
     >              ', PLANT CODE=',A)
          ENDDO
        ENDIF
      ENDIF

C     TURN ON CLIMATE ESTAB AND TURN OFF BASE ESTAB.      

      LAESTB=.TRUE.
      CALL ESNOAU ('********',LKECHO)
            
      GOTO 10
  296 CONTINUE
      WRITE (JOSTND,297)
  297 FORMAT (/,'********',T12,
     >          'ERROR: FILE READ ERROR, DATA NOT STORED.')
      NATTRS=0
      NYEARS=0
      INDXSPECIES=0
      IF (IUTMP.NE.IREAD) CLOSE (UNIT=IUTMP)
      CALL RCDSET (2,.TRUE.)
      GOTO 10
  298 CONTINUE
      WRITE (JOSTND,299)
  299 FORMAT (T12,'FILE OPEN ERROR, FILE NOT READ.')
      CALL RCDSET (2,.TRUE.)
      GOTO 10
  300 CONTINUE
C                        OPTION NUMBER 3 -- MORTMULT
C     ACTIVITY CODE 2801
      IDT=1
      IF (LNOTBK(1)) IDT=IFIX(ARRAY(1))
C
C     IF THE KEYWORD RECORD HAS THE 'PARMS' OPTION, CALL OPNEWC
C     TO PROCESS IT.
C
      IF (IPRMPT.GT.0) THEN
        IF (IPRMPT.NE.2) THEN
          CALL KEYDMP (JOSTND,IRECNT,KEYWRD,ARRAY,KARD)
          CALL ERRGRO (.TRUE.,25)
        ELSE
          CALL OPNEWC (KODE,JOSTND,IREAD,IDT,2801,KEYWRD,KARD,
     >                 IPRMPT,IRECNT,ICYC)
          CALL fvsGetRtnCode(IRTNCD)
          IF (IRTNCD.NE.0) RETURN
        ENDIF
      ELSE      
        CALL SPDECD (2,I,NSP(1,1),JOSTND,IRECNT,KEYWRD,
     >               ARRAY,KARD)
        IF (.NOT.LNOTBK(1)) THEN  ! YEAR/CYCLE NOT SPECIFIED
          IF (I.GT.0 .AND. I.LE.MAXSP) THEN
            IF (LNOTBK(3)) CLMRTMLT1(I)=ARRAY(3)
            IF (LNOTBK(4)) CLMRTMLT2(I)=ARRAY(4)
            IF(LKECHO)WRITE(JOSTND,310) KEYWRD,I,JSP(I),CLMRTMLT1(I),
     >            CLMRTMLT2(I)
  310       FORMAT (/A8,'   CLIMATE-CAUSED MORTALITY MULTIPLIERS',
     >           ' FOR SPECIES ',I3,'=',A,' ARE ',2F12.4)
          ELSE IF (I.EQ.0) THEN
            IF (LNOTBK(3)) CLMRTMLT1 = ARRAY(3)
            IF (LNOTBK(4)) CLMRTMLT2 = ARRAY(4)
            IF(LKECHO)WRITE(JOSTND,315) KEYWRD,CLMRTMLT1(1),
     >            CLMRTMLT2(1)
  315       FORMAT (/A8,'   CLIMATE-CAUSED MORTALITY MULTIPLIERS',
     >           ' FOR ALL SPECIES ARE',2F12.4)
          ENDIF
        ELSE
          IF (I.GT.0 .AND. I.LE.MAXSP) THEN
            PRMS(1) = I
          ELSE 
            PRMS(1) = 0
          ENDIF
          PRMS(2) = ARRAY(3)
          PRMS(3) = ARRAY(4)
          CALL OPNEW (KODE,IDT,2801,3,PRMS)
          IF (KODE .GT. 0) GOTO 10
          IF(LKECHO)WRITE(JOSTND,325) KEYWRD,IDT,IFIX(PRMS(1)),
     >    KARD(2)(1:3),PRMS(2),PRMS(3)
  325     FORMAT (/A8,'   DATE/CYCLE=',I5,' CLIMATE-CAUSED MORTALITY ',
     >         ' MULTIPLIERS FOR SPECIES ',I4,'=',A,'    ARE ',2F12.4)
        ENDIF
      ENDIF
      GOTO 10
  400 CONTINUE
C                        OPTION NUMBER 4 -- AUTOESTB
C     ACTIVITY CODE 2802
      IDT=1
      IF (LNOTBK(1)) IDT=IFIX(ARRAY(1))
      IF (.NOT.LNOTBK(1)) THEN
        IF (LNOTBK(2)) AESTOCK=ARRAY(2)
        IF (LNOTBK(3)) AESNTREES=ARRAY(3)
        IF (LNOTBK(4)) NESPECIES=IFIX(ARRAY(4))
        IF (NESPECIES.GT.MAXSP) NESPECIES=MAXSP
        LAESTB=.TRUE.
        IF(LKECHO)WRITE(JOSTND,410) KEYWRD,AESTOCK,AESNTREES,NESPECIES
  410   FORMAT (/A8,'   TURN ON AUTOMATIC',
     >    ' ESTABLISHMENT IN THE CLIMATE MODEL. STOCKING THRESHOLD= ',
     >    F6.2,' PERCENT; BASE NUMBER OF TREES/ACRE TO ADD ',F6.2/T12,
     >    'MAXIMUM NUMBER OF SPECIES TO ADD =',I3)
      ELSE
        IF (IPRMPT.GT.0) THEN
          IF (IPRMPT.NE.2) THEN
            CALL KEYDMP (JOSTND,IRECNT,KEYWRD,ARRAY,KARD)
            CALL ERRGRO (.TRUE.,25)
          ELSE
            CALL OPNEWC (KODE,JOSTND,IREAD,IDT,2802,KEYWRD,KARD,
     >                   IPRMPT,IRECNT,ICYC)
            CALL fvsGetRtnCode(IRTNCD)
            IF (IRTNCD.NE.0) RETURN
          ENDIF
        ELSE
          PRMS(1) = AESTOCK
          PRMS(2) = AESNTREES
          PRMS(3) = NESPECIES
          IF (LNOTBK(2)) PRMS(1)=ARRAY(2)
          IF (LNOTBK(3)) PRMS(2)=ARRAY(3)
          IF (LNOTBK(4)) PRMS(3)=IFIX(ARRAY(4))
          CALL OPNEW (KODE,IDT,2802,3,PRMS)
          IF (KODE .GT. 0) GOTO 10
          IF(LKECHO)WRITE(JOSTND,425) KEYWRD,IDT,PRMS(1),PRMS(2),
     >              IFIX(PRMS(3))
  425       FORMAT (/A8,'   DATE/CYCLE=',I5,' TURN ON AUTOMATIC',
     >      ' ESTABLISHMENT IN THE CLIMATE MODEL. STOCKING THRESHOLD= ',
     >      F6.2,' PERCENT'/T12,'BASE NUMBER OF TREES/ACRE TO ADD ',F6.2
     >      'MAXIMUM NUMBER OF SPECIES TO ADD =',I3)
        ENDIF
      ENDIF
      CALL ESNOAU (KEYWRD,LKECHO)
      GOTO 10
  500 CONTINUE
C                        OPTION NUMBER 5 -- GROWMULT
C     ACTIVITY CODE 2803
      IDT=1
      IF (LNOTBK(1)) IDT=IFIX(ARRAY(1))
C
C     IF THE KEYWORD RECORD HAS THE 'PARMS' OPTION, CALL OPNEWC
C     TO PROCESS IT.
C
      IF (IPRMPT.GT.0) THEN
        IF (IPRMPT.NE.2) THEN
          CALL KEYDMP (JOSTND,IRECNT,KEYWRD,ARRAY,KARD)
          CALL ERRGRO (.TRUE.,25)
        ELSE
          CALL OPNEWC (KODE,JOSTND,IREAD,IDT,2803,KEYWRD,KARD,
     >                 IPRMPT,IRECNT,ICYC)
          CALL fvsGetRtnCode(IRTNCD)
          IF (IRTNCD.NE.0) RETURN
        ENDIF
      ELSE      
        CALL SPDECD (2,I,NSP(1,1),JOSTND,IRECNT,KEYWRD,
     >               ARRAY,KARD)
        IF (.NOT.LNOTBK(1)) THEN
          IF (I.GT.0 .AND. I.LE.MAXSP) THEN
            IF (LNOTBK(3)) CLGROWMULT(I)=ARRAY(3)
            IF(LKECHO)WRITE(JOSTND,510) KEYWRD,I,JSP(I),CLGROWMULT(I)
  510       FORMAT (/A8,'   CLIMATE-CAUSED GROWTH MULTIPLIER',
     >           ' FOR SPECIES ',I3,'=',A,' IS ',F12.4)
          ELSE IF (I.EQ.0) THEN
            IF (LNOTBK(3)) CLGROWMULT = ARRAY(3)
            IF(LKECHO)WRITE(JOSTND,515) KEYWRD,CLGROWMULT(1)
  515       FORMAT (/A8,'   CLIMATE-CAUSED GROWTH MULTIPLIER',
     >           ' FOR ALL SPECIES IS',F12.4)
          ENDIF
        ELSE
          IF (I.GT.0 .AND. I.LE.MAXSP) THEN
            PRMS(1) = I
          ELSE 
            PRMS(1) = 0
          ENDIF
          PRMS(2) = ARRAY(3)
          CALL OPNEW (KODE,IDT,2803,2,PRMS)
          IF (KODE .GT. 0) GOTO 10
          IF(LKECHO)WRITE(JOSTND,525) KEYWRD,IDT,IFIX(PRMS(1)),
     >    KARD(2)(1:3),PRMS(2)
  525     FORMAT (/A8,'   DATE/CYCLE=',I5,' CLIMATE-CAUSED GROWTH ',
     >         ' MULTIPLIER FOR SPECIES ',I4,'=',A,'    IS ',F10.4)
        ENDIF
      ENDIF
      GOTO 10
  600 CONTINUE
C                        OPTION NUMBER 6 -- MXDENMLT
C     ACTIVITY CODE 2804
      IDT=1
      IF (LNOTBK(1)) IDT=IFIX(ARRAY(1))
C
C     IF THE KEYWORD RECORD HAS THE 'PARMS' OPTION, CALL OPNEWC
C     TO PROCESS IT.
C
      IF (IPRMPT.GT.0) THEN
        IF (IPRMPT.NE.2) THEN
          CALL KEYDMP (JOSTND,IRECNT,KEYWRD,ARRAY,KARD)
          CALL ERRGRO (.TRUE.,25)
        ELSE
          CALL OPNEWC (KODE,JOSTND,IREAD,IDT,2804,KEYWRD,KARD,
     >                 IPRMPT,IRECNT,ICYC)
          CALL fvsGetRtnCode(IRTNCD)
          IF (IRTNCD.NE.0) RETURN
        ENDIF
      ELSE
        IF (.NOT.LNOTBK(1)) THEN
          IF (LNOTBK(2)) CLMXDENMULT = ARRAY(2)
          IF (LKECHO) WRITE(JOSTND,610) KEYWRD,CLMXDENMULT
  610     FORMAT (/A8,'   CLIMATE-CAUSED MAXIMUM DENSITY ADJUSTMENT',
     >            ' MULTIPLIER IS ',F10.4)
        ELSE
          PRMS(1)=CLMXDENMULT
          IF(LNOTBK(2)) PRMS(1)=ARRAY(2)
          CALL OPNEW (KODE,IDT,2804,1,PRMS)
          IF (KODE .GT. 0) GOTO 10
          IF(LKECHO)WRITE(JOSTND,620) KEYWRD,IDT,PRMS(1)
  620     FORMAT (/A8,'   DATE/CYCLE=',I5,
     >             ' CLIMATE-CAUSED MAXIMUM DENSITY ADJUSTMENT',
     >             ' MULTIPLIER IS ',F10.4)
        ENDIF
      ENDIF 
      GOTO 10
  700 CONTINUE
C                        OPTION NUMBER 6 -- CLIMREPT
      JCLREF = 0
      IF (LKECHO) WRITE(JOSTND,710) KEYWRD
  710   FORMAT (/A8,'   GENERATE FVS-CLIMATE REPORT.')
      GOTO 10
C                        OPTION NUMBER 7 -- SETATTR
  800 CONTINUE
      IF (NATTRS .LE. 0) THEN
        CALL ERRGRO (.TRUE.,30)
        WRITE (JOSTND,810) 
  810   FORMAT (T12,'SETATTR KEYWORD MUST FOLLOW CLIMDATA KEYWORD.')
        GOTO 10
      ENDIF
      KARD(1) = ADJUSTL(KARD(1))
      IF (KARD(1) .EQ. " ") GOTO 825
      DO I=1,NATTRS
        IF (TRIM(KARD(1)).EQ.TRIM(ATTR_LABELS(I))) THEN
          IF (LKECHO) WRITE(JOSTND,820) KEYWRD,TRIM(KARD(1)),
     >       ATTRS(1:4,I),ARRAY(2:5)
  820     FORMAT (/A8,'   ATTRIBUTE "',A,'" VALUES CHANGED FROM: ',
     >            4F10.4,' TO: ',4F10.4)
          ATTRS(1:4,I) = ARRAY(2:5)
          GOTO 10
        ENDIF
      ENDDO  
  825 CONTINUE
      CALL ERRGRO (.TRUE.,4)
      WRITE (JOSTND,830) 
  830 FORMAT (T12,'SETATTR ATTRIBUTE STRING WAS NOT MATCHED.')
      GOTO 10
      RETURN
      
      ENTRY CLKEY(IPAS,PASKEY)
      PASKEY = TABLE(IPAS)
      RETURN
      END

