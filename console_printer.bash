#!/bin/bash

__CONSOLE_PRINTER_LINE_LENGTH=110
__CONSOLE_PRINTER_NO_ECHO=false

function __console_frame_printer() {  # (text)
    if [ "$__CONSOLE_PRINTER_NO_ECHO" != true ] ; then
        echo -e -n "**  $1"
        COUNTER=0
        SPACES=$[$__CONSOLE_PRINTER_LINE_LENGTH - 8 - ${#1}]
        while [[ $COUNTER -lt $SPACES ]]; do
            echo -e -n " "
            ((COUNTER++))
        done
        echo -e "  **"
        #printf "##  %-$(($__CONSOLE_PRINTER_LINE_LENGTH - 8))s  ##\n" $*
    fi
}

function __console_centered_frame_printer() {  # (text)
    if [ "$__CONSOLE_PRINTER_NO_ECHO" != true ] ; then
        echo -e -n "**  "
        LINE_LENGTH=${#1}
        FIXED_LENGTH=8
        #FIRST_SPACES_LENGTH=$(( ($__CONSOLE_PRINTER_LINE_LENGTH - $FIXED_LENGTH - $LINE_LENGTH) / 2 ))
        __console_print_text_centered $(( $__CONSOLE_PRINTER_LINE_LENGTH - $FIXED_LENGTH )) false "$1"
        LAST_SPACES_LENGTH=$(( $__CONSOLE_PRINTER_LINE_LENGTH - $FIXED_LENGTH - $LINE_LENGTH - $FIRST_SPACES_LENGTH ))
        echo -e "  **"
        #echo "Line length: $__CONSOLE_PRINTER_LINE_LENGTH - Text length: $LINE_LENGTH - Fixed length: $FIXED_LENGTH - First spaces: $FIRST_SPACES_LENGTH - Last spaces: $LAST_SPACES_LENGTH - SUM: $(( FIRST_SPACES_LENGTH + LINE_LENGTH + FIXED_LENGTH + LAST_SPACES_LENGTH ))"
    fi
}

function __console_box_printer() {  # (text)
    __console_box_line_printer
    __console_centered_frame_printer "$1"
    __console_box_line_printer
}

function __console_box_line_printer() {  # (void)
    COUNTER=0
    while [[ $COUNTER -lt $__CONSOLE_PRINTER_LINE_LENGTH ]]; do
        echo -n "*"
        ((COUNTER++))
    done
    echo -e ""
}

function __console_pad_text_balanced() {  # (return variable, resulting length, string[...])
    printf -v "$1" %s ""
    SPACES_TO_PRINT=$(( $2 - ${#3} ))
    FIRST_SPACES_LENGTH="$(( $SPACES_TO_PRINT / 2 ))"
    COUNTER=0
    while [[ $COUNTER -lt $FIRST_SPACES_LENGTH ]]; do
        printf -v "$1" %s "${!1} "
        ((COUNTER++))
    done
    printf -v "$1" %s "${!1}$3"
    LAST_SPACES_LENGTH="$(( $SPACES_TO_PRINT - $FIRST_SPACES_LENGTH ))"
    COUNTER=0
    while [[ $COUNTER -lt $LAST_SPACES_LENGTH ]]; do
        printf -v "$1" %s "${!1} "
        ((COUNTER++))
    done
}

function __console_pad_text_right() {  # (return variable, resulting length, string)
    SPACES_LENGTH=$(($2 - ${#3}))
    COUNTER=0
    printf -v "$1" %s "$3"
    while [[ $COUNTER -lt $SPACES_LENGTH ]]; do
        printf -v "$1" %s "${!1} "
        ((COUNTER++))
    done
}

function __console_print_text_padded_right() {  # (resulting length, break after, string)
    __console_pad_text_right ret "$1" "$3"
    if [[ "$1" == true ]]; then
        echo -e "$ret"
    else
        echo -e -n "$ret"
    fi
}

function __console_print_text_centered() {  # (resulting length, break after, string)
    __console_pad_text_balanced ret "$1" "$3"
    if [[ "$1" == true ]]; then
        echo -e "$ret"
    else
        echo -e -n "$ret"
    fi
}

function __console_print_text() {  # (break after, string)
    if [[ "$1" == true ]]; then
        echo -e "$2"
    else
        echo -e -n "$2"
    fi
}

function __console_print_available_colors() {
    #
    #   This file echoes a bunch of color codes to the
    #   terminal to demonstrate what's available.  Each
    #   line is the color code of one forground color,
    #   out of 17 (default + 16 escapes), followed by a
    #   test use of that color on all nine background
    #   colors (default + 8 escapes).
    #

    T='gYw'   # The test text

    echo -e "\n                 40m     41m     42m     43m\
     44m     45m     46m     47m";

    for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
           '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
           '  36m' '1;36m' '  37m' '1;37m';
        do FG=${FGs// /}
        echo -en " $FGs \033[$FG  $T  "
        for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
            do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
        done
        echo;
    done
    echo
}
