#!/usr/bin/bash

function __console_parse_parameters {
    getopt --test > /dev/null
    if [[ $? -ne 4 ]]; then
        echo "I’m sorry, `getopt --test` failed in this environment."
        exit 1
    fi

    INPUT=$1
    #echo "INPUT: $INPUT"
    #echo "ROS2_RMW: "$ROS2_RMW
    shift

    OPTIONS=""
    LONGOPTIONS=""

    PARAMETER_DEFINITIONS=${@:1}

    for var in $PARAMETER_DEFINITIONS; do
        declare -n optionArray=$var
        #echo "Array: ${optionArray[@]}"
        #echo "Short Option: "${optionArray[0]}
        #echo "Long Option: "${optionArray[1]}
        #echo "Param: "${optionArray[2]}
        #echo "Required Param: "${optionArray[3]}
        #echo "Single Value: "${optionArray[3]}
        #echo "Single Value Expanded: "${!optionArray[3]}
        #DELIM=""
        #[[ ${optionArray[2]} == true && ${optionArray[2]} == false ]] && DELIM="::"
        [[ ${optionArray[2]} == true && ${optionArray[2]} == true ]] && DELIM=":" || DELIM=""
        OPTIONS="$OPTIONS${optionArray[0]}$DELIM"
        LONGOPTIONS="$LONGOPTIONS${optionArray[1]},"

        #declare ${optionArray[2]}="bla"
    done

    # First parameter must be the options string passed to the calling script
    #echo "$OPTIONS"
    #echo "$LONGOPTIONS"


    # -temporarily store output to be able to check for errors
    # -e.g. use “--options” parameter by name to activate quoting/enhanced mode
    # -pass arguments only via   -- "$@"   to separate them correctly
    PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- $INPUT)
    if [[ $? != 0 ]]; then
        # e.g. $? == 1
        #  then getopt has complained about wrong arguments to stdout
        exit 2
    fi
    # read getopt’s output this way to handle the quoting right:
    #echo "$PARSED"
    #set -f
    #array=("${PARSED//--/ }")
    #echo $array
    eval set -- "$PARSED"

    COUNT=0
    NEXT=0
    while true; do
        if [[ $1 == "--" ]]; then
            break
        fi
        #echo "Current param: $1"
        SHIFT_EXTRA=false
        for option in $PARAMETER_DEFINITIONS; do
            declare -n optionArray="$option"
            #echo "Array: ${optionArray[@]}"
            #echo "Short Option: "${optionArray[0]}
            #echo "Long Option: "${optionArray[1]}
            #echo "Param: "${optionArray[2]}
            #echo "Required Param: "${optionArray[3]}
            #echo "Single Value: "${optionArray[3]}
            #echo "Single Value Expanded: "${!optionArray[3]}
            #echo "Checking -"${optionArray[0]}" equal to $1"
            #echo "Checking --"${optionArray[1]}" equal to $1"
            if [[ "-"${optionArray[0]} == $1 || "--"${optionArray[1]} == $1 ]]; then
                #echo "Taking value: "$2
                #echo "First character: ${2:0:1}"
                #eval "${optionArray[3]}=$2"
                #echo "varname: $varname"
                #typeset -n $varname=$2
                if [[ ${2:0:1} != "-" && ${optionArray[2]} == true ]]; then
                    printf -v "${optionArray[3]}" %s "$2"
                    #echo "Set to: "${!optionArray[3]}
                    SHIFT_EXTRA=true
                elif [[ ${2:0:1} == "-" && ${optionArray[2]} == false ]]; then
                    printf -v "${optionArray[3]}" %s "true"
                fi
            fi
        done
        if [[ $SHIFT_EXTRA == true ]]; then
            #echo "Performing additional shift"
            shift 2
        else
            shift
        fi

    done

    #echo "ROS2_RMW: "$ROS2_RMW
}
