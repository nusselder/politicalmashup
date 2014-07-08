#!/bin/bash
# Simple call of the start.jar with used port.

SCRIPT_ABS_PATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"
. "$SCRIPT_ABS_PATH/settings.sh"

# Go to the installation directory.
cd "$PM_EXIST_INSTALL_DIR"

if [ ! -f "start.jar" ]; then
  echo "No eXist installation found, at:"
  echo "$PM_EXIST_INSTALL_DIR"
  echo "Please run from the directory from where the initial_install.sh was run."
  exit 1
fi

if [ -z "$1" ]; then
  echo "Please supply the exist admin password as first (and only) argument."
  exit 1
fi

HOST="localhost:$PM_EXIST_PORT"
PASSWORD="$1"

java -jar start.jar shutdown --uri xmldb:exist://"$HOST"/exist/xmlrpc --user admin --password "$PASSWORD"

