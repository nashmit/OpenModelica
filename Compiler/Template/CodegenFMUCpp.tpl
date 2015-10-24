// This file defines templates for transforming Modelica/MetaModelica code to FMU
// code. They are used in the code generator phase of the compiler to write
// target code.
//
// There are one root template intended to be called from the code generator:
// translateModel. These template do not return any
// result but instead write the result to files. All other templates return
// text and are used by the root templates (most of them indirectly).
//
// To future maintainers of this file:
//
// - A line like this
//     # var = "" /*BUFD*/
//   declares a text buffer that you can later append text to. It can also be
//   passed to other templates that in turn can append text to it. In the new
//   version of Susan it should be written like this instead:
//     let &var = buffer ""
//
// - A line like this
//     ..., Text var /*BUFP*/, ...
//   declares that a template takes a text buffer as input parameter. In the
//   new version of Susan it should be written like this instead:
//     ..., Text &var, ...
//
// - A line like this:
//     ..., var /*BUFC*/, ...
//   passes a text buffer to a template. In the new version of Susan it should
//   be written like this instead:
//     ..., &var, ...
//
// - Style guidelines:
//
//   - Try (hard) to limit each row to 80 characters
//
//   - Code for a template should be indented with 2 spaces
//
//     - Exception to this rule is if you have only a single case, then that
//       single case can be written using no indentation
//
//       This single case can be seen as a clarification of the input to the
//       template
//
//   - Code after a case should be indented with 2 spaces if not written on the
//     same line

package CodegenFMUCpp



import interface SimCodeTV;
import interface SimCodeBackendTV;
import CodegenUtil.*;
import CodegenCpp.*; //unqualified import, no need the CodegenC is optional when calling a template; or mandatory when the same named template exists in this package (name hiding)
import CodegenCppCommon.*;
import CodegenFMU.*;
import CodegenCppInit;
import CodegenFMUCommon;
import CodegenFMU2;

template translateModel(SimCode simCode, String FMUVersion, String FMUType)
 "Generates C++ code and Makefile for compiling an FMU of a Modelica model.
  Calls CodegenCpp.translateModel for the actual model code."
::=
match simCode
case SIMCODE(modelInfo=modelInfo as MODELINFO(__)) then
  let guid = getUUIDStr()
  let target  = simulationCodeTarget()
  let stateDerVectorName = "__zDot"
  let &extraFuncs = buffer "" /*BUFD*/
  let &extraFuncsDecl = buffer "" /*BUFD*/
  let &complexStartExpressions = buffer ""

  let numRealVars = numRealvars(modelInfo)
  let numIntVars = numIntvars(modelInfo)
  let numBoolVars = numBoolvars(modelInfo)
  let numStringVars = numStringvars(modelInfo)

  let cpp = CodegenCpp.translateModel(simCode)
  let()= textFile(fmuWriteOutputHeaderFile(simCode , &extraFuncs , &extraFuncsDecl, ""),'OMCpp<%fileNamePrefix%>WriteOutput.h')
  let()= textFile(fmuModelHeaderFile(simCode, extraFuncs, extraFuncsDecl, "",guid, FMUVersion), 'OMCpp<%fileNamePrefix%>FMU.h')
  let()= textFile(fmuModelCppFile(simCode, extraFuncs, extraFuncsDecl, "",guid, FMUVersion), 'OMCpp<%fileNamePrefix%>FMU.cpp')
  let()= textFile((if isFMIVersion20(FMUVersion) then fmuModelDescriptionFileCpp(simCode, extraFuncs, extraFuncsDecl, "", guid, FMUVersion, FMUType) else CodegenCppInit.modelInitXMLFile(simCode, numRealVars, numIntVars, numBoolVars, numStringVars, FMUVersion, FMUType, guid, true, "cpp-runtime", complexStartExpressions, stateDerVectorName)), 'modelDescription.xml')
  let()= textFile(fmudeffile(simCode, FMUVersion), '<%fileNamePrefix%>.def')
  let()= textFile(fmuMakefile(target,simCode, extraFuncs, extraFuncsDecl, "", FMUVersion, "", "", "", ""), '<%fileNamePrefix%>_FMU.makefile')
  let()= textFile(fmuCalcHelperMainfile(simCode), 'OMCpp<%fileNamePrefix%>CalcHelperMain.cpp')
 ""
   // Return empty result since result written to files directly
end translateModel;

