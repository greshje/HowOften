# ---
# 
# ReportingConnectionDetailsUtil
# This script creates the DatabaseConnector connectionDetails objects used for reporting. 
# Use this code as is or substitute with your own. 
#
# ---

ReportingConnectionDetailsUtil <- {}

ReportingConnectionDetailsUtil$createConnectionDetails <- function() {
  # connection parameters
  dbms <- "postgresql"
  pathToDriver <- "C:/_YES/databases/postgres/drivers/42.3.3"
  connectionString <- "jdbc:postgresql://localhost:5432/?user=postgres&password=ohdsi"
  # create the connection details object
  rtn <- DatabaseConnector::createConnectionDetails (
    dbms = dbms,
    pathToDriver = pathToDriver,
    connectionString = connectionString
  )
  # done
  return(rtn)
}

ReportingConnectionDetailsUtil$testConnection <- function() {
  testConnection <- DatabaseConnector::connect(ReportingConnectionDetailsUtil$createConnectionDetails())
  success <- DatabaseConnector::querySql(testConnection, "select 1 as one")
  success
  DatabaseConnector::disconnect(testConnection)
  if (success != 1) {
    stop("We were not able to create the database connection for the given connectionDetails.")
  } else {
    print("CONNECTION TEST PASSED")
  }
}


