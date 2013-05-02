/*
 * OpenTurns wrapper code generated by OpenModelica
 * for model: <%fullModelName%>
 */
/**
 *  @file  wrapper.c
 *  @brief The wrapper adapts the interface of OpenTURNS and of the wrapped code
 *
 */

#include "Wrapper.h"

#define WRAPPERNAME <%wrapperName%>
#define MODELNAMESTR "<%fullModelName%>"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#define DEBUG 0

#ifndef OMC_READ_MATLAB4_H
#define OMC_READ_MATLAB4_H

#include <stdio.h>
#include <stdint.h>

extern const char *omc_mat_Aclass;

typedef struct {
  uint32_t type;
  uint32_t mrows;
  uint32_t ncols;
  uint32_t imagf;
  uint32_t namelen;
} MHeader_t;

typedef struct {
  char *name,*descr;
  int isParam;
  /* Parameters are stored in data_1, variables in data_2; parameters are defined at any time, variables only within the simulation start/stop interval */
  int index;
} ModelicaMatVariable_t;

typedef struct {
  FILE *file;
  char *fileName;
  uint32_t nall;
  ModelicaMatVariable_t *allInfo; /* Sorted array of variables and their associated information */
  uint32_t nparam;
  double *params; /* This has size 2*nparam; the first parameter has row0=startTime,row1=stopTime. Other variables are stored as row0=row1 */
  uint32_t nvar,nrows;
  size_t var_offset; /* This is the offset in the file */
  double **vars;
} ModelicaMatReader;

/* Returns 0 on success; the error message on error.
 * The internal data is free'd by omc_free_matlab4_reader.
 * The data persists until free'd, and is safe to use in your own data-structures
 */
#ifdef __cplusplus
extern "C" {
#endif
const char* omc_new_matlab4_reader(const char *filename, ModelicaMatReader *reader);

void omc_free_matlab4_reader(ModelicaMatReader *reader);

/* Returns a variable or NULL */
ModelicaMatVariable_t *omc_matlab4_find_var(ModelicaMatReader *reader, const char *varName);

/* Writes the number of values in the returned array if nvals is non-NULL
 * Returns all values that the given variable may have.
 * Note: This function is _not_ defined for parameters; check var->isParam and then send the index
 * No bounds checking is performed. The returned data persists until the reader is closed.
 */
double* omc_matlab4_read_vals(ModelicaMatReader *reader, int varIndex);

/* Returns 0 on success */
int omc_matlab4_val(double *res, ModelicaMatReader *reader, ModelicaMatVariable_t *var, double time);

/* For debugging */
void omc_matlab4_print_all_vars(FILE *stream, ModelicaMatReader *reader);

double omc_matlab4_startTime(ModelicaMatReader *reader);

double omc_matlab4_stopTime(ModelicaMatReader *reader);
#ifdef __cplusplus
} /* extern "C" */
#endif

#endif