template fmuCalcHelperMainfile(SimCode simCode)
::=
  match simCode
    case SIMCODE(modelInfo = MODELINFO(__)) then
    <<
    /*****************************************************************************
    *
    * Helper file that includes all generated calculation files, except the alg loops.
    * This file is generated by the OpenModelica Compiler and produced to speed-up the compile time.
    *
    *****************************************************************************/
    #include <Core/ModelicaDefine.h>
    #include <Core/Modelica.h>
    #include <Core/System/FactoryExport.h>
    #include <Core/DataExchange/SimData.h>
    #include <Core/System/SimVars.h>
    #include <Core/System/DiscreteEvents.h>
    #include <Core/System/EventHandling.h>
    #include <Core/Utils/extension/logger.hpp>

    #include "OMCpp<%fileNamePrefix%>Types.h"
    #include "OMCpp<%fileNamePrefix%>.h"
    #include "OMCpp<%fileNamePrefix%>Functions.h"
    #include "OMCpp<%fileNamePrefix%>Jacobian.h"
    #include "OMCpp<%fileNamePrefix%>Mixed.h"
    #include "OMCpp<%fileNamePrefix%>StateSelection.h"
    #include "OMCpp<%fileNamePrefix%>WriteOutput.h"
    #include "OMCpp<%fileNamePrefix%>Initialize.h"
    #include "OMCpp<%fileNamePrefix%>FMU.h"

    #include "OMCpp<%fileNamePrefix%>AlgLoopMain.cpp"
    #include "OMCpp<%fileNamePrefix%>FactoryExport.cpp"
    #include "OMCpp<%fileNamePrefix%>Mixed.cpp"
    #include "OMCpp<%fileNamePrefix%>Functions.cpp"
    <%if(boolOr(Flags.isSet(Flags.HARDCODED_START_VALUES), Flags.isSet(Flags.GEN_DEBUG_SYMBOLS))) then
    <<
    #include "OMCpp<%fileNamePrefix%>InitializeParameter.cpp"
    #include "OMCpp<%fileNamePrefix%>InitializeAlgVars.cpp"
    #include "OMCpp<%fileNamePrefix%>InitializeAliasVars.cpp"
    >>
    %>
    #include "OMCpp<%fileNamePrefix%>InitializeExtVars.cpp"
    #include "OMCpp<%fileNamePrefix%>Initialize.cpp"
    #include "OMCpp<%fileNamePrefix%>Jacobian.cpp"
    #include "OMCpp<%fileNamePrefix%>StateSelection.cpp"
    #include "OMCpp<%fileNamePrefix%>.cpp"
    #include "OMCpp<%fileNamePrefix%>FMU.cpp"
    >>
end fmuCalcHelperMainfile;

template fmuWriteOutputHeaderFile(SimCode simCode ,Text& extraFuncs,Text& extraFuncsDecl,Text extraFuncsNamespace)
 "Overrides code for writing simulation file. FMU does not write an output file"
::=
match simCode
case SIMCODE(modelInfo=MODELINFO(__),simulationSettingsOpt = SOME(settings as SIMULATION_SETTINGS(__))) then
  <<
  #pragma once

  // Dummy code for FMU that writes no output file
  class <%lastIdentOfPath(modelInfo.name)%>WriteOutput  : public IWriteOutput,public <%lastIdentOfPath(modelInfo.name)%>StateSelection
  {
   public:
    <%lastIdentOfPath(modelInfo.name)%>WriteOutput(IGlobalSettings* globalSettings, shared_ptr<IAlgLoopSolverFactory> nonLinSolverFactory, shared_ptr<ISimData> simData, shared_ptr<ISimVars> simVars): <%lastIdentOfPath(modelInfo.name)%>StateSelection(globalSettings, nonLinSolverFactory, simData,simVars) {}
    virtual ~<%lastIdentOfPath(modelInfo.name)%>WriteOutput() {}

    virtual void writeOutput(const IWriteOutput::OUTPUT command = IWriteOutput::UNDEF_OUTPUT) {}
    virtual IHistory* getHistory() {return NULL;}

   protected:
    void initialize() {}
  };
  >>
end fmuWriteOutputHeaderFile;

template fmuModelDescriptionFileCpp(SimCode simCode,Text& extraFuncs,Text& extraFuncsDecl,Text extraFuncsNamespace,String guid, String FMUVersion, String FMUType)
 "Generates code for ModelDescription file for FMU target."
::=
match simCode
case SIMCODE(__) then
  <<
  <?xml version="1.0" encoding="UTF-8"?>
  <%
    if isFMIVersion20(FMUVersion) then CodegenFMU2.fmiModelDescription(simCode, guid)
    else fmiModelDescriptionCpp(simCode, extraFuncs ,extraFuncsDecl, extraFuncsNamespace,guid)
  %>
  >>
end fmuModelDescriptionFileCpp;

template fmiModelDescriptionCpp(SimCode simCode,Text& extraFuncs,Text& extraFuncsDecl,Text extraFuncsNamespace, String guid)
 "Generates code for ModelDescription file for FMU target."
::=
//  <%UnitDefinitions(simCode, extraFuncs, extraFuncsDecl, extraFuncsNamespace)%>
//  <%TypeDefinitions(simCode, extraFuncs, extraFuncsDecl, extraFuncsNamespace)%>
//  <%VendorAnnotations(simCode, extraFuncs, extraFuncsDecl, extraFuncsNamespace)%>
match simCode
case SIMCODE(__) then
  <<
  <fmiModelDescription
    <%CodegenCppInit.fmiModelDescriptionAttributes(simCode, guid)%>>
    <%CodegenFMUCommon.DefaultExperiment(simulationSettingsOpt)%>
    <%CodegenFMUCommon.fmiModelVariables(simCode, "1.0")%>
  </fmiModelDescription>
  >>
end fmiModelDescriptionCpp;

template fmuModelHeaderFile(SimCode simCode,Text& extraFuncs,Text& extraFuncsDecl,Text extraFuncsNamespace, String guid, String FMUVersion)
 "Generates declaration for FMU target."
