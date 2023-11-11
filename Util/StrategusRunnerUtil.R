# ---
#
# global variables and functions for this project
#
# ---

StrategusRunnerUtil <- {}

source("./Util/lib/StrategusRunnerLibUtil.R")

# ---
#
# stratagus keyring stuff
#
# Basically, just use usethis::edit_r_environ() to check your .Renviron file.  
# It should include something like the following
#
# STRATEGUS_KEYRING_PASSWORD='sos'
# GITHUB_PAT='ghp_ThisIsMyGithubPersonalAccessTokenM2bgp91'
# INSTANTIATED_MODULES_FOLDER='C:/_YES/_STRATEGUS/HowOften/Modules'
#
# ---

# ---
#
# store keyring
#
# ---

StrategusRunnerUtil$storeKeyRing <- function(dvo) {
  class(dvo) <- "StrategusRunnerDvo"
  if (Sys.getenv("STRATEGUS_KEYRING_PASSWORD") == "") {
    # set keyring password by adding STRATEGUS_KEYRING_PASSWORD='sos' to renviron
    usethis::edit_r_environ()
    # then add STRATEGUS_KEYRING_PASSWORD='yourPassword', save and close
    # Restart your R Session to confirm it worked
    stop("Please add STRATEGUS_KEYRING_PASSWORD='yourPassword' to your .Renviron file
       via usethis::edit_r_environ() as instructed, save and then restart R session")
  }
  
  if (Sys.getenv("INSTANTIATED_MODULES_FOLDER") == "") {
    # set a env var to a path to cache Strategus modules
    usethis::edit_r_environ()
    # then add INSTANTIATED_MODULES_FOLDER='path/to/module/cache', save and close
    # Restart your R Session to confirm it worked
    stop("Please add INSTANTIATED_MODULES_FOLDER='{path to module cache folder}' to your .Renviron file
       via usethis::edit_r_environ() as instructed, save and then restart R session")
  }
  
  # Create the keyring if it does not exist.
  keyringName <- dvo$keyringName
  allKeyrings <- keyring::keyring_list()
  if (!(keyringName %in% allKeyrings$keyring)) {
    keyring::keyring_create(keyring = keyringName, password = Sys.getenv("STRATEGUS_KEYRING_PASSWORD"))
  } else {
    print("Keyring already exists. You do not need to create it again.")
  }
  
  # excecute this for each connectionDetails/ConnectionDetailsReference you are going to use
  Strategus::storeConnectionDetails(
    connectionDetails = dvo$connectionDetails,
    connectionDetailsReference = dvo$connectionDetailsReference,
    keyringName = keyringName
  )
  
}

# --- 
#
# create a database keyring if it doesn't exist
# 
# ---

StrategusRunnerUtil$createDatabaseKeyRing <- function(kr_name, kr_service, kr_username) {
  kb <- keyring::backend_file$new()
  # Get a list of existing keyrings
  existing_keyrings <- kb$keyring_list()
  # Check if the keyring already exists
  if (!(kr_name %in% existing_keyrings$keyring)) {
    kb$keyring_create(kr_name)
    kb$set(kr_service, username = kr_username, keyring = kr_name)
    kb$keyring_lock(kr_name)
  } else {
    print(paste("Keyring already exists for: ", kr_name))
  }
}

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
# stratagus keyring stuff
#
# Basically, just use usethis::edit_r_environ() to check your .Renviron file.  
# It should include something like the following
#
# STRATEGUS_KEYRING_PASSWORD='sos'
# GITHUB_PAT='ghp_ThisIsMyGithubPersonalAccessTokenM2bgp91'
# INSTANTIATED_MODULES_FOLDER='C:/_YES/_STRATEGUS/HowOften/Modules'
#
# Restart R after editing .Renviron for the changes to take effect.  
#
# ---

StrategusRunnerUtil$checkstrategusKeyring <- function() {
  if(
    Sys.getenv("STRATEGUS_KEYRING_PASSWORD") == "" || 
    Sys.getenv("INSTANTIATED_MODULES_FOLDER") == "" || 
    Sys.getenv("GITHUB_PAT") == ""
  ) {
    usethis::edit_r_environ()
    stop("Set .Renviron before running this script")
  }
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



