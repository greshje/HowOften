
# source("./Util/database/ReportingConnectionDetailsFactory.R")

CreateStrategusReportingTablesUtil <- {}

csrtu <- CreateStrategusReportingTablesUtil

# ---
#
# configuration
#
# ---

csrtu$resultsTableFolderRoot <- "C:/_YES/_STRATEGUS/HowOften/Output/covid-nachc-test-02/ERGASIA/strategusOutput"
csrtu$resultsDatabaseSchemaCreationLogFolder <- "C:/temp/_DELETE_ME"
csrtu$resultsDatabaseSchemaPrefix <- "COVID_HOMELESS_"
csrtu$resultsDatabaseSchemaSuffixList <- c("NACHC")

# ---
#
# drop and create schema functions
#
# ---

csrtu$dropSchema <- function(schemaName, connection) {
  writeLines(paste("Droping schema if exists: ", schemaName))
  sqlString <- paste("drop schema if exists ", schemaName, " cascade")
  DatabaseConnector::executeSql(connection, sqlString)
}

csrtu$createSchema <- function(schemaName, connection) {
  writeLines(paste("Creating schema: ", schemaName))
  sqlString <- paste("create schema ", schemaName)
  DatabaseConnector::executeSql(connection, sqlString)
}  

csrtu$dropAndRecreateSchema <- function(schemaName, connection) {
  csrtu$dropSchema(schemaName, connection)
  csrtu$createSchema(schemaName, connection)
}

# ---
#
# logging
# 
# ---

csrtu$initLogging <- function(resultsDatabaseSchemaCreationLogFolder) {
  # stdout logging
  ParallelLogger::clearLoggers()
  ParallelLogger::addDefaultFileLogger(
    fileName = file.path(resultsDatabaseSchemaCreationLogFolder, "results-schema-setup-log.txt"),
    name = "RESULTS_SCHEMA_SETUP_FILE_LOGGER"
  )
  # stderr logging
  ParallelLogger::addDefaultErrorReportLogger(
    fileName = file.path(resultsDatabaseSchemaCreationLogFolder, 'results-schema-setup-errorReport.txt'),
    name = "RESULTS_SCHEMA_SETUP_ERROR_LOGGER"
  )
}

# ---
#
# database connection
# 
# --

csrtu$getConnection <- function() {
  resultsDatabaseConnectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = "postgresql",
    connectionString = "jdbc:postgresql://localhost:5432/OHDSI_HOMELESS_COVID_RESULTS_DB?user=postgres&password=ohdsi&currentSchema=OHDSI_HOMELESS_COVID_RESULTS_DB",
    pathToDriver = "D:/_YES/databases/postgres/drivers/42.3.3"
  )
  connection <- DatabaseConnector::connect(connectionDetails = resultsDatabaseConnectionDetails)
}

# ---
#
# create a table for each module
#
# ---

csrtu$createModuleTables <- function(moduleFolders, resultsDatabaseSchema, connection) {
  message("Creating results tables in schema: ", resultsDatabaseSchema)
  for (moduleFolder in moduleFolders) {
    moduleName <- basename(moduleFolder)
    if (csrtu$isModuleComplete(moduleFolder) == FALSE) {
      warning("Module ", moduleName, " did not complete. Skipping table creation")
    } else {
      csrtu$createModuleTable(moduleName, moduleFolder, resultsDatabaseSchema, connection)
    }
  }
}
  
# ---
#
# create a table for a module
#
# ---

csrtu$createModuleTable <- function(moduleName, moduleFolder, resultsDatabaseSchema, connection) {
  message("- Creating results for module ", moduleName)
  rdmsFile <- file.path(moduleFolder, "resultsDataModelSpecification.csv")
  if (file.exists(rdmsFile) == FALSE) {
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

# ---
#
# create a characterization table
#
# ---

csrtu$createCharacterizationTable <- function(resultsDatabaseSchema, connection) {
  message("Creating empty characterization tables in schema: ", resultsDatabaseSchema)
  rdmsFile <- "./UploadResults/cc_resultsDataModelSpecification.csv"
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
# did the module complete
#
# ---

csrtu$isModuleComplete <- function(moduleFolder) {
  doneFileFound <- (length(list.files(path = moduleFolder, pattern = "done")) > 0)
  isDatabaseMetaDataFolder <- basename(moduleFolder) == "DatabaseMetaData"
  return(doneFileFound || isDatabaseMetaDataFolder)
}

# ---
#
# is the schema empty
#
# ---

csrtu$schemaIsEmpty <- function(resultsDatabaseSchema, connection) {
  tables <- DatabaseConnector::getTableNames(
    connection = connection,
    databaseSchema = resultsDatabaseSchema
  )
  if(length(tables) == 0) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

# ----------------------------------------------------------------------------
# method to create database tables
# ----------------------------------------------------------------------------

HowOftenResultsUpload <- function() {
  
  # init parameters
  resultsTableFolderRoot <- csrtu$resultsTableFolderRoot
  resultsDatabaseSchemaCreationLogFolder <- csrtu$resultsDatabaseSchemaCreationLogFolder
  resultsDatabaseSchemaPrefix <- csrtu$resultsDatabaseSchemaPrefix
  resultsDatabaseSchemaSuffixList <- csrtu$resultsDatabaseSchemaSuffixList

  # init logging
  csrtu$initLogging(resultsDatabaseSchemaCreationLogFolder)
  # get a database connection
  connection <- csrtu$getConnection()
  # get the modules (studies)
  moduleFolders <- list.dirs(path = resultsTableFolderRoot, recursive = FALSE)

  tryCatch({

    # echo status
    message("Creating result tables based on definitions found in ", resultsTableFolderRoot)

    # ---
    #
    # create a separate schema for each data partner
    #
    # ---
    
    for (schemaSuffix in resultsDatabaseSchemaSuffixList) {
      resultsDatabaseSchema <- paste(resultsDatabaseSchemaPrefix, schemaSuffix, sep = "")
      # drop and recreate the schema
      writeLines(paste("DROPPING DATABASE SCHEMA: ", resultsDatabaseSchema))
      csrtu$dropAndRecreateSchema(resultsDatabaseSchema, connection)
      writeLines(paste("DROPPED DATABASE SCHEMA:  ", resultsDatabaseSchema))
      
      # ---
      #
      # create the data tables if the schema is empty
      #
      # ---
      
      if (csrtu$schemaIsEmpty(resultsDatabaseSchema, connection)) {
        # create the module tables
        csrtu$createModuleTables(moduleFolders, resultsDatabaseSchema, connection)
        # create the characterization table
        csrtu$createCharacterizationTable(resultsDatabaseSchema, connection)
      } else {
        message("SKIPPING - Results tables already exist")
      }
    }
  },
  finally = {
    # Disconnect from the database -------------------------------------------------
    DatabaseConnector::disconnect(connection)
    
    # Unregister loggers -----------------------------------------------------------
    ParallelLogger::unregisterLogger("RESULTS_SCHEMA_SETUP_FILE_LOGGER")
    ParallelLogger::unregisterLogger("RESULTS_SCHEMA_SETUP_ERROR_LOGGER")
  })
  
}

# debugonce(HowOftenResultsUpload)

HowOftenResultsUpload()