::=
match simCode
case SIMCODE(modelInfo=MODELINFO(__)) then
  let modelShortName = lastIdentOfPath(modelInfo.name)
  //let modelIdentifier = System.stringReplace(dotPath(modelInfo.name), ".", "_")
  <<
  // declaration for Cpp FMU target

  class <%modelShortName%>FMU: public <%modelShortName%>Initialize {
   public:
    // constructor
    <%modelShortName%>FMU(IGlobalSettings* globalSettings,
        shared_ptr<IAlgLoopSolverFactory> nonLinSolverFactory,
        shared_ptr<ISimData> simData,
        shared_ptr<ISimVars> simVars);

    // initialization
    virtual void initialize();

    // getters for given value references
    virtual void getReal(const unsigned int vr[], int nvr, double value[]);
    virtual void getInteger(const unsigned int vr[], int nvr, int value[]);
    virtual void getBoolean(const unsigned int vr[], int nvr, int value[]);
    virtual void getString(const unsigned int vr[], int nvr, string value[]);

    // setters for given value references
    virtual void setReal(const unsigned int vr[], int nvr, const double value[]);
    virtual void setInteger(const unsigned int vr[], int nvr, const int value[]);
    virtual void setBoolean(const unsigned int vr[], int nvr, const int value[]);
    virtual void setString(const unsigned int vr[], int nvr, const string value[]);
  };

  /// create instance of <%modelShortName%>FMU
  static <%modelShortName%>FMU *createSystemFMU(IGlobalSettings *globalSettings);
  >>
end fmuModelHeaderFile;

template fmuModelCppFile(SimCode simCode,Text& extraFuncs,Text& extraFuncsDecl,Text extraFuncsNamespace, String guid, String FMUVersion)
 "Generates code for FMU target."
::=
match simCode
case SIMCODE(modelInfo=MODELINFO(__)) then
  let modelName = dotPath(modelInfo.name)
  let modelShortName = lastIdentOfPath(modelInfo.name)
  let modelLongName = System.stringReplace(modelName, ".", "_")
  let algloopfiles = (listAppend(allEquations,initialEquations) |> eqs => algloopMainfile2(eqs, simCode , &extraFuncs , &extraFuncsDecl,  extraFuncsNamespace, modelShortName) ;separator="\n")
  let solverFactoryInclude = match algloopfiles case "" then '' else
    '#include <Core/System/AlgLoopSolverFactory.h>'
  let solverFactory = match algloopfiles case "" then 'NULL' else
    'new AlgLoopSolverFactory(globalSettings, PATH(""), PATH(""))'
  <<
  // define model identifier and unique id
  #define MODEL_IDENTIFIER <%modelLongName%>
  #define MODEL_IDENTIFIER_SHORT <%modelShortName%>
  #define MODEL_CLASS <%modelShortName%>FMU
  #define MODEL_GUID "{<%guid%>}"

  <%ModelDefineData(modelInfo)%>
  #define NUMBER_OF_EVENT_INDICATORS <%CodegenFMUCommon.getNumberOfEventIndicators(simCode)%>

  <%if isFMIVersion20(FMUVersion) then
    '#include "FMU2/FMU2Wrapper.cpp"'
  else
    '#include <FMU/FMUWrapper.h>'%>
  <%if isFMIVersion20(FMUVersion) then
    '#include "FMU2/FMU2Interface.cpp"'
  else
    '#include <FMU/FMULibInterface.h>'%>

  <%solverFactoryInclude%>

  // create instance of <%modelShortName%>FMU
  <%modelShortName%>FMU *createSystemFMU(IGlobalSettings *globalSettings) {
    return new <%modelShortName%>FMU(globalSettings,
      shared_ptr<IAlgLoopSolverFactory>(<%solverFactory%>),
      shared_ptr<ISimData>(new SimData()),
      shared_ptr<ISimVars>(new SimVars(<%numRealvars(modelInfo)%>, <%numIntvars(modelInfo)%>, <%numBoolvars(modelInfo)%>, <%numStringvars(modelInfo)%>, <%getPreVarsCount(modelInfo)%>, <%numStatevars(modelInfo)%>, <%numStateVarIndex(modelInfo)%>)));
  }

  // constructor
  <%modelShortName%>FMU::<%modelShortName%>FMU(IGlobalSettings* globalSettings,
    shared_ptr<IAlgLoopSolverFactory> nonLinSolverFactory,
    shared_ptr<ISimData> simData,
    shared_ptr<ISimVars> simVars)
    : <%modelShortName%>Initialize(globalSettings, nonLinSolverFactory, simData, simVars) {
  }

  // initialization
  void <%modelShortName%>FMU::initialize() {
    <%modelShortName%>WriteOutput::initialize();
    <%modelShortName%>Initialize::initializeMemory();
    <%modelShortName%>Initialize::initializeFreeVariables();
    <%modelShortName%>Jacobian::initialize();
    <%modelShortName%>Jacobian::initializeColoredJacobianA();
  }

  // getters
  <%if isFMIVersion20(FMUVersion) then accessFunctionsFMU2(simCode, "get", modelShortName, modelInfo) else accessFunctionsFMU1(simCode, "get", modelShortName, modelInfo)%>
  // setters
  <%if isFMIVersion20(FMUVersion) then accessFunctionsFMU2(simCode, "set", modelShortName, modelInfo) else accessFunctionsFMU1(simCode, "set", modelShortName, modelInfo)%>
  >>
  // TODO:
  // <%setDefaultStartValues(modelInfo)%>
  // <%setStartValues(modelInfo)%>
  // <%setExternalFunction(modelInfo)%>
end fmuModelCppFile;

template ModelDefineData(ModelInfo modelInfo)
 "Generates global data in simulation file."
::=
match modelInfo
case MODELINFO(varInfo=VARINFO(__), vars=SIMVARS(stateVars = listStates)) then
  <<
  /* TODO: implement external functions in FMU wrapper for c++ target
  <%System.tmpTickReset(0)%>
  <%(functions |> fn => defineExternalFunction(fn) ; separator="\n")%>
  */
  >>
