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
  connectionString <- "jdbc:postgresql://localhost:5432/?user=postgres&password=ohdsi&currentSchema=OHDSI_HOMELESS_COVID_RESULTS_DB"
  # create the connection details object
  rtn <- DatabaseConnector::createConnectionDetails (
    dbms = dbms,
    pathToDriver = pathToDriver,
    connectionString = connectionString
  )
  # done
  return(rtn)
}

