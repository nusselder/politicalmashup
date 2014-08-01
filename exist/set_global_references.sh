#!/bin/bash
# Set the references to 'http://resolver.politicalmashup.nl/' instead of
# local (=relative) references.
#
# The pm-modules-[X].xar app *must* be installed first.
# This script patches a settings file. For the changes to take effect,
# restart (stop and then start) the database.
# Additionally, a small "hack" for the ODE-II project is possible.

SCRIPT_ABS_PATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"
. "$SCRIPT_ABS_PATH/settings.sh"

# Default data location if it was not changed during install.
SETTINGS_FILE="$SCRIPT_ABS_PATH/install/webapp/WEB-INF/data/fs/db/apps/modules/settings.xqm"

# What will happen.
DO="$1"

if [ -z "$DO" ]; then
  sed -i -e 's/local-references := true/local-references := false/' "$SETTINGS_FILE"

elif [ "$DO" = "local" ]; then
  sed -i -e 's/local-references := false/local-references := true/' "$SETTINGS_FILE"
  sed -i -e 's~^declare variable \$settings:local-resolver := .*$~declare variable \$settings:local-resolver := "../resolver/";~' "$SETTINGS_FILE"

elif [ "$DO" = "ode" ]; then
  sed -i -e 's/local-references := false/local-references := true/' "$SETTINGS_FILE"
  sed -i -e 's~^declare variable \$settings:local-resolver := .*$~declare variable \$settings:local-resolver := "http://ode.politicalmashup.nl/resolver/";~' "$SETTINGS_FILE"

else
  echo "Nothing happened."
fi

#declare variable $settings:local-references := true();
#declare variable $settings:local-resolver := '../resolver/';

