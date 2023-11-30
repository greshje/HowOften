# ---
# 
# ConnectionDetailsFactoryForReporting.R
# This script creates the DatabaseConnector connectionDetails objects used for reporting. 
# Use this code as is or substitute with your own. 
#
# ---

ReportingConnectionDetailsUtil <- {}

ReportingConnectionDetailsUtil$createConnectionDetails <- function() {
  resultsDatabaseConnectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = "postgresql",
    connectionString = "jdbc:postgresql://localhost:5432/OHDSI_HOMELESS_COVID_RESULTS_DB?user=postgres&password=ohdsi&currentSchema=OHDSI_HOMELESS_COVID_RESULTS_DB",
    pathToDriver = "D:/_YES/databases/postgres/drivers/42.3.3"
  )
  return(resultsDatabaseConnectionDetails)
}

