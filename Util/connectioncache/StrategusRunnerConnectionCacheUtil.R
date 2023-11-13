# ---
#
# stratagus .Renviron stuff
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

StrategusRunnerConnectionCacheUtil <- {}

# ---
#
# check everything we need is in the .renv file
#
# ---

StrategusRunnerConnectionCacheUtil$checkEnv <- function () {
  if(
    Sys.getenv("STRATEGUS_KEYRING_PASSWORD") == "" || 
    Sys.getenv("INSTANTIATED_MODULES_FOLDER") == "" || 
    Sys.getenv("GITHUB_PAT") == ""
  ) {
    msg <- "\n"
    msg <- paste(msg, "* ----------------------------- \n")
    msg <- paste(msg, "* \n")
    msg <- paste(msg, "* ENVIRONMENT NOT CORRECTLY CONFIGURED: \n")
    msg <- paste(msg, "* \n")
    msg <- paste(msg, "* The following parameters need to be set in .Renviron \n")
    msg <- paste(msg, "*   GITHUB_PAT='ghp_ThisIsMyGithubPersonalAccessTokenM2bgp91'\n")
    msg <- paste(msg, "*   INSTANTIATED_MODULES_FOLDER='C:/path/to/where/you/want/to/store/modules'\n")
    msg <- paste(msg, "*   STRATEGUS_KEYRING_PASSWORD='sos'\n")
    msg <- paste(msg, "* \n")
    msg <- paste(msg, "*   To set the parameters run the following to edit the contents of the .Renviron file.\n")
    msg <- paste(msg, "*   Restart R after editing .Renviron for the changes to take effect.\n")
    msg <- paste(msg, "*   usethis::edit_r_environ()\n")
    msg <- paste(msg, "* \n")
    msg <- paste(msg, "* ----------------------------- \n")
    writeLines(msg)
    usethis::edit_r_environ() 
    stop("Set .Renviron before running this script")
  }
}

# ---
#
# list existing keyrings
#
# ---

StrategusRunnerConnectionCacheUtil$getExistingKeyrings <- function () {
  return(keyring::keyring_list())
}

# ---
#
# create the keyring if it does not exist
#
# ---

StrategusRunnerConnectionCacheUtil$createKeyring <- function (keyringName) {
  # create the keyring if it does not exist.
  class(dvo) <- "StrategusRunnerDvo"
  allKeyrings <- keyring::keyring_list()
  if (!(keyringName %in% allKeyrings$keyring)) {
    print(paste("Keyring not found, creating it now: ", keyringName))
    keyring::keyring_create(keyring = keyringName, password = Sys.getenv("STRATEGUS_KEYRING_PASSWORD"))
    print(paste("Keyring created: ", keyringName))
  } else {
    print("Keyring already exists. You do not need to create it again.")
  }
}

# ---
#
# delete a keyring
#
# ---

StrategusRunnerConnectionCacheUtil$deleteKeyring <- function (keyringName) {
  keyring::keyring_delete(keyringName)
}    

# ---
#
# store connection details
#
# ---

StrategusRunnerConnectionCacheUtil$storeConnectionDetails <- function(dvo) {
  # get the dvo and the keyringName
  class(dvo) <- "StrategusRunnerDvo"
  keyringName = StrategusRunnerUtil$keyringName
  # set up the keyring
  StrategusRunnerConnectionCacheUtil$checkEnv()
  StrategusRunnerConnectionCacheUtil$createKeyring(keyringName)
  StrategusRunnerConnectionCacheUtil$getExistingKeyrings()
  # save the cdm connection details for strategus
  Strategus::storeConnectionDetails(
    connectionDetails = dvo$cdmConnectionDetails,
    connectionDetailsReference = dvo$cdmConnectionDetailsReference,
    keyringName = keyringName
  )
}

