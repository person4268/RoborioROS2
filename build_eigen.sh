git clone https://gitlab.com/libeigen/eigen.git

EIGEN_DIR=$(pwd)/eigen/
mkdir -p eigen/build/

# Setup default arg for this function
if [[ -z $TOOLCHAIN ]]; then
    echo "No toolchain given for tinyxml build"
    TOOLCHAIN=$(pwd)/rio_toolchain.cmake
fi

if [[ -z $CROSS_ROOT ]]; then
    echo "Cross root not set. Please specify a cross root"
    exit -1
fi

cd ${EIGEN_DIR}/build

cmake -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN} ..

cmake --build .

cmake --install . --prefix ${CROSS_ROOT}/usr

# Include path symlink
ln -s ${CROSS_ROOT}/usr/include/eigen3/Eigen ${CROSS_ROOT}/usr/include/Eigen