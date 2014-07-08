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

exist_start_foreground

