#!/usr/bin/bash

function __ros1_read_config() {
    # Source the parameter config file
    source ~/ros1_config.bash
}

function __ros1_greeter() {
    __console_box_printer "ROS 1 CLI Loader.."
    __console_frame_printer
}

function __ros1_finisher() {
    __console_frame_printer
    __console_box_printer "Finished loading ROS 1 CLI."
}

function r1() {
	__ros1_read_config

	__ros1_greeter
	__console_frame_printer "ROS1: Loading tools..."
	# __console_wait_spinner
	source "/opt/ros/$ROS1_DISTRO/setup.bash"
	__console_frame_printer "ROS1: Loading workspace environment..."
	source ${ROS1_BASE_DIR/#\~/$HOME}"devel/setup.bash"
	__ros1_finisher
}