end ModelDefineData;

template DefineVariables(SimVar simVar, Boolean useFlatArrayNotation)
 "Generates code for defining variables in c file for FMU target. "
::=
match simVar
  case SIMVAR(__) then
  let description = if comment then '// "<%comment%>"'
  if stringEq(crefStr(name),"$dummy") then
  <<>>
  else if stringEq(crefStr(name),"der($dummy)") then
  <<>>
  else
  <<
  #define <%cref(name,useFlatArrayNotation)%>_ <%System.tmpTick()%> <%description%>
  >>
end DefineVariables;

template defineExternalFunction(Function fn)
 "Generates external function definitions."
::=
  match fn
    case EXTERNAL_FUNCTION(dynamicLoad=true) then
      let fname = extFunctionName(extName, language)
      <<
      #define $P<%fname%> <%System.tmpTick()%>
      >>
end defineExternalFunction;


template setDefaultStartValues(ModelInfo modelInfo)
 "Generates code in c file for function setStartValues() which will set start values for all variables."
::=
match modelInfo
case MODELINFO(varInfo=VARINFO(numStateVars=numStateVars, numAlgVars= numAlgVars),vars=SIMVARS(__)) then
  <<
  // Set values for all variables that define a start value
  void setDefaultStartValues(ModelInstance *comp) {
  /*
  <%vars.stateVars |> var => initValsDefault(var,"realVars",0) ;separator="\n"%>
  <%vars.derivativeVars |> var => initValsDefault(var,"realVars",numStateVars) ;separator="\n"%>
  <%vars.algVars |> var => initValsDefault(var,"realVars",intMul(2,numStateVars)) ;separator="\n"%>
  <%vars.discreteAlgVars |> var => initValsDefault(var, "realVars", intAdd(intMul(2,numStateVars), numAlgVars)) ;separator="\n"%>
  <%vars.intAlgVars |> var => initValsDefault(var,"integerVars",0) ;separator="\n"%>
  <%vars.boolAlgVars |> var => initValsDefault(var,"booleanVars",0) ;separator="\n"%>
  <%vars.stringAlgVars |> var => initValsDefault(var,"stringVars",0) ;separator="\n"%>
  <%vars.paramVars |> var => initParamsDefault(var,"realParameter") ;separator="\n"%>
  <%vars.intParamVars |> var => initParamsDefault(var,"integerParameter") ;separator="\n"%>
  <%vars.boolParamVars |> var => initParamsDefault(var,"booleanParameter") ;separator="\n"%>
  <%vars.stringParamVars |> var => initParamsDefault(var,"stringParameter") ;separator="\n"%>
  */
  }
  >>
end setDefaultStartValues;

template setStartValues(ModelInfo modelInfo)
 "Generates code in c file for function setStartValues() which will set start values for all variables."
::=
match modelInfo
case MODELINFO(varInfo=VARINFO(numStateVars=numStateVars, numAlgVars= numAlgVars),vars=SIMVARS(__)) then
  <<
  // Set values for all variables that define a start value
  void setStartValues(ModelInstance *comp) {
  /*
  <%vars.stateVars |> var => initVals(var,"realVars",0) ;separator="\n"%>
  <%vars.derivativeVars |> var => initVals(var,"realVars",numStateVars) ;separator="\n"%>
  <%vars.algVars |> var => initVals(var,"realVars",intMul(2,numStateVars)) ;separator="\n"%>
  <%vars.discreteAlgVars |> var => initVals(var, "realVars", intAdd(intMul(2,numStateVars), numAlgVars)) ;separator="\n"%>
  <%vars.intAlgVars |> var => initVals(var,"integerVars",0) ;separator="\n"%>
  <%vars.boolAlgVars |> var => initVals(var,"booleanVars",0) ;separator="\n"%>
  <%vars.stringAlgVars |> var => initVals(var,"stringVars",0) ;separator="\n"%>
  <%vars.paramVars |> var => initParams(var,"realParameter") ;separator="\n"%>
  <%vars.intParamVars |> var => initParams(var,"integerParameter") ;separator="\n"%>
  <%vars.boolParamVars |> var => initParams(var,"booleanParameter") ;separator="\n"%>
  <%vars.stringParamVars |> var => initParams(var,"stringParameter") ;separator="\n"%>
  */
  }
  >>
end setStartValues;

template initVals(SimVar var, String arrayName, Integer offset) ::=
  match var
    case SIMVAR(__) then
    if stringEq(crefStr(name),"$dummy") then
    <<>>
    else if stringEq(crefStr(name),"der($dummy)") then
    <<>>
    else
    let str = 'comp->fmuData->modelData.<%arrayName%>Data[<%intAdd(index,offset)%>].attribute.start'
    <<
      <%str%> =  comp->fmuData->localData[0]-><%arrayName%>[<%intAdd(index,offset)%>];
    >>
end initVals;

template initParams(SimVar var, String arrayName) ::=
  match var
    case SIMVAR(__) then
    let str = 'comp->fmuData->modelData.<%arrayName%>Data[<%index%>].attribute.start'
      '<%str%> = comp->fmuData->simulationInfo.<%arrayName%>[<%index%>];'
end initParams;


