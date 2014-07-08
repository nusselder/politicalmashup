#!/bin/bash
# Install (and download) exist using the console (no gui, for headless machines).

SCRIPT_ABS_PATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"

. "$SCRIPT_ABS_PATH/settings.sh"

echo -e "eXist installation .jar will be downloaded, and installed to:"
echo "$PM_EXIST_INSTALL_DIR"
echo -e "\nThe headless installation will ask some input; for an explanation see:"
echo "http://mashup2.science.uva.nl/guides/exist2/headlessinstall/#installation"
echo "----"

# Current setup jar filename.
INSTALL_JAR="eXist-db-setup-2.1-rev18721.jar"

# Download eXist. Very specific file, as others are untested.
if [ ! -f "$INSTALL_JAR" ]; then
  wget "http://downloads.sourceforge.net/project/exist/Stable/2.1/$INSTALL_JAR"
else
  echo "Using existing $INSTALL_JAR"
fi

# Setup to install in directory.
mkdir -p "$PM_EXIST_INSTALL_DIR"
cd "$PM_EXIST_INSTALL_DIR"

# Start headless install (-console == headless).
java -jar $PM_EXIST_BASE_DIR/$INSTALL_JAR -console

echo "----"
echo "Done"
echo "Next, run setup_apps.sh to add apps and start the database."

