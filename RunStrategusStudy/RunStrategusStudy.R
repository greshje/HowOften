# ---
#
# Initialize the session: this deals with all of the library loading and declarations
# including setting all of the versions and loads the functions used below. 
# 
# ---

# imports and installs
source("./Util/StrategusRunnerUtil.R")
source("./Util/StrategusRunnerDvo.R")
StrategusRunnerUtil$initLibs()

# ---
#
# Optional code: run the following lines to reset the environment.  
# This will unload and re-install all of the libraries installed by this project.  
#
# -- 

# StrategusRunnerUtil$removePackagesInstalledHere()

# set strategus keyring stuff
StrategusRunnerUtil$checkEnv()

# ---
#
# set basic parameters
#
# ---

dvo <- StrategusRunnerDvo$new()

# file locations
dvo$resultsLocation <- "D:/_YES/_STRATEGUS/HowOften/Output"
dvo$outputLocation <- "D:/_YES/_STRATEGUS/HowOften"
dvo$loggingOutputLocation <- "D:/_YES/_STRATEGUS/HowOften"
# database schemas
dvo$workDatabaseSchema <- "how_often_scratch"
dvo$cohortTableName <- "howoften_cohort"
dvo$cdmDatabaseSchema <- "covid_ohdsi"
# minimum number of cells
dvo$minCellCount <- 5
# connection info
dvo$dbms = "spark"
dvo$pathToDriver="D:\\_YES_2023-05-28\\workspace\\SosExamples\\_COVID\\02-data-diagnostics\\drivers\\databricks\\"
# references to stored values (these can be anything)
dvo$keyringName <- "HowOften"
dvo$connectionDetailsReference <- "ERGASIA"

# FIX THIS
# set temp emulation schema using options
dvo$setSqlRendererTempEmulationSchema("how_often_temp")

# ---
#
# create the execution environment
#
# ---

# create the connection details
dvo$connectionDetails <- StrategusRunnerUtil$createConnectionDetails()

# init the environment (see functionsForInit.R file for details)
dvo$executionSettings <- StrategusRunnerUtil$initStratagus(dvo)

# ---
#
# Execute one or more studies
#
# ---

StrategusRunnerUtil$executeAnalysis(
  "./RunStrategusStudy/json/FromNachc/nachc-covid-homeless.json", 
  dvo$executionSettings, 
  "covid-nachc-test-02", 
  dvo$outputLocation, 
  dvo$resultsLocation, 
  dvo$keyringName
)







