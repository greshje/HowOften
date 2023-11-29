
library(Eunomia)
library(Characterization)

connectionDetails <- Eunomia::getEunomiaConnectionDetails()
Eunomia::createCohorts(connectionDetails = connectionDetails)

targetIds <- c(1,2,4)
outcomeIds <- c(3)

timeToEventSettings1 <- createTimeToEventSettings(
  targetIds = 1,
  outcomeIds = c(3,4)
)
timeToEventSettings2 <- createTimeToEventSettings(
  targetIds = 2,
  outcomeIds = c(3,4)
)

dechallengeRechallengeSettings <- createDechallengeRechallengeSettings(
  targetIds = targetIds,
  outcomeIds = outcomeIds,
  dechallengeStopInterval = 30,
  dechallengeEvaluationWindow = 31
)

aggregateCovariateSettings1 <- createAggregateCovariateSettings(
  targetIds = targetIds,
  outcomeIds = outcomeIds,
  riskWindowStart = 1,
  startAnchor = 'cohort start',
  riskWindowEnd = 365,
  endAnchor = 'cohort start',
  covariateSettings = FeatureExtraction::createCovariateSettings(
    useDemographicsGender = T,
    useDemographicsAge = T,
    useDemographicsRace = T
  )
)

aggregateCovariateSettings2 <- createAggregateCovariateSettings(
  targetIds = targetIds,
  outcomeIds = outcomeIds,
  riskWindowStart = 1,
  startAnchor = 'cohort start',
  riskWindowEnd = 365,
  endAnchor = 'cohort start',
  covariateSettings = FeatureExtraction::createCovariateSettings(
    useConditionOccurrenceLongTerm = T
  )
)

characterizationSettings <- createCharacterizationSettings(
  timeToEventSettings = list(
    timeToEventSettings1,
    timeToEventSettings2
  ),
  dechallengeRechallengeSettings = list(
    dechallengeRechallengeSettings
  ),
  aggregateCovariateSettings = list(
    aggregateCovariateSettings1,
    aggregateCovariateSettings2
  )
)

runCharacterizationAnalyses(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = 'main',
  targetDatabaseSchema = 'main',
  targetTable = 'cohort',
  outcomeDatabaseSchema = 'main',
  outcomeTable = 'cohort',
  characterizationSettings = characterizationSettings,
  saveDirectory = file.path(tempdir(), 'example'),
  tablePrefix = 'c_',
  databaseId = 'Eunomia'
)

