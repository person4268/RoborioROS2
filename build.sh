#!/bin/bash

# constants used for build
export TOOLCHAIN=$(pwd)/rio_toolchain.cmake
export COLCON_META=$(pwd)/colcon.meta
export YEAR=2022
export ARM_PREFIX=arm-frc${YEAR}-linux-gnueabi
export CROSS_ROOT=${HOME}/.gradle/toolchains/frc/${YEAR}/roborio/${ARM_PREFIX}
export DDS_IMPL=FastRTPS

# pull in cross root deps and compilier
echo "Confirguring cross compile sysroot"
python3 ./downloadDeps.py

echo "Configuring the installation"
./mark_ignore_deps.sh

./build_asio.sh
./build_eigen.sh

# clean the last build if it exists
#echo "Cleaning prior build artifacts"
#rm -rf build install log

# Create the dirs needed for install processes that pre-run
mkdir -p install/lib install/include

if [[ "$DDS_IMPL" == *FastRTPS* ]]; then
	# build tinyxml2 for the target and copy to sysroot
	source ./build_target_tinyxml.sh
        # Use a newer (patched) version of FindThreads.cmake since they vendor their own and it has bugs
        cp ./FindThreads-patched.cmake /src/eprosima/Fast-DDS/cmake/modules/FindThreads.cmake
else
	# Build the host copy of cyclonedds to allow for config and message generation
	source ./build_host_cyclone.sh
fi

# build it!
echo "Executing build"
colcon build --merge-install --metas ${COLCON_META} --cmake-args "--no-warn-unused-cli" -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN} -DCMAKE_VERBOSE_MAKEFILE=ON -DRCL_LOGGING_IMPLEMENTATION=rcl_logging_noop
	

./make_bundle.sh
