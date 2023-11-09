# ---
#
# functionsForInit.R
# 
# ---

# ---
#
# versions
#
# ---

R.Version()
system("java -version")
getwd()

# ---
#
# install functions
#
# ---

installFromCran <- function(pkgName, pkgVersion) {
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

installFromGithub <- function(pkgName, pkgVersion) {
  if (requireNamespace(pkgName, quietly = TRUE) == TRUE && packageVersion(pkgName) == pkgVersion) {
    print(paste("Correct version of package already installed: ", pkgName, pkgVersion, sep = " "))
  } else {  
    print(paste("* * * Installing from GitHub:", pkgName, pkgVersion, sep = " "))
    remotes::install_github(pkgName, ref=pkgVersion, upgrade = FALSE, INSTALL_opts = "--no-multiarch")
  }
}

checkPackageVersion <- function(packageName) {
  available_packages <- available.packages()
  latest_keyring_version <- available_packages[packageName, "Version"]
  print(latest_keyring_version)  
}

removePackage <- function(pkgName) {
  required <- requireNamespace(pkgName, quietly = TRUE)
  print(paste(pkgName, required, sep = ": "))
  if (required) {
    remove.packages(pkgName)
  }
}

# ---
#
# detach
# A function to remove the packages that are installed here.  
#
# ---

removePackagesInstalledHere <- function() {
  # from cran
  removePackage("keyring")
  removePackage("usethis")
  removePackage("DatabaseConnector")
  # from github
  removePackage("Strategus")
  removePackage("CohortGenerator")
  removePackage("CirceR")
}

# ---
#
# installs
#
# ---

# installs from cran
installFromCran("remotes", "2.4.2.1")
installFromCran("keyring", "1.3.1")
installFromCran("usethis", "2.2.2")
installFromCran("DatabaseConnector", "6.2.4")

# installs from github
installFromGithub("OHDSI/Strategus", "v0.1.0")
installFromGithub("OHDSI/CohortGenerator", "v0.8.1")
installFromGithub("OHDSI/CirceR", "v1.3.1")

library(remotes)
library(keyring)
library(usethis)
library(Strategus)
library(DatabaseConnector)
library(CohortGenerator)

# show the module list
Strategus::getModuleList()

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

storeKeyRing <- function() {
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
  keyringName <- keyringName
  allKeyrings <- keyring::keyring_list()
  if (!(keyringName %in% allKeyrings$keyring)) {
    keyring::keyring_create(keyring = keyringName, password = Sys.getenv("STRATEGUS_KEYRING_PASSWORD"))
  } else {
    print("Keyring already exists. You do not need to create it again.")
  }
  
  # excecute this for each connectionDetails/ConnectionDetailsReference you are going to use
  Strategus::storeConnectionDetails(
    connectionDetails = connectionDetails,
    connectionDetailsReference = connectionDetailsReference,
    keyringName = keyringName
  )
  
}

# function to create a database keyring if it doesn't exist
createDatabaseKeyRing <- function(kr_name, kr_service, kr_username) {
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

createExecutionsSettings <- function() {
  executionSettings <- Strategus::createCdmExecutionSettings(
    connectionDetailsReference = connectionDetailsReference,
    workDatabaseSchema = workDatabaseSchema,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTableName),
    workFolder = file.path(outputLocation, connectionDetailsReference, "strategusWork"),
    resultsFolder = file.path(outputLocation, connectionDetailsReference, "strategusOutput"),
    minCellCount = minCellCount
  )
  return(executionSettings)
}

# ---
#
# function to test the connectionDetails
#
# ---

testConnection <- function() {
  testConnection <- DatabaseConnector::connect(connectionDetails)
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

initStratagus <- function() {
  storeKeyRing()
  executionSettings <- createExecutionsSettings()
  testConnection()
  return(executionSettings)
}

# ---
#
# function to execute stratagus
#
# ---

executeAnalysis <- function (
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
    executionSettings = executionSettings,
    executionScriptFolder = file.path(outputLocation, connectionDetailsReference, "strategusExecution"),
    keyringName = keyringName
  )
  
  # copy Results to final location
  resultsDir <- file.path(resultsLocation, analysisName, connectionDetailsReference)
  if (dir.exists(resultsDir)) {
    unlink(resultsDir, recursive = TRUE)
  }
  dir.create(file.path(resultsDir), recursive = TRUE)
  file.copy(
    file.path(outputLocation, connectionDetailsReference, "strategusOutput"),
    file.path(resultsDir), recursive = TRUE
  )
  return(NULL)
}



