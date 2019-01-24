#!/bin/bash

__CONSOLE_PRINTER_LINE_LENGTH=110
__CONSOLE_PRINTER_NO_ECHO=false

CONSOLE_DEFAULT_COLOR=9
CONSOLE_BLACK=0
CONSOLE_RED=1
CONSOLE_GREEN=2
CONSOLE_YELLOW=3
CONSOLE_BLUE=4
CONSOLE_MAGENTA=5
CONSOLE_CYAN=6
CONSOLE_LIGHT_GRAY=7
CONSOLE_DARK_GRAY=60
CONSOLE_LIGHT_RED=61
CONSOLE_LIGHT_GREEN=62
CONSOLE_LIGHT_YELLOW=63
CONSOLE_LIGHT_BLUE=64
CONSOLE_LIGHT_MAGENTA=65
CONSOLE_LIGHT_CYAN=66
CONSOLE_WHITE=67

#########################################
## FOREGROUND COLORS
#########################################
##	39 	Default foreground color
##	30 	Black
##	31 	Red
##	32 	Green
##	33 	Yellow
##	34 	Blue
##	35 	Magenta
##	36 	Cyan
##	37 	Light gray
##	90 	Dark gray
##	91 	Light red
##	92 	Light green
##	93 	Light yellow
##	94 	Light blue
##	95 	Light magenta
##	96 	Light cyan
##	97 	White
#########################################

#########################################
## BACKGROUND_COLORS
#########################################
##	49 		Default background color
##	40 		Black
##	41 		Red
##	42 		Green
##	43 		Yellow
##	44 		Blue
##	45 		Magenta
##	46 		Cyan
##	47 		Light gray
##	100 	Dark gray
##	101 	Light red
##	102 	Light green
##	103 	Light yellow
##	104 	Light blue
##	105 	Light magenta
##	106 	Light cyan
##	107 	White
#########################################

function __console_change_foreground_color() {
	if [[ -n $1 ]] ; then
		echo -e -n "\033[$(($1+30))m"
	fi
}

function __console_change_background_color() {
	if [[ -n $1 ]] ; then
		echo -e -n "\033[$(($1+40))m"
	fi
}

function __console_clear_color () {
	echo -e -n "\e[0m"
}

function __console_change_color () {
	__console_change_foreground_color $1
	__console_change_background_color $2
}

function __console_frame_printer() {  # (text, fg_frame, bg_frame, fg_text, bg_text)
    if [ "$__CONSOLE_PRINTER_NO_ECHO" != true ] ; then
		if [[ -n "$2" ]] ; then
			__console_change_color $2 $3
		fi
        echo -e -n "**"
		__console_clear_color
		if [[ -n "$4" ]] ; then
			echo -e -n "Shit"
			__console_change_color $4 $5
		fi
		echo -e -n "  $1  "
        COUNTER=0
        SPACES=$[$__CONSOLE_PRINTER_LINE_LENGTH - 8 - ${#1}]
        while [[ $COUNTER -lt $SPACES ]]; do
            echo -e -n " "
            ((COUNTER++))
        done
		if [[ -n "$2" ]] ; then
			__console_change_color $2 $3
		fi
        echo -e "**"
		__console_clear_color
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
