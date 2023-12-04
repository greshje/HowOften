# clear the environment
rm(list = ls())

# import dependencies
source("./impl/uploadresults/CreateStrategusResultsTablesUtil.R")

# create the results tables for each study
util = CreateStrategusResultsTablesUtil$new()
util$createResultsTables("nachc", TRUE)