long callOpenModelicaModel(STATE p_state, INPOINT inPoint, OUTPOINT outPoint, EXCHANGEDDATA p_exchangedData, ERROR p_error)
{
    int idx = 0;
    long exitCode = 0;
    char systemCommand[5000] = {0}, buf[5000] = {0};
    char *variableName = NULL;
    unsigned long variableType = 0;
    /* read the model name from the included model_name.h file */
    char *modelName = MODELNAMESTR;
    char *resultFile = "OT_res.mat";
    char *errorMsg = 0;
    double variableValue = 0, stopTime = 0, F, E, L, I, y;
    struct WrapperVariableList *varLst = p_exchangedData->variableList_;
    ModelicaMatReader matReader = {0};
    char *uniqueTmpDir = 0;
    char *cmd = 0;
    char *currentWorkingDirectory = 0;
    char *prefix = MODELNAMESTR;
    char *tmpStr = NULL;

    /* We save the current working directory for a future come back */
    currentWorkingDirectory = getCurrentWorkingDirectory( p_error );
    if (currentWorkingDirectory == NULL) return WRAPPER_EXECUTION_ERROR;

    /* We build a temporary directory in which we will work */
    uniqueTmpDir = createTemporaryDirectory( (prefix) ? (prefix) : getUserPrefix(p_exchangedData),
                                                   p_exchangedData, p_error );
    if (uniqueTmpDir == NULL) return WRAPPER_EXECUTION_ERROR;

    if (varLst->variable_ == NULL)
    {
        SETERROR("The input variables structure is NULL");
        return WRAPPER_EXECUTION_ERROR;
    }

    // make it empty!
    systemCommand[0] = '\0';
    /* move to start */
    idx = 0;
    varLst = p_exchangedData->variableList_;
    while (varLst != NULL)
    {
      variableName = varLst->variable_->id_;
      variableType = varLst->variable_->type_;
      /* filter the output variables */
      if (variableType == 0)
      {
        variableValue = inPoint->data_[idx];
        /* construct the override string */
        tmpStr = strdup(systemCommand);
        sprintf(systemCommand, "%s%s=%g,",tmpStr,variableName,variableValue);
        free(tmpStr);
        idx++;
      }
      /* move to next */
      varLst = varLst->next_;
    }
    /* add stepSize=1 */
    tmpStr = strdup(systemCommand);
    sprintf(systemCommand, "%sstepSize=1.0",tmpStr);
    free(tmpStr);
    /* build the command */
    tmpStr = strdup(systemCommand);
    sprintf(systemCommand, "\"%s/%s\" -override %s -r %s/%s", currentWorkingDirectory, MODELNAMESTR, tmpStr, uniqueTmpDir, resultFile);
    free(tmpStr);

    if (DEBUG)
    {
      sprintf(buf, "%s\n\t -> ", systemCommand);
    }
    exitCode = system(systemCommand);
    if (exitCode)
    {
      SETERROR( "Error executing the Modelica model, command %s returned %d", systemCommand, exitCode );
      return WRAPPER_EXECUTION_ERROR;
    }
    sprintf(systemCommand, "%s/%s", uniqueTmpDir, resultFile);
    errorMsg = (char*)omc_new_matlab4_reader(systemCommand, &matReader);
    if (errorMsg)
    {
      SETERROR( "Error in opening the result file: %s", systemCommand );
      return WRAPPER_EXECUTION_ERROR;
    }
    stopTime = omc_matlab4_stopTime(&matReader);
    /*
    E = inPoint->data_[0];
    F = inPoint->data_[1];
    L = inPoint->data_[2];
    I = inPoint->data_[3];
    y = (F*L*L*L)/(3.0*E*I);
    */
    /* move to start */
    idx = 0;
    varLst = p_exchangedData->variableList_;
    /* populate the outPoint! */
    while (varLst)
    {
      variableName = varLst->variable_->id_;
      variableType = varLst->variable_->type_;
      /* filter the output variables */
      if (variableType == 1)
      {
        /* read the variable at stop time */
        ModelicaMatVariable_t *matVar = omc_matlab4_find_var(&matReader, variableName);
        omc_matlab4_val(&variableValue, &matReader, matVar, stopTime);
        if (DEBUG)
        {
          tmpStr = strdup(buf);
          //sprintf(buf, "%s %s=%g[%g] at time %g, ", tmpStr, variableName, variableValue, y, stopTime);
          sprintf(buf, "%s %s=%g at time %g, ", tmpStr, variableName, variableValue, stopTime);
          free(tmpStr);
        }
        outPoint->data_[idx] = variableValue;
        idx++;
      }
      /* move to next */
      varLst = varLst->next_;
    }

    if (DEBUG)
    {
      fprintf(stderr, "%s\n", buf); fflush(NULL);
    }
    omc_free_matlab4_reader(&matReader);
    close(systemCommand);

    /* We kill the temporary directory if no error has occurred */
    deleteTemporaryDirectory(uniqueTmpDir, exitCode, p_error);

    free ( currentWorkingDirectory );

    return exitCode;
}

BEGIN_C_DECLS
WRAPPER_BEGIN

/*
 *  This is the declaration of function named 'myWrapper' into the wrapper.
 */

