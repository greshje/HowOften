# ---
#
# functionsForInit.R
# 
# ---

# ---
#
# install functions
#
# ---

installFromCran <- function(pkgName, pkgVersion) {
  if (!requireNamespace(pkgName, quietly = TRUE) || packageVersion(pkgName) != pkgVersion) {
    remotes::install_version(pkgName, version = pkgVersion)
  }
}

installFromGithub <- function(pkgName, pkgVersion) {
  if (!requireNamespace(pkgName, quietly = TRUE) || packageVersion(pkgName) != pkgVersion) {
    remotes::install_github(pkgName, ref=pkgVersion)
  }
}

# ---
#
# installs
#
# ---

# installs from cran
installFromCran("remotes", "2.4.2.1")
installFromCran("keyring", "1.3.1")
installFromCran("DatabaseConnector", "6.2.4")

#installs from github
installFromGithub("OHDSI/Strategus", "v0.1.0")
installFromGithub("OHDSI/CohortGenerator", "v0.8.1")

# ---
#
# functions to get databricks token (user will be prompted for keyring password)
#
# ---

getToken <- function () {
  return (
    keyring::backend_file$new()$get(
      service = "production",
      user = "token",
      keyring = "databricks_keyring"
    )
  )
}

# ---
#
# functions to get databricks url with token included
#
# ---

getUrl <- function () {
  url <- "jdbc:databricks://nachc-databricks.cloud.databricks.com:443/default;transportMode=http;ssl=1;httpPath=sql/protocolv1/o/3956472157536757/0123-223459-leafy532;AuthMech=3;UseNativeQuery=1;UID=token;PWD="
  return (
    paste(url, getToken(), sep = "")
  )  
}

# --- R Version ---------------------
R.Version()
# --- Java Version ------------------
system("java -version")
# --- Working Directory -------------
getwd()

