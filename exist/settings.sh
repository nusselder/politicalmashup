#!/bin/bash
# Load this file to set some variables.

PM_EXIST_PORT="8006"
PM_EXIST_PORT_SSL="8444"
PM_EXIST_LOG="start_jetty.log"
PM_EXIST_ERR="start_jetty.err"

PM_EXIST_BASE_DIR="`pwd`"
PM_EXIST_INSTALL_DIR="$PM_EXIST_BASE_DIR/install"
PM_EXIST_APPS_DIR="$PM_EXIST_BASE_DIR/app_packages"
PM_EXIST_DATA_APPS_DIR="$PM_EXIST_BASE_DIR/app_data"
PM_EXIST_FOLDER_DATA_DIR="$PM_EXIST_BASE_DIR/folder_data"


#TODO: get absolute dir of this script (to determine where the apps etc. are)
#TODO: get the current running dir to determine where to install?

# TODO also try:
# java -Xmx1024M 
# PM_EXIST_MAXMEM="4000M"


# Some utility functions..

function exist_start_foreground {
  java -Djetty.port=$PM_EXIST_PORT -Djetty.port.ssl=$PM_EXIST_PORT_SSL -jar start.jar jetty
}

function exist_start_background {
  exist_start_foreground 1>> "$PM_EXIST_LOG" 2>> "$PM_EXIST_ERR" &
  tail -f "$PM_EXIST_LOG"
}

function confirm {
  read -p "Press [Enter] key to $*..."
}

