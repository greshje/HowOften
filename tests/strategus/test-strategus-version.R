library(testthat)

test_that(
  "Get Version",
  {
    version <- Strategus::getStrategusVersion()
    print(paste("Version: ", version))
    expect_equal(1, 1)
  }
)

