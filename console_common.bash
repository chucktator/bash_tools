#!/usr/bin/bash
source ./console_debug.bash
__CONSOLE_PRINTER_LINE_LENGTH=110

__CONSOLE_SHORT_OPT_INDEX=0
__CONSOLE_LONG_OPT_INDEX=1
__CONSOLE_IS_FLAG_INDEX=3
__CONSOLE_TARGET_VARIABLE_INDEX=2
__CONSOLE_OPTS_INDEX=4

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
        __console_debug "INFO" "Param Parser" "Read segment $i: ${INPUT_PARTS[$i]}"
        DESCEND=true
        if [[ ${INPUT_PARTS[$i]} == "#RECURSIVE#" ]]; then
            DESCEND=false
            continue
        fi
        if [[ ${INPUT_PARTS[$i]} == "--" ]]; then
            break
        fi
        for option in $PARAMETER_DEFINITIONS; do
            declare -n optionArray="$option"
            #echo -e "Array: ${optionArray[@]}"
            __console_debug "DEBUG" "Param Parser" "Array: ${optionArray[@]}"
            __console_debug "DEBUG" "Param Parser" "Short Option: ${optionArray[__CONSOLE_SHORT_OPT_INDEX]}"
            __console_debug "DEBUG" "Param Parser" "Long Option: ${optionArray[__CONSOLE_LONG_OPT_INDEX]}"
            __console_debug "DEBUG" "Param Parser" "Is Flag: ${optionArray[__CONSOLE_IS_FLAG_INDEX]}"
            __console_debug "DEBUG" "Param Parser" "Single Value: ${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}"
            __console_debug "DEBUG" "Param Parser" "Single Value Expanded: ${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}"
            __console_debug "DEBUG" "Param Parser" "Checking -${optionArray[__CONSOLE_SHORT_OPT_INDEX]} equal to ${INPUT_PARTS[$i]}"
            __console_debug "DEBUG" "Param Parser" "Checking --${optionArray[__CONSOLE_LONG_OPT_INDEX]} equal to ${INPUT_PARTS[$i]}"
            __console_debug "DEBUG" "Param Parser" "Possible parameter value would be: ${INPUT_PARTS[$((i+1))]}"

            # Read sub-options from the current option to determine further processing
            if [[ -n "${optionArray[__CONSOLE_OPTS_INDEX]}" ]]; then
                __console_debug "INFO" "Param Parser" "Parameter has parameters"
                if [[ $DESCEND == true ]]; then
                    __console_debug "DEBUG" "Param Parser" "Descending into parameter's parameters"
                    overwrite=("n" "no-overwrite" OPTION_NO_OVERWRITE true)
                    __console_parse_parameters "#RECURSIVE# ${optionArray[__CONSOLE_OPTS_INDEX]} --" overwrite
                    __console_debug "DEBUG" "Param Parser" "Overwrite Variable: $OPTION_NO_OVERWRITE"
                fi
                __console_debug "INFO" "Param Parser" "Finished processing sub-options."
            else
                __console_debug "INFO" "Param Parser" "No sub-options specified."
            fi

            if [[ "-${optionArray[__CONSOLE_SHORT_OPT_INDEX]}" == "${INPUT_PARTS[$i]}" || "--${optionArray[__CONSOLE_LONG_OPT_INDEX]}" == "${INPUT_PARTS[$i]}" ]]; then
                __console_debug "DEBUG" "Param Parser" "--OPTION MATCHED--"
                __console_debug "DEBUG" "Param Parser" "Examined character: ${INPUT_PARTS[(($i+1))]:0:1}"
                __console_debug "DEBUG" "Param Parser" "Is Flag: ${optionArray[__CONSOLE_IS_FLAG_INDEX]}"
                if [[ -z "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" ]]; then
                    __console_debug "DEBUG" "Param Parser" "Variable is NOT empty."
                    if [[ $OPTION_NO_OVERWRITE == true ]]; then
                        __console_debug "DEBUG" "Param Parser" "Variable is not empty and configured as 'no-overwrite'. Continue."
                        continue
                    fi
                else
                    __console_debug "DEBUG" "Param Parser" "Variable is empty."
                fi
                if [[ ${INPUT_PARTS[(($i+1))]:0:1} != "-" && ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == false ]]; then
                    __console_debug "DEBUG" "Param Parser" "Arg case"
                    # A parameter is required for the current opition, so read it and advance the pointer by 2
                    printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s ""
                    while [[ ${INPUT_PARTS[(($i+1))]:0:1} != "-" ]]; do
                        __console_debug "DEBUG" "Param Parser" "Possible parameter value would be: ${INPUT_PARTS[$((i+1))]}"
                        if [[ -n "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" ]]; then
                            printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]} ${INPUT_PARTS[$((i+1))]}"
                        else
                            printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s "${INPUT_PARTS[$((i+1))]}"
                        fi
                        ((i++))
                        __console_debug "DEBUG" "Param Parser" "Next Possible: ${INPUT_PARTS[$((i+1))]}"
                    done
                    __console_debug "DEBUG" "Param Parser" "Wrote follwing to variable:"${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}
                elif [[ ${INPUT_PARTS[(($i+1))]:0:1} == "-" && ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == true ]]; then
                    __console_debug "DEBUG" "Param Parser" "Flag case"
                    # The current option is only a flag, so set it and advance the pointer by 1
                    printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s "true"
                    __console_debug "DEBUG" "Param Parser" "Wrote follwing to variable: ${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}"
                else
                    __console_debug "ERROR" "Param Parser" "Error Case"
                    # An error occured, which getopt should have caught
                    if [[ ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == false ]]; then
                        __console_debug "ERROR" "Param Parser" "A required parameter is missing. Exit."
                        exit 3
                    elif [[ ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == true ]]; then
                        __console_debug "ERROR" "Param Parser" "A flag was passed a parameter. Exit."
                        exit 4
                    else
                        __console_debug "ERROR" "Param Parser" "An unknown error occurred. Exit."
                        exit 5
                    fi
                fi
            fi
        done
    done
}

__console_debug_test() {
    __console_debug "DEBUG" "Param Parser" "$*"
}
