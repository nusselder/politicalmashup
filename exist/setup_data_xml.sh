#!/bin/bash
# Add an data tree on disk to eXist as a collection tree.

SCRIPT_ABS_PATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"

. "$SCRIPT_ABS_PATH/settings.sh"

echo "Run this script from the same folder where the initial installation"
echo "was called."
echo "------------"
echo ""

echo "Make sure the database is running, before using this script."
echo "Note that adding (i.e. indexing) a lot of data can take quite some"
echo "time (+/- one hour per 2GB xml)."
echo ""

DATA_FOLDER="$PM_EXIST_FOLDER_DATA_DIR/permanent"
HOST="localhost:$PM_EXIST_PORT"
TARGET_COLLECTION="/db/data/permanent"
PASSWORD="$1"

if [ ! -d "$DATA_FOLDER" ]; then
  echo "No data director found, stopping."
  echo "Was expecting: $DATA_FOLDER"
  exit 1
fi

if [ -z "$PASSWORD" ]; then
  echo "Please supply the exist admin password as first (and only) argument."
  exit 1
fi

confirm "start adding data"

time "$PM_EXIST_INSTALL_DIR"/bin/client.sh -ouri=xmldb:exist://"$HOST"/exist/xmlrpc -d -m "$TARGET_COLLECTION" -p "$DATA_FOLDER" -u admin -P "$PASSWORD"

