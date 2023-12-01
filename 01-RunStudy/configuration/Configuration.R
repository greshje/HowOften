# ---
#
# Update this file to use your parameters
#
# ---

RunConfiguration <- {}

# ---
#
# RunStudy 
# These are the variables used to run the study (i.e. by RunStudy.R and code called from there)
#
# ---

# file locations
RunConfiguration$resultsLocation <- "D:/_YES/_STRATEGUS/CovidHomelessnessNetworkStudy/Results"
RunConfiguration$outputLocation <- "D:/_YES/_STRATEGUS/CovidHomelessnessNetworkStudy"
RunConfiguration$loggingOutputLocation <- "D:/_YES/_STRATEGUS/CovidHomelessnessNetworkStudy/loggingOutput"
# database schemas
RunConfiguration$cdmDatabaseSchema <- "covid_ohdsi"
RunConfiguration$workDatabaseSchema <- "covid_ohdsi_scratch"
RunConfiguration$cohortTableName <- "covid_ohdsi_cohort"
RunConfiguration$sqlRenderTempEmulationSchema <- "covid_ohdsi_temp"
# minimum number of cells
RunConfiguration$minCellCount <- 5
# connection info
RunConfiguration$dbms = "spark"
RunConfiguration$pathToDriver="D:\\_YES_2023-05-28\\workspace\\SosExamples\\_COVID\\02-data-diagnostics\\drivers\\databricks\\"
# data source name
RunConfiguration$dataPartnerName <- "NACHC"

# ---
#
# CreateResultsTables
# These are the variables used to create the database tables for the results of the study.  
# (i.e. by CreateResultsTables.R and code called from there)
#
# ---

RunConfiguration$resultsTableFolderRoot = "D:/_YES/_STRATEGUS/CovidHomelessnessNetworkStudy/Results/nachc/NACHC/strategusOutput"
RunConfiguration$resultsDatabaseSchemaCreationLogFolder = "C:/temp"
RunConfiguration$resultsDatabaseSchemaPrefix = "covid_homeless_"
RunConfiguration$resultsDatabaseSchemaSuffixList = c("nachc")

# ---
#
# UploadResults
# These are the variables used to upload the results of the study.  
# (i.e. by UploadResults.R and code called from there)
#
# ---

resultsFolderRoot <- "D:/_YES/_STRATEGUS/CovidHomelessnessNetworkStudy"
howOftenAnalysesFilterList <- c()
databaseFilterList <- c()