template initValsDefault(SimVar var, String arrayName, Integer offset) ::=
  match var
    case SIMVAR(index=index, type_=type_) then
    let str = 'comp->fmuData->modelData.<%arrayName%>Data[<%intAdd(index,offset)%>].attribute.start'
    match initialValue
      case SOME(v) then
      '<%str%> = <%initVal(v)%>;'
      case NONE() then
        match type_
          case T_INTEGER(__)
          case T_REAL(__)
          case T_ENUMERATION(__)
          case T_BOOL(__) then '<%str%> = 0;'
          case T_STRING(__) then '<%str%> = "";'
          else 'UNKOWN_TYPE'
end initValsDefault;

template initParamsDefault(SimVar var, String arrayName) ::=
  match var
    case SIMVAR(__) then
    let str = 'comp->fmuData->modelData.<%arrayName%>Data[<%index%>].attribute.start'
    match initialValue
      case SOME(v) then
      '<%str%> = <%initVal(v)%>;'
end initParamsDefault;

template initVal(Exp initialValue)
::=
  match initialValue
  case ICONST(__) then integer
  case RCONST(__) then real
  case SCONST(__) then '"<%Util.escapeModelicaStringToXmlString(string)%>"'
  case BCONST(__) then if bool then "1" else "0"
  case ENUM_LITERAL(__) then '<%index%>/*ENUM:<%dotPath(name)%>*/'
  else "*ERROR* initial value of unknown type"
end initVal;


template setExternalFunction(ModelInfo modelInfo)
 "Generates setString function for c file."
::=
match modelInfo
case MODELINFO(vars=SIMVARS(__)) then
  let externalFuncs = setExternalFunctionsSwitch(functions)
  <<
  fmiStatus setExternalFunction(ModelInstance* c, const fmiValueReference vr, const void* value){
    switch (vr) {
    /*
        <%externalFuncs%>
    */
        default:
            return fmiError;
    }
    return fmiOK;
  }

  >>
end setExternalFunction;

template setExternalFunctionsSwitch(list<Function> functions)
 "Generates external function definitions."
::=
  (functions |> fn => setExternalFunctionSwitch(fn) ; separator="\n")
end setExternalFunctionsSwitch;

template setExternalFunctionSwitch(Function fn)
 "Generates external function definitions."
::=
  match fn
    case EXTERNAL_FUNCTION(dynamicLoad=true) then
      let fname = extFunctionName(extName, language)
      <<
      case $P<%fname%> : ptr_<%fname%>=(ptrT_<%fname%>)value; break;
      >>
end setExternalFunctionSwitch;

template accessFunctionsFMU1(SimCode simCode, String direction, String modelShortName, ModelInfo modelInfo)
 "Generates getters or setters for Real, Integer, Boolean, and String."
::=
match modelInfo
case MODELINFO(vars=SIMVARS(__)) then
  let qualifier = if stringEq(direction, "set") then "const"
  <<
  <%accessVarsFunctionFMU1(simCode, direction, modelShortName, "Real", "double", "_pointerToRealVars")%>
  <%accessVarsFunctionFMU1(simCode, direction, modelShortName, "Integer", "int", "_pointerToIntVars")%>
  <%accessVarsFunctionFMU1(simCode, direction, modelShortName, "Boolean", "int", "_pointerToBoolVars")%>

  void <%modelShortName%>FMU::<%direction%>String(const unsigned int vr[], int nvr, <%qualifier%> string value[]) {
  }
  >>
end accessFunctionsFMU1;

template accessVarsFunctionFMU1(SimCode simCode, String direction, String modelShortName, String typeName, String typeImpl, String arrayName)
 "Generates get<%typeName%> or set<%typeName%> function."
::=
  let qualifier = if stringEq(direction, "set") then "const"
  <<
  void <%modelShortName%>FMU::<%direction%><%typeName%>(const unsigned int vr[], int nvr, <%qualifier%> <%typeImpl%> value[]) {
    for (int i = 0; i < nvr; i++)
    {
      <%if stringEq(direction, "get") then
        'value[i] = <%arrayName%>[vr[i]];'
        else '<%arrayName%>[vr[i]] = value[i];'
      %>
    }
  }
  >>
end accessVarsFunctionFMU1;

template accessFunctionsFMU2(SimCode simCode, String direction, String modelShortName, ModelInfo modelInfo)
 "Generates getters or setters for Real, Integer, Boolean, and String."
::=
match modelInfo
case MODELINFO(vars=SIMVARS(__)) then
  <<
  <%accessRealFunctionFMU2(simCode, direction, modelShortName, modelInfo)%>
  <%accessVarsFunctionFMU2(simCode, direction, modelShortName, "Integer", "int", vars.intAlgVars, vars.intParamVars, vars.intAliasVars)%>
  <%accessVarsFunctionFMU2(simCode, direction, modelShortName, "Boolean", "int", vars.boolAlgVars, vars.boolParamVars, vars.boolAliasVars)%>
  <%accessVarsFunctionFMU2(simCode, direction, modelShortName, "String", "string", vars.stringAlgVars, vars.stringParamVars, vars.stringAliasVars)%>
  >>
end accessFunctionsFMU2;

template accessRealFunctionFMU2(SimCode simCode, String direction, String modelShortName, ModelInfo modelInfo)
 "Generates getReal or setReal function."
