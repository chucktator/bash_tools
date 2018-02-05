#!/usr/bin/bash

__CONSOLE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $__CONSOLE_DIR/console_debug.bash

__CONSOLE_PRINTER_LINE_LENGTH=110

__CONSOLE_SHORT_OPT_INDEX=0
__CONSOLE_LONG_OPT_INDEX=1
__CONSOLE_IS_FLAG_INDEX=3
__CONSOLE_TARGET_VARIABLE_INDEX=2
__CONSOLE_DOC_INDEX=4
__CONSOLE_OPTS_INDEX=5

function __console_parse_parameters() {  # (input, options[...])
    # First parameter must be the options string passed to the calling script, store it and advance 1
    local INPUT=$1
    shift

    local PARAMETER_DEFINITIONS=${@:1}
    local INPUT_PARTS=()
    for word in $INPUT; do
        INPUT_PARTS+=("$word")
    done
    INPUT_PARTS+=("--")

    for ((i=0; i<${#INPUT_PARTS[@]}; i++)); do
        __console_debug "DEBUG" "Param Parser" "$INDENT Read segment $i: ${INPUT_PARTS[$i]}"
        DESCEND=true
        if [[ ${INPUT_PARTS[$i]} == "#RECURSIVE#" ]]; then
            DESCEND=false
            continue
        fi
        if [[ ${INPUT_PARTS[$i]} == "--" ]]; then
            break
        fi
        if [[ ${INPUT_PARTS[$i]} == "-h" || ${INPUT_PARTS[$i]} == "--help" ]]; then
            __console_box_printer "Parameter Help Page"
            for option in $PARAMETER_DEFINITIONS; do
                declare -n optionArray="$option"
                __console_print_text_padded_right 16 false "-${optionArray[__CONSOLE_SHORT_OPT_INDEX]}, --${optionArray[__CONSOLE_LONG_OPT_INDEX]}"
                __console_print_text true "${optionArray[__CONSOLE_DOC_INDEX]}"
            done
            exit
        fi
        for option in $PARAMETER_DEFINITIONS; do
            declare -n optionArray="$option"
            #echo -e "Array: ${optionArray[@]}"
            __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Array: ${optionArray[@]}"
            __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Short Option: ${optionArray[__CONSOLE_SHORT_OPT_INDEX]}"
            __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Long Option: ${optionArray[__CONSOLE_LONG_OPT_INDEX]}"
            __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Is Flag: ${optionArray[__CONSOLE_IS_FLAG_INDEX]}"
            __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Single Value: ${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}"
            __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Single Value Expanded: ${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}"
            __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Checking -${optionArray[__CONSOLE_SHORT_OPT_INDEX]} equal to ${INPUT_PARTS[$i]}"
            __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Checking --${optionArray[__CONSOLE_LONG_OPT_INDEX]} equal to ${INPUT_PARTS[$i]}"
            __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Possible parameter value would be: ${INPUT_PARTS[$((i+1))]}"

            # Read sub-options from the current option to determine further processing
            if [[ -n "${optionArray[__CONSOLE_OPTS_INDEX]}" ]]; then
                __console_debug "DEBUG" "Param Parser" "$INDENT Parameter has parameters"
                if [[ $DESCEND == true ]]; then
                    INDENT="|--"
                    __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Descending into parameter's parameters"
                    overwrite=("n" "no-overwrite" OPTION_NO_OVERWRITE true)
                    __console_parse_parameters "#RECURSIVE# ${optionArray[__CONSOLE_OPTS_INDEX]} --" overwrite
                    __console_debug "DEBUG" "Param Parser" "$INDENT Overwrite Variable: $OPTION_NO_OVERWRITE"
                    INDENT=""
                fi
                __console_debug "DEBUG" "Param Parser" "$INDENT Finished processing sub-options."
            else
                __console_debug "DEBUG_FULL" "Param Parser" "$INDENT No sub-options specified."
            fi

            if [[ "-${optionArray[__CONSOLE_SHORT_OPT_INDEX]}" == "${INPUT_PARTS[$i]}" || "--${optionArray[__CONSOLE_LONG_OPT_INDEX]}" == "${INPUT_PARTS[$i]}" ]]; then
                __console_debug "DEBUG" "Param Parser" "$INDENT --OPTION MATCHED--"
                __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Examined character: ${INPUT_PARTS[(($i+1))]:0:1}"
                __console_debug "DEBUG" "Param Parser" "$INDENT Is Flag: ${optionArray[__CONSOLE_IS_FLAG_INDEX]}"
                if [[ -z "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" ]]; then
                    __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Variable is NOT empty."
                    if [[ $OPTION_NO_OVERWRITE == true ]]; then
                        __console_debug "WARNING" "Param Parser" "$INDENT Variable is not empty and configured as 'no-overwrite'. Continue."
                        continue
                    fi
                else
                    __console_debug "DEBUG" "Param Parser" "$INDENT Variable is empty."
                fi
                if [[ ${INPUT_PARTS[(($i+1))]:0:1} != "-" && ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == false ]]; then
                    __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Arg case"
                    # A parameter is required for the current opition, so read it and advance the pointer by 2
                    printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s ""
                    while [[ ${INPUT_PARTS[(($i+1))]:0:1} != "-" ]]; do
                        __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Possible parameter value would be: ${INPUT_PARTS[$((i+1))]}"
                        if [[ -n "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" ]]; then
                            printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]} ${INPUT_PARTS[$((i+1))]}"
                        else
                            printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s "${INPUT_PARTS[$((i+1))]}"
                        fi
                        ((i++))
                        __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Next Possible: ${INPUT_PARTS[$((i+1))]}"
                    done
                    __console_debug "DEBUG" "Param Parser" "$INDENT Wrote follwing to variable:"${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}
                elif [[ ${INPUT_PARTS[(($i+1))]:0:1} == "-" && ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == true ]]; then
                    __console_debug "DEBUG_FULL" "Param Parser" "$INDENT Flag case"
                    # The current option is only a flag, so set it and advance the pointer by 1
                    printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s "true"
                    __console_debug "DEBUG" "Param Parser" "$INDENT Wrote follwing to variable: ${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}"
                else
                    __console_debug "ERROR" "Param Parser" "$INDENT Error Case"
                    # An error occured, which getopt should have caught
                    if [[ ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == false ]]; then
                        __console_debug "ERROR" "Param Parser" "$INDENT A required parameter is missing. Exit."
                        exit 3
                    elif [[ ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == true ]]; then
                        __console_debug "ERROR" "Param Parser" "$INDENT A flag was passed a parameter. Exit."
                        exit 4
                    else
                        __console_debug "ERROR" "Param Parser" "$INDENT An unknown error occurred. Exit."
                        exit 5
                    fi
                fi
                break
            fi
        done
    done
}

function __console_wait_spinner() {  # (void)

	#echo "in wait_complete function: $1"

	local STATE=0
	local STARTED=0

	while :
	do

		if kill -0 $! 2>/dev/null; then

			if [[ $STARTED -eq 1 ]]; then
				echo -ne "\b"
			fi

			if [[ $STATE -eq 0 ]]; then
				echo -n "-"
				let STATE++
			elif [[ $STATE -eq 1 ]]; then
				echo -n "\\"
				let STATE++
			elif [[ $STATE -eq 2 ]]; then
				echo -n "|"
				let STATE++
			elif [[ $STATE -eq 3 ]]; then
				echo -n "/"
				STATE=0
			fi

			STARTED=1
			sleep 0.3

		else

			if [[ $STARTED -eq 1 ]]; then
				echo -ne "\b"
			fi
			break

		fi

	done

}
