# run the functionsForInit script
source("functionsForInit.R")

# ---
#
# Function to get database token and url. 
# https://ohdsi.github.io/DatabaseOnSpark/developer-how-tos_gen_dev_keyring.html
#
# The createDatabaseKeyRing will only create a new key ring if it does not exist. 
# If the keyring allready exists, you will be asked for the password used when it was created.  
# In this example: <a_new_password_for_the_keyring_that_is_not_your_database_password>
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



# set the temp emulation schema
options(sqlRenderTempEmulationSchema = "how_often_temp")

# create your connection details
connectionDetails <- DatabaseConnector::createConnectionDetails (
  dbms = "spark",
  connectionString = getUrl(),
  pathToDriver="D:\\_YES_2023-05-28\\workspace\\SosExamples\\_COVID\\02-data-diagnostics\\drivers\\databricks\\"
)
connectionDetailsReference <- "covid_ohdsi_connection_details"

storeKeyRing()

# --- start test of connectionDetails -----------------------------------------------------------
testConnection <- DatabaseConnector::connect(connectionDetails)
testConnection 
DatabaseConnector::querySql(testConnection, "select 1 as one")
DatabaseConnector::disconnect(testConnection)
# --- end test of connectionDetails -------------------------------------------------------------



