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
# set basic parameters
#
# ---

# file locations
outputLocation <- 'D:/_YES/_STRATEGUS/HowOften/Strategus'
resultsLocation <- 'D:/_YES/_STRATEGUS/HowOften/Output'
# database schemas
workDatabaseSchema <- 'how_often_scratch'
cohortTableName <- "howoften_cohort"
cdmDatabaseSchema <- 'covid_ohdsi'
options(sqlRenderTempEmulationSchema = "how_often_temp")
# references to stored values (these can be anything)
keyringName <- "HowOften"
connectionDetailsReference <- "covid_ohdsi_connection_details"
# minimum number of cells
minCellCount <- 5
# connection info
dbms = "spark"
pathToDriver="D:\\_YES_2023-05-28\\workspace\\SosExamples\\_COVID\\02-data-diagnostics\\drivers\\databricks\\"
# create a reference to the connection details


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
  "<a_new_password_for_the_keyring_that_is_not_your_database_password>"
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
# Test the connectionDetails
#
# ---

testConnection <- DatabaseConnector::connect(connectionDetails)
success <- DatabaseConnector::querySql(testConnection, "select 1 as one")
success
DatabaseConnector::disconnect(testConnection)

if (success != 1) {
  stop("We were not able to create the database connection for the given connectionDetails.")
} else {
  print("CONNECTION TEST PASSED")
}

# ---
#
# Execute one or more studies
#
# ---

executeAnalysis("howoften_azza.json", executionSettings, "azza", outputLocation, resultsLocation, keyringName)


