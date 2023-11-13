
source("./Util/database/ReportingConnectionDetailsFactory.R")

CreateStrategusReportingTablesUtil <- {}

# ---
#
# logging configuration
#
# ---

configureLogging <- function(outputDir) {
  # configure out logging
  ParallelLogger::clearLoggers()
  ParallelLogger::addDefaultFileLogger(
    fileName = file.path(outputDir, "results-schema-setup-log.txt"),
    name = "RESULTS_SCHEMA_SETUP_FILE_LOGGER"
  )
  # configure error logging
  ParallelLogger::addDefaultErrorReportLogger(
    fileName = file.path(outputDir, 'results-schema-setup-errorReport.txt'),
    name = "RESULTS_SCHEMA_SETUP_ERROR_LOGGER"
  )
}

# ---
#
# create table for module
#
# ---

createTableForModule <- function(resultsDatabaseSchema, moduleFolder, connection) {
  moduleName <- basename(moduleFolder)
  if (isModuleComplete(moduleFolder) == FALSE) {
    warning("Module ", moduleName, " did not complete. Skipping table creation")
  } else {
    message("- Creating results for module ", moduleName)
    rdmsFile <- file.path(moduleFolder, "resultsDataModelSpecification.csv")
    if (!file.exists(rdmsFile)) {
      stop("resultsDataModelSpecification.csv not found in ", moduleFolder)
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

# ---
#
# create characterization tables
#
# ---

createCharacterizationTables <- function(resultsDatabaseSchema, connection) {
  message("Creating empty characterization tables in schema: ", resultsDatabaseSchema)
  rdmsFile <- "./ResultsUpload/cc_resultsDataModelSpecification.csv"
  specification <- CohortGenerator::readCsv(file = rdmsFile)
  sql <- ResultModelManager::generateSqlSchema(csvFilepath = rdmsFile)
  sql <- SqlRender::render(
    sql = sql,
    database_schema = resultsDatabaseSchema
  )
  DatabaseConnector::executeSql(connection = connection, sql = sql)
}

# ---
# 
# create tables method
#
# ---

createTables <- function(resultsDatabaseSchema, moduleFolders, connection) {
  message("Creating results tables in schema: ", resultsDatabaseSchema)
  for (moduleFolder in moduleFolders) {
    createTableForModule(resultsDatabaseSchema, moduleFolder, connection)
  }
  createCharacterizationTables(resultsDatabaseSchema, connection)
}

CreateStrategusReportingTablesUtil$createTables <- function (rootDir, loggingDir, resultsDatabaseSchema) {
  # get the parameters
  resultsTableFolderRoot <- rootDir
  resultsDatabaseSchemaCreationLogFolder <- loggingDir
  # connect to the database
  resultsDatabaseConnectionDetails <- ReportingConnectionDetailsUtil$createConnectionDetails()
  connection <- DatabaseConnector::connect(connectionDetails = resultsDatabaseConnectionDetails)
  # configure logging
  configureLogging(loggingDir)
  # get the list of dirs  
  moduleFolders <- list.dirs(path = resultsTableFolderRoot, recursive = FALSE)
  # check that the run completed
  isModuleComplete <- function(moduleFolder) {
    doneFileFound <- (length(list.files(path = moduleFolder, pattern = "done")) > 0)
    isDatabaseMetaDataFolder <- basename(moduleFolder) == "DatabaseMetaData"
    return(doneFileFound || isDatabaseMetaDataFolder)
  }
  # get tables that already exist in the schema
  tables <- DatabaseConnector::getTableNames(
    connection = connection,
    databaseSchema = resultsDatabaseSchema
  )
  if (length(tables) == 0) {
    createTables(resultsDatabaseSchema, moduleFolders, connection)    
  } else {
    message("SKIPPING - Results tables already exist")
  }

}

  


