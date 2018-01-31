#!/usr/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/console_common.bash
source $DIR/console_printer.bash

__CONSOLE_PRINTER_NO_ECHO=$ROS_NO_ECHO

function __ros2_greeter {
    __console_box_printer "ROS2 CLI Loader"
    __console_printer
}

function __ros2_finisher {
    __console_printer
    __console_box_printer "Finished loading ROS2 CLI."
}

function __ros2_read_config {
    # Source the parameter config file
    source ~/ros2_config.bash
}

function __ros2_common {
    #echo "ROS2_RMW: "$ROS2_RMW
    # Correct expansion of home folder macro in config parameters
    ROS2_INSTALL_DIR="${ROS2_INSTALL_DIR/#\~/$HOME}"

    __console_printer "Loading autcompletion macros..."
    source $ROS2_INSTALL_DIR"share/ros2cli/environment/ros2-argcomplete.bash"

    # Load the configured ROS DDS middleware implementation
    case $ROS2_RMW in
        "RTPS")
            ros2_dds_rtps
            ;;
        "OSplice")
            ros2_dds_opensplice
            ;;
        "RTI")
            ros2_dds_rti
            ;;
        *)
            ros2_dds_default
            ;;
    esac
}

function ros2_dds_default {
    ros2_dds_rtps
}

function ros2_dds_rtps {
    __console_printer "ROS2 Middleware DDS: Loading eProsima Fast RTPS..."
    export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
}

function ros2_dds_rti {
    __console_printer "ROS2 Middleware DDS: Loading RTI Connext..."
    export RTI_LICENSE_FILE=$RTI_LICENSE
    source ${RTI_SCRIPT/#\~/$HOME} &> /dev/null
    export RMW_IMPLEMENTATION=rmw_connext_cpp
}

function ros2_dds_opensplice {
    __console_printer "ROS2 Middleware DDS: Loading PrismTech OpenSplice..."
    export RMW_IMPLEMENTATION=rmw_opensplice_cpp
}

function ros2_local_setup {
    __ros2_common
    __console_printer "ROS2: Setting up local workspace..."
    source $ROS2_INSTALL_DIR"local_setup.bash"
}

function ros2_global_setup {
    __ros2_common
    __console_printer "ROS2: Setting up global workspace..."
    source $ROS2_INSTALL_DIR"setup.bash"
}

function r2 {
    __ros2_read_config
    # param = (SHORT_OPTION LONG_OPTION PARAMETER OVERWRITE TARGET_VARIABLE)
    testVariable=false
    param=("m" "middleware" true ROS2_RMW)
    paramTEST=("t" "testing" false testVariable)
    #echo "TEST: "$testVariable
    param2=("d" "basedir" true ROS2_BASE_DIR)
    param3=("w" "workspace" true ROS2_WS_SETUP)
    param4=("i" "installdir" true ROS2_INSTALL_DIR)
    #echo "Providing INPUT: $*"
    __console_parse_parameters "$*" param param2 param3 param4 paramTEST
    echo "TEST: "$testVariable
    # (m middleware true ${!ROS2_RMW}) (d basedir true ${!ROS2_BASE_DIR}) (w workspace true ${!ROS2_WS_SETUP}) (i installdir true ${!ROS2_INSTALL_DIR})

    __ros2_greeter
    case $ROS2_WS_SETUP in
        "Global")
            ros2_global_setup
            ;;
        "Local")
            ros2_local_setup
            ;;
    esac
    __ros2_finisher
}