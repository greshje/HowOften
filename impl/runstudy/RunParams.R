source("./01-RunStudy/configuration/UserConfiguration.R")

RunConfiguration$resultsLocation <- paste0(RunConfiguration$outputLocation, "/Results")
RunConfiguration$loggingOutputLocation <- paste0(RunConfiguration$outputLocation, "/loggingOutput/runStudy")
RunConfiguration$resultsDatabaseSchemaCreationLogFolder = paste0(RunConfiguration$outputLocation, "/loggingOutput/tableCreation")

RunConfiguration$executionSettings <- ""
RunConfiguration$cdmConnectionDetails <- ""

RunConfiguration$init <- function(runName) {
  suppressWarnings({
    RunConfiguration$resultsTableFolderRoot <- paste0 (RunConfiguration$outputLocation, "/Results/", runName, "/", RunConfiguration$dataPartnerName, "/strategusOutput")
    dir.create(RunConfiguration$resultsLocation, recursive = TRUE)
    dir.create(RunConfiguration$loggingOutputLocation, recursive = TRUE)
    dir.create(RunConfiguration$resultsDatabaseSchemaCreationLogFolder, recursive = TRUE)
    dir.create(RunConfiguration$resultsTableFolderRoot, recursive = TRUE)
  })
  return(RunConfiguration)
}


