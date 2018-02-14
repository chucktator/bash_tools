#!/bin/bash

source $__CONSOLE_DIR/console_printer.bash

__CONSOLE_PRINTER_LINE_LENGTH=110

INFO=1
DEBUG_FULL=10
DEBUG=15
WARNING=20
ERROR=30

__CONSOLE_DEBUG_TAG_INFO="INFO"
__CONSOLE_DEBUG_TAG_DEBUG_FULL="DEBUG"
__CONSOLE_DEBUG_TAG_DEBUG="DEBUG"
__CONSOLE_DEBUG_TAG_WARNING="WARNING"
__CONSOLE_DEBUG_TAG_ERROR="ERROR"
__CONSOLE_DEBUG_TAG_ALL="MSG"

RED='\033[0;31m'
YELLOW='\033[0;33m'
GRAY='\033[0;30m'
LIGHT_GRAY='\033[0;37m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

function __console_log() {  # (level[color], tag, message)
    COLOR=$NC
    STRING=${@:3}
    LEVEL_IS_COLOR=false
    LEVEL_INPUT=$1
    case "$LEVEL_INPUT" in
        "DEBUG")
            COLOR=$LIGHT_BLUE
            ;;
        "DEBUG_FULL")
            ;;
        "WARNING")
            COLOR=$YELLOW
            ;;
        "ERROR")
            COLOR=$RED
            ;;
        "INFO")
            COLOR=$LIGHT_GRAY
            ;;
        *)
            echo -e -n "${RED} LEVEL IS A COLOR! ${NC}"
            LEVEL_IS_COLOR=true
            COLOR=$LEVEL_INPUT
            LEVEL_INPUT="ALL"
            ;;

    esac
    if [[ "${!LEVEL_INPUT}" -ge "$__CONSOLE_LOG_LEVEL" || "$LEVEL_IS_COLOR" == true  ]]; then
        echo -e -n ${COLOR}
        levelName="__CONSOLE_DEBUG_TAG_"$LEVEL_INPUT
        __console_pad_text_balanced levelPadded 9 ${!levelName}
        __console_pad_text_right tagPadded 20 "$2"
        echo -e "[$levelPadded] # $tagPadded:  ${STRING}"
        echo -e -n ${NC}
    fi
}

function __console_debug_header() {  # (message)
    __console_box_printer "$1"
}
