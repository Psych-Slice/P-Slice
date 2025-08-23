lime build ios -nosign
./setup/ios-utils/simforge convert ./export/release/ios/build/Release-iphoneos/PSliceEngine.app
codesign -f -s - ./export/release/ios/build/Release-iphoneos/PSliceEngine.app