/*
*********************************************************************************
*                                                                               *
*                             myWrapper function                                *
*                                                                               *
*********************************************************************************
*/

  /* The wrapper information informs the NumericalMathFunction object that loads the wrapper of the
   * signatures of the wrapper functions. In particular, it hold the size of the input
   * NumericalPoint (inSize_) and of the output NumericalPoint (outSize_).
   * Those information are also used by the gradient and hessian functions to set the correct size
   * of the returned matrix and tensor.
   */

  /* The getInfo function is optional. Except if you alter the description of the wrapper, you'd better
   * use the standard one automatically provided by the platform. Uncomment the following definition if
   * you want to provide yours instead. */
  /* FUNC_INFO( WRAPPERNAME , { } ) */

  /* The state creation/deletion functions allow the wrapper to create or delete a memory location
   * that it will manage itself. It can save in this location any information it needs. The OpenTURNS
   * platform only ensures that the wrapper will receive the state (= the memory location) it works
   * with. If many wrappers are working simultaneously or if the same wrapper is called concurrently,
   * this mechanism will avoid any collision or confusion.
   * The consequence is that NO STATIC DATA should be used in the wrapper OR THE WRAPPER WILL BREAKE
   * one day. You may think that you can't do without static data, but in general this is the case
   * of a poor design. But if you persist to use static data, do your work correctly and make use
   * of mutex (for instance) to protect your data against concurrent access. But don't complain about
   * difficulties or poor computational performance!
   */


  /* The createState function is optional. If you need to manage an internal state, uncomment the following
   * definitions and adapt the source code to your needs. By default Open TURNS provides default ones. */
  /* FUNC_CREATESTATE( WRAPPERNAME , {
     CHECK_WRAPPER_MODE( WRAPPER_STATICLINK );
     CHECK_WRAPPER_IN(   WRAPPER_ARGUMENTS  );
     CHECK_WRAPPER_OUT(  WRAPPER_ARGUMENTS  );

     COPY_EXCHANGED_DATA_TO( p_p_state );

     PRINT( "My message is here" );
     } ) */

  /* The deleteState function is optional. See FUNC_CREATESTATE for explanation. */
  /* FUNC_DELETESTATE( WRAPPERNAME , {
     DELETE_EXCHANGED_DATA_FROM( p_state );
     } ) */

  /* Any function declared into the wrapper may declare three actual functions prefixed with
   * 'init_', 'exec_' and 'finalize_' followed by the name of the function, here 'myWrapper'.
   *
   * The 'init_' function is only called once when the NumericalMathFunction object is created.
   * It allows the wrapper to set some internal state, read some external file, prepare the function
   * to run, etc.
   *
   * The 'exec_' function is intended to execute what the wrapper is done for: compute an mathematical
   * function or anything else. It takes the internal state pointer as its first argument, the input
   * NumericalPoint pointer as the second and the output NumericalPoint pointer as the third.
   *
   * The 'finalize_' function is only called once when the NumericalMathFunction object is destroyed.
   * It allows the wrapper to flush anything before unloading.
   *
   * Only the 'exec_' function is mandatory because the other ones are automatically provided by the platform.
   */


  /**
   * Initialization function
   * This function is called once just before the wrapper first called to initialize
   * it, ie create a temparary subdirectory (remember that the wrapper may be called
   * concurrently), store exchanged data in some internal repository, do some
   * pre-computational operation, etc. Uncomment the following definition if you want to
   * do some pre-computation work.
   */
   FUNC_INIT( WRAPPERNAME , {
       //struct WrapperVariableList   *varLst = p_exchangedData->variableList_;
       //fprintf(stderr, "CRAP_: %p\n", varLst->variable_); fflush(NULL);
   } )


  /**
   * Execution function
   * This function is called by the platform to do the real work of the wrapper. It may be
   * called concurrently, so be aware of not using shared or global data not protected by
   * a critical section.
   * This function has a mathematical meaning. It operates on one vector (aka point) and
   * returns another vector.
   *
   * This definition is MANDATORY.
   */
  FUNC_EXEC( WRAPPERNAME ,
    {
      long rc = callOpenModelicaModel(p_state, inPoint, outPoint, p_exchangedData, p_error);
      if (rc)
      {
        PRINT( "Error in calling the OpenModelica simulation code" );
        return WRAPPER_EXECUTION_ERROR;
      }
    } )

  /**
   * Finalization function
   * This function is called once just before the wrapper is unloaded. It is the place to flush
   * any output file or free any allocated memory. When this function returns, the wrapper is supposed
   * to have all its work done, so it is not possible to get anymore information from it after that.
   * Uncomment the following definition if you need to do some post-computation work. See FUNC_INIT. */
  /* FUNC_FINALIZE( WRAPPERNAME , {} ) */


