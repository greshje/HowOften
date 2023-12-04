# clear the environment
rm(list = ls())

# import dependencies
source("./impl/uploadresults/UploadResultsUtil.R")

# upload the results
UploadResultsUtil$uploadResults()

