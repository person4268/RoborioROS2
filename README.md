### Roborio RCLCPP
This is a builder for the ros2 RCLCPP client library and its dependencies for the NI roborio. It currently is only able to use Fast-DDS from Eprosima, but CycloneDDS support is being resolved currently.

## Setup
In order to use this builder tool to release a version of rclcpp for the roborio, the following needs to be set up.
1. Install wpilib on an ubuntu computer, and make sure the C++ development tools are selected
2. Clone this repository into a directory on the desired computer
3. Run the following commands to setup the submodules inside this directory:
```
git submodule init
git submodule update
```
4. You can now add any additional packages (like message libraries you wish to use).
5. In rclcpp_components, modify the (CMakeLists.txt)[] and comment out the following lines. In the current release they are lines 64 - 67
```
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_link_libraries(component_container "stdc++fs")
  target_link_libraries(component_container_mt "stdc++fs")
endif()
```
6. In src/ros2/yaml_cpp_vendor/CMakeLists.txt, comment out or remove the following lines:
```
if(NOT WIN32)
  list(APPEND YAML_C_FLAGS -w)
  list(APPEND YAML_CXX_FLAGS -std=c++14 -w)
endif()
```
7. Make sure the host computer has a working installation of ros and colcon.
8. Open a terminal session that does not have any version of ros currently sourced. This is crucial as we cannot pull in the host builds of all the libraries for the roborio build. This can be accomplished by removing the `source /opt/ros/<version>/setup.bash` from your `~/.bashrc` and opening a new terminal session.

## Building
There are 3 main scripts that control the building of rclcpp for the roborio. `build.sh`, which orchestrates the whole building process. `download_deps.sh`, which handles downloading dependencies for the roborio and adding them to the cross compilation root. And `mark_ignore_deps.sh`, which creates `COLCON_IGNORE` files on all unnecessary packages needed for running rclcpp on the rio. This is the one that may need additional changes for any additional libraries you may want to introduce. There are two other important files, `rio_toolchain.cmake` and `colcon.meta`. `rio_toolchain.cmake` is the toolchain file which cmake uses to produce the library. this points to the rio compiler for the given year. `colcon.meta` is a configuration file for colcon which allows it to turn on and off certain configuration variables based on what packages it is building. this file should not need to be modified. 


In order to build the library for the rio, all you need to invoke is `./build.sh` in a terminal session. It will automatically orchestrate the whole build process, and produce the resulting tarball. The tarball will sow up in the root directory with the name `rclcpp_rio.tar` which is a tarball of install and adds some of the needed libraries for deploying to the rio. 

Please note that you may need to update the paths in build.sh, downloadDeps.py, and rio_toolchain.cmake to match the paths of your RoboRIO toolchain.

## Usage
For an example use case, please see the [RCLCPP Rio Example project](example/README.md) in the example folder of this repository. It provides a working `build.gradle` file as well as example code for a node, a publisher and a subscriber. At this time, the rio version of the library does not support using the actionlib or lifecycle systems built into ros, as they do not compile properly. 

Ideallly, you should package it into a vendordep installed in your local maven repository. Put the include folder into the headers zip, and put the lib folder, sans the python folders in the athena and athenadebug zip files. For native simulation compilation, can have a separate entry that only supports the x86-64 version and uses the x86-64 headers. 
