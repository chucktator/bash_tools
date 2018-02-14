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

__CONSOLE_LOG_LEVEL=20

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
    for K in "${!INPUT_PARTS[@]}"; do
        __console_log "DEBUG" "OPTION_CONFIG" "$INDENT $K --- ${INPUT_PARTS[$K]}"
    done

    local -A SHORT_OPTIONS
    local -A LONG_OPTIONS
    local -A OPTION_CONFIG
    local OPTION_COUNTER=0

    local DESCEND=true
    local CONTINUE=false
    # Skip the '#RECURSIVE#' flag and continue to the first real input parameter
    if [[ "${INPUT_PARTS[0]}" == "#RECURSIVE#" ]]; then
        DESCEND=false
    fi

    local PARAM_ERROR=false
    # Read in parameter config
    for option in $PARAMETER_DEFINITIONS; do
        declare -n optionArray="$option"
        __console_log "DEBUG" "Param Validator" "$INDENT Processing option with short index: ${optionArray[$__CONSOLE_SHORT_OPT_INDEX]}"
        #(SHORT_OPTION LONG_OPTION TARGET_VARIABLE IS_FLAG DOC OPTS)
        local INDEX="-${optionArray[$__CONSOLE_SHORT_OPT_INDEX]}"
        SHORT_OPTIONS["$INDEX"]="$OPTION_COUNTER"
        INDEX=--"${optionArray[$__CONSOLE_LONG_OPT_INDEX]}"
        LONG_OPTIONS["$INDEX"]="$OPTION_COUNTER"
        OPTION_CONFIG["$OPTION_COUNTER,SHORT_OPT"]="${optionArray[$__CONSOLE_SHORT_OPT_INDEX]}"
        OPTION_CONFIG["$OPTION_COUNTER,LONG_OPT"]="${optionArray[$__CONSOLE_LONG_OPT_INDEX]}"
        OPTION_CONFIG["$OPTION_COUNTER,TARGET_VARIABLE"]="${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}"
        OPTION_CONFIG["$OPTION_COUNTER,IS_FLAG"]="${optionArray[__CONSOLE_IS_FLAG_INDEX]}"
        OPTION_CONFIG["$OPTION_COUNTER,DOC"]="${optionArray[__CONSOLE_DOC_INDEX]}"

        __console_log "DEBUG" "Param Validator" "$INDENT Option shall be saved in: "${OPTION_CONFIG["$OPTION_COUNTER,TARGET_VARIABLE"]}

        OPTION_NO_OVERWRITE=false
        OPTION_DEFAULT_VALUE=""
        OPTION_REQUIRED=false
        # Read sub-options from the current option to determine further processing
        if [[ -n "${optionArray[__CONSOLE_OPTS_INDEX]}" ]]; then
            __console_log "DEBUG" "Param Validator" "$INDENT Parameter has parameters"
            if [[ $DESCEND == true ]]; then
                INDENT="|--"
                __console_log "DEBUG_FULL" "Param Validator" "$INDENT Descending into parameter's parameters"
                # overwrite=("n" "no-overwrite" ${OPTION_CONFIG['$OPTION_COUNTER,NO_OVERWRITE']} true)
                # default=("d" "default" ${OPTION_CONFIG['$OPTION_COUNTER,DEFAULT_VALUE']} false)
                # required=("r" "required" ${OPTION_CONFIG['$OPTION_COUNTER,REQUIRED']} true)
                # __console_parse_parameters "#RECURSIVE# ${optionArray[__CONSOLE_OPTS_INDEX]}" overwrite default required
                overwrite=("n" "no-overwrite" OPTION_NO_OVERWRITE true)
                default=("d" "default" OPTION_DEFAULT_VALUE false)
                required=("r" "required" OPTION_REQUIRED true)
                __console_parse_parameters "#RECURSIVE# ${optionArray[__CONSOLE_OPTS_INDEX]}" overwrite default required
                OPTION_CONFIG["$OPTION_COUNTER,NO_OVERWRITE"]=$OPTION_NO_OVERWRITE
                OPTION_CONFIG["$OPTION_COUNTER,DEFAULT_VALUE"]=$OPTION_DEFAULT_VALUE
                OPTION_CONFIG["$OPTION_COUNTER,REQUIRED"]=$OPTION_REQUIRED
                __console_log "DEBUG" "Param Validator" "$INDENT No Overwrite: ${OPTION_CONFIG['$OPTION_COUNTER,NO_OVERWRITE']}"
                INDENT=""
            fi
            __console_log "DEBUG" "Param Validator" "$INDENT Finished processing sub-options."
        else
            __console_log "DEBUG_FULL" "Param Validator" "$INDENT No sub-options specified."
        fi
        local FOUND=-1
        local NEXT_STRING="#"
        for ((i=0; i<${#INPUT_PARTS[@]}; i++)); do
            if [[ ${INPUT_PARTS[$i]} == "-${OPTION_CONFIG["$OPTION_COUNTER,SHORT_OPT"]}" || ${INPUT_PARTS[$i]} == "--${OPTION_CONFIG["$OPTION_COUNTER,LONG_OPT"]}" ]]; then
                FOUND=$i
                NEXT_STRING=${INPUT_PARTS[(($i+1))]:0:1}
            fi
        done
        if [[ -n "${OPTION_CONFIG["$OPTION_COUNTER,DEFAULT_VALUE"]}" && ${OPTION_CONFIG["$OPTION_COUNTER,NO_OVERWRITE"]} == false ]]; then
            printf -v "${OPTION_CONFIG["$OPTION_COUNTER,TARGET_VARIABLE"]}" %s "${OPTION_CONFIG["$OPTION_COUNTER,DEFAULT_VALUE"]}"
            __console_log "WARNING" "Param Validator" "Default value specified: ${OPTION_CONFIG["$OPTION_COUNTER,DEFAULT_VALUE"]}"
            __console_log "WARNING" "Param Validator" "Variable set to: ${!OPTION_CONFIG["$OPTION_COUNTER,TARGET_VARIABLE"]}"
        fi
        if [[ $FOUND -ge 0 ]]; then
            local paramString="'-${OPTION_CONFIG["$OPTION_COUNTER,SHORT_OPT"]}, --${OPTION_CONFIG["$OPTION_COUNTER,LONG_OPT"]}'"
            __console_log "DEBUG_FULL" "Param Validator" "IS_FLAG: ${OPTION_CONFIG["$OPTION_COUNTER,IS_FLAG"]} - NEXT_STRING: '$NEXT_STRING'"
            if [[ ${OPTION_CONFIG["$OPTION_COUNTER,IS_FLAG"]} == false && $NEXT_STRING == "-" ]]; then
                __console_log "ERROR" "Param Validator" "$INDENT A required value for $paramString is missing."
                PARAM_ERROR=true
            elif [[ ${OPTION_CONFIG["$OPTION_COUNTER,IS_FLAG"]} == true && $NEXT_STRING != "-" ]]; then
                __console_log "ERROR" "Param Validator" "$INDENT The flag $paramString was passed a parameter."
                PARAM_ERROR=true
                # else
                #     __console_log "ERROR" "Param Validator" "$INDENT An unknown error occurred processing $paramString. Exit."
                #     PARAM_ERROR=true
            fi
        elif [[ $OPTION_REQUIRED == true ]]; then
            __console_log "ERROR" "Param Validator" "Required parameter '-${optionArray[$__CONSOLE_SHORT_OPT_INDEX]}, --${optionArray[$__CONSOLE_LONG_OPT_INDEX]}' is missing."
            PARAM_ERROR=true
        fi
        ((OPTION_COUNTER++))
    done

    for K in "${!SHORT_OPTIONS[@]}"; do
        __console_log "DEBUG" "OPTION_CONFIG" "$INDENT $K --- ${SHORT_OPTIONS[$K]}"
    done
    for K in "${!LONG_OPTIONS[@]}"; do
        __console_log "DEBUG" "OPTION_CONFIG" "$INDENT $K --- ${LONG_OPTIONS[$K]}"
    done
    for K in "${!OPTION_CONFIG[@]}"; do
        __console_log "DEBUG" "OPTION_CONFIG" "$INDENT $K --- ${OPTION_CONFIG[$K]}"
    done

    if [[ $PARAM_ERROR == true ]]; then
        exit 1
    fi

    for ((i=0; i<${#INPUT_PARTS[@]}; i++)); do
        __console_log "DEBUG" "Param Parser" "$INDENT Read segment $i: ${INPUT_PARTS[$i]}"
        DESCEND=true
        # Skip the '#RECURSIVE#' flag and continue to the first real input parameter
        if [[ ${INPUT_PARTS[$i]} == "#RECURSIVE#" ]]; then
            DESCEND=false
            continue
        fi
        # Break if the end flag is detected
        if [[ ${INPUT_PARTS[$i]} == "--" ]]; then
            break
        fi
        if [[ ${INPUT_PARTS[$i]} == "-h" || ${INPUT_PARTS[$i]} == "--help" ]]; then
            __console_box_printer "Parameter Help Page"
            for option in $PARAMETER_DEFINITIONS; do
                declare -n optionArray="$option"
                __console_print_text_padded_right 25 false "-${optionArray[__CONSOLE_SHORT_OPT_INDEX]}, --${optionArray[__CONSOLE_LONG_OPT_INDEX]}"
                __console_print_text true "${optionArray[__CONSOLE_DOC_INDEX]}"
            done
            exit 0
        fi

        local OPTION_KEY="${INPUT_PARTS[$i]}"
        if [[ ${SHORT_OPTIONS["$OPTION_KEY"]} ]]; then
            OPTION_INDEX=${SHORT_OPTIONS["$OPTION_KEY"]}
        elif [[ ${LONG_OPTIONS["$OPTION_KEY"]} ]]; then
            OPTION_INDEX=${LONG_OPTIONS["$OPTION_KEY"]}
        else
            OPTION_INDEX=-10
        fi
        __console_log "DEBUG_FULL" "Param Parser" "$INDENT OPTION_INDEX is $OPTION_INDEX."

        # if [[ -z ${OPTION_CONFIG["$OPTION_INDEX,TARGET_VARIABLE"]} ]]; then
        #     __console_log "DEBUG_FULL" "Param Parser" "$INDENT Variable for key $OPTION_INDEX,TARGET_VARIABLE is NOT empty"
        # else
        #     __console_log "DEBUG_FULL" "Param Parser" "$INDENT Variable for key $OPTION_INDEX,TARGET_VARIABLE is empty"
        # fi

        if [[ "$OPTION_INDEX" -ge 0 ]]; then
            if [[ -n "${!OPTION_CONFIG["$OPTION_INDEX,TARGET_VARIABLE"]}" ]]; then
                __console_log "DEBUG_FULL" "Param Parser" "$INDENT Variable is NOT empty."
                if [[ "${OPTION_CONFIG["$OPTION_INDEX,NO_OVERWRITE"]}" == true ]]; then
                    __console_log "WARNING" "Param Parser" "$INDENT Variable is not empty and configured as 'no-overwrite'. Continue."
                    continue
                fi
            else
                __console_log "DEBUG" "Param Parser" "$INDENT Variable is empty."
            fi
            if [[ ${INPUT_PARTS[(($i+1))]:0:1} != "-" && ${OPTION_CONFIG["$OPTION_INDEX,IS_FLAG"]} == false ]]; then
               __console_log "DEBUG_FULL" "Param Parser" "$INDENT Arg case"
               # A parameter is required for the current opition, so read it and advance the pointer by 2
               printf -v "${OPTION_CONFIG["$OPTION_INDEX,TARGET_VARIABLE"]}" %s ""
               while [[ ${INPUT_PARTS[(($i+1))]:0:1} != "-" ]]; do
                   __console_log "DEBUG_FULL" "Param Parser" "$INDENT Possible parameter value would be: ${INPUT_PARTS[$((i+1))]}"
                   if [[ "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" ]]; then
                       printf -v "${OPTION_CONFIG["$OPTION_INDEX,TARGET_VARIABLE"]}" %s "${!OPTION_CONFIG["$OPTION_INDEX,TARGET_VARIABLE"]} ${INPUT_PARTS[$((i+1))]}"
                   else
                       printf -v "${OPTION_CONFIG["$OPTION_INDEX,TARGET_VARIABLE"]}" %s "${INPUT_PARTS[$((i+1))]}"
                   fi
                   ((i++))
                   __console_log "DEBUG_FULL" "Param Parser" "$INDENT Next Possible: ${INPUT_PARTS[$((i+1))]}"
               done
               __console_log "DEBUG" "Param Parser" "$INDENT Wrote follwing to variable: ${!OPTION_CONFIG["$OPTION_INDEX,TARGET_VARIABLE"]}"
            elif [[ ${INPUT_PARTS[(($i+1))]:0:1} == "-" && ${OPTION_CONFIG["$OPTION_INDEX,IS_FLAG"]} == true ]]; then
               __console_log "DEBUG_FULL" "Param Parser" "$INDENT Flag case"
               # The current option is only a flag, so set it and advance the pointer by 1
               printf -v "${OPTION_CONFIG["$OPTION_INDEX,TARGET_VARIABLE"]}" %s "true"
               __console_log "DEBUG" "Param Parser" "$INDENT Wrote follwing to variable:  ${!OPTION_CONFIG["$OPTION_INDEX,TARGET_VARIABLE"]}"
            fi
        fi
    done

        # for option in $PARAMETER_DEFINITIONS; do
        #     declare -n optionArray="$option"
        #     #echo -e "Array: ${optionArray[@]}"
        #     __console_log "DEBUG_FULL" "Param Parser" "$INDENT Array: ${optionArray[@]}"
        #     __console_log "DEBUG_FULL" "Param Parser" "$INDENT Short Option: ${optionArray[__CONSOLE_SHORT_OPT_INDEX]}"
        #     __console_log "DEBUG_FULL" "Param Parser" "$INDENT Long Option: ${optionArray[__CONSOLE_LONG_OPT_INDEX]}"
        #     __console_log "DEBUG_FULL" "Param Parser" "$INDENT Is Flag: ${optionArray[__CONSOLE_IS_FLAG_INDEX]}"
        #     __console_log "DEBUG_FULL" "Param Parser" "$INDENT Single Value: ${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}"
        #     __console_log "DEBUG_FULL" "Param Parser" "$INDENT Single Value Expanded: ${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}"
        #     __console_log "DEBUG_FULL" "Param Parser" "$INDENT Checking -${optionArray[__CONSOLE_SHORT_OPT_INDEX]} equal to ${INPUT_PARTS[$i]}"
        #     __console_log "DEBUG_FULL" "Param Parser" "$INDENT Checking --${optionArray[__CONSOLE_LONG_OPT_INDEX]} equal to ${INPUT_PARTS[$i]}"
        #     __console_log "DEBUG_FULL" "Param Parser" "$INDENT Possible parameter value would be: ${INPUT_PARTS[$((i+1))]}"
        #
        #     # Read sub-options from the current option to determine further processing
        #     if [[ -n "${optionArray[__CONSOLE_OPTS_INDEX]}" ]]; then
        #         __console_log "DEBUG" "Param Parser" "$INDENT Parameter has parameters"
        #         if [[ $DESCEND == true ]]; then
        #             INDENT="|--"
        #             __console_log "DEBUG_FULL" "Param Parser" "$INDENT Descending into parameter's parameters"
        #             overwrite=("n" "no-overwrite" OPTION_NO_OVERWRITE true)
        #             default=("d" "default" OPTION_DEFAULT_VALUE false)
        #             required=("r" "required" OPTION_REQUIRED true)
        #             __console_parse_parameters "#RECURSIVE# ${optionArray[__CONSOLE_OPTS_INDEX]}" overwrite default required
        #             __console_log "DEBUG" "Param Parser" "$INDENT No Overwrite: $OPTION_NO_OVERWRITE"
        #             INDENT=""
        #         fi
        #         __console_log "DEBUG" "Param Parser" "$INDENT Finished processing sub-options."
        #     else
        #         __console_log "DEBUG_FULL" "Param Parser" "$INDENT No sub-options specified."
        #     fi
        #
        #     if [[ "-${optionArray[__CONSOLE_SHORT_OPT_INDEX]}" == "${INPUT_PARTS[$i]}" || "--${optionArray[__CONSOLE_LONG_OPT_INDEX]}" == "${INPUT_PARTS[$i]}" ]]; then
        #         __console_log "DEBUG" "Param Parser" "$INDENT --OPTION MATCHED--"
        #         __console_log "DEBUG_FULL" "Param Parser" "$INDENT Examined character: ${INPUT_PARTS[(($i+1))]:0:1}"
        #         __console_log "DEBUG" "Param Parser" "$INDENT Is Flag: ${optionArray[__CONSOLE_IS_FLAG_INDEX]}"
        #         if [[ -z "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" ]]; then
        #             __console_log "DEBUG_FULL" "Param Parser" "$INDENT Variable is NOT empty."
        #             if [[ $OPTION_NO_OVERWRITE == true ]]; then
        #                 __console_log "WARNING" "Param Parser" "$INDENT Variable is not empty and configured as 'no-overwrite'. Continue."
        #                 continue
        #             fi
        #         else
        #             __console_log "DEBUG" "Param Parser" "$INDENT Variable is empty."
        #         fi
        #         if [[ ${INPUT_PARTS[(($i+1))]:0:1} != "-" && ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == false ]]; then
        #             __console_log "DEBUG_FULL" "Param Parser" "$INDENT Arg case"
        #             # A parameter is required for the current opition, so read it and advance the pointer by 2
        #             printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s ""
        #             while [[ ${INPUT_PARTS[(($i+1))]:0:1} != "-" ]]; do
        #                 __console_log "DEBUG_FULL" "Param Parser" "$INDENT Possible parameter value would be: ${INPUT_PARTS[$((i+1))]}"
        #                 if [[ -n "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" ]]; then
        #                     printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s "${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]} ${INPUT_PARTS[$((i+1))]}"
        #                 else
        #                     printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s "${INPUT_PARTS[$((i+1))]}"
        #                 fi
        #                 ((i++))
        #                 __console_log "DEBUG_FULL" "Param Parser" "$INDENT Next Possible: ${INPUT_PARTS[$((i+1))]}"
        #             done
        #             __console_log "DEBUG" "Param Parser" "$INDENT Wrote follwing to variable:"${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}
        #         elif [[ ${INPUT_PARTS[(($i+1))]:0:1} == "-" && ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == true ]]; then
        #             __console_log "DEBUG_FULL" "Param Parser" "$INDENT Flag case"
        #             # The current option is only a flag, so set it and advance the pointer by 1
        #             printf -v "${optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}" %s "true"
        #             __console_log "DEBUG" "Param Parser" "$INDENT Wrote follwing to variable: ${!optionArray[__CONSOLE_TARGET_VARIABLE_INDEX]}"
        #         else
        #             __console_log "ERROR" "Param Parser" "$INDENT Error Case"
        #             # An error occured, which getopt should have caught
        #             if [[ ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == false ]]; then
        #                 __console_log "ERROR" "Param Parser" "$INDENT A required value is missing. Exit."
        #                 exit 3
        #             elif [[ ${optionArray[__CONSOLE_IS_FLAG_INDEX]} == true ]]; then
        #                 __console_log "ERROR" "Param Parser" "$INDENT A flag was passed a parameter. Exit."
        #                 exit 4
        #             else
        #                 __console_log "ERROR" "Param Parser" "$INDENT An unknown error occurred. Exit."
        #                 exit 5
        #             fi
        #         fi
        #         break
        #     fi
        # done
}

function exists(){
  if [[ "$2" != in ]]; then
    echo "Incorrect usage."
    echo "Correct usage: exists {key} in {array}"
    return
  fi
  echo $3
  echo $1
  eval '${$3[$1]}'
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
