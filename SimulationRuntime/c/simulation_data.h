/*
* This file is part of OpenModelica.
*
* Copyright (c) 1998-CurrentYear, Linköping University,
* Department of Computer and Information Science,
* SE-58183 Linköping, Sweden.
*
* All rights reserved.
*
* THIS PROGRAM IS PROVIDED UNDER THE TERMS OF GPL VERSION 3
* AND THIS OSMC PUBLIC LICENSE (OSMC-PL).
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS PROGRAM CONSTITUTES RECIPIENT'S
* ACCEPTANCE OF THE OSMC PUBLIC LICENSE.
*
* The OpenModelica software and the Open Source Modelica
* Consortium (OSMC) Public License (OSMC-PL) are obtained
* from Linköping University, either from the above address,
* from the URLs: http://www.ida.liu.se/projects/OpenModelica or
* http://www.openmodelica.org, and in the OpenModelica distribution.
* GNU version 3 is obtained from: http://www.gnu.org/copyleft/gpl.html.
*
* This program is distributed WITHOUT ANY WARRANTY; without
* even the implied warranty of  MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE, EXCEPT AS EXPRESSLY SET FORTH
* IN THE BY RECIPIENT SELECTED SUBSIDIARY LICENSE CONDITIONS
* OF OSMC-PL.
*
* See the full OSMC Public License conditions for more details.
*
*/

/*! \file simulation_data.h
 * Description: This is the C header file to provide all information
 * for simulation
 */

#ifndef SIMULATION_DATA_H
#define SIMULATION_DATA_H

#include "openmodelica.h"
#include "ringbuffer.h"
#include "omc_error.h"
#include "f2c.h"

#define omc_dummyFileInfo {"",-1,-1,-1,-1,1}
#define omc_dummyVarInfo {-1,"","",omc_dummyFileInfo}
#define omc_dummyEquationInfo {-1,0,"",-1,NULL}
#define omc_dummyFunctionInfo {-1,"",omc_dummyFileInfo}

#if defined(_MSC_VER)
#define set_struct(TYPE, x, info) { const TYPE tmp = info; x = tmp; }
#else
#define set_struct(TYPE, x, info) x = (TYPE)info
#endif

/* Forward declaration of DATA to avoid warnings in NONLINEAR_SYSTEM_DATA. */
struct DATA;

/* Model info structures */
typedef struct VAR_INFO
{
  int id;
  const char *name;
  const char *comment;
  const FILE_INFO info;
}VAR_INFO;

typedef struct EQUATION_INFO
{
  int id;
  int profileBlockIndex;
  const char *name;
  int numVar;
  const VAR_INFO** vars;               /* The variables involved in the equation. Not sure we need this anymore as the info.xml has this information. */
}EQUATION_INFO;

typedef struct FUNCTION_INFO
{
  int id;
  const char* name;
  FILE_INFO info;
}FUNCTION_INFO;

typedef struct SAMPLE_INFO
{
  long index;
  double start;
  double interval;
} SAMPLE_INFO;

typedef enum {ERROR_AT_TIME,NO_PROGRESS_START_POINT,NO_PROGRESS_FACTOR,IMPROPER_INPUT} equationSystemError;

/* SPARSE_PATTERN
  *
  * sparse pattern struct used by jacobians
  * leadindex points to an index where to corresponding
  * index of an row or column is noted in index.
  * sizeofIndex contain number of elements in index
  * colorsCols contain color of colored columns
  *
  */
typedef struct SPARSE_PATTERN
{
    unsigned int* leadindex;
    unsigned int* index;
    unsigned int sizeofIndex;
    unsigned int* colorCols;
    unsigned int maxColors;
}SPARSE_PATTERN;

/* ANALYTIC_JACOBIAN
  *
  * analytic jacobian struct used for dassl and linearization.
  * jacobianName contain "A" || "B" etc.
  * sizeCols contain size of column
  * sizeRows contain size of rows
  * sparsePattern contain the sparse pattern include colors
  * seedVars contain seed vector to the corresponding jacobian
  * resultVars contain result of one column to the corresponding jacobian
  * jacobian contains dense jacobian elements
  *
  */
typedef struct ANALYTIC_JACOBIAN
{
    unsigned int sizeCols;
    unsigned int sizeRows;
    SPARSE_PATTERN sparsePattern;
    modelica_real* seedVars;
    modelica_real* tmpVars;
    modelica_real* resultVars;
    modelica_real* jacobian;

}ANALYTIC_JACOBIAN;

