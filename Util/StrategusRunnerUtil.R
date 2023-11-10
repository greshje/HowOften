# ---
#
# global variables and functions for this project
#
# ---

StrategusRunnerUtil <- {}

# sqlRenderer temp emulation schema
StrategusRunnerUtil$setSqlRendererTempEmulationSchema <- function(schemaName) {
  options(sqlRenderTempEmulationSchema = schemaName)
}

# file locations
StrategusRunnerUtil$resultsLocation <- NULL
StrategusRunnerUtil$outputLocation <- NULL
StrategusRunnerUtil$loggingOutputLocation <- NULL

# database schemas
StrategusRunnerUtil$workDatabaseSchema <- NULL
StrategusRunnerUtil$cohortTableName <- NULL
StrategusRunnerUtil$cdmDatabaseSchema <- NULL

# minimum number of cells
StrategusRunnerUtil$minCellCount <- NULL

# connection info
StrategusRunnerUtil$dbms = NULL
StrategusRunnerUtil$pathToDriver = NULL

# references to stored values (these can be anything)
StrategusRunnerUtil$keyringName <- NULL
StrategusRunnerUtil$connectionDetailsReference <- NULL

# connection and execution details
StrategusRunnerUtil$connectionDetails <- NULL
StrategusRunnerUtil$executionSettings <- NULL

# ---
#
# show versions
#
# ---

StrategusRunnerUtil$showVersions <- function() {
  # show versions
  R.Version()
  system("java -version")
  getwd()
  # show the module list
  Strategus::getModuleList()
}

# ---
#
# library functions
#
# ---

StrategusRunnerUtil$installFromCran <- function(pkgName, pkgVersion) {
  if (requireNamespace(pkgName, quietly = TRUE) == TRUE && packageVersion(pkgName) == pkgVersion) {
    print(paste("Correct version of package already installed: ", pkgName, pkgVersion, sep = " "))
  } else {  
    print(paste("* * * Installing from CRAN:", pkgName, pkgVersion, sep = " "))
    if(pkgName == "remotes") {
      install.packages("remotes", INSTALL_opts = "--no-multiarch")  
    } else {
      remotes::install_version(pkgName, version = pkgVersion, upgrade = FALSE, INSTALL_opts = "--no-multiarch", )
    }
  }
}

StrategusRunnerUtil$installFromGithub <- function(pkgName, pkgVersion) {
  if (requireNamespace(pkgName, quietly = TRUE) == TRUE && packageVersion(pkgName) == pkgVersion) {
    print(paste("Correct version of package already installed: ", pkgName, pkgVersion, sep = " "))
  } else {  
    print(paste("* * * Installing from GitHub:", pkgName, pkgVersion, sep = " "))
    remotes::install_github(pkgName, ref=pkgVersion, upgrade = FALSE, INSTALL_opts = "--no-multiarch")
  }
}

StrategusRunnerUtil$checkPackageVersion <- function(packageName) {
  available_packages <- available.packages()
  latest_keyring_version <- available_packages[packageName, "Version"]
  print(latest_keyring_version)  
}

StrategusRunnerUtil$removePackage <- function(pkgName) {
  required <- requireNamespace(pkgName, quietly = TRUE)
  print(paste(pkgName, required, sep = ": "))
  if (required) {
    remove.packages(pkgName)
  }
}

# ---
#
# remove libraries that are installed here
#
# ---

StrategusRunnerUtil$removePackagesInstalledHere <- function() {
  # from cran
  StrategusRunnerUtil$removePackage("keyring")
  StrategusRunnerUtil$removePackage("usethis")
  StrategusRunnerUtil$removePackage("DatabaseConnector")
  # from github
  StrategusRunnerUtil$removePackage("Strategus")
  StrategusRunnerUtil$removePackage("CohortGenerator")
  StrategusRunnerUtil$removePackage("CirceR")
}

# ---
#
# install and load libraries
#
# ---

