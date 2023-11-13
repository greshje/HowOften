# ---
#
# Running this script will reload the libraries installed by this project.
#
# ---

source("./Util/StrategusRunnerUtil.R")
source("./Util/StrategusRunnerDvo.R")
StrategusRunnerUtil$removePackagesInstalledHere()
StrategusRunnerUtil$initLibs()

