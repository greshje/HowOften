# ---
#
# RunStrategusStudy.R
# A script to execute your Strategus study. 
#
# Before running this script:
#   - Define your configuration:
#     Update ./01-RunStudy/Configuration.R
#   - Define your database connection:
#     Update ./impl/database/StrategusRunnerConnectionDetailsFactory.R
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
source("./impl/runstudy/StrategusRunnerUtil.R")
dvo <- StrategusRunnerUtil$initRun()

# ---
#
# Execute one or more studies
#
# ---

specRoot <- "C:/_YES/workspace/HowOften/01-RunStudy/StudySpecification/FromNachc/"

# run nachc study
StrategusRunnerUtil$executeAnalysis (paste0(specRoot,"nachc-covid-homeless.json"),"nachc",dvo)





