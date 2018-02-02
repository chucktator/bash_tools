#!/bin/bash

source ./console_printer.bash

__CONSOLE_PRINTER_LINE_LENGTH=110

INFO=1
DEBUG=10
DEBUG_HALF=15
WARNING=20
ERROR=30

RED='\033[0;31m'
YELLOW='\033[0;33m'
GRAY='\033[0;30m'
LIGHT_GRAY='\033[0;37m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

__CONSOLE_LOG_LEVEL=1

function __console_debug() {  # (level, tag, message)
    COLOR=$NC
    STRING=${@:3}
    case "$1" in
        "DEBUG")
            COLOR=$LIGHT_BLUE
            ;;

        "WARNING")
            COLOR=$YELLOW
            ;;
        "ERROR")
            COLOR=$RED
            ;;
        "INFO" | *)
            COLOR=$GRAY
            ;;

    esac
    if [[ ${!1} -ge __CONSOLE_LOG_LEVEL ]]; then
        echo -e -n ${COLOR}
        __console_printer "[ $1 ][ $2 ]:  ${STRING}"
        echo -e -n ${NC}
    fi
}

function __console_debug_header() {  # (message)
    __console_box_printer "$1"
}
