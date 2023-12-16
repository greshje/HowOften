# ---
#
# functions to load and install libraries/packages
#
# ---

StrategusRunnerLibUtil <- {}

StrategusRunnerLibUtil$setIsInit <- function (isInit) {
  StrategusRunnerLibUtil$isInit <<- isInit
}

StrategusRunnerLibUtil$setIsInit (FALSE)
  
StrategusRunnerLibUtil$showVersions <- function() {
  # show versions
  R.Version()
  system("java -version")
  getwd()
  # show the module list
  Strategus::getModuleList()
}

StrategusRunnerLibUtil$packageVersionExists <- function (pkgName, pkgVersion) {
  tryCatch (
    {
      return(packageVersion(pkgName) == pkgVersion)
    },
    error = function(e) {
      return(FALSE)
    }
  )
}

StrategusRunnerLibUtil$installFromCran <- function(pkgName, pkgVersion) {
  if (requireNamespace(pkgName, quietly = TRUE) == TRUE && StrategusRunnerLibUtil$packageVersionExists(pkgName, pkgVersion)) {
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

StrategusRunnerLibUtil$installFromGithub <- function(pkgName, pkgVersion) {
  if (requireNamespace(pkgName, quietly = TRUE) == TRUE && StrategusRunnerLibUtil$packageVersionExists(pkgName, pkgVersion)) {
    print(paste("Correct version of package already installed: ", pkgName, pkgVersion, sep = " "))
  } else {  
    print(paste("* * * Installing from GitHub:", pkgName, pkgVersion, sep = " "))
    remotes::install_github(pkgName, ref=pkgVersion, upgrade = FALSE, INSTALL_opts = "--no-multiarch")
  }
}

StrategusRunnerLibUtil$checkPackageVersion <- function(packageName) {
  available_packages <- available.packages()
  latest_keyring_version <- available_packages[packageName, "Version"]
  print(latest_keyring_version)  
}

StrategusRunnerLibUtil$removePackage <- function(pkgName) {
  required <- requireNamespace(pkgName, quietly = TRUE)
  print(paste(pkgName, required, sep = ": "))
  if (required) {
    remove.packages(pkgName)
  }
}

StrategusRunnerLibUtil$forceRemovePackage <- function(pkgName) {
  tryCatch({
    devtools::unload(pkgname)
  }, error = function(e) {
    writeLines(paste0("COULD NOT UNLOAD PACKAGE: ", pkgName))
  })
  tryCatch({
    StrategusRunnerLibUtil$removePackage(pkgName)
  }, error = function(e) {
    writeLines(paste0("COULD NOT REMOVE PACKAGE: ", pkgName))
  })
}

# ---
#
# remove libraries that are installed here
#
# ---

StrategusRunnerLibUtil$removePackagesInstalledHere <- function() {
  # from cran
  StrategusRunnerLibUtil$removePackage("keyring")
  StrategusRunnerLibUtil$removePackage("usethis")
  StrategusRunnerLibUtil$removePackage("DatabaseConnector")
  # from github
  StrategusRunnerLibUtil$removePackage("Strategus")
  StrategusRunnerLibUtil$removePackage("CohortGenerator")
  StrategusRunnerLibUtil$removePackage("CirceR")
  # done
  StrategusRunnerLibUtil$setIsInit(FALSE)
}

# ---
#
# install and load libraries
#
# ---

StrategusRunnerLibUtil$initLibs <- function() {

  doInstall <- function() {
    # installs from cran
    StrategusRunnerLibUtil$installFromCran("remotes", "2.4.2.1")
    StrategusRunnerLibUtil$installFromCran("keyring", "1.3.1")
    StrategusRunnerLibUtil$installFromCran("usethis", "2.2.2")
    StrategusRunnerLibUtil$installFromCran("dplyr", "1.1.4")
    StrategusRunnerLibUtil$installFromCran("R6", "2.5.1")
    StrategusRunnerLibUtil$installFromCran("DatabaseConnector", "6.2.4")
    
    
    # installs from github
    StrategusRunnerLibUtil$installFromGithub("OHDSI/Strategus", "v0.1.0")
    StrategusRunnerLibUtil$installFromGithub("OHDSI/CohortGenerator", "v0.8.1")
    StrategusRunnerLibUtil$installFromGithub("OHDSI/CohortMethod", "v5.1.0")
    StrategusRunnerLibUtil$installFromGithub("OHDSI/CirceR", "v1.3.1")
    
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
    
    # done
    StrategusRunnerLibUtil$setIsInit(TRUE) 
    print("Done with doInstall()")
  }

  if(StrategusRunnerLibUtil$isInit == FALSE) {
    print("INITIALIZAING LIBRARIES...")
    doInstall()
    print("DONE INITIALIZING LIBRARIES.")
  } else {
    print("LIBRARIES ALREADY INITIALIZED, SKIPPING INITIALIZATION.")
  }
  
}

# ---
#
# initialize the libraries
#
# ---

StrategusRunnerLibUtil$initLibs()
