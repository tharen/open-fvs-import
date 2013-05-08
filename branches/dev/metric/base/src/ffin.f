      SUBROUTINE FFIN (JOSTND,IRECNT,KEYWRD,ARRAY,LNOTBK,KARD,LKECHO)
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
      INCLUDE  'METRIC.F77'
C
C     PART OF THE FERTILIZER OPTION.  CALLED BY INITRE TO ENTER
C     FERTILIZER KEYWORD.
C     KEYWRD=THE KEYWORD READ.
C     ARRAY =THE PARAMETER ARRAY ON THE KEYWORD RECORD.
C     LNOTBK=TRUE IF THE CORRESPONDING MEMBER OF ARRAY WAS ENTERED.
C     JOSTND=THE PRINTER DATA SET REFERENCE NUMBER.
C
      LOGICAL LNOTBK(7),LKECHO
      REAL ARRAY(7)
      INTEGER IRECNT,JOSTND,IDT,KODE,I
      CHARACTER*8 KEYWRD
      CHARACTER*10 KARD(7)
C
C     200 LBS = 91 KG (TO THE NECESSARY PRECISION)
C
      IF (.NOT.LNOTBK(2)) ARRAY(2)=91.0
      IF (ARRAY(2).NE.91.0) THEN
         IF(LKECHO)WRITE(JOSTND,5)
    5    FORMAT (T13,'ONLY TREATMENTS WITH 91 KG NITROGEN ',
     >          'CAN BE REPRESENTED.  PARAMETER CHANGED ACCORDINGLY.')
         ARRAY(2)=200.0
      ENDIF
      IDT=1
      IF (LNOTBK(1)) IDT=IFIX(ARRAY(1))
      IF (.NOT.LNOTBK(5)) ARRAY(5)=1.0
      CALL OPNEW (KODE,IDT,260,4,ARRAY(2))
      IF (KODE.GT.0) RETURN
      WRITE (JOSTND,10) KEYWRD,IDT,(ARRAY(I),I=2,5)
   10 FORMAT(/1X,A8,'   DATE/CYCLE=',I5,'; APPLY ',F6.0,' KG ',
     >       'NITROGEN, ',F6.0,' KG PHOSPHORUS, AND ',F6.0,
     >       ' KG POTASSIUM PER ACRE.'/
     >       T13,'THE EFFECT OF THIS APPLICATION IS MULTIPLIED BY ',
     >       F10.4)
      IF (ARRAY(3).GT.0. .OR. ARRAY(4).GT.0) WRITE (JOSTND,20)
   20 FORMAT (T13,'TREATMENTS WITH PHOSPHORUS AND POTASSIUM CAN NOT ',
     >            'BE REPRESENTED.  THESE VALUES WILL BE IGNORED.')
      IF (ARRAY(2).NE.200.0) WRITE (JOSTND,30)
   30 FORMAT (T13,'TREATMENTS WITH OTHER THAN 91 KG NITROGEN ',
     >            'CAN NOT BE REPRESENTED; 91 KG IS ASSUMED.')
      RETURN
      END
