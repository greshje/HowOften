# ---
#
# Running this script will install the libraries used by this project.  
# It is not necescary to run this script (it is run when it is needed elsewhere).  
#
# ---

source("./impl/lib/StrategusRunnerLibUtil.R")
StrategusRunnerLibUtil$initLibs()
rm(list = ls())
rstudioapi::restartSession()