WRAPPER_END
END_C_DECLS


#define size_omc_mat_Aclass 45
const char *omc_mat_Aclass = "A1 bt. ir1 na  Tj  re  ac  nt  so   r   y   ";
const char *dymola_mat_Aclass = "A1 bt.\0ir1 na\0 Nj  oe  rc  mt  ao  lr  \0y\0\0\0";

int omc_matlab4_comp_var(const void *a, const void *b)
{
  char *as = ((ModelicaMatVariable_t*)a)->name;
  char *bs = ((ModelicaMatVariable_t*)b)->name;
  return strcmp(as,bs);
}

int mat_element_length(int type)
{
  int m = (type/1000);
  int o = (type%1000)/100;
  int p = (type%100)/10;
  int t = (type%10);
  if (m) return -1; /* We require IEEE Little Endian for now */
  if (o) return -1; /* Reserved number; forced 0 */
  if (t == 1 && p != 5) return -1; /* Text matrix? Force element length=1 */
  if (t == 2) return -1; /* Sparse matrix fails */
  switch (p) {
    case 0: return 8;
    case 1: return 4;
    case 2: return 4;
    case 3: return 2;
    case 4: return 2;
    case 5: return 1;
    default: return -1;
  }
}

/* Do not double-free this :) */
void omc_free_matlab4_reader(ModelicaMatReader *reader)
{
  unsigned int i;
  fclose(reader->file);
  free(reader->fileName); reader->fileName=NULL;
  for (i=0; i<reader->nall; i++) {
    free(reader->allInfo[i].name);
    free(reader->allInfo[i].descr);
  }
  free(reader->allInfo); reader->allInfo=NULL;
  free(reader->params); reader->params=NULL;
  for (i=0; i<reader->nvar*2; i++)
    if (reader->vars[i]) free(reader->vars[i]);
  free(reader->vars); reader->vars=NULL;
}

