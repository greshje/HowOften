# ---
#
# Update this file to use your parameters
#
# ---

RunConfiguration <- {}

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


