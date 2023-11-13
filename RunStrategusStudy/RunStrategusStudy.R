# ---
#
# RunStrategusStudy.R
# A script to execute your Strategus study. 
#
# Before running this script:
#   - Update ./RunStrategusStudy/RunStrategusConfiguration.R
#   - Update ./Util/database/StrategusRunnerConnectionDetailsFactory.R
#   - Update ./Util/database/StrategusRunnerReportingConnectionDetailsFactory.R
#     (this step is only required if you are uploading results data)
#   - Update the call to StrategusRunnerUtil$executeAnalysis below 
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

StrategusRunnerUtil$executeAnalysis("./RunStrategusStudy/json/FromNachc/nachc-covid-homeless.json", "covid-nachc-test-02", dvo)

