# ---
#
# RunStrategusStudy.R
# A script to execute your Strategus study. 
#
# Before running this script:
#   - Define your configuration:
#     Update ./RunStrategusStudy/RunStrategusConfiguration.R
#   - Define your database connection:
#     Update ./Util/database/StrategusRunnerConnectionDetailsFactory.R
#   - Use your study definition:
#     Update the call to StrategusRunnerUtil$executeAnalysis below 
#     to use your json file and the name you want for the output folder.  
# 
# ---

# setup the run
source("./Util/StrategusRunnerUtil.R")
dvo <- StrategusRunnerUtil$initRun()

# ---
#
# Execute one or more studies
#
# ---

StrategusRunnerUtil$executeAnalysis (
  "./RunStrategusStudy/json/FromNachc/nachc-covid-homeless.json", 
  "covid_homeless_nachc", 
  dvo
)

