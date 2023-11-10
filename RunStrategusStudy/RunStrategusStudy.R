# ---
#
# Initialize the session: this deals with all of the library loading and declarations
# including setting all of the versions and loads the functions used below. 
# 
# ---

source("./Util/StrategusRunnerUtil.R")
# StrategusRunnerUtil$initLibs()
StrategusRunnerUtil$checkstrategusKeyring()

# ---
#
# Optional code: run the following lines to reset the environement.  
#
# -- 

# StrategusRunnerUtil$removePackagesInstalledHere()

# ---
#
# set basic parameters
#
# ---

# file locations
StrategusRunnerUtil$resultsLocation <- "D:/_YES/_STRATEGUS/HowOften/Output"
StrategusRunnerUtil$outputLocation <- "D:/_YES/_STRATEGUS/HowOften"
StrategusRunnerUtil$loggingOutputLocation <- "D:/_YES/_STRATEGUS/HowOften"

# database schemas
StrategusRunnerUtil$workDatabaseSchema <- "how_often_scratch"
StrategusRunnerUtil$cohortTableName <- "howoften_cohort"
StrategusRunnerUtil$cdmDatabaseSchema <- "covid_ohdsi"

# minimum number of cells
StrategusRunnerUtil$minCellCount <- 5

# connection info
StrategusRunnerUtil$dbms = "spark"
StrategusRunnerUtil$pathToDriver="D:\\_YES_2023-05-28\\workspace\\SosExamples\\_COVID\\02-data-diagnostics\\drivers\\databricks\\"

# references to stored values (these can be anything)
StrategusRunnerUtil$keyringName <- "HowOften"
StrategusRunnerUtil$connectionDetailsReference <- "ERGASIA"

# set temp emulation schema using options
StrategusRunnerUtil$setSqlRendererTempEmulationSchema("how_often_temp")

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

StrategusRunnerUtil$createDatabaseKeyRing (
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
StrategusRunnerUtil$connectionDetails <- DatabaseConnector::createConnectionDetails (
  dbms = StrategusRunnerUtil$dbms,
  pathToDriver = StrategusRunnerUtil$pathToDriver,
  connectionString = getUrl()
)

# init the environment (see functionsForInit.R file for details)
StrategusRunnerUtil$executionSettings <- StrategusRunnerUtil$initStratagus()

# ---
#
# Execute one or more studies
#
# ---

StrategusRunnerUtil$executeAnalysis(
  "./RunStrategusStudy/json/FromNachc/nachc-covid-homeless.json", 
  StrategusRunnerUtil$executionSettings, 
  "covid-nachc-test-02", 
  StrategusRunnerUtil$outputLocation, 
  StrategusRunnerUtil$resultsLocation, 
  StrategusRunnerUtil$keyringName
)



