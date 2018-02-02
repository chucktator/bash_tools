#!/usr/bin/bash

__CONSOLE_SHORT_OPT_INDEX=0
__CONSOLE_LONG_OPT_INDEX=1
__CONSOLE_IS_FLAG_INDEX=3
__CONSOLE_TARGET_VARIABLE_INDEX=2

__console_parse_parameters() {
    getopt --test > /dev/null
    if [[ $? -ne 4 ]]; then
        echo "I’m sorry, `getopt --test` failed in this environment."
        exit 1
    fi

    # First parameter must be the options string passed to the calling script, store it and advance 1
    INPUT=$1
    shift

    OPTIONS="h"
    LONGOPTIONS="help"

    PARAMETER_DEFINITIONS=${@:1}
    INPUT_PARTS=()
    for word in $INPUT; do
        INPUT_PARTS+=("$word")
    done
    INPUT_PARTS+=("--")

    for ((i=0; i<${#INPUT_PARTS[@]}; i++)); do
        echo "Part $i: ${INPUT_PARTS[$i]}"
        if [[ ${INPUT_PARTS[$i]} == "--" ]]; then
            break
        fi
        for option in $PARAMETER_DEFINITIONS; do
            declare -n optionArray="$option"
            echo "Array: ${optionArray[@]}"
            echo "Short Option: "${optionArray[__CONSOLE_SHORT_OPT_INDEX]}
            echo "Long Option: "${optionArray[__CONSOLE_LONG_OPT_INDEX]}
            echo "Is Flag: "${optionArray[__CONSOLE_IS_FLAG_INDEX]}
            echo "Single Value: "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}
            echo "Single Value Expanded: "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}
            echo "Checking -"${optionArray[__CONSOLE_SHORT_OPT_INDEX]}" equal to ${INPUT_PARTS[$i]}"
            echo "Checking --"${optionArray[__CONSOLE_LONG_OPT_INDEX]}" equal to ${INPUT_PARTS[$i]}"
            echo "Possible parameter value would be: ${INPUT_PARTS[$((i+1))]}"
            if [[ "-"${optionArray[__CONSOLE_SHORT_OPT_INDEX]} == ${INPUT_PARTS[$i]} || "--"${optionArray[__CONSOLE_LONG_OPT_INDEX]} == ${INPUT_PARTS[$i]} ]]; then
                echo "Examined character: ${INPUT_PARTS[(($i+1))]:0:1}"
                echo "Is Flag: ${optionArray[__CONSOLE_IS_FLAG_INDEX]}"
                if [[ ${INPUT_PARTS[(($i+1))]:0:1} != "-" && ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == false ]]; then
                    echo "Arg case"
                    # A parameter is required for the current opition, so read it and advance the pointer by 2
                    printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s ""
                    while [[ ${INPUT_PARTS[(($i+1))]:0:1} != "-" ]]; do
                        echo "Possible parameter value would be: ${INPUT_PARTS[$((i+1))]}"
                        if [ -n "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" ]; then
                            printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]} ${INPUT_PARTS[$((i+1))]}"
                        else
                            printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s "${INPUT_PARTS[$((i+1))]}"
                        fi
                        echo "i is now: $i"
                        ((i++))
                        echo "i is now: $i"
                        echo "Next Possible: ${INPUT_PARTS[$((i+1))]}"
                    done
                    echo "Wrote follwing to variable: ${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}"
                elif [[ ${INPUT_PARTS[(($i+1))]:0:1} == "-" && ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == true ]]; then
                    echo "Flag case"
                    # The current option is only a flag, so set it and advance the pointer by 1
                    printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s "true"
                else
                    echo "Error Case"
                    # An error occured, which getopt should have caught
                    if [[ ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == false ]]; then
                        echo "A required parameter is missing. Exit."
                        exit 3
                    elif [[ ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == true ]]; then
                        echo "A flag was passed a parameter. Exit."
                        exit 4
                    else
                        echo "An unknown error occurred. Exit."
                        exit 5
                    fi
                fi
            fi
        done
    done
}
