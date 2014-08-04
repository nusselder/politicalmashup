#!/bin/bash
# Install apps into a non-running database and start it afterwards.
# Call after initial_install.sh

# Patch the settings file in pm-modules (see set_global_references.sh).
if [ "$1" = "politicalmashup" ]; then
  sgr=""
elif [ "$1" = "ode" ]; then
  sgr="ode"
else
  sgr="local"
fi


SCRIPT_ABS_PATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"

. "$SCRIPT_ABS_PATH/settings.sh"

echo "The database will be started thrice, first with the generally required"
echo "pm-modules added, second then with all other code modules, and third"
echo "with data-apps."
echo "After the first and second setup, CTRL-C to shutdown the database and"
echo "continue the next step."
echo "The first setup is done when the message is shown:"
echo "\"Server has started on ports [...]\""
echo ""
echo "The third time, the database is started in the background, with a"
echo "\`tail -f\` on the logfile."
echo "When finished starting (can take quite some time when data apps are"
echo "added), CTRL-C to exist tail; the database keeps running."
echo ""

confirm "start .xar deployment"


# Note, some warnings will likely be shown, ignore these..

# Exit after seeing:
#03 Jul 2014 15:49:25,650 [main] INFO  (JettyStart.java [run]:224) - -----------------------------------------------------
#03 Jul 2014 15:49:25,651 [main] INFO  (JettyStart.java [run]:225) - Server has started on ports 8006 8444. Configured contexts: 
#03 Jul 2014 15:49:25,651 [main] INFO  (JettyStart.java [run]:234) - '/exist'
#03 Jul 2014 15:49:25,651 [main] INFO  (JettyStart.java [run]:272) - -----------------------------------------------------



if [ ! -d "$PM_EXIST_APPS_DIR" ]; then
  echo "No directory with app .xar packages found, stopping."
  echo "Was expecting: $PM_EXIST_APPS_DIR"
  exit 1
fi

# Go to the installation directory.
cd "$PM_EXIST_INSTALL_DIR"

# Copy the pm-modules-x.y.z.xar to autodeploy and start for the first time.
cp -v "$PM_EXIST_APPS_DIR"/pm-modules*.xar autodeploy/

exist_start_foreground

# Edit settings.xqm, after ctrl-c (so, during shutdown).
echo "*****"
echo "* setting glocal references as: $sgr"
$SCRIPT_ABS_PATH/set_global_references.sh "$sgr"
echo "*****"

# Copy all apps (modules already exists but is ignored by the database).
cp -v "$PM_EXIST_APPS_DIR"/*.xar autodeploy/

#exist_start_background
exist_start_foreground

cp -v "$PM_EXIST_DATA_APPS_DIR"/*.xar autodeploy/

exist_start_background


