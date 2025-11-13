cd export/release/android/obj
rm libApplicationMain-64.so
rm libApplicationMain-v7.so

haxelib run hxcpp Build.xml -DHXCPP_DEBUG_LINK -options ./Options.txt # 
echo "COmpiling the alt lib"
sed -i 's/HXCPP_ARM64=1/HXCPP_ARMV7=1/g' ./Options.txt
haxelib run hxcpp Build.xml -DHXCPP_DEBUG_LINK -options ./Options.txt # 
sed -i 's/HXCPP_ARMV7=1/HXCPP_ARM64=1/g' ./Options.txt
cd -

rm -r export/release/android/bin/unstrippedLibs/
mkdir -p export/release/android/bin/unstrippedLibs/arm64-v8a/
mkdir export/release/android/bin/unstrippedLibs/armeabi-v7a/

mv export/release/android/obj/libApplicationMain-64.so export/release/android/bin/unstrippedLibs/arm64-v8a/libApplicationMain.so
mv export/release/android/obj/libApplicationMain-v7.so export/release/android/bin/unstrippedLibs/armeabi-v7a/libApplicationMain.so
cd export/release/android/bin/
# JAVA_HOME="/usr/lib/jvm/java-17-openjdk/" ./gradlew tasks
JAVA_HOME="/usr/lib/jvm/java-17-openjdk/" ./gradlew app:uploadCrashlyticsSymbolFile
cd -