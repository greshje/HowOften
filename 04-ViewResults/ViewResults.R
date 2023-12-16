detach(package:ShinyAppBuilder, unload = TRUE)
remove.packages("ShinyAppBuilder")
remotes::install_github("OHDSI/ShinyAppBuilder", ref="main", upgrade = FALSE, INSTALL_opts = "--no-multiarch")
library(ShinyAppBuilder)
library(dplyr)
library(OhdsiShinyModules)

aboutModule <- createModuleConfig(
  moduleId = 'about',
  tabName = "About",
  shinyModulePackage = "OhdsiShinyModule",
  moduleUiFunction = 'aboutViewer',
  moduleServerFunction = 'aboutServer',
  moduleDatabaseConnectionKeyService = NULL,
  moduleDatabaseConnectionKeyUsername = NULL,
  moduleInfoBoxFile =  "aboutHelperFile()",
  moduleIcon = 'info',
  resultDatabaseDetails = NULL,
  useKeyring = TRUE
)

# resultDatabaseDetails <- list(
#   dbms = 'postgres',
#   tablePrefix = 'plp_',
#   cohortTablePrefix = 'cg_',
#   databaseTablePrefix = '',
#   schema = 'main',
#   databaseTable = 'database_meta_data'
# )
# 
# predictionModule <- createModuleConfig(
#   moduleId = 'prediction',
#   tabName = "Prediction",
#   shinyModulePackage = 'OhdsiShinyModules',
#   moduleUiFunction = "predictionViewer",
#   moduleServerFunction = "predictionServer",
#   moduleDatabaseConnectionKeyService ="resultDatabaseDetails",
#   moduleDatabaseConnectionKeyUsername = "prediction",
#   moduleInfoBoxFile =  "predictionHelperFile()",
#   moduleIcon = "chart-line",
#   resultDatabaseDetails = resultDatabaseDetails,
#   useKeyring = TRUE
# )

resultDatabaseDetails <- list(
  dbms = 'postgres',
  tablePrefix = 'cm_',
  cohortTablePrefix = 'cg_',
  databaseTablePrefix = '',
  schema = 'main',
  databaseTable = 'database_meta_data'
)

cohortMethodModule <- createDefaultEstimationConfig(
  resultDatabaseDetails = resultDatabaseDetails,
  useKeyring = TRUE
)

cohortGeneratorModule <- createDefaultCohortGeneratorConfig()


# add the modules into a single shiny config
shinyAppConfig <- initializeModuleConfig() %>%
  addModuleConfig(aboutModule) %>%
  addModuleConfig(cohortGeneratorModule) %>%
  addModuleConfig(cohortMethodModule)
#  addModuleConfig(predictionModule)


# add connection details to result database
# connectionDetails <- DatabaseConnector::createConnectionDetails() 
source("./02-UploadResults/configuration/ConnectionDetailsFactoryForReporting.R")
connectionDetails <- ReportingConnectionDetailsUtil$createConnectionDetails()
connection <- ResultModelManager::ConnectionHandler$new(connectionDetails)

viewShiny(shinyAppConfig, connection)


