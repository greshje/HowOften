# ---
#
# variables and functions for this project
#
# ---

# ---
#
# dependencies
#
# ---

source("./Util/lib/StrategusRunnerLibUtil.R")
source("./Util/connectioncache/StrategusRunnerConnectionCacheUtil.R")
source("./Util/database/StrategusRunnerConnectionDetailsFactory.R")
source("./Util/database/StrategusRunnerConnectionKeyringFactory.R")
source("./Util/dvo/StrategusRunnerDvo.R")
source("./RunStrategusStudy/RunStrategusConfiguration.R")

StrategusRunnerUtil <- {}

# ---
#
# global variables
#
# ---

StrategusRunnerUtil$keyringName <- "org.ohdsi.strategus.ergasia"

# ------------------------------------------------------------------------------
# functionality from util classes
# ------------------------------------------------------------------------------

# ---
#
# libraries functionality
#
# ---

srlu <- StrategusRunnerLibUtil
StrategusRunnerUtil$showVersions <- srlu$showVersions
StrategusRunnerUtil$packageVersionExists <- srlu$packageVersionExists
StrategusRunnerUtil$installFromCran <- srlu$installFromCran
StrategusRunnerUtil$installFromGithub <- srlu$checkPackageVersion
StrategusRunnerUtil$checkPackageVersion <- srlu$checkPackageVersion
StrategusRunnerUtil$removePackage <- srlu$removePackage
StrategusRunnerUtil$removePackagesInstalledHere <- srlu$removePackagesInstalledHere
StrategusRunnerUtil$initLibs <- srlu$initLibs

# ---
#
# database keyring functionality
#
# ---

srkf <- StrategusRunnerConnectionKeyringFactory
StrategusRunnerUtil$createDatabaseKeyRing <- srkf$createDatabaseKeyRing
StrategusRunnerUtil$addUserToKeyring <- srkf$addUserToKeyring
StrategusRunnerUtil$deleteKeyring <- srkf$deleteKeyring
StrategusRunnerUtil$getExistingKeyrings <- srkf$getExistingKeyrings
StrategusRunnerUtil$getPasswordFromKeyring <- srkf$getPassword

# ---
#
# connection details
#
# ---

srcdu <- StrategusRunnerConnectionDetailsUtil
StrategusRunnerUtil$createCdmConnectionDetails <- srcdu$createCdmConnectionDetails

# ---
#
# connection cache
#
# ---

srccu <- StrategusRunnerConnectionCacheUtil
StrategusRunnerUtil$storeConnectionDetails <- srccu$storeConnectionDetails
StrategusRunnerUtil$checkEnv <- srccu$checkEnv

# ------------------------------------------------------------------------------
# implementation
# ------------------------------------------------------------------------------

# ---
#
# initialize configuration for the run
#
# ---

StrategusRunnerUtil$initRun <- function() {
  # initialize libraries/packages
  StrategusRunnerUtil$initLibs()
  # init strategus keyring stuff
  StrategusRunnerUtil$checkEnv()
  # configuration
  dvo <- StrategusRunnerDvo$new()
  dvo <- RunStrategusConfiguration$configure(dvo)
  dvo$init()
  return(dvo)
}

# ---
#
# function to create stratagus settings
#
# ---

StrategusRunnerUtil$createExecutionsSettings <- function(dvo) {
  class(dvo) <- "StrategusRunnerDvo"
  executionSettings <- Strategus::createCdmExecutionSettings(
    connectionDetailsReference = dvo$cdmConnectionDetailsReference,
    workDatabaseSchema = dvo$workDatabaseSchema,
    cdmDatabaseSchema = dvo$cdmDatabaseSchema,
    cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = dvo$cohortTableName),
    workFolder = file.path(dvo$outputLocation, dvo$cdmConnectionDetailsReference, "strategusWork"),
    resultsFolder = file.path(dvo$outputLocation, dvo$cdmConnectionDetailsReference, "strategusOutput"),
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
  StrategusRunnerUtil$storeConnectionDetails(dvo)
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
    analysisName, 
    dvo) {

  class(dvo) <- "StrategusRunnerDvo"
  executionSettings <- dvo$executionSettings
  outputLocation <- dvo$outputLocation
  resultsLocation <- dvo$resultsLocation
    
  # create the connection details
  dvo$cdmConnectionDetails <- StrategusRunnerUtil$createCdmConnectionDetails()
  # init the environment (see functionsForInit.R file for details)
  dvo$executionSettings <- StrategusRunnerUtil$initStratagus(dvo)
  # load the json specification for the study
  analysisSpecifications <- ParallelLogger::loadSettingsFromJson(fileName = analysisFile)
  
  # execute stratagus
  Strategus::execute(
    analysisSpecifications = analysisSpecifications,
    executionSettings = dvo$executionSettings,
    executionScriptFolder = file.path(
      dvo$outputLocation, 
      dvo$cdmConnectionDetailsReference, 
      "strategusExecution"),
    keyringName = StrategusRunnerUtil$keyringName
  )
  
  # copy Results to final location
  resultsDir <- file.path (
    resultsLocation, 
    analysisName, 
    dvo$cdmConnectionDetailsReference)
  if (dir.exists(resultsDir)) {
    unlink(resultsDir, recursive = TRUE)
  }
  dir.create(file.path(resultsDir), recursive = TRUE)
  file.copy(
    file.path(dvo$outputLocation, dvo$cdmConnectionDetailsReference, "strategusOutput"),
    file.path(resultsDir), recursive = TRUE
  )
  
  return("Execution completed ! ! !")
  
}

# ---
#
# function to test the connectionDetails
#
# ---

StrategusRunnerUtil$testConnection <- function(dvo) {
  class(dvo) <- "StrategusRunnerDvo"
  testConnection <- DatabaseConnector::connect(dvo$cdmConnectionDetails)
  success <- DatabaseConnector::querySql(testConnection, "select 1 as one")
  success
  DatabaseConnector::disconnect(testConnection)
  if (success != 1) {
    stop("We were not able to create the database connection for the given connectionDetails.")
  } else {
    print("CONNECTION TEST PASSED")
  }
}





