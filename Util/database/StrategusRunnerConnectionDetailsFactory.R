# ---
# 
# StrategusRunnerConnectionDetailsUtil
# This script creates the DatabaseConnector connectionDetails objects used for the CDM. 
# Use this code as is or substitute with your own. 
#
# ---

source("./Util/database/StrategusRunnerConnectionKeyringFactory.R")

StrategusRunnerConnectionDetailsUtil <- {}

StrategusRunnerConnectionDetailsUtil$createCdmConnectionDetails <- function() {
  
  # create connection details params
  url <- "jdbc:databricks://nachc-databricks.cloud.databricks.com:443/default;transportMode=http;ssl=1;httpPath=sql/protocolv1/o/3956472157536757/0123-223459-leafy532;AuthMech=3;UseNativeQuery=1;UID=token;PWD="
  keyringName <- "databricks_keyring"
  serviceName <- "production"
  userName <- "token"
  
  # alias for keyring functions
  srkf <- StrategusRunnerConnectionKeyringFactory
  
  # get the token from the keyring
  getToken <- function () {
    return(srkf$getPassword(keyringName,serviceName,userName))
  }
  
  # concatinate the url and the token
  getUrl <- function () {
    url <- url
    return (
      paste(url, getToken(), sep = "")
    )  
  }
  
  # create the connection details object
  rtn <- DatabaseConnector::createConnectionDetails (
    dbms = dvo$dbms,
    pathToDriver = dvo$pathToDriver,
    connectionString = getUrl()
  )
  
  return(rtn)
  
}

