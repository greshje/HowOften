# ---
#
# stratagus .Renv stuff
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

