# ---
#
# global variables and functions for this project
#
# ---

StrategusRunnerUtil <- {}

source("./Util/lib/StrategusRunnerLibUtil.R")
source("./Util/keyring/StrategusRunnerKeyringUtil.R")
source("./Util/database/StrategusConnectionDetailsFactory.R")

# ---
#
# function to create stratagus settings
#
# ---

StrategusRunnerUtil$createExecutionsSettings <- function(dvo) {
  class(dvo) <- "StrategusRunnerDvo"
  executionSettings <- Strategus::createCdmExecutionSettings(
    connectionDetailsReference = dvo$connectionDetailsReference,
    workDatabaseSchema = dvo$workDatabaseSchema,
    cdmDatabaseSchema = dvo$cdmDatabaseSchema,
    cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = dvo$cohortTableName),
    workFolder = file.path(dvo$outputLocation, dvo$connectionDetailsReference, "strategusWork"),
    resultsFolder = file.path(dvo$outputLocation, dvo$connectionDetailsReference, "strategusOutput"),
    minCellCount = dvo$minCellCount
  )
  return(executionSettings)
}

# ---
#
# function to init stratagus
#
# ---

StrategusRunnerUtil$initStratagus <- function(dvo) {
  class(dvo) <- "StrategusRunnerDvo"
  StrategusRunnerUtil$storeKeyRing(dvo)
  dvo$executionSettings <- StrategusRunnerUtil$createExecutionsSettings(dvo)
  StrategusRunnerUtil$testConnection(dvo)
  return(dvo$executionSettings)
}

# ---
#
# function to execute stratagus
#
# ---

StrategusRunnerUtil$executeAnalysis <- function (
    analysisFile, 
    executionSettings, 
    analysisName, 
    outputLocation, 
    resultsLocation, 
    keyringName) {
  
  analysisSpecifications <- ParallelLogger::loadSettingsFromJson(fileName = analysisFile)
  
  # execute stratagus
  Strategus::execute(
    analysisSpecifications = analysisSpecifications,
    executionSettings = dvo$executionSettings,
    executionScriptFolder = file.path(
      dvo$outputLocation, 
      dvo$connectionDetailsReference, 
      "strategusExecution"),
    keyringName = keyringName
  )
  
  # copy Results to final location
  resultsDir <- file.path(
    resultsLocation, 
    analysisName, 
    dvo$connectionDetailsReference)
  if (dir.exists(resultsDir)) {
    unlink(resultsDir, recursive = TRUE)
  }
  dir.create(file.path(resultsDir), recursive = TRUE)
  file.copy(
    file.path(dvo$outputLocation, dvo$connectionDetailsReference, "strategusOutput"),
    file.path(resultsDir), recursive = TRUE
  )
  return(NULL)
}

# ---
#
# function to test the connectionDetails
#
# ---

StrategusRunnerUtil$testConnection <- function(dvo) {
  class(dvo) <- "StrategusRunnerDvo"
  testConnection <- DatabaseConnector::connect(dvo$connectionDetails)
  success <- DatabaseConnector::querySql(testConnection, "select 1 as one")
  success
  DatabaseConnector::disconnect(testConnection)
  if (success != 1) {
    stop("We were not able to create the database connection for the given connectionDetails.")
  } else {
    print("CONNECTION TEST PASSED")
  }
}




