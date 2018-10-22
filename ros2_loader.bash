#!/usr/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/console_printer.bash
source $DIR/console_common.bash

__CONSOLE_PRINTER_NO_ECHO=$ROS_NO_ECHO

function __ros2_greeter() {
    __console_box_printer "ROS2 CLI Loader.."
    __console_frame_printer
}

function __ros2_finisher() {
    __console_frame_printer
    __console_box_printer "Finished loading ROS2 CLI."
}

function __ros2_read_config() {
    # Source the parameter config file
    source ~/ros2_config.bash
}

function __ros2_common() {
    #echo "ROS2_RMW: "$ROS2_RMW
    # Correct expansion of home folder macro in config parameters
    ROS2_INSTALL_DIR="${ROS2_INSTALL_DIR/#\~/$HOME}"

    #__console_frame_printer "Loading autcompletion macros..."
    #source $ROS2_INSTALL_DIR"share/ros2cli/environment/ros2-argcomplete.bash"

    __console_frame_printer "ROS2: Loading tools..."
    source "/opt/ros/${ROS2_DISTRO}/setup.bash"

    # Load the configured ROS DDS middleware implementation
    __console_log "WARNING" "ROS2 Loader" "Selected Middleware is: '${ROS2_RMW}'"
    case $ROS2_RMW in
        "RTPS")
            echo "RTPS case"
            ros2_dds_rtps
            ;;
        "OSplice")
            echo "OSplice case"
            ros2_dds_opensplice
            ;;
        "RTI")
            echo "RTI case"
            ros2_dds_rti
            ;;
        *)
            echo "Default case"
            ros2_dds_default
            ;;
    esac
}

function ros2_dds_default() {
    ros2_dds_rtps
}

function ros2_dds_rtps() {
    __console_frame_printer "ROS2 Middleware DDS: Loading eProsima Fast RTPS..."
    export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
}

function ros2_dds_rti() {
    __console_frame_printer "ROS2 Middleware DDS: Loading RTI Connext..."
    export RTI_LICENSE_FILE=$RTI_LICENSE
    source ${RTI_SCRIPT/#\~/$HOME} &> /dev/null
    export RMW_IMPLEMENTATION=rmw_connext_cpp
}

function ros2_dds_opensplice() {
    __console_frame_printer "ROS2 Middleware DDS: Loading PrismTech OpenSplice..."
    export RMW_IMPLEMENTATION=rmw_opensplice_cpp
}

function ros2_local_setup() {
    __ros2_common
    __console_frame_printer "ROS2: Setting up local workspace..."
    source $ROS2_INSTALL_DIR"local_setup.bash"
}

function ros2_global_setup() {
    __ros2_common
    __console_frame_printer "ROS2: Setting up global workspace..."
    source $ROS2_INSTALL_DIR"setup.bash"
}

function r2() {
    __ros2_read_config
    # param = (SHORT_OPTION LONG_OPTION TARGET_VARIABLE IS_FLAG DOC OPTS)
    # IDEAS:
    # - Read config file too
    # - "--default OSplice --required"
    # testVariable=false

    # -n, --no-overwrite        Never overwrite an existing value (including by default and passed values)
    # -r, --required            This parameter must be passed
    # -d, --default             If the parameter is not passed, then set it to the given default value

    __console_log "WARNING" "ROS2 Loader" "Configured Middleware is: $ROS2_RMW"
    __console_log "WARNING" "ROS2 Loader" "test variable is: $testVariable"
    param=("m" "middleware" ROS2_RMW false "Choose the RMW implementation for ROS2 to use" "")
    paramTEST=("t" "testing" testVariable false "This is merely a test parameter." "--default bla")
    #echo "TEST: "$testVariable
    param2=("d" "basedir" ROS2_BASE_DIR false "Specify the base directory of the ROS2 installation." "")
    param3=("w" "workspace" ROS2_WS_SETUP false "Specify whether ROS2 should setup a global or local workspace definition." "")
    param4=("i" "installdir" ROS2_INSTALL_DIR false "Specify the install location of ROS2.")
	paramTEST2=("f" "flag" FLAG_FUCK true "Test parameter for flags")
	paramTEST3=("n" "num" NUMBER_FUCK false "Give it a single number")
    #echo "Providing INPUT: $*"
    __console_parse_parameters "$*" param param2 param3 param4 paramTEST paramTEST2 paramTEST3
    # Get return value of parameter parser
    result=$?
    if [[ $result == 0 ]]; then
      #echo "TEST: "$testVariable
      # (m middleware true ${!ROS2_RMW}) (d basedir true ${!ROS2_BASE_DIR}) (w workspace true ${!ROS2_WS_SETUP}) (i installdir true ${!ROS2_INSTALL_DIR})
      __console_log "WARNING" "ROS2 Loader" "Selected Middleware is: $ROS2_RMW"
      __console_log "WARNING" "ROS2 Loader" "test variable is: $testVariable"
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
    fi
}
