
libidn.a is built manually (http://unrealexpectations.com/blog/2011/12/xmppframework-ios-libidn-all_load-failure/)

procedure:
download libidn-1.24 from http://ftp.gnu.org/gnu/libidn/

$ ./configure --host=arm-apple-darwin --disable-shared CC=/Developer/Platforms/iPhoneOS.platform/Developer/usr/llvm-gcc-4.2/bin/llvm-gcc-4.2 CFLAGS="-arch armv7 -fmessage-length=0 -pipe -std=c99 -Wno-trigraphs -fpascal-strings -O0 -Wreturn-type -Wunused-variable -Wunused-value -isysroot /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk -fvisibility=hidden -gdwarf-2 -mthumb -miphoneos-version-min=4.0 " CPP=/Developer/Platforms/iPhoneOS.platform/Developer/usr/llvm-gcc-4.2/bin/llvm-cpp-4.2 AR=/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/ar
$ make clean
$ make
$ cp lib/.libs/libidn.a libidn-arm7.a

$ ./configure --host=arm-apple-darwin --disable-shared CC=/Developer/Platforms/iPhoneOS.platform/Developer/usr/llvm-gcc-4.2/bin/llvm-gcc-4.2 CFLAGS="-arch armv6 -fmessage-length=0 -pipe -std=c99 -Wno-trigraphs -fpascal-strings -O0 -Wreturn-type -Wunused-variable -Wunused-value -isysroot /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk -fvisibility=hidden -gdwarf-2 -mthumb -miphoneos-version-min=4.0 " CPP=/Developer/Platforms/iPhoneOS.platform/Developer/usr/llvm-gcc-4.2/bin/llvm-cpp-4.2 AR=/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/ar
$ make clean
$ make
$ cp lib/.libs/libidn.a libidn-arm6.a

$ ./configure --host=i686-apple-darwin --disable-shared CC=/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/llvm-gcc-4.2/bin/llvm-gcc-4.2 CFLAGS="-arch i386 -fmessage-length=0 -pipe -std=c99 -Wno-trigraphs -fpascal-strings -O0 -Wreturn-type -Wunused-variable -Wunused-value -isysroot /Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator5.0.sdk -fvisibility=hidden -gdwarf-2 -mthumb -miphoneos-version-min=4.0 " CPP=/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/llvm-gcc-4.2/bin/llvm-cpp-4.2 AR=/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin/ar
$ make clean
$ make
$ cp lib/.libs/libidn.a libidn-i386.a

$ lipo -create libidn-i386.a libidn-arm6.a libidn-arm7.a -output libidn.a


----------------------------------------


Switching to ios 3.1.3
----------------------

Try:
http://0xced.blogspot.com/2010/07/using-sdk-313-with-iphone-sdk-4.html

* stop xcode
* download sdk 3.1.3 (comes together with old xcode version)
* run script that text refers to
* restart xcode

Now in xcode must put project on 3.1.3
Do the following for each project (= both master project and in each Three20 project - need to doubleclick them to open)
* rightmouse on project -> Get Info
** Base SDK = iOS 3.1.3
** C/C++ compiler Version = LLVM GCC 4.2
** Deployment target = iOS 3.1.3
** (only in main project): at left bottom click on cog + add user-defined setting
*** key GCC_OBJC_ABI_VERSION - value 1
* rightmouse on project target -> Get Info
** Base SDK = iOS 3.1.3
** iOS Deployment target = iOS3.1.3

Now click on alt + dropdown left top of your screen --> here you can select ios 3.1.3 or iphonesimulator 3.1.3

Now make sure that all your Frameworks are added from the 3.1.3 set (this might require removing them all and re-adding them).
List is:
* QuartzCore
* MobileCoreServices
* SystemConfiguration
* CFNetwork
* UIKit
* Foundation
* CoreGraphics
* MapKit
* CoreData
* CoreLocation
* libz.1.2.3
* libsqlite3
* libxml2
* libresolv
 
