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
  if (!requireNamespace(pkgName, quietly = TRUE) || packageVersion(pkgName) != pkgVersion) {
    remotes::install_version(pkgName, version = pkgVersion)
  }
}

installFromGithub <- function(pkgName, pkgVersion) {
  if (!requireNamespace(pkgName, quietly = TRUE) || packageVersion(pkgName) != pkgVersion) {
    remotes::install_github(pkgName, ref=pkgVersion)
  }
}

checkPackageVersion <- function(packageName) {
  available_packages <- available.packages()
  latest_keyring_version <- available_packages[packageName, "Version"]
  print(latest_keyring_version)  
}

# ---
#
# installs
#
# ---

# installs from cran
installFromCran("remotes", "2.4.2.1")
installFromCran("keyring", "1.3.1")
installFromCran("DatabaseConnector", "6.2.4")

#installs from github
installFromGithub("OHDSI/Strategus", "v0.1.0")
installFromGithub("OHDSI/CohortGenerator", "v0.8.1")

library(remotes)
library(keyring)
library(DatabaseConnector)
library(Strategus)
library(CohortGenerator)

# ---
#
# stratagus keyring stuff
#
# Basically, just use usethis::edit_r_environ() to check your .Renviron file.  
# It should include the following
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
  keyringName <- "HowOften"
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



