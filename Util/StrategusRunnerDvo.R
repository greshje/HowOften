# ---
#
# init libraries
# 
# ---

source("./Util/StrategusRunnerUtil.R")
StrategusRunnerUtil$initLibs()

# ---
#
# Definition of StrategusRunnerDvo
#
# ---

StrategusRunnerDvo <- R6Class(
  classname = "StrategusRunnerDvo",
  public = list(
    # file locations
    resultsLocation = NULL,
    outputLocation = NULL,
    loggingOutputLocation = NULL,
    
    # database schemas
    workDatabaseSchema = NULL,
    cohortTableName = NULL,
    cdmDatabaseSchema = NULL,
    
    # minimum number of cells
    minCellCount = NULL,
    
    # connection info
    dbms = NULL,
    pathToDriver = NULL,
    
    # references to stored values (these can be anything)
    keyringName = NULL,
    connectionDetailsReference = NULL,
    
    # connection and execution details
    connectionDetails = NULL,
    executionSettings = NULL,
    
    # sqlRenderer temp emulation schema
    setSqlRendererTempEmulationSchema = function(schemaName) {
      options(sqlRenderTempEmulationSchema = schemaName)
    }
  )
)