/* Alias data with various types*/
typedef struct DATA_REAL_ALIAS
{
  int negate;
  int nameID;                          /* pointer to Alias */
  char aliasType;                      /* 0 variable, 1 parameter, 2 time */
  VAR_INFO info;
  modelica_boolean filterOutput;       /* true if this variable should be filtered */
}DATA_REAL_ALIAS;

typedef struct DATA_INTEGER_ALIAS
{
  int negate;
  int nameID;
  char aliasType;                      /* 0 variable, 1 parameter */
  VAR_INFO info;
  modelica_boolean filterOutput;       /* true if this variable should be filtered */
}DATA_INTEGER_ALIAS;

typedef struct DATA_BOOLEAN_ALIAS
{
  int negate;
  int nameID;
  char aliasType;                      /* 0 variable, 1 parameter */
  VAR_INFO info;
  modelica_boolean filterOutput;       /* true if this variable should be filtered */
}DATA_BOOLEAN_ALIAS;

typedef struct DATA_STRING_ALIAS
{
  int negate;
  int nameID;
  char aliasType;                      /* 0 variable, 1 parameter */
  VAR_INFO info;
  modelica_boolean filterOutput;       /* true if this variable should be filtered */
}DATA_STRING_ALIAS;


/* collect all attributes from one variable in one struct */
typedef struct REAL_ATTRIBUTE
{
  modelica_string quantity;            /* = "" */
  modelica_string unit;                /* = "" */
  modelica_string displayUnit;         /* = "" */
  modelica_real min;                   /* = -Inf */
  modelica_real max;                   /* = +Inf */
  modelica_boolean fixed;              /* depends on the type */
  modelica_boolean useNominal;         /* = false */
  modelica_real nominal;               /* = 1.0 */
  modelica_boolean useStart;           /* = false */
  modelica_real start;                 /* = 0.0 */
}REAL_ATTRIBUTE;

typedef struct INTEGER_ATTRIBUTE
{
  modelica_string quantity;            /* = "" */
  modelica_integer min;                /* = -Inf */
  modelica_integer max;                /* = +Inf */
  modelica_boolean fixed;              /* depends on the type */
  modelica_boolean useStart;           /* = false */
  modelica_integer start;              /* = 0 */
}INTEGER_ATTRIBUTE;

typedef struct BOOLEAN_ATTRIBUTE
{
  modelica_string quantity;            /* = "" */
  modelica_boolean fixed;              /* depends on the type */
  modelica_boolean useStart;           /* = false */
  modelica_boolean start;              /* = false */
}BOOLEAN_ATTRIBUTE;

typedef struct STRING_ATTRIBUTE
{
  modelica_string quantity;            /* = "" */
  modelica_boolean useStart;           /* = false */
  modelica_string start;               /* = "" */
}STRING_ATTRIBUTE;

typedef struct STATIC_REAL_DATA
{
  VAR_INFO info;
  REAL_ATTRIBUTE attribute;
  modelica_boolean filterOutput;       /* true if this variable should be filtered */
}STATIC_REAL_DATA;

typedef struct STATIC_INTEGER_DATA
{
  VAR_INFO info;
  INTEGER_ATTRIBUTE attribute;
  modelica_boolean filterOutput;       /* true if this variable should be filtered */
}STATIC_INTEGER_DATA;

typedef struct STATIC_BOOLEAN_DATA
{
  VAR_INFO info;
  BOOLEAN_ATTRIBUTE attribute;
  modelica_boolean filterOutput;       /* true if this variable should be filtered */
}STATIC_BOOLEAN_DATA;

typedef struct STATIC_STRING_DATA
{
  VAR_INFO info;
  STRING_ATTRIBUTE attribute;
  modelica_boolean filterOutput;       /* true if this variable should be filtered */
}STATIC_STRING_DATA;

typedef struct NONLINEAR_SYSTEM_DATA
{
  modelica_integer size;
  modelica_integer equationIndex;      /* index for EQUATION_INFO */

  /* attributes for x */
  modelica_real *min;
  modelica_real *max;
  modelica_real *nominal;

  /* if analyticalJacobianColumn != NULL analyticalJacobian is available and
   * can be produced with the help of analyticalJacobianColumnn function pointer
   * which is a generic column of the jacobian matrix. (see ANALYTIC_JACOBIAN)
   *
   * if analyticalJacobianColumn == NULL no analyticalJacobian is available
   */
  int (*analyticalJacobianColumn)(void*);
  int (*initialAnalyticalJacobian)(void*);
  modelica_integer jacobianIndex;

  void (*residualFunc)(void*, double*, double*, integer*);
  void (*initializeStaticNLSData)(void*, void*);

  void *solverData;
  modelica_real *nlsx;                 /* x */
  modelica_real *nlsxOld;              /* previous x */
  modelica_real *nlsxExtrapolation;    /* extrapolated values for x from old and old2 - used as initial guess */

  modelica_integer method;             /* used for linear tearing system if 1: Newton step is done otherwise 0 */
  modelica_real residualError;         /* not used */
  modelica_boolean solved;             /* 1: solved in current step - else not */
}NONLINEAR_SYSTEM_DATA;

