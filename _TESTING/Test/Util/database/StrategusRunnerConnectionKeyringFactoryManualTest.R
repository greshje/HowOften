# ---
#
# Tests for StrategusConnectionKeyringFactory.R that can be run manually. 
#
# ---

# load the source and create alias kf
source("./impl/database/StrategusRunnerConnectionKeyringFactory.R")
srkf <- StrategusRunnerConnectionKeyringFactory

# create the keyring (new and existing use cases)
srkf$deleteKeyring("foo")
srkf$createDatabaseKeyRing("foo","bar","bat")
srkf$createDatabaseKeyRing("foo","bar","bat")
srkf$addUserToKeyring("foo","bar2","bat2")
print(srkf$getExistingKeyrings())

# get the passwords we just stored
pw1 <- srkf$getPassword("foo","bar","bat")
pw2 <- srkf$getPassword("foo","bar2","bat2")

# delete the keyring (existing and non-existing cases)
srkf$deleteKeyring("foo")
srkf$deleteKeyring("foo")
print(srkf$getExistingKeyrings())

# echo the results
pw1
pw2