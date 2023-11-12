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
    sqlRenderTempEmulationSchema = NULL,
    
    # minimum number of cells
    minCellCount = NULL,
    
    # connection info
    dbms = NULL,
    pathToDriver = NULL,
    
    # references to stored values (these can be anything)
    connectionDetailsReference = NULL,
    
    # connection and execution details
    connectionDetails = NULL,
    executionSettings = NULL,
    
    # init
    init = function(schemaName) {
      options(sqlRenderTempEmulationSchema = self$sqlRenderTempEmulationSchema)
    }
    
  )
)