typedef struct LINEAR_SYSTEM_DATA
{
  /* set matrix A */
  void (*setA)(void* data, void* systemData);
  /* set vector b (rhs) */
  void (*setb)(void* data, void* systemData);

  modelica_integer size;
  modelica_integer equationIndex;     /* index for EQUATION_INFO */

  void *solverData;
  modelica_real *x;                /* solution vector x */
  modelica_real *A;                /* matrix A */
  modelica_real *b;                /* vector b */

  modelica_integer method;          /* not used yet*/
  modelica_real residualError;      /* not used yet*/
  modelica_boolean solved;          /* 1: solved in current step - else not */
}LINEAR_SYSTEM_DATA;

typedef struct MIXED_SYSTEM_DATA
{
  modelica_integer size;
  modelica_integer equationIndex;     /* index for EQUATION_INFO */
  modelica_boolean continuous_solution; /* indicates if the continuous part could be solved */

  /* solveContinuousPart */
  void (*solveContinuousPart)(void* data);

  void (*updateIterationExps)(void* data);

  modelica_boolean** iterationVarsPtr;
  modelica_boolean** iterationPreVarsPtr;
  void *solverData;

  modelica_integer method;          /* not used yet*/
  modelica_boolean solved;          /* 1: solved in current step - else not */
}MIXED_SYSTEM_DATA;

typedef struct STATE_SET_DATA
{
  modelica_integer nCandidates;
  modelica_integer nStates;
  modelica_integer nDummyStates;

  VAR_INFO* A;
  modelica_integer* rowPivot;
  modelica_integer* colPivot;
  modelica_real* J;

  VAR_INFO** states;
  VAR_INFO** statescandidates;

  /* if analyticalJacobianColumn != NULL analyticalJacobian is available and
   * can be produced with the help of analyticalJacobianColumnn function pointer
   * which is a generic column of the jacobian matrix. (see ANALYTIC_JACOBIAN)
   *
   * if analyticalJacobianColumn == NULL no analyticalJacobian is available
   */
  int (*analyticalJacobianColumn)(void*);
  int (*initialAnalyticalJacobian)(void*);
  modelica_integer jacobianIndex;
}STATE_SET_DATA;

typedef struct MODEL_DATA_XML
{
  const char *fileName;
  long nFunctions;
  long nEquations;
  long nProfileBlocks;
  FUNCTION_INFO *functionNames;        /* lazy loading; read from file if it is NULL when accessed */
  EQUATION_INFO *equationInfo;         /* lazy loading; read from file if it is NULL when accessed */
} MODEL_DATA_XML;

typedef struct MODEL_DATA
{
  STATIC_REAL_DATA* realVarsData;
  STATIC_INTEGER_DATA* integerVarsData;
  STATIC_BOOLEAN_DATA* booleanVarsData;
  STATIC_STRING_DATA* stringVarsData;

  STATIC_REAL_DATA* realParameterData;
  STATIC_INTEGER_DATA* integerParameterData;
  STATIC_BOOLEAN_DATA* booleanParameterData;
  STATIC_STRING_DATA* stringParameterData;

  DATA_REAL_ALIAS* realAlias;
  DATA_INTEGER_ALIAS* integerAlias;
  DATA_BOOLEAN_ALIAS* booleanAlias;
  DATA_STRING_ALIAS* stringAlias;

  MODEL_DATA_XML modelDataXml;         /* TODO: Rename me? */

  modelica_string_t modelName;
  modelica_string_t modelFilePrefix;
  modelica_string_t modelDir;
  modelica_string_t modelGUID;

  long nSamples;                       /* number of different sample-calls */
  SAMPLE_INFO* samplesInfo;            /* array containing each sample-call */

  fortran_integer nStates;
  long nVariablesReal;                 /* all Real Variables of the model (states, statesderivatives, algebraics) */
  long nVariablesInteger;
  long nVariablesBoolean;
  long nVariablesString;
  long nParametersReal;
  long nParametersInteger;
  long nParametersBoolean;
  long nParametersString;
  long nInputVars;
  long nOutputVars;

  long nZeroCrossings;
  long nRelations;
  long nMathEvents;                    /* number of math triggering functions e.g. cail, floor, integer */
  long nDelayExpressions;
  long nInitEquations;                 /* number of initial equations */
  long nInitAlgorithms;                /* number of initial algorithms */
  long nInitResiduals;                 /* number of initial residuals */
  long nExtObjs;
  long nMixedSystems;
  long nLinearSystems;
  long nNonLinearSystems;
  long nStateSets;
  long nInlineVars;                    /* number of additional variables for the inline solverr */

  long nAliasReal;
  long nAliasInteger;
  long nAliasBoolean;
  long nAliasString;

  long nJacobians;
}MODEL_DATA;

