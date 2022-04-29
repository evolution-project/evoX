set -x #echo on
curr_path=${BASH_SOURCE%/*}

# check that all the required environment vars are set
: "${EVOX_QT_PATH:?variable not set, see also macosx_build_config.command}"
: "${EVOX_BOOST_ROOT:?variable not set, see also macosx_build_config.command}"
: "${EVOX_BOOST_LIBS_PATH:?variable not set, see also macosx_build_config.command}"
: "${EVOX_BUILD_DIR:?variable not set, see also macosx_build_config.command}"
: "${CMAKE_OSX_SYSROOT:?CMAKE_OSX_SYSROOT should be set to macOS SDK path, e.g.: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk}"

BUILD_DIR=$curr_path/../$EVOX_BUILD_DIR/macos_xcodeproj
BUILD_TYPE=Release

rm -rf $BUILD_DIR
mkdir -p "$BUILD_DIR/$BUILD_TYPE"
cd "$BUILD_DIR/$BUILD_TYPE"

cmake -D BUILD_GUI=TRUE -D CMAKE_PREFIX_PATH="$EVOX_QT_PATH/clang_64" -D CMAKE_BUILD_TYPE=$BUILD_TYPE -D BOOST_ROOT="$EVOX_BOOST_ROOT" -D BOOST_LIBRARYDIR="$EVOX_BOOST_LIBS_PATH" -G Xcode ../../..

