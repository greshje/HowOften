# ---
#
# Definition of StrategusRunnerDvo
#
# ---

source("./impl/lib/StrategusRunnerLibUtil.R")
library(R6)

StrategusRunnerDvo <- R6Class (
  classname = "StrategusRunnerDvo",
  public = list(

    # data source
    dataPartnerName = NULL,

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
    
    # cdm connection info
    dbms = NULL,
    pathToDriver = NULL,
    cdmConnectionDetails = NULL,

    # connection and execution details
    executionSettings = NULL,
    
    # init
    init = function(schemaName) {
      options(sqlRenderTempEmulationSchema = self$sqlRenderTempEmulationSchema)
    }
    
  )
)

