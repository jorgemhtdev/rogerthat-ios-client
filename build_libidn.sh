set -ex

VERSION="1.25"
SDKVERSION="8.1"
MIN_IOS_VERSION="7.0"

if [ ! -e "libidn-${VERSION}.tar.gz" ]; then
    echo "Downloading libidn-${VERSION}.tar.gz"
    curl -LO http://ftp.gnu.org/gnu/libidn/libidn-${VERSION}.tar.gz
else
    echo "Using libidn-${VERSION}.tar.gz"
fi

rm -rf "libidn-${VERSION}"
tar zxf libidn-${VERSION}.tar.gz
cd "libidn-${VERSION}"

export CC='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang'
export CPP="$CC -E"
export AR=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/ar
IOS_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${SDKVERSION}.sdk"
SIM_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator${SDKVERSION}.sdk"
CFLAGS_COMMON="-fmessage-length=0 -pipe -std=c99 -Wno-trigraphs -fpascal-strings -O0 -Wreturn-type -Wunused-variable -Wunused-value -fvisibility=hidden -gdwarf-2 -mthumb"

./configure --host=arm-apple-darwin --disable-shared CFLAGS="-arch armv7 -miphoneos-version-min=${MIN_IOS_VERSION} -isysroot $IOS_SYSROOT $CFLAGS_COMMON"
make clean
make -j5
cp lib/.libs/libidn.a libidn-armv7.a

./configure --host=arm-apple-darwin --disable-shared CFLAGS="-arch armv7s -miphoneos-version-min=${MIN_IOS_VERSION} -isysroot $IOS_SYSROOT $CFLAGS_COMMON"
make clean
make -j5
cp lib/.libs/libidn.a libidn-armv7s.a

./configure --host=arm-apple-darwin --disable-shared CFLAGS="-arch arm64 -miphoneos-version-min=${MIN_IOS_VERSION} -isysroot $IOS_SYSROOT $CFLAGS_COMMON"
make clean
make -j5
cp lib/.libs/libidn.a libidn-arm64.a

./configure --host=arm-apple-darwin --disable-shared CFLAGS="-arch i386 -miphoneos-version-min=${MIN_IOS_VERSION} -isysroot $SIM_SYSROOT $CFLAGS_COMMON"
make clean
make -j5
cp lib/.libs/libidn.a libidn-i386.a

unset CC
unset CPP
./configure
make clean
make -j5
cp lib/.libs/libidn.a libidn-x86_64.a

lipo -create libidn-x86_64.a libidn-armv7.a libidn-armv7s.a libidn-arm64.a libidn-i386.a -output libidn.a

cp libidn.a ../3rdParty/Code/3rdParty/xmppframework/Vendor/libidn/libidn.a

