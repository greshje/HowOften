# ---
#
# Tests for StrategusConnectionKeyringFactory.R that can be run manually. 
#
# ---

# step through the code

# load the source and create alias kf
source("./Util/database/StrategusConnectionKeyringFactory.R")
kf <- StrategusConnectionKeyringFactory

# create the keyring (new and existing use cases)
kf$deleteKeyring("foo")
kf$createDatabaseKeyRing("foo","bar","bat")
kf$createDatabaseKeyRing("foo","bar","bat")
kf$addUser("foo","bar2","bat2")
print(kf$getExistingKeyrings())

# get the password we just stored
kf$getPassword("foo","bar","bat")
kf$getPassword("foo","bar2","bat2")

# delete the keyring (existing and non-existing cases)
kf$deleteKeyring("foo")
kf$deleteKeyring("foo")
print(kf$getExistingKeyrings())