::=
match modelInfo
case MODELINFO(vars=SIMVARS(__), varInfo=VARINFO(numStateVars=numStateVars, numAlgVars=numAlgVars, numDiscreteReal=numDiscreteReal, numParams=numParams)) then
  let qualifier = if stringEq(direction, "set") then "const"
  <<
  void <%modelShortName%>FMU::<%direction%>Real(const unsigned int vr[], int nvr, <%qualifier%> double value[]) {
    std::stringstream message;
    for (int i = 0; i < nvr; i++)
      switch (vr[i]) {
        <%vars.stateVars |> var => accessVecVarFMU2(direction, var, 0, "__z"); separator="\n"%>
        <%vars.derivativeVars |> var => accessVecVarFMU2(direction, var, numStateVars, "__zDot"); separator="\n"%>
        <%vars.algVars |> var => accessVarFMU2(simCode, direction, var, intMul(2, numStateVars)); separator="\n"%>
        <%vars.discreteAlgVars |> var => accessVarFMU2(simCode, direction, var, intAdd(intMul(2, numStateVars), numAlgVars)); separator="\n"%>
        <%vars.paramVars |> var => accessVarFMU2(simCode, direction, var, intAdd(intAdd(intMul(2, numStateVars), numAlgVars), numDiscreteReal)); separator="\n"%>
        <%vars.aliasVars |> var => accessVarFMU2(simCode, direction, var, intAdd(intAdd(intAdd(intMul(2, numStateVars), numAlgVars), numDiscreteReal), numParams)); separator="\n"%>
        default:
          message.str("");
          message << "<%direction%>Real with wrong value reference " << vr[i];
          throw std::invalid_argument(message.str());
      }
  }

  >>
end accessRealFunctionFMU2;

template accessVarsFunctionFMU2(SimCode simCode, String direction, String modelShortName, String typeName, String typeImpl, list<SimVar> algVars, list<SimVar> paramVars, list<SimVar> aliasVars)
 "Generates get<%typeName%> or set<%typeName%> function."
::=
  let qualifier = if stringEq(direction, "set") then "const"
  <<
  void <%modelShortName%>FMU::<%direction%><%typeName%>(const unsigned int vr[], int nvr, <%qualifier%> <%typeImpl%> value[]) {
    std::stringstream message;
    for (int i = 0; i < nvr; i++)
      switch (vr[i]) {
        <%algVars |> var => accessVarFMU2(simCode, direction, var, 0); separator="\n"%>
        <%paramVars |> var => accessVarFMU2(simCode, direction, var, listLength(algVars)); separator="\n"%>
        <%aliasVars |> var => accessVarFMU2(simCode, direction, var, intAdd(listLength(algVars), listLength(paramVars))); separator="\n"%>
        default:
          message.str("");
          message << "<%direction%><%typeName%> with wrong value reference " << vr[i];
          throw std::invalid_argument(message.str());
      }
  }
  >>
end accessVarsFunctionFMU2;

template accessVarFMU2(SimCode simCode, String direction, SimVar simVar, Integer offset)
 "Generates a case statement accessing one variable."
::=
match simVar
  case SIMVAR(__) then
  let descName = System.stringReplace(crefStrNoUnderscore(name), "$", "_D_")
  let description = if comment then '/* <%descName%> "<%comment%>" */' else '/* <%descName%> */'
  let cppName = getCppName(simCode, simVar)
  let cppSign = getCppSign(simCode, simVar)
  if stringEq(direction, "get") then
  <<
  case <%intAdd(offset, index)%>: <%description%>
    value[i] = <%cppSign%><%cppName%>; break;
  >>
  else
  <<
  case <%intAdd(offset, index)%>: <%description%>
    <%cppName%> = <%cppSign%>value[i]; break;
  >>
end accessVarFMU2;

template getCppName(SimCode simCode, SimVar simVar)
  "Get name of variable in Cpp runtime, resolving aliases"
::=
match simVar
  case SIMVAR(__) then
    let actualName = cref1(name, simCode, "", "", "", contextOther, "", "", false)
    match aliasvar
      case ALIAS(__)
      case NEGATEDALIAS(__) then
        '<%cref1(varName, simCode, "", "", "", contextOther, "", "", false)%>'
      else
        '<%actualName%>'
end getCppName;

template getCppSign(SimCode simCode, SimVar simVar)
  "Get sign of variable in Cpp runtime, resolving aliases"
::=
match simVar
  case SIMVAR(type_=type_) then
    match aliasvar
      case NEGATEDALIAS(__) then
        match type_ case T_BOOL(__) then '!' else '-'
      else ''
end getCppSign;

template accessVecVarFMU2(String direction, SimVar simVar, Integer offset, String vecName)
 "Generates a case statement accessing one variable of a vector, neglecting $dummy state."
::=
match simVar
  case SIMVAR(__) then
  let descName = System.stringReplace(crefStrNoUnderscore(name), "$", "_D_")
  let description = if comment then '/* <%descName%> "<%comment%>" */' else '/* <%descName%> */'
  if stringEq(crefStr(name), "$dummy") then
  <<>>
  else if stringEq(crefStr(name), "der($dummy)") then
  <<>>
  else if stringEq(direction, "get") then
  <<
  case <%intAdd(offset, index)%>: <%description%>
    value[i] = <%vecName%>[<%index%>]; break;
  >>
  else
  <<
  case <%intAdd(offset, index)%>: <%description%>
    <%vecName%>[<%index%>] = value[i]; break;
  >>
end accessVecVarFMU2;

template fmuMakefile(String target, SimCode simCode, Text& extraFuncs, Text& extraFuncsDecl, Text extraFuncsNamespace, String FMUVersion, String additionalLinkerFlags_GCC,
                            String additionalLinkerFlags_MSVC, String additionalCFlags_GCC, String additionalCFlags_MSVC)
 "Generates the contents of the makefile for the simulation case. Copy libexpat & correct linux fmu"
::=
match target
case "msvc" then
match simCode
case SIMCODE(modelInfo=MODELINFO(__), makefileParams=MAKEFILE_PARAMS(__), simulationSettingsOpt = sopt) then
  let dirExtra = if modelInfo.directory then '-L"<%modelInfo.directory%>"' //else ""
  let libsStr = (makefileParams.libs |> lib => lib ;separator=" ")
  let libsPos1 = if not dirExtra then libsStr //else ""
  let libsPos2 = if dirExtra then libsStr // else ""
  let ParModelicaLibs = if acceptParModelicaGrammar() then '-lOMOCLRuntime -lOpenCL' // else ""
  let extraCflags = match sopt case SOME(s as SIMULATION_SETTINGS(__)) then
    match s.method case "dassljac" then "-D_OMC_JACOBIAN "

  <<
  # Makefile generated by OpenModelica

  # Simulations use -O3 by default
  SIM_OR_DYNLOAD_OPT_LEVEL=
  MODELICAUSERCFLAGS=
  CXX=cl
  EXEEXT=.exe
  DLLEXT=.dll
  include <%makefileParams.omhome%>/include/omc/cpp/ModelicaConfig_msvc.inc
  include <%makefileParams.omhome%>/include/omc/cpp/ModelicaLibraryConfig_msvc.inc
  # /Od - Optimization disabled
  # /EHa enable C++ EH (w/ SEH exceptions)
  # /fp:except - consider floating-point exceptions when generating code
  # /arch:SSE2 - enable use of instructions available with SSE2 enabled CPUs
  # /I - Include Directories
  # /DNOMINMAX - Define NOMINMAX (does what it says)
  # /TP - Use C++ Compiler
  CFLAGS=/Od /EHa /MP /fp:except /I"<%makefileParams.omhome%>/include/omc/cpp/" /I"$(BOOST_INCLUDE)" /I"$(SUITESPARSE_INCLUDE)" /I. /DNOMINMAX /TP /DNO_INTERACTIVE_DEPENDENCY <%additionalCFlags_MSVC%>

  # /ZI enable Edit and Continue debug info
  CDFLAGS = /ZI

  # /MD - link with MSVCRT.LIB
  # /link - [linker options and libraries]
  # /LIBPATH: - Directories where libs can be found
  LDFLAGS=/MD   /link /DLL /NOENTRY /LIBPATH:"<%makefileParams.omhome%>/lib/<%getTriple()%>/omc/cpp/" /LIBPATH:"<%makefileParams.omhome%>/bin" OMCppSystem.lib OMCppBase.lib OMCppMath.lib OMCppModelicaExternalC.lib <%additionalLinkerFlags_MSVC%>

  # /MDd link with MSVCRTD.LIB debug lib
  # lib names should not be appended with a d just switch to lib/omc/cpp


  FILEPREFIX=<%fileNamePrefix%>
  FUNCTIONFILE=OMCpp<%lastIdentOfPath(modelInfo.name)%>Functions.cpp
  INITFILE=OMCpp<%fileNamePrefix%>Initialize.cpp
  FACTORYFILE=OMCpp<%fileNamePrefix%>FactoryExport.cpp
  MIXEDFILE=OMCpp<%fileNamePrefix%>Mixed.cpp
  JACOBIANFILE=OMCpp<%fileNamePrefix%>Jacobian.cpp
  WRITEOUTPUTFILE=OMCpp<%fileNamePrefix%>WriteOutput.cpp
  MAINFILE=OMCpp<%lastIdentOfPath(modelInfo.name)%><% if acceptMetaModelicaGrammar() then ".conv"%>.cpp
  MAINFILEFMU=OMCpp<%lastIdentOfPath(modelInfo.name)%>FMU.cpp
  STATESELECTIONFILE=OMCpp<%fileNamePrefix%>StateSelection.cpp
  MAINOBJ=$(MODELICA_SYSTEM_LIB)

  CALCHELPERMAINFILE=OMCpp<%fileNamePrefix%>CalcHelperMain.cpp
  ALGLOOPMAINFILE=OMCpp<%fileNamePrefix%>AlgLoopMain.cpp
  GENERATEDFILES=$(MAINFILEFMU) $(MAINFILE) $(FUNCTIONFILE) $(ALGLOOPMAINFILE)

  $(MODELICA_SYSTEM_LIB)$(DLLEXT):
  <%\t%>$(CXX) /Fe$(MODELICA_SYSTEM_LIB) $(MAINFILEFMU) $(MAINFILE) $(CALCHELPERMAINFILE) $(GENERATEDFILES) $(CFLAGS) $(LDFLAGS)
  >>