/* Returns 0 on success; the error message on error */
const char* omc_new_matlab4_reader(const char *filename, ModelicaMatReader *reader)
{
  typedef const char *_string;
  const int nMatrix=6;
  _string matrixNames[6]={"Aclass","name","description","dataInfo","data_1","data_2"};
  const int matrixTypes[6]={51,51,51,20,0,0};
  int i;
  char binTrans = 1;
  reader->file = fopen(filename, "rb");
  if (!reader->file) return strerror(errno);
  reader->fileName = strdup(filename);
  for (i=0; i<nMatrix;i++) {
    MHeader_t hdr;
    int nr = fread(&hdr,sizeof(MHeader_t),1,reader->file);
    int matrix_length,element_length;
    char *name;
    if (nr != 1) return "Corrupt header (1)";
    /* fprintf(stderr, "Found matrix type=%04d mrows=%d ncols=%d imagf=%d namelen=%d\n", hdr.type, hdr.mrows, hdr.ncols, hdr.imagf, hdr.namelen); */
    if (hdr.type != matrixTypes[i]) return "Matrix type mismatch";
    if (hdr.imagf > 1) return "Matrix uses imaginary numbers";
    if ((element_length = mat_element_length(hdr.type)) == -1) return "Could not determine size of matrix elements";
    name = (char*) malloc(hdr.namelen);
    nr = fread(name,hdr.namelen,1,reader->file);
    if (nr != 1) return "Corrupt header (2)";
    if (name[hdr.namelen-1]) return "Corrupt header (3)";
    /* fprintf(stderr, "  Name of matrix: %s\n", name); */
    matrix_length = hdr.mrows*hdr.ncols*(1+hdr.imagf)*element_length;
    if (0 != strcmp(name,matrixNames[i])) return "Matrix name mismatch";
    free(name); name=NULL;
    switch (i) {
    case 0: {
      char tmp[size_omc_mat_Aclass];
      if (fread(tmp,size_omc_mat_Aclass-1,1,reader->file) != 1) return "Corrupt header: Aclass matrix";
      tmp[size_omc_mat_Aclass-1] = '\0';
     /* binTrans */
     if (0 == strncmp(tmp,omc_mat_Aclass,size_omc_mat_Aclass))  {
        /* fprintf(stderr, "use binTrans format\n"); */
        binTrans = 1;
      } else if (0 == strncmp(tmp,dymola_mat_Aclass,size_omc_mat_Aclass))  {
        /* binNormal */
        /* fprintf(stderr, "use binNormal format\n"); */
        binTrans = 0;
      }
      else return "Aclass matrix does not match the magic number";
      break;
    }
    case 1: { /* "names" */
      unsigned int i;
      if (binTrans==0)
         reader->nall = hdr.mrows;
      else
        reader->nall = hdr.ncols;
      reader->allInfo = (ModelicaMatVariable_t*) malloc(sizeof(ModelicaMatVariable_t)*reader->nall);
      if (binTrans==1) {
        for (i=0; i<hdr.ncols; i++) {
          reader->allInfo[i].name = (char*) malloc(hdr.mrows+1);
          if (fread(reader->allInfo[i].name,hdr.mrows,1,reader->file) != 1) return "Corrupt header: names matrix";
          reader->allInfo[i].name[hdr.mrows] = '\0';
          reader->allInfo[i].isParam = -1;
          reader->allInfo[i].index = -1;
          /* fprintf(stderr, "    Adding variable %s\n", reader->allInfo[i].name); */
         }
      }
      if (binTrans==0) {
      uint32_t j;
      char* tmp = (char*) malloc(hdr.ncols*hdr.mrows+1);
        if (fread(tmp,hdr.ncols*hdr.mrows,1,reader->file) != 1)  {
          free(tmp);
          return "Corrupt header: names matrix";
        }
        for (i=0; i<hdr.mrows; i++) {
          reader->allInfo[i].name = (char*) malloc(hdr.ncols+1);
          for(j=0; j<hdr.ncols; j++) {
            reader->allInfo[i].name[j] = tmp[j*hdr.mrows+i];
          }
          reader->allInfo[i].name[hdr.ncols] = '\0';
          reader->allInfo[i].isParam = -1;
          reader->allInfo[i].index = -1;
          /* fprintf(stderr, "    Adding variable %s\n", reader->allInfo[i].name); */
        }
        free(tmp);
      }
      break;
    }
    case 2: { /* description */
      unsigned int i;
      if (binTrans==1) {
        for (i=0; i<hdr.ncols; i++) {
          reader->allInfo[i].descr = (char*) malloc(hdr.mrows+1);
          if (fread(reader->allInfo[i].descr,hdr.mrows,1,reader->file) != 1) return "Corrupt header: names matrix";
          reader->allInfo[i].descr[hdr.mrows] = '\0';
         }
      } else if (binTrans==0) {
        uint32_t j;
        char* tmp = (char*) malloc(hdr.ncols*hdr.mrows+1);
        if (fread(tmp,hdr.ncols*hdr.mrows,1,reader->file) != 1)  {
          free(tmp);
          return "Corrupt header: names matrix";
        }
        for (i=0; i<hdr.mrows; i++) {
          reader->allInfo[i].descr = (char*) malloc(hdr.ncols+1);
          for(j=0; j<hdr.ncols; j++) {
            reader->allInfo[i].descr[j] = tmp[j*hdr.mrows+i];
          }
          reader->allInfo[i].descr[hdr.ncols] = '\0';
          /* fprintf(stderr, "    Adding variable %s\n", reader->allInfo[i].name); */
        }
        free(tmp);
      }
      break;
    }
    case 3: { /* "dataInfo" */
      unsigned int i;
      int32_t *tmp = (int32_t*) malloc(sizeof(int32_t)*hdr.ncols*hdr.mrows);
      if (1 != fread(tmp,sizeof(int32_t)*hdr.ncols*hdr.mrows,1,reader->file)) {
        free(tmp); tmp=NULL;
        return "Corrupt header: dataInfo matrix";
      }
      if (binTrans==1) {
        for (i=0; i<hdr.ncols; i++) {
          reader->allInfo[i].isParam = tmp[i*hdr.mrows] == 1;
          reader->allInfo[i].index = tmp[i*hdr.mrows+1];
          /* fprintf(stderr, "    Variable %s isParam=%d index=%d\n", reader->allInfo[i].name, reader->allInfo[i].isParam, reader->allInfo[i].index); */
        }
      }
      if (binTrans==0) {
        for (i=0; i<hdr.mrows; i++) {
          reader->allInfo[i].isParam = tmp[i] == 1;
          reader->allInfo[i].index =  tmp[i + hdr.mrows];
          /* fprintf(stderr, "    Variable %s isParam=%d index=%d\n", reader->allInfo[i].name, reader->allInfo[i].isParam, reader->allInfo[i].index); */
        }
      }
      free(tmp); tmp=NULL;
      /* Sort the variables so we can do faster lookup */
      qsort(reader->allInfo,reader->nall,sizeof(ModelicaMatVariable_t),omc_matlab4_comp_var);
      break;
    }
    case 4: { /* "data_1" */
      if (binTrans==1) {
        unsigned int i;
        if (hdr.mrows == 0) return "data_1 matrix does not contain at least 1 variable";
        if (hdr.ncols != 2) return "data_1 matrix does not have 2 rows";
        reader->nparam = hdr.mrows;
        reader->params = (double*) malloc(hdr.mrows*hdr.ncols*sizeof(double));
        if (1 != fread(reader->params,matrix_length,1,reader->file)) return "Corrupt header: data_1 matrix";
        /* fprintf(stderr, "    startTime = %.6g\n", reader->params[0]);
        * fprintf(stderr, "    stopTime = %.6g\n", reader->params[1]); */
        for (i=1; i<reader->nparam; i++) {
          if (reader->params[i] != reader->params[i+reader->nparam]) return "data_1 matrix contained parameter that changed between start and stop-time";
          /* fprintf(stderr, "    Parameter[%d] = %.6g\n", i, reader->params[i]); */
        }
      }
      if (binTrans==0) {
        unsigned int i,j;
        double *tmp=NULL;
        if (hdr.ncols == 0) return "data_1 matrix does not contain at least 1 variable";
        if (hdr.mrows != 2) return "data_1 matrix does not have 2 rows";
        reader->nparam = hdr.ncols;
        tmp = (double*) malloc(hdr.mrows*hdr.ncols*sizeof(double));
        reader->params = (double*) malloc(hdr.mrows*hdr.ncols*sizeof(double));
        if (1 != fread(tmp,matrix_length,1,reader->file)) return "Corrupt header: data_1 matrix";
        for (i=0; i<hdr.mrows; i++) {
          for (j=0; j<hdr.ncols; j++) {
            reader->params[i*hdr.ncols+j] = tmp[i +j*hdr.mrows];
          }
        }
        free(tmp);
        for (i=1; i<reader->nparam; i++) {
          if (reader->params[i] != reader->params[i+reader->nparam]) return "data_1 matrix contained parameter that changed between start and stop-time";
        }
      }
      break;
    }
    case 5: { /* "data_2" */
      if (binTrans==1) {
        reader->nrows = hdr.ncols;
        reader->nvar = hdr.mrows;
        if (reader->nrows < 2) return "Too few rows in data_2 matrix";
        reader->var_offset = ftell(reader->file);
        reader->vars = (double**) calloc(reader->nvar*2,sizeof(double*));
        if (-1==fseek(reader->file,matrix_length,SEEK_CUR)) return "Corrupt header: data_2 matrix";
      }
      if (binTrans==0) {
        unsigned int i,j;
        double *tmp=NULL;
        reader->nrows = hdr.mrows;
        reader->nvar = hdr.ncols;
        if (reader->nrows < 2) return "Too few rows in data_2 matrix";
        reader->var_offset = ftell(reader->file);
        reader->vars = (double**) calloc(reader->nvar*2,sizeof(double*));
        tmp = (double*) malloc(hdr.mrows*hdr.ncols*sizeof(double));
        if (1 != fread(tmp,matrix_length,1,reader->file)) return "Corrupt header: data_2 matrix";
        for (i=0; i<hdr.ncols; i++) {
          reader->vars[i] = (double*) malloc(hdr.mrows*sizeof(double));
          for (j=0; j<hdr.mrows; j++) {
            reader->vars[i][j] = tmp[j+i*hdr.mrows];
          }
        }
        for (i=reader->nvar; i<reader->nvar*2; i++) {
          reader->vars[i] = (double*) malloc(hdr.mrows*sizeof(double));
          for (j=0; j<hdr.mrows; j++) {
            reader->vars[i][j] = -reader->vars[i-reader->nvar][j];
          }
        }
        free(tmp);
        if (-1==fseek(reader->file,matrix_length,SEEK_CUR)) return "Corrupt header: data_2 matrix";
      }
      break;
    }
    default:
      return "Implementation error: Unknown case";
    }
  };
  return 0;
}

