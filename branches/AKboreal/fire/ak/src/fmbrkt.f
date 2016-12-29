      FUNCTION FMBRKT(DBH,ISP)
      IMPLICIT NONE
C----------
C  **FMBRKT  FIRE-AK-DATE OF LAST REVISION:  02/22/08
C----------

C     COMPUTES THE BARK THICKNESS FOR USE IN THE FIRE-CAUSED MORTALITY
C     ROUTINE (FMEFF). DATA ARE FROM FOFEM V5.0 (REINHARDT ET AL. 2000)

COMMONS

      INCLUDE 'PRGPRM.F77'

COMMONS

      INTEGER ISP
      REAL    DBH,FMBRKT
      REAL    B1(MAXSP)

      DATA B1/
     >     0.025,  ! 1 = white spruce
     >     0.035,  ! 2 = western redcedar
     >     0.047,  ! 3 = pacific silver fir
     >     0.040,  ! 4 = mountain hemlock
     >     0.040,  ! 5 = western hemlock
     >     0.022,  ! 6 = alaska-cedar
     >     0.028,  ! 7 = lodgepole pine
     >     0.027,  ! 8 = sitka spruce
     >     0.041,  ! 9 = subalpine fir
     >     0.026,  !10 = red alder
     >     0.044,  !11 = black cottonwood
     >     0.044,  !12 = other hardwoods
     >     0.047,  !13 = other softwoods
     >     0.047,  !14 = TAMARACK (TA)               
     >     0.047,  !15 = LUTZ’S SPRUCE (LS)(NEW CODE)
     >     0.047,  !16 = BLACK SPRUCE (BE)           
     >     0.047,  !17 = ALDER SPECIES (AD)          
     >     0.047,  !18 = RED ALDER (RA)              
     >     0.047,  !19 = PAPER BIRCH (PB)            
     >     0.047,  !20 = BALSAM POPLAR (BA)          
     >     0.047,  !21 = QUAKING ASPEN (AS)          
     >     0.047,  !22 = WILLOW SPECIES (WI)         
     >     0.047/  !23 = SCOULER’S WILLOW (SU)       

      FMBRKT = DBH*B1(ISP)

      RETURN
      END
