#!/bin/bash
# Prepare aps and data for database inclusion after installation.

# The data location might change if servers are moved..
PM_DATA_BASE="http://data.politicalmashup.nl/permanent/"

function get_folder_data {
  if [ -n "$1" ]; then
    wget "${PM_DATA_BASE}$1"
    tar -xf "$1"
  fi
}

SCRIPT_ABS_PATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"

. "$SCRIPT_ABS_PATH/settings.sh"

package="$SCRIPT_ABS_PATH/../scripts/appsrc2packagexar.sh"
src_dir="$SCRIPT_ABS_PATH/../app_src"

# Create apps dir and package/zip the apps from source.
echo "Creating code apps from source."
mkdir -p "$PM_EXIST_APPS_DIR"
cd "$PM_EXIST_APPS_DIR"
"$package" "$src_dir/pm-modules/"
"$package" "$src_dir/pm-backend/"
"$package" "$src_dir/pm-resolver/"
"$package" "$src_dir/pm-search/"
cd -

echo "Downloading and unpacking annotated proceedings data."
mkdir -p "$PM_EXIST_FOLDER_DATA_DIR"
cd "$PM_EXIST_FOLDER_DATA_DIR"
get_folder_data "p-nl.tar.gz"
get_folder_data "m-nl.tar.gz"
get_folder_data "d-nl-proc-ob.tar.gz"
get_folder_data "d-nl-proc-sgd.tar.gz"
cd -

