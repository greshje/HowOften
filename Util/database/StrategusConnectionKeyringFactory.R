# ---
#
# code related to database connection keyring
#
# ---

StrategusConnectionKeyringFactory <- {}

StrategusConnectionKeyringFactory$createDatabaseKeyRing <- function(keyringName, keyringService, keyringUsername) {
  kb <- keyring::backend_file$new()
  # Get a list of existing keyrings
  existing_keyrings <- kb$keyring_list()
  # Check if the keyring already exists
  if (!(keyringName %in% existing_keyrings$keyring)) {
    kb$keyring_create(keyringName)
    kb$set( keyring = keyringName, service = keyringService, username = keyringUsername)
    kb$keyring_lock(keyringName)
  } else {
    print(paste("Keyring already exists for: ", keyringName))
  }
}

StrategusConnectionKeyringFactory$addUser <- function(keyringName, keyringService, keyringUsername) {
  kb <- keyring::backend_file$new()
  
  # Check if the keyring exists
  existing_keyrings <- kb$keyring_list()
  if (keyringName %in% existing_keyrings$keyring) {
    # Add new credentials to the existing keyring
    kb$set(keyring = keyringName, service = keyringService, username = keyringUsername)
    print(paste("Credentials added to keyring: ", keyringName))
  } else {
    print(paste("Keyring not found for: ", keyringName))
  }
}

StrategusConnectionKeyringFactory$deleteKeyring <- function (name) {
  print(paste("DELETING KEYRING: ", name))
  kb <- keyring::backend_file$new()
  # Get a list of existing keyrings
  existing_keyrings <- kb$keyring_list()
  # Check if the keyring already exists
  if (name %in% existing_keyrings$keyring == TRUE) {
    kb$keyring_delete(name)
    print("Key deleted")
  } else {
    print("Key not found, delete skipped.")
  }
}

StrategusConnectionKeyringFactory$getExistingKeyrings <- function () {
  kb <- keyring::backend_file$new()
  keyringList <- kb$keyring_list()
  return(keyringList)
}

StrategusConnectionKeyringFactory$getPassword <- function (keyringName, service, user) {
  keyring::backend_file$new()$get (
    keyring = keyringName,
    service = service,
    user = user
  )

}  



