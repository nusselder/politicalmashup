#!/bin/bash
# Perform all installation steps to arrive at a running ode.politicalmashup.nl.

SCRIPT_ABS_PATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"

$SCRIPT_ABS_PATH/prepare_ode.sh
$SCRIPT_ABS_PATH/initial_install.sh
$SCRIPT_ABS_PATH/setup_apps.sh
$SCRIPT_ABS_PATH/setup_data_xml.sh "$@"