end match
case "gcc" then
match simCode
case SIMCODE(modelInfo=MODELINFO(__), makefileParams=MAKEFILE_PARAMS(__), simulationSettingsOpt = sopt) then
  let dirExtra = if modelInfo.directory then '-L"<%modelInfo.directory%>"' //else ""
  let libsExtra = (makefileParams.libs |> lib => lib ;separator=" ")
  let extraCflags = match sopt case SOME(s as SIMULATION_SETTINGS(__)) then ""
  // Note: FMI 1.0 did not distinguish modelIdentifier from fileNamePrefix
  let modelName = if isFMIVersion20(FMUVersion) then dotPath(modelInfo.name) else fileNamePrefix
  let platformstr = match makefileParams.platform case "i386-pc-linux" then 'linux32' case "x86_64-linux" then 'linux64' else '<%makefileParams.platform%>'
  let mkdir = match makefileParams.platform case "win32" then '"mkdir.exe"' else 'mkdir'
  <<
  # Makefile generated by OpenModelica
  OMHOME=<%makefileParams.omhome%>
  include $(OMHOME)/include/omc/cpp/ModelicaConfig_gcc.inc
  include $(OMHOME)/include/omc/cpp/ModelicaLibraryConfig_gcc.inc
  # Simulations use -O0 by default; can be changed to e.g. -O2 or -Ofast
  SIM_OR_DYNLOAD_OPT_LEVEL=-O0
  CC=<%makefileParams.ccompiler%>
  CXX=<%makefileParams.cxxcompiler%>
  LINK=<%makefileParams.linker%>
  EXEEXT=<%makefileParams.exeext%>
  DLLEXT=<%makefileParams.dllext%>
  CFLAGS_BASED_ON_INIT_FILE=<%extraCflags%>

  FMU_CFLAGS=$(SYSTEM_CFLAGS:-O0=$(SIM_OR_DYNLOAD_OPT_LEVEL)) -DFMU_BUILD
  CFLAGS=$(CFLAGS_BASED_ON_INIT_FILE) -Winvalid-pch $(FMU_CFLAGS) -DRUNTIME_STATIC_LINKING -I"$(OMHOME)/include/omc/cpp" -I"$(UMFPACK_INCLUDE)" -I"$(SUNDIALS_INCLUDE)" -I"$(BOOST_INCLUDE)" <%makefileParams.includes ; separator=" "%> <%additionalCFlags_GCC%>

  ifeq ($(USE_LOGGER),ON)
  $(eval CFLAGS=$(CFLAGS) -DUSE_LOGGER)
  endif

  LDFLAGS=-L"$(OMHOME)/lib/<%getTriple()%>/omc/cpp" -L"$(BOOST_LIBS)" <%additionalLinkerFlags_GCC%>
  PLATFORM="<%platformstr%>"

  CALCHELPERMAINFILE=OMCpp<%fileNamePrefix%>CalcHelperMain.cpp

  # CVode can be used for Co-Simulation FMUs, Kinsol is available to handle non linear equation systems
  OMCPP_SOLVER_LIBS=-lOMCppNewton_static
  ifeq ($(USE_FMU_SUNDIALS),ON)
  $(eval OMCPP_SOLVER_LIBS=$(OMCPP_SOLVER_LIBS) -lOMCppKinsol_static $(SUNDIALS_LIBRARIES))
  $(eval CFLAGS=-DENABLE_SUNDIALS_STATIC $(CFLAGS))
  endif

  CPPFLAGS = $(CFLAGS)

  OMCPP_LIBS=-Wl,--start-group -lOMCppSystem_FMU_static -Wl,--end-group -lOMCppDataExchange_static $(OMCPP_SOLVER_LIBS) -lOMCppSolver_static -lOMCppMath_static -lOMCppModelicaUtilities_static -lOMCppExtensionUtilities_static -lOMCppFMU_static
  MODELICA_EXTERNAL_LIBS=-lModelicaExternalC -lModelicaStandardTables -L$(LAPACK_LIBS) $(LAPACK_LIBRARIES)
  LIBS= $(OMCPP_LIBS) $(MODELICA_EXTERNAL_LIBS) $(BASE_LIB)

  # need boost system lib prior to C++11
  ifneq ($(findstring USE_CPP_ELEVEN,$(CFLAGS)),USE_CPP_ELEVEN)
    $(eval LIBS= $(LIBS) -l$(BOOST_SYSTEM_LIB))
  endif

  CPPFILES=$(CALCHELPERMAINFILE)
  OFILES=$(CPPFILES:.cpp=.o)

  .PHONY: <%modelName%>.fmu $(CPPFILES) clean

  <%modelName%>.fmu: $(OFILES)
  <%\t%>$(CXX) -shared -o <%fileNamePrefix%>$(DLLEXT) $(OFILES) $(LDFLAGS) $(LIBS)
  <%\t%>rm -rf binaries
  <%\t%><%mkdir%> -p "binaries/$(PLATFORM)"
  <%\t%>cp <%fileNamePrefix%>$(DLLEXT) "binaries/$(PLATFORM)/"
  ifeq ($(USE_FMU_SUNDIALS),ON)
  <%\t%>rm -rf documentation
  <%\t%><%mkdir%> -p "documentation"
  <%\t%>cp $(SUNDIALS_LIBRARIES_KINSOL) "binaries/$(PLATFORM)/"
  <%\t%>cp $(OMHOME)/share/omc/runtime/cpp/licenses/sundials.license "documentation/"
  endif
  <%\t%>rm -f <%modelName%>.fmu
  ifeq ($(USE_FMU_SUNDIALS),ON)
  <%\t%>zip -r "<%modelName%>.fmu" modelDescription.xml binaries documentation
  <%\t%>rm -rf documentation
  else
  <%\t%>zip -r "<%modelName%>.fmu" modelDescription.xml binaries
  endif
  <%\t%>rm -rf binaries

  clean:
  <%\t%>rm $(SRC) <%fileNamePrefix%>$(DLLEXT)

  >>
end fmuMakefile;

annotation(__OpenModelica_Interface="backend");
end CodegenFMUCpp;

// vim: filetype=susan sw=2 sts=2
