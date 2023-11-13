
source("./Util/reporting/CreateStrategusReportingTablesUtil.R")

rootDir <- "C:/_YES/_STRATEGUS/HowOften/Output/covid-nachc-test-02/ERGASIA/strategusOutput"
loggingDir <- "C:/temp/strategus-test"
resultsDatabaseSchema <- "DELETE_ME"

configureLogging(loggingDir)

CreateStrategusReportingTablesUtil$createTables(rootDir, loggingDir, resultsDatabaseSchema)

