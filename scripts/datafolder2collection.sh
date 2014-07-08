#!/bin/bash
# More of a memory aid about how to add data from the commandline
# with respect to a custom port etc.

# Variables, get these from somewhere.
INSTALL_DIR="."
HOST="localhost:8002"
TARGET_COLLECTION="/db/data/permanent/d/nl/proc/ob"
DATA_FOLDER="nl-proc-sum/20052006/data_summary_xml/"
PASSWORD="somepw"


# Let's not actually do something yet.. :)
exit 0

./"$INSTALL_DIR"/bin/client.sh -ouri=xmldb:exist://"$HOST"/exist/xmlrpc -d -m "$TARGET_COLLECTION" -p "$DATA_FOLDER" -u admin -P "$PASSWORD"