StrategusRunnerUtil$initLibs <- function() {
  # installs from cran
  StrategusRunnerUtil$installFromCran("remotes", "2.4.2.1")
  StrategusRunnerUtil$installFromCran("keyring", "1.3.1")
  StrategusRunnerUtil$installFromCran("usethis", "2.2.2")
  StrategusRunnerUtil$installFromCran("DatabaseConnector", "6.2.4")
  
  # installs from github
  StrategusRunnerUtil$installFromGithub("OHDSI/Strategus", "v0.1.0")
  StrategusRunnerUtil$installFromGithub("OHDSI/CohortGenerator", "v0.8.1")
  StrategusRunnerUtil$installFromGithub("OHDSI/CirceR", "v1.3.1")
  
  library(remotes)
  library(keyring)
  library(usethis)
  library(Strategus)
  library(DatabaseConnector)
  library(CohortGenerator)
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
# ---

# ---
#
# store keyring
#
# ---

StrategusRunnerUtil$storeKeyRing <- function() {
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
  keyringName <- StrategusRunnerUtil$keyringName
  allKeyrings <- keyring::keyring_list()
  if (!(keyringName %in% allKeyrings$keyring)) {
    keyring::keyring_create(keyring = keyringName, password = Sys.getenv("STRATEGUS_KEYRING_PASSWORD"))
  } else {
    print("Keyring already exists. You do not need to create it again.")
  }
  
  # excecute this for each connectionDetails/ConnectionDetailsReference you are going to use
  Strategus::storeConnectionDetails(
    connectionDetails = StrategusRunnerUtil$connectionDetails,
    connectionDetailsReference = StrategusRunnerUtil$connectionDetailsReference,
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

StrategusRunnerUtil$createExecutionsSettings <- function() {
  executionSettings <- Strategus::createCdmExecutionSettings(
    connectionDetailsReference = StrategusRunnerUtil$connectionDetailsReference,
    workDatabaseSchema = StrategusRunnerUtil$workDatabaseSchema,
    cdmDatabaseSchema = StrategusRunnerUtil$cdmDatabaseSchema,
    cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = StrategusRunnerUtil$cohortTableName),
    workFolder = file.path(StrategusRunnerUtil$outputLocation, StrategusRunnerUtil$connectionDetailsReference, "strategusWork"),
    resultsFolder = file.path(StrategusRunnerUtil$outputLocation, StrategusRunnerUtil$connectionDetailsReference, "strategusOutput"),
    minCellCount = StrategusRunnerUtil$minCellCount
  )
  return(executionSettings)
}

# ---
#
# function to test the connectionDetails
#
# ---

StrategusRunnerUtil$testConnection <- function() {
  testConnection <- DatabaseConnector::connect(StrategusRunnerUtil$connectionDetails)
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

StrategusRunnerUtil$initStratagus <- function() {
  StrategusRunnerUtil$storeKeyRing()
  StrategusRunnerUtil$executionSettings <- StrategusRunnerUtil$createExecutionsSettings()
  StrategusRunnerUtil$testConnection()
  return(StrategusRunnerUtil$executionSettings)
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
  
  StrategusRunnerUtil$analysisSpecifications <- ParallelLogger::loadSettingsFromJson(fileName = analysisFile)
  
  # execute stratagus
  Strategus::execute(
    analysisSpecifications = StrategusRunnerUtil$analysisSpecifications,
    executionSettings = StrategusRunnerUtil$executionSettings,
    executionScriptFolder = file.path(
      StrategusRunnerUtil$outputLocation, 
      StrategusRunnerUtil$connectionDetailsReference, 
      "strategusExecution"),
    keyringName = keyringName
  )
  
  # copy Results to final location
  resultsDir <- file.path(
    resultsLocation, 
    analysisName, 
    StrategusRunnerUtil$connectionDetailsReference)
  if (dir.exists(resultsDir)) {
    unlink(resultsDir, recursive = TRUE)
  }
  dir.create(file.path(resultsDir), recursive = TRUE)
  file.copy(
    file.path(StrategusRunnerUtil$outputLocation, StrategusRunnerUtil$connectionDetailsReference, "strategusOutput"),
    file.path(resultsDir), recursive = TRUE
  )
  return(NULL)
}



