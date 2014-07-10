      SUBROUTINE ESETPR (METH,ZMECH,ZBURN,PNONE,PMECH,PBURN,IALN,
     &                   IDSDAT,KDT,IP)
      IMPLICIT NONE
C----------
C  **ESETPR DATE OF LAST REVISION:  07/25/08
C----------
C
C     SET SITE PREPARATION FOR THE REGENERATION MODEL.
C
      REAL PRMS(3)
      INTEGER IALN(3)
      INTEGER IP,KDT,IDSDAT,METH,I,KODE,NPRMS,IDT
      REAL PBURN,PMECH,PNONE,ZBURN,ZMECH
      METH=0
      ZMECH=0.0
      ZBURN=0.0
      PNONE=0.0
      PMECH=0.0
      PBURN=0.0
      DO 10 I=1,3
      IALN(I)=0
   10 CONTINUE
C
C     PROCESS BURNPREP
C
      I=0
   80 CONTINUE
      I=I+1
      CALL OPGET2(491,IDT,IDSDAT,KDT,I,3,NPRMS,PRMS,KODE)
      IF (KODE.GT.0) GOTO 90
      IP=0
      ZBURN=FLOAT(IDT)
      IF (NPRMS.GT.0) GOTO 85
      METH=3
      CALL OPDON2(491,IDT,IDSDAT,KDT,I,KODE)
      RETURN
   85 CONTINUE
      PBURN=PRMS(1)/100.
      IALN(3)=1
      GOTO 80
   90 CONTINUE
      I=I-1
      IF (I.EQ.0) GOTO 110
C
C     FLAG THE LAST BURNPREP ACCOMPLISHED.
C
      CALL OPDON2(491,IDT,IDSDAT,KDT,I,KODE)
  100 CONTINUE
C
C     FLAG THE REST OF THE BURNPREPS AS CANCELLED.
C
      I=I-1
      IF (I.LE.0) GOTO 110
      CALL OPDON2(491,-1,IDSDAT,KDT,I,KODE)
      GOTO 100
  110 CONTINUE
C
C     PROCESS MECHPREP
C
      I=0
  120 CONTINUE
      I=I+1
      CALL OPGET2(493,IDT,IDSDAT,KDT,I,3,NPRMS,PRMS,KODE)
      IF (KODE.GT.0) GOTO 130
      IP=0
      ZMECH=FLOAT(IDT)
      IF (NPRMS.GT.0) GOTO 125
      METH=2
      CALL OPDON2(493,IDT,IDSDAT,KDT,I,KODE)
      GOTO 130
  125 CONTINUE
      PMECH=PRMS(1)/100.
      IALN(2)=1
      GOTO 120
  130 CONTINUE
      I=I-1
      IF (I.EQ.0) GOTO 150
C
C     FLAG THE LAST MECHPREP ACCOMPLISHED.
C
      CALL OPDON2(493,IDT,IDSDAT,KDT,I,KODE)
  140 CONTINUE
C
C     FLAG THE REST OF THE MECHPREPS AS CANCELLED.
C
      I=I-1
      IF (I.LE.0) GOTO 150
      CALL OPDON2(493,-1,IDSDAT,KDT,I,KODE)
      GOTO 140
  150 CONTINUE
      RETURN
      END
