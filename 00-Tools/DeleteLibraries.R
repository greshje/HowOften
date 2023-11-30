# ---
#
# Running this script will delete all of the libraries installed by this project.
#
# ---

source("./impl/lib/StrategusRunnerLibUtil.R")
StrategusRunnerLibUtil$removePackagesInstalledHere()
rm(list = ls())
rstudioapi::restartSession()

