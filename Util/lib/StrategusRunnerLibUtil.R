# ---
#
# library functions
#
# ---

StrategusRunnerUtil$showVersions <- function() {
  # show versions
  R.Version()
  system("java -version")
  getwd()
  # show the module list
  Strategus::getModuleList()
}

StrategusRunnerUtil$installFromCran <- function(pkgName, pkgVersion) {
  if (requireNamespace(pkgName, quietly = TRUE) == TRUE && packageVersion(pkgName) == pkgVersion) {
    print(paste("Correct version of package already installed: ", pkgName, pkgVersion, sep = " "))
  } else {  
    print(paste("* * * Installing from CRAN:", pkgName, pkgVersion, sep = " "))
    if(pkgName == "remotes") {
      install.packages("remotes", INSTALL_opts = "--no-multiarch")  
    } else {
      remotes::install_version(pkgName, version = pkgVersion, upgrade = FALSE, INSTALL_opts = "--no-multiarch", )
    }
  }
}

StrategusRunnerUtil$installFromGithub <- function(pkgName, pkgVersion) {
  if (requireNamespace(pkgName, quietly = TRUE) == TRUE && packageVersion(pkgName) == pkgVersion) {
    print(paste("Correct version of package already installed: ", pkgName, pkgVersion, sep = " "))
  } else {  
    print(paste("* * * Installing from GitHub:", pkgName, pkgVersion, sep = " "))
    remotes::install_github(pkgName, ref=pkgVersion, upgrade = FALSE, INSTALL_opts = "--no-multiarch")
  }
}

StrategusRunnerUtil$checkPackageVersion <- function(packageName) {
  available_packages <- available.packages()
  latest_keyring_version <- available_packages[packageName, "Version"]
  print(latest_keyring_version)  
}

StrategusRunnerUtil$removePackage <- function(pkgName) {
  required <- requireNamespace(pkgName, quietly = TRUE)
  print(paste(pkgName, required, sep = ": "))
  if (required) {
    remove.packages(pkgName)
  }
}

# ---
#
# remove libraries that are installed here
#
# ---

StrategusRunnerUtil$removePackagesInstalledHere <- function() {
  # from cran
  StrategusRunnerUtil$removePackage("keyring")
  StrategusRunnerUtil$removePackage("usethis")
  StrategusRunnerUtil$removePackage("DatabaseConnector")
  # from github
  StrategusRunnerUtil$removePackage("Strategus")
  StrategusRunnerUtil$removePackage("CohortGenerator")
  StrategusRunnerUtil$removePackage("CirceR")
}

# ---
#
# install and load libraries
#
# ---

StrategusRunnerUtil$initLibs <- function() {

    # installs from cran
  StrategusRunnerUtil$installFromCran("remotes", "2.4.2.1")
  StrategusRunnerUtil$installFromCran("keyring", "1.3.1")
  StrategusRunnerUtil$installFromCran("usethis", "2.2.2")
  StrategusRunnerUtil$installFromCran("R6", "2.5.1")
  StrategusRunnerUtil$installFromCran("DatabaseConnector", "6.2.4")
  
  # installs from github
  StrategusRunnerUtil$installFromGithub("OHDSI/Strategus", "v0.1.0")
  StrategusRunnerUtil$installFromGithub("OHDSI/CohortGenerator", "v0.8.1")
  StrategusRunnerUtil$installFromGithub("OHDSI/CirceR", "v1.3.1")
  
  # from cran
  library(remotes)
  library(keyring)
  library(usethis)
  library(R6)
  library(DatabaseConnector)
  # from github
  library(Strategus)
  library(CohortGenerator)
  library(CirceR)

}