typedef struct SIMULATION_INFO
{
  modelica_real startTime;
  modelica_real stopTime;
  modelica_integer numSteps;
  modelica_real stepSize;
  modelica_real tolerance;
  modelica_string solverMethod;
  modelica_string outputFormat;
  modelica_string variableFilter;
  int lsMethod;                        /* linear solver */
  int mixedMethod;                     /* mixed solver */
  int nlsMethod;                       /* nonlinear solver */


  /* indicators for simulations state */
  modelica_boolean initial;            /* =1 during initialization, 0 otherwise. */
  modelica_boolean terminal;           /* =1 at the end of the simulation, 0 otherwise. */
  modelica_boolean discreteCall;       /* =1 for a discrete step, otherwise 0 */
  modelica_boolean needToIterate;      /* =1 if reinit has been activated, iteration about the system is needed */
  modelica_boolean simulationSuccess;  /* =0 the simulation run successful, otherwise an error code is set */
  modelica_boolean sampleActivated;    /* =1 a sample expresion if going to be actived, 0 otherwise */
  modelica_boolean solveContinuous;    /* =1 during the continuous integration to avoid zero-crossings jums,  0 otherwise. */
  modelica_boolean noThrowDivZero;     /* =1 if solving nonlinear system to avoid THROW for division by zero,  0 otherwise. */

  void** extObjs;                      /* External objects */

  double nextSampleEvent;              /* point in time of next sample-call */
  double *nextSampleTimes;             /* array of next sample time */
  modelica_boolean *samples;           /* array of the current value for all sample-calls */

  modelica_real* zeroCrossings;
  modelica_real* zeroCrossingsPre;
  modelica_boolean* relations;
  modelica_boolean* relationsPre;
  modelica_boolean* hysteresisEnabled;
  modelica_real* mathEventsValuePre;
  long* zeroCrossingIndex;             /* pointer for a list events at event instants */

  /* old vars for event handling */
  modelica_real timeValueOld;
  modelica_real* realVarsOld;

  modelica_real* realVarsPre;
  modelica_integer* integerVarsPre;
  modelica_boolean* booleanVarsPre;
  modelica_string* stringVarsPre;

  modelica_real* realParameter;
  modelica_integer* integerParameter;
  modelica_boolean* booleanParameter;
  modelica_string* stringParameter;

  modelica_real* inputVars;
  modelica_real* outputVars;

  ANALYTIC_JACOBIAN* analyticJacobians;

  NONLINEAR_SYSTEM_DATA* nonlinearSystemData;
  int currentNonlinearSystemIndex;

  LINEAR_SYSTEM_DATA* linearSystemData;
  int currentLinearSystemIndex;

  MIXED_SYSTEM_DATA* mixedSystemData;

  STATE_SET_DATA* stateSetData;

  /* delay vars */
  double tStart;
  RINGBUFFER **delayStructure;
  const char *OPENMODELICAHOME;
}SIMULATION_INFO;

/* collects all dynamic model data like the variabel-values */
typedef struct SIMULATION_DATA
{
  modelica_real timeValue;

  modelica_real* realVars;
  modelica_integer* integerVars;
  modelica_boolean* booleanVars;
  modelica_string* stringVars;

  modelica_real* inlineVars;           /* needed for the inline solver */

}SIMULATION_DATA;

/* top-level struct to collect dynamic and static model data */
typedef struct DATA
{
  RINGBUFFER* simulationData;          /* RINGBUFFER of SIMULATION_DATA */
  SIMULATION_DATA **localData;
  MODEL_DATA modelData;                /* static stuff */
  SIMULATION_INFO simulationInfo;
}DATA;

#endif
