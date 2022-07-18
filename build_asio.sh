git clone https://github.com/chriskohlhoff/asio.git

ASIO_DIR=$(pwd)/asio
YEAR=2022
PREFIX=arm-frc${YEAR}-linux-gnueabi

if [[ -z $CROSS_ROOT ]]; then
    echo "Cross root not set. Please specify a cross root"
    exit -1
fi

cd ${ASIO_DIR}/asio

./autogen.sh
export CC=${CROSS_ROOT}/../bin/${PREFIX}-gcc
export CXX=${CROSS_ROOT}/../bin/${PREFIX}-g++
export LD=${CROSS_ROOT}/../bin/${PREFIX}-ld
# Not sure if they're necessary but they were the more important arguments in rio_toolchain
export CFLAGS="-fdata-sections -fPIC -fpermissive -fsigned-char"
export CXXFLAGS=${CFLAGS}
./configure --prefix=${CROSS_ROOT}/usr --host=${PREFIX}

make -j4
make install