source("./impl/uploadresults/CreateStrategusResultsTablesUtil.R")

util = CreateStrategusResultsTablesUtil$new()
util$dropAndRecreateSchema()

