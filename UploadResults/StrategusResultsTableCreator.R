# ---
#
# Code to create results tables for Strategus Results.  
#
# ---

StrategusTableCreator <- {}

StrategusTableCreator$createTable <- function(resultsDatabaseSchema) {

  ParallelLogger::clearLoggers()
  ParallelLogger::addDefaultFileLogger(
    fileName = file.path(resultsDatabaseSchemaCreationLogFolder, "results-schema-setup-log.txt"),
    name = "RESULTS_SCHEMA_SETUP_FILE_LOGGER"
  )
  ParallelLogger::addDefaultErrorReportLogger(
    fileName = file.path(resultsDatabaseSchemaCreationLogFolder, 'results-schema-setup-errorReport.txt'),
    name = "RESULTS_SCHEMA_SETUP_ERROR_LOGGER"
  )

  tables <- DatabaseConnector::getTableNames(
    connection = connection,
    databaseSchema = resultsDatabaseSchema
  )
  if (length(tables) == 0) {
    message("Creating results tables in schema: ", resultsDatabaseSchema)
    for (moduleFolder in moduleFolders) {
      moduleName <- basename(moduleFolder)
      if (!isModuleComplete(moduleFolder)) {
        warning("Module ", moduleName, " did not complete. Skipping table creation")
      } else {
        message("- Creating results for module ", moduleName)
        rdmsFile <- file.path(moduleFolder, "resultsDataModelSpecification.csv")
        if (!file.exists(rdmsFile)) {
          stop("resultsDataModelSpecification.csv not found in ", resumoduleFolderltsFolder)
        } else {
          specification <- CohortGenerator::readCsv(file = rdmsFile)
          sql <- ResultModelManager::generateSqlSchema(csvFilepath = rdmsFile)
          sql <- SqlRender::render(
            sql = sql,
            database_schema = resultsDatabaseSchema
          )
          DatabaseConnector::executeSql(connection = connection, sql = sql)
        }
      }
    }
    message("Creating empty characterization tables in schema: ", resultsDatabaseSchema)
    rdmsFile <- "./ResultsUpload/cc_resultsDataModelSpecification.csv"
    specification <- CohortGenerator::readCsv(file = rdmsFile)
    sql <- ResultModelManager::generateSqlSchema(csvFilepath = rdmsFile)
    sql <- SqlRender::render(
      sql = sql,
      database_schema = resultsDatabaseSchema
    )
    DatabaseConnector::executeSql(connection = connection, sql = sql)
  } else {
    message("SKIPPING - Results tables already exist")
  }
} 