# clear the environment
rm(list = ls())

# import dependencies
source("./impl/uploadresults/CreateStrategusResultsTablesUtil.R")

# create the results tables
util = CreateStrategusResultsTablesUtil$new()
util$createResultsTables(TRUE)

