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

# connection info
RunConfiguration$dbms = "spark"
# data source name
RunConfiguration$dataPartnerName <- "NACHC"
# file locations
RunConfiguration$outputLocation <-          "D:/_YES/_STRATEGUS/CovidHomelessnessNetworkStudy"
RunConfiguration$pathToDriver=              "D:\\_YES_2023-05-28\\workspace\\SosExamples\\_COVID\\02-data-diagnostics\\drivers\\databricks\\"
# database schemas
RunConfiguration$cdmDatabaseSchema <-               "covid_ohdsi"
RunConfiguration$workDatabaseSchema <-              "covid_ohdsi_scratch"
RunConfiguration$sqlRenderTempEmulationSchema <-    "covid_ohdsi_temp"
RunConfiguration$resultsDatabaseSchemaPrefix <-     "covid_homeless_"
RunConfiguration$cohortTableName <-                 "covid_ohdsi_cohort"
# list filters
RunConfiguration$resultsDatabaseSchemaSuffixList <- c("nachc")
RunConfiguration$howOftenAnalysesFilterList <-      c()
RunConfiguration$databaseFilterList <-              c()
# minimum number of cells
RunConfiguration$minCellCount <- 5




