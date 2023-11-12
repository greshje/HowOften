
# ---
#
# Create the connections details (etc.) and create and test a connection.  
#
# More on the function to get database token and url. 
# https://ohdsi.github.io/DatabaseOnSpark/developer-how-tos_gen_dev_keyring.html
#
# The createDatabaseKeyRing will only create a new key ring if it does not exist. 
# You can then store your database token/password safely in the key ring.  
# If the keyring allready exists, you will be asked for the password used when it was created.  
# In this example: <a_new_password_for_the_keyring_that_is_not_your_database_password>.  
#
# The getToken() and getUrl() functions and connectionDetails assignment 
# below can be used as is, or you can write your own.  
#
# ---

StrategusRunnerUtil$createConnectionDetails <- function() {

  # ---  
  #  
  # create the keyring (if it doesn't already exist)
  #
  # ---
  
  # ---  
  #  
  # get the authentication token from the keyring
  #  
  # ---  

  getToken <- function () {
    return (
      keyring::backend_file$new()$get (
        keyring = "databricks_keyring",
        service = "production",
        user = "token"
      )
    )
  }

  getUrl <- function () {
    url <- "jdbc:databricks://nachc-databricks.cloud.databricks.com:443/default;transportMode=http;ssl=1;httpPath=sql/protocolv1/o/3956472157536757/0123-223459-leafy532;AuthMech=3;UseNativeQuery=1;UID=token;PWD="
    return (
      paste(url, getToken(), sep = "")
    )  
  }
  
  rtn <- DatabaseConnector::createConnectionDetails (
    dbms = dvo$dbms,
    pathToDriver = dvo$pathToDriver,
    connectionString = getUrl()
  )
  
  return(rtn)

}

