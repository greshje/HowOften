# ---
#
# RunStrategusStudy.R
# A script to execute your Strategus study. 
#
# Before running this script:
#   - Define your configuration:
#     Update ./01-RunStudy/configuration/UserConfiguration.R
#   - Define your database connection:
#     Update ./01-RunStudy/configuration/ConnectionDetailsFactoryForCdm.R
#   - Use your study definition:
#     Update the call to StrategusRunnerUtil$executeAnalysis below 
#     to use your json file and the name you want for the output folder.  
# 
# ---

# clear the environment
rm(list = ls())

# echo some info about the environment
print(R.Version())
print(system("java -version"))
print(getwd())

# setup the run
source("./impl/runstudy/StrategusRunnerUtil.R")
StrategusRunnerUtil$initRun()

# ---
#
# Execute one or more studies
#
# ---

specRoot <- "./01-RunStudy/configuration/specifications/"

# StrategusRunnerUtil$executeAnalysis (paste0(specRoot,"FromNachc/nachc-covid-homeless.json"),"nachc")

for(i in 1:length(studiesToRun)) {
  study <- studiesToRun[[i]]
  studyFile <- study[[1]]
  studyName <- study[[2]]
  writeLines("")
  writeLines("")
  writeLines("")
  writeLines("")
  writeLines("")
  writeLines("* ---")
  writeLines("*")
  writeLines(paste0("* RUNNING STUDY: ", studyName))
  writeLines(paste0("* Using file: ", studyFile))
  writeLines("*")
  writeLines("* ---")
  writeLines("")
  writeLines("")
  writeLines("")
  StrategusRunnerUtil$executeAnalysis (studyFile, studyName)
  writeLines("")
  writeLines("")
  writeLines("")
}