ModelicaMatVariable_t *omc_matlab4_find_var(ModelicaMatReader *reader, const char *varName)
{
  ModelicaMatVariable_t key;
  key.name = (char*) varName;
  return (ModelicaMatVariable_t*)bsearch(&key,reader->allInfo,reader->nall,sizeof(ModelicaMatVariable_t),omc_matlab4_comp_var);
}

/* Writes the number of values in the returned array if nvals is non-NULL */
double* omc_matlab4_read_vals(ModelicaMatReader *reader, int varIndex)
{
  size_t absVarIndex = abs(varIndex);
  size_t ix = (varIndex < 0 ? absVarIndex + reader->nvar : absVarIndex) -1;
  assert(absVarIndex > 0 && absVarIndex <= reader->nvar);
  if (!reader->vars[ix]) {
    unsigned int i;
    double *tmp = (double*) malloc(reader->nrows*sizeof(double));
    for (i=0; i<reader->nrows; i++) {
      fseek(reader->file,reader->var_offset + sizeof(double)*(i*reader->nvar + absVarIndex-1), SEEK_SET);
      if (1 != fread(&tmp[i], sizeof(double), 1, reader->file)) {
        /* fprintf(stderr, "Corrupt file at %d of %d? nvar %d\n", i, reader->nrows, reader->nvar); */
        free(tmp);
        tmp=NULL;
        return NULL;
      }
      if (varIndex < 0) tmp[i] = -tmp[i];
      /* fprintf(stderr, "tmp[%d]=%g\n", i, tmp[i]); */
    }
    reader->vars[ix] = tmp;
  }
  return reader->vars[ix];
}

