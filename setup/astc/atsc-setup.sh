#!/bin/bash
echo Making the haxelib and setuping folder in same time...
#haxelib run astc-compressor compress-from-json -json ./setup/astc-compression-data.json         
DEST_DIR="$(pwd)/mod_core/base";
DEST_ASTC_DIR="$(pwd)/mod_core/astc";
mkdir -p "$DEST_DIR";
mkdir -p "$DEST_ASTC_DIR";

# cd assets/shared/
# find . -name "*" -exec cp --parents -t "$DEST_DIR" {} +
# cd - > /dev/null


cd assets/atsc_shared/
find . -name "*.xml" -exec cp -r --parents -t "$DEST_ASTC_DIR" {} +
cd - > /dev/null

cd astc-textures/assets/atsc_shared/
find . -name "*" -exec cp -r --parents -t "$DEST_ASTC_DIR" {} +
cd - > /dev/null


cd assets/base_game/shared
find . -name "*" -exec cp -r --parents -t "$DEST_DIR" {} +
cd - > /dev/null


cd assets/base_game/
find characters -name "*"  -exec cp -r --parents -t "$DEST_DIR/images" {} +
find characters -name "*.json" -exec cp -r --parents -t "$DEST_ASTC_DIR/images" {} +
cd - > /dev/null

cd astc-textures/assets/base_game/
find characters -name "*" -exec cp -r --parents -t "$DEST_ASTC_DIR/images" {} +
cd - > /dev/null

cd assets/base_game/characters_pixel
find . -name "*" -exec cp -r --parents -t "$DEST_DIR/images/characters" {} +
cd - > /dev/null

cd assets/base_game/shared
find . -name "*" -exec cp -r --parents -t "$DEST_DIR" {} +
find images -name "*.json" -exec cp -r --parents -t "$DEST_ASTC_DIR" {} +
cd - > /dev/null

cd astc-textures/assets/base_game/shared
find . -name "*" -exec cp -r --parents -t "$DEST_ASTC_DIR" {} +
cd - > /dev/null




cd assets/base_game/week_data
find . -name "*" -exec cp -r --parents -t "$DEST_DIR" {} +
cd - > /dev/null

cd astc-textures/assets/base_game/week_data
find . -name "*" -exec cp -r --parents -t "$DEST_ASTC_DIR" {} +
cd - > /dev/null

cp "art/mod/pack-astc.json" "$DEST_ASTC_DIR/pack.json";
cp "art/mod/pack-full.json" "$DEST_DIR/pack.json";
cp "art/mod/supportMod.png" "$DEST_ASTC_DIR/pack.png";
cp "art/mod/supportMod-full.png" "$DEST_DIR/pack.png";