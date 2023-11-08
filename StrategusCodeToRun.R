# ---
#
# Initialize the session: this deals with all of the library loading and declarations
# including setting all of the versions and loads the functions used below. 
# Details are in the functionsForInit.R file.  
# 
# ---

source("functionsForInit.R")

# ---
#
# Optional code: run the following lines to reset the environement.  
#
# -- 

# removePackagesInstalledHere()

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

if(
    Sys.getenv("STRATEGUS_KEYRING_PASSWORD") == "" || 
    Sys.getenv("INSTANTIATED_MODULES_FOLDER") == "" || 
    Sys.getenv("GITHUB_PAT") == ""
  ) {
  usethis::edit_r_environ()
  stop("Set .Renviron before running this script")
}

# ---
#
# set basic parameters
#
# ---

# file locations
outputLocation <- 'D:/_YES/_STRATEGUS/HowOften'
resultsLocation <- 'D:/_YES/_STRATEGUS/HowOften/Output'
# database schemas
workDatabaseSchema <- 'how_often_scratch'
cohortTableName <- "howoften_cohort"
cdmDatabaseSchema <- 'covid_ohdsi'
options(sqlRenderTempEmulationSchema = "how_often_temp")
# minimum number of cells
minCellCount <- 5
# connection info
dbms = "spark"
pathToDriver="D:\\_YES_2023-05-28\\workspace\\SosExamples\\_COVID\\02-data-diagnostics\\drivers\\databricks\\"
# references to stored values (these can be anything)
keyringName <- "HowOften"
connectionDetailsReference <- "local-modules"

# ---
#
# Create the connections details (etc.) and create and test a connection.  
#
# More on the function to get database token and url. 
# https://ohdsi.github.io/DatabaseOnSpark/developer-how-tos_gen_dev_keyring.html
#
# The createDatabaseKeyRing will only create a new key ring if it does not exist. 
# You can then store your database token/password safely in the key ring.  
# If the keyring allready exists, you will be asked for the password used when it was created.  
# In this example: <a_new_password_for_the_keyring_that_is_not_your_database_password>.  
#
# The getToken() and getUrl() functions and connectionDetails assignment 
# below can be used as is, or you can write your own.  
#
# ---

createDatabaseKeyRing (
  "databricks_keyring", 
  "production", 
  "@ANewPasswordForTheKeyringThatIsNotYourDatabasePassword"
)

getToken <- function () {
  return (
    keyring::backend_file$new()$get(
      service = "production",
      user = "token",
      keyring = "databricks_keyring"
    )
  )
}

getUrl <- function () {
  url <- "jdbc:databricks://nachc-databricks.cloud.databricks.com:443/default;transportMode=http;ssl=1;httpPath=sql/protocolv1/o/3956472157536757/0123-223459-leafy532;AuthMech=3;UseNativeQuery=1;UID=token;PWD="
  return (
    paste(url, getToken(), sep = "")
  )  
}

# create your connection details
connectionDetails <- DatabaseConnector::createConnectionDetails (
  dbms = dbms,
  connectionString = getUrl(),
  pathToDriver = pathToDriver
)

# init the environment (see functionsForInit.R file for details)
executionSettings <- initStratagus()

# ---
#
# Execute one or more studies
#
# ---

# executeAnalysis("howoften_azza.json", executionSettings, "azza", outputLocation, resultsLocation, keyringName)

# executeAnalysis("flouroquinolone_COMPLETE.json", executionSettings, "flouro", outputLocation, resultsLocation, keyringName)

# executeAnalysis("nachc-covid-homeless-test-01.json", executionSettings, "covid-nachc-test-01", outputLocation, resultsLocation, keyringName)

# executeAnalysis("nachc-covid-homeless-test-02.json", executionSettings, "covid-nachc-test-02", outputLocation, resultsLocation, keyringName)

# executeAnalysis("./test-resources/01a-single-cohort.json", executionSettings, "test-01a", outputLocation, resultsLocation, keyringName)
executeAnalysis("./test-resources/01b-single-cohort-with-neg.json", executionSettings, "test-01b", outputLocation, resultsLocation, keyringName)
# executeAnalysis("./test-resources/02-single-covid-cohort.json", executionSettings, "test-02", outputLocation, resultsLocation, keyringName)
# executeAnalysis("./test-resources/03-all-covid-cohorts.json", executionSettings, "test-03", outputLocation, resultsLocation, keyringName)
# executeAnalysis("./test-resources/04-all-covid-cohorts-with-neg.json", executionSettings, "test-03", outputLocation, resultsLocation, keyringName)