double omc_matlab4_read_single_val(double *res, ModelicaMatReader *reader, int varIndex, int timeIndex)
{
  size_t absVarIndex = abs(varIndex);
  size_t ix = (varIndex < 0 ? absVarIndex + reader->nvar : absVarIndex) -1;
  assert(absVarIndex > 0 && absVarIndex <= reader->nvar);
  if (reader->vars[ix]) {
    *res = reader->vars[ix][timeIndex];
    return 0;
  }
  fseek(reader->file,reader->var_offset + sizeof(double)*(timeIndex*reader->nvar + absVarIndex-1), SEEK_SET);
  if (1 != fread(res, sizeof(double), 1, reader->file))
    return 1;
  if (varIndex < 0)
    *res = -(*res);
  return 0;
}

void find_closest_points(double key, double *vec, int nelem, int *index1, double *weight1, int *index2, double *weight2)
{
  int min = 0;
  int max = nelem-1;
  int mid;
  /* fprintf(stderr, "search closest: %g in %d elem\n", key, nelem); */
  do {
    mid = min + (max-min)/2;
    if (key == vec[mid]) {
      /* If we have events (multiple identical time stamps), use the right limit */
      while (mid < max && vec[mid] == vec[mid+1]) mid++;
      *index1 = mid;
      *weight1 = 1.0;
      *index2 = -1;
      *weight2 = 0.0;
      return;
    } else if (key > vec[mid]) {
      min = mid + 1;
    } else {
      max = mid - 1;
    }
  } while (max > min);
  if (max == min) {
    if (key > vec[max])
      max++;
    else
      min--;
  }
  *index1 = max;
  *index2 = min;
  /* fprintf(stderr, "closest: %g = (%d,%g),(%d,%g)\n", key, min, vec[min], max, vec[max]); */
  *weight1 = (key - vec[min]) / (vec[max]-vec[min]);
  *weight2 = 1.0 - *weight1;
}

