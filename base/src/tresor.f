      SUBROUTINE TRESOR
      IMPLICIT NONE
C----------
C  **TRESOR--BS   DATE OF LAST REVISION:  07/23/08
C----------
C   THIS SUBROUTINE IS CALLED TO SORT AND MATCH TREE IDS (IDTREE)
C   WITH THE INTERNAL TREE INDEX NUMBERS GENERATED BY PROGNOSIS.
C   THIS IS NECESSARY TO INSURE THAT DATA  NEEDED BY EXTENSIONS
C   TO THE PROGNOSIS MODEL IS MAPPED TO THE RIGHT TREE RECORDS.
C   THIS ROUTINE IS CALLED FROM INITRE.
C----------
C  CALL SUBROUTINES TO SORT AND MATCH RECORDS FOR THE VARIOUS
C  EXTENSIONS.
C----------
C
C*    CALL MISSOR
C*    CALL RRSOR
C*    CALL BWSOR
C*    CALL TMSOR
C*    CALL MPBSOR
      CALL BRSOR
C
      RETURN
      END
