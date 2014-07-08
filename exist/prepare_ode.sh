#!/bin/bash
# Install apps into a non-running database and start it afterwards.
# Call after initial_install.sh

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
"$package" "$src_dir/ode-tools/"
cd -


echo "Downloading demo-data apps."
mkdir -p "$PM_EXIST_DATA_APPS_DIR"
cd "$PM_EXIST_DATA_APPS_DIR"
wget "http://ode.politicalmashup.nl/data/xar/ode-data-municipality-0.1.2.xar"
wget "http://ode.politicalmashup.nl/data/xar/ode-data-vergunningen-0.1.1.xar"
cd -

echo "Downloading and unpacking annotated proceedings data."
mkdir -p "$PM_EXIST_FOLDER_DATA_DIR"
cd "$PM_EXIST_FOLDER_DATA_DIR"
#wget "http://ode.politicalmashup.nl/data/targz/nl-proc-ob-annotated.tar.gz"
#tar -xf nl-proc-ob-annotated.tar.gz
wget "http://ode.politicalmashup.nl/data/targz/nl-proc-ob-annotated-20112012.tar.gz"
tar -xf nl-proc-ob-annotated-20112012.tar.gz
cd -

