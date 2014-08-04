#!/bin/bash
# Perform all installation steps to arrive at a running search.politicalmashup.nl.
#
# Note, it is more clear to do every step individually.
# When using this script, supply as argument the password you are going to
# enter during the exist database installation.

SCRIPT_ABS_PATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"

PASSWORD="$@"

if [ -z "$PASSWORD" ]; then
  echo "Please supply as first (and only) argument the exact password"
  echo "that will be used during the installation step."
  exit 1
fi

$SCRIPT_ABS_PATH/prepare_search.sh
$SCRIPT_ABS_PATH/initial_install.sh
time $SCRIPT_ABS_PATH/setup_apps.sh "politicalmashup"
time $SCRIPT_ABS_PATH/setup_data_xml.sh "$PASSWORD"

