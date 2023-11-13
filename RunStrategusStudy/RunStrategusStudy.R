# ---
#
# Initialize the session: this deals with all of the library loading and declarations
# including setting all of the versions and loads the functions used below. 
# 
# ---

# imports and installs
source("./Util/StrategusRunnerUtil.R")
source("./Util/dvo/StrategusRunnerDvo.R")
source("./RunStrategusStudy/RunStrategusConfiguration.R")

# initialize libraries/packages
StrategusRunnerUtil$initLibs()
# init strategus keyring stuff
StrategusRunnerUtil$checkEnv()
# configuration
dvo <- StrategusRunnerDvo$new()
dvo <- RunStrategusConfiguration$configure(dvo)
dvo$init()

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
  dvo$resultsLocation
)







