## Middleware (DDS) implementation to be used
## Can be:
## - RTPS:			FastRTPS, the default implementation bundled with ROS
## - OSplice:		PrismTech OpenSplice
## - RTI:			RTI Connext DDS implementation (proprietary and neccessary for realtime)
ROS2_RMW="RTPS"

ROS2_BASE_DIR="~/ros2_ws/"

ROS2_NO_ECHO=false

ROS2_DISTRO="bouncy"

## Set the setup script to be used, either:
## - Global:		Assuming one workspace, this sets up the workspace globally
## - Local:			Useful when using multiple ROS2 worskspaces
ROS2_WS_SETUP="Global"

ROS2_INSTALL_DIR=$ROS2_BASE_DIR"install/"

RTI_LICENSE="~/rti_connext_dds-5.3.0/rti_license.dat"

RTI_SCRIPT="~/rti_connext_dds-5.3.0/resource/scripts/rtisetenv_x64Linux3gcc5.4.0.bash"
