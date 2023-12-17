# ---
#
# Use this script to delete a single library (change the name below)
#
# ---

source("./impl/lib/StrategusRunnerLibUtil.R")
pkgToDelete <- "ChangeThisToThePkgYouWantToRemove"
StrategusRunnerLibUtil$forceRemovePackage(pkgToDelete)
rm(list = ls())
rstudioapi::restartSession()