double omc_matlab4_startTime(ModelicaMatReader *reader)
{
  return reader->params[0];
}

double omc_matlab4_stopTime(ModelicaMatReader *reader)
{
  return reader->params[reader->nparam];
}

/* Returns 0 on success */
int omc_matlab4_val(double *res, ModelicaMatReader *reader, ModelicaMatVariable_t *var, double time)
{
  if (var->isParam) {
    if (var->index < 0)
      *res = -reader->params[abs(var->index)-1];
    else
      *res = reader->params[var->index-1];
  } else {
    double w1,w2,y1,y2;
    int i1,i2;
    if (time > omc_matlab4_stopTime(reader)) return 1;
    if (time < omc_matlab4_startTime(reader)) return 1;
    if (!omc_matlab4_read_vals(reader,1)) return 1;
    find_closest_points(time, reader->vars[0], reader->nrows, &i1, &w1, &i2, &w2);
    if (i2 == -1) {
      return (int)omc_matlab4_read_single_val(res,reader,var->index,i1);
    } else if (i1 == -1) {
      return (int)omc_matlab4_read_single_val(res,reader,var->index,i2);
    } else {
      if (omc_matlab4_read_single_val(&y1,reader,var->index,i1)) return 1;
      if (omc_matlab4_read_single_val(&y2,reader,var->index,i2)) return 1;
      *res = w1*y1 + w2*y2;
      return 0;
    }
  }
  return 0;
}

void omc_matlab4_print_all_vars(FILE *stream, ModelicaMatReader *reader)
{
  unsigned int i;
  fprintf(stream, "allSortedVars(\"%s\") => {", reader->fileName);
  for (i=0; i<reader->nall; i++)
    fprintf(stream, "\"%s\",", reader->allInfo[i].name);
  fprintf(stream, "}\n");
}

#if 0
int main(int argc, char** argv)
{
  ModelicaMatReader reader;
  const char *msg;
  int i;
  double r;
  ModelicaMatVariable_t *var;
  if (argc < 2) {
    fprintf(stderr, "Usage: %s filename.mat var0 ... varn\n", *argv);
    exit(1);
  }
  if (0 != (msg=omc_new_matlab4_reader(argv[1],&reader))) {
    fprintf(stderr, "%s is not in the MATLAB4 subset accepted by OpenModelica: %s\n", argv[1], msg);
    exit(1);
  }
  omc_matlab4_print_all_vars(stderr, &reader);
  for (i=2; i<argc; i++) {
    int printAll = *argv[i] == '.';
    char *name = argv[i] + printAll;
    var = omc_matlab4_find_var(&reader, name);
    if (!var) {
      fprintf(stderr, "%s not found\n", name);
    } else if (printAll) {
      int n,j;
      if (var->isParam) {
        fprintf(stderr, "%s is param, but tried to read all values", name);
        continue;
      }
      double *vals = omc_matlab4_read_vals(&n,&reader,var->index);
      if (!vals) {
        fprintf(stderr, "%s = #FAILED TO READ VALS", name);
      } else {
        fprintf(stderr, "  allValues(%s) => {", name);
        for (j=0; j<n; j++)
          fprintf(stderr, "%g,", vals[j]);
        fprintf(stderr, "}\n");
      }
    } else {
      int j;
      double ts[4] = {-1.0,0.0,0.1,1.0};
      for (j=0; j<4; j++)
        if (0==omc_matlab4_val(&r,&reader,var,ts[j]))
          fprintf(stderr, "  val(\"%s\",%4g) => %g\n", name, ts[j], r);
        else
          fprintf(stderr, "  val(\"%s\",%4g) => fail()\n", name, ts[j]);
    }
  }
  omc_free_matlab4_reader(&reader);
  return 0;
}
#endif
