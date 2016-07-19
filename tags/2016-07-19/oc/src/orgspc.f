      SUBROUTINE ORGSPC(INSPEC,OUTSPC)
      IMPLICIT NONE
C----------
C  **ORGSPC--OC   DATE OF LAST REVISION:  06/16/15
C----------
C THIS SUBROUTINE CONVERTS AN FVS SPECIES SEQUENCE NUMBER TO A VALID
C ORGANON SPECIES FIA CODE.
C
C CALLED FROM SUBROUTINES **CRATET** AND **DGDRIV**
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
COMMONS
C----------
      INTEGER OSPMAP(MAXSP),INSPEC,OUTSPC
C
C   SPECIES ORDER IN THIS VARIANT
C
C  1=PC  2=IC  3=RC  4=GF  5=RF  6=SH  7=DF  8=WH  9=MH 10=WB
C 11=KP 12=LP 13=CP 14=LM 15=JP 16=SP 17=WP 18=PP 19=MP 20=GP
C 21=JU 22=BR 23=GS 24=PY 25=OS 26=LO 27=CY 28=BL 29=EO 30=WO
C 31=BO 32=VO 33=IO 34=BM 35=BU 36=RA 37=MA 38=GC 39=DG 40=FL
C 41=WN 42=TO 43=SY 44=AS 45=CW 46=WI 47=CN 48=CL 49=OH
C----------
C MAPPING OF FVS SPECIES TO VALID ORGANON SPECIES FOR THE 
C ORGANON SOUTHWEST OREGON MODEL TYPE:
C
C VALID
C ORGANON   FVS
C 015=WF*   WF IS MAPPED TO GF IN THIS VARIANT
C 081=IC*   IC
C 242=RC    RC, PC
C 017=GF*   GF, BR
C 202=DF*   DF, RF, SH
C 263=WH    WH, MH
C 117=SP*   SP
C 122=PP*   PP, WB, KP, LP, CP, LM, JP, WP, MP, GP, GS
C 231=PY    PY, WJ, OS
C 805=CY    CY, LO, BL, EO, VO, IO
C 815=WO    WO
C 818=BO    BO
C 312=BM    BM, BU, FL, WN, SY, AS, CW
C 351=RA    RA
C 361=MA    MA
C 431=GC    GC
C 492=DG    DG, CN, CL, OH
C 631=TO    TO
C 920=WI    WI
C *SPECIES INCLUDED IN ORGANON "BIG 6"
C----------
      DATA OSPMAP/
C       PC   IC   RC   GF   RF   SH   DF   WH   MH   WB      
     & 242, 081, 242, 017, 202, 202, 202, 263, 263, 122, 
C       KP   LP   CP   LM   JP   SP   WP   PP   MP   GP      
     & 122, 122, 122, 122, 122, 117, 122, 122, 122, 122, 
C       WJ   BR   GS   PY   OS   LO   CY   BL   EO   WO      
     & 231, 017, 122, 231, 231, 805, 805, 805, 805, 815, 
C       BO   VO   IO   BM   BU   RA   MA   GC   DG   FL      
     & 818, 805, 805, 312, 312, 351, 361, 431, 492, 312, 
C       WN   TO   SY   AS   CW   WI   CN   CL   OH        
     & 312, 631, 312, 312, 312, 920, 492, 492, 492/ 
C
      OUTSPC = OSPMAP(INSPEC)
C
      RETURN
      END
