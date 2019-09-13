#include <stdlib.h>
#include <string.h>

// BASE $Id$

// this is a collection of C-language callable API routines that pass
// character data to or from correspoinding Fortran subroutines in FVS.
// Nick Crookston, September 2019, Moscow, ID

void fvsSetCmdLineC(char  *theCmdLine,int *lenCL,int *IRTNCD);
void CfvsSetCmdLine(char **theCmdLine,int *lenCL,int *IRTNCD)
{
  fvsSetCmdLineC(*theCmdLine,lenCL,IRTNCD);  
}  

void fvsTreeAttrC(char *name,int *nch,char *action,int *ntrees,
                  double *attr,int *rtnCode);
void CfvsTreeAttr(char **name,int *nch,char **action,int *ntrees,
                  double *attr, int *rtnCode)
{
  fvsTreeAttrC(*name,nch,*action,ntrees,attr,rtnCode);  
}

void fvsSpeciesAttrC(char *name,int *nch,char *action,
                     double *attr,int *rtnCode);
void CfvsSpeciesAttr(char **name,int *nch,char **action,
                     double *attr, int *rtnCode)
{
  fvsSpeciesAttrC(*name,nch,*action,attr,rtnCode);  
}

void fvsEvmonAttrC(char *name,int *nch,char *action,
                   double *attr,int *rtnCode);
void CfvsEvmonAttr(char **name,int *nch,char **action,
                   double *attr, int *rtnCode)
{
  fvsEvmonAttrC(*name,nch,*action,attr,rtnCode);  
}

void fvsSpeciesCodeC(char *fvs_code,char *fia_code,char *plant_code, int *indx,
                     int *nchfvs,int *nchfia,int *nchplant,int *rtnCode);
void CfvsSpeciesCode(char **fvs_code,char **fia_code,char **plant_code,
                     int  *indx,int *nchfvs,int *nchfia, int *nchplant, int *rtnCode)
{
  fvsSpeciesCodeC(*fvs_code,*fia_code,*plant_code,indx,nchfvs,nchfia,nchplant,rtnCode);  
}
 
void fvsStandIDC(char *,char  *,char  *,char  *);
void CfvsStandID(char **sID,char **sCN,char **mID,char **mCASE)
{
    fvsStandIDC(sID[0],sCN[0],mID[0],mCASE[0]);
}

void fvsUnitConversionC(char  *name,int *nch, double *value, int *rtnCode);
void CfvsUnitConversion(char **name,int *nch, double *value, int *rtnCode)
{
  fvsUnitConversionC(name[0],nch,value,rtnCode);  
}

void fvsCloseFileC(char  *name,int *nch);
void CfvsCloseFile(char **name,int *nch)
{
  fvsCloseFileC(name[0],nch);  
}

void fvsSVSObjDataC(char *name,int *nch,char *action,int *nobjs,
                    double *attr,int *rtnCode);
void CfvsSVSObjData(char **name,int *nch,char **action,int *nobjs,
                    double *attr, int *rtnCode)
{
  fvsSVSObjDataC(name[0],nch,*action,nobjs,attr,rtnCode);  
}

void fvsFFEAttrsC(char *name,int *nch,char *action,int *nobjs,
                  double *attr,int *rtnCode);
void CfvsFFEAttrs(char **name,int *nch,char **action,int *nobjs,
                  double *attr, int *rtnCode)
{
  fvsFFEAttrsC(name[0],nch,*action,nobjs,attr,rtnCode);  
}




