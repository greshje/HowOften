# ---
#
# One of three touch points to run strategus:
#
# - Update this file to use your parameters
#   (only change values between the START CONFIGURATION and END CONFIGURATION comments)
# - Update ./impl/database/StrategusRunnerConnectionDetailsFactory.R
# - Update ./impl/database/StrategusRunnerReportingConnectionDetailsFactory.R
#   (this step is only required if you are uploading results data)
# 
# ---

source("./impl/dvo/StrategusRunnerDvo.R")

Configuration <- {}

Configuration$configure <- function (dvo) {
  # set the type of the data value object
  class(dvo) <- "StrategusRunnerDvo"

  # *************************************
  # *** START CONFIGURATION           ***
  # *************************************
  
  # file locations
  dvo$resultsLocation <- "D:/_YES/_STRATEGUS/CovidHomelessnessNetworkStudy/Results"
  dvo$outputLocation <- "D:/_YES/_STRATEGUS/CovidHomelessnessNetworkStudy"
  dvo$loggingOutputLocation <- "D:/_YES/_STRATEGUS/CovidHomelessnessNetworkStudy/loggingOutput"
  # database schemas
  dvo$cdmDatabaseSchema <- "covid_ohdsi"
  dvo$workDatabaseSchema <- "covid_ohdsi_scratch"
  dvo$cohortTableName <- "covid_ohdsi_cohort"
  dvo$sqlRenderTempEmulationSchema <- "covid_ohdsi_temp"
  # minimum number of cells
  dvo$minCellCount <- 5
  # connection info
  dvo$dbms = "spark"
  dvo$pathToDriver="D:\\_YES_2023-05-28\\workspace\\SosExamples\\_COVID\\02-data-diagnostics\\drivers\\databricks\\"
  # data source name
  dvo$dataPartnerName <- "NACHC"

  # *************************************
  # *** END CONFIGURATION
  # *************************************
  
  # return the configured dvo
  return(dvo)
}

