# ---
#
# This script consolidates the utilities functions of the other scripts
# here for one stop shopping.  
#
# ---

# ---
#
# dependencies
#
# ---

source("./impl/lib/StrategusRunnerLibUtil.R")
source("./impl/connectioncache/StrategusRunnerConnectionCacheUtil.R")
source("./01-RunStudy/configuration/ConnectionDetailsFactoryForCdm.R")
source("./impl/database/StrategusRunnerConnectionKeyringFactory.R")
source("./impl/runstudy/RunParams.R")

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
  options(sqlRenderTempEmulationSchema = RunConfiguration$sqlRenderTempEmulationSchema)
  # echo stratagus module list
  writeLines("STRATEGUS MODULE LIST:")
  print(Strategus::getModuleList())
}

# ---
#
# function to create stratagus settings
#
# ---

StrategusRunnerUtil$createExecutionsSettings <- function() {
  RunConfiguration$executionSettings <- Strategus::createCdmExecutionSettings(
    connectionDetailsReference = RunConfiguration$dataPartnerName,
    workDatabaseSchema = RunConfiguration$workDatabaseSchema,
    cdmDatabaseSchema = RunConfiguration$cdmDatabaseSchema,
    cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = RunConfiguration$cohortTableName),
    workFolder = file.path(RunConfiguration$outputLocation, RunConfiguration$dataPartnerName, "strategusWork"),
    resultsFolder = file.path(RunConfiguration$outputLocation, RunConfiguration$dataPartnerName, "strategusOutput"),
    minCellCount = RunConfiguration$minCellCount
  )
}

# ---
#
# function to init stratagus
#
# ---

StrategusRunnerUtil$initStratagus <- function(runParams) {
  StrategusRunnerUtil$storeConnectionDetails(runParams)
  RunConfiguration$executionSettings <- StrategusRunnerUtil$createExecutionsSettings()
  StrategusRunnerUtil$testConnection(runParams)
  return(RunConfiguration$executionSettings)
}

# ---
#
# function to execute stratagus
#
# ---

StrategusRunnerUtil$executeAnalysis <- function (
    analysisFile, 
    analysisName) {

  executionSettings <- StrategusRunnerUtil$createExecutionsSettings()
  outputLocation <- RunConfiguration$outputLocation
  resultsLocation <- RunConfiguration$resultsLocation
  dataPartnerName <- RunConfiguration$dataPartnerName
  
  # create the connection details
  RunConfiguration$cdmConnectionDetails <- StrategusRunnerUtil$createCdmConnectionDetails()
  # init the environment (see functionsForInit.R file for details)
  executionSettings <- StrategusRunnerUtil$initStratagus(RunConfiguration)
  RunConfiguration$init(analysisName)
  # load the json specification for the study
  analysisSpecifications <- ParallelLogger::loadSettingsFromJson(fileName = analysisFile)
  
  # execute stratagus
  Strategus::execute(
    analysisSpecifications = analysisSpecifications,
    executionSettings = executionSettings,
    executionScriptFolder = file.path(
      outputLocation, 
      dataPartnerName, 
      "strategusExecution"),
    keyringName = StrategusRunnerUtil$keyringName
  )

  # copy Results to final location
  resultsDir <- file.path (
    resultsLocation, 
    analysisName, 
    RunConfiguration$dataPartnerName)
  if (dir.exists(resultsDir)) {
    unlink(resultsDir, recursive = TRUE)
  }
  dir.create(file.path(resultsDir), recursive = TRUE)
  file.copy(
    file.path(RunConfiguration$outputLocation, RunConfiguration$dataPartnerName, "strategusOutput"),
    file.path(resultsDir), recursive = TRUE
  )
  
  return("Execution completed ! ! !")
  
}

# ---
#
# function to test the connectionDetails
#
# ---

StrategusRunnerUtil$testConnection <- function(runParams) {
  testConnection <- DatabaseConnector::connect(runParams$cdmConnectionDetails)
  success <- DatabaseConnector::querySql(testConnection, "select 1 as one")
  print(success)
  DatabaseConnector::disconnect(testConnection)
  if (success != 1) {
    stop("We were not able to create the database connection for the given connectionDetails.")
  } else {
    print("CONNECTION TEST PASSED")
  }
}





