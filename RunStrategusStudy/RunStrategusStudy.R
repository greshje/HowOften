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

# echo some info about the environment
print(R.Version())
print(system("java -version"))
print(getwd())

# setup the run
source("./Util/StrategusRunnerUtil.R")
dvo <- StrategusRunnerUtil$initRun()

# ---
#
# Execute one or more studies
#
# ---

# filePath <- "./RunStrategusStudy/json/FromNachc/nachc-covid-homeless.json"
filePath <- "C:/_YES/workspace/HowOften/RunStrategusStudy/json/FromNachc/nachc-covid-homeless.json"
StrategusRunnerUtil$executeAnalysis (
  filePath,
  "covid_homeless_nachc_test01", 
  dvo
)

