#!/bin/bash
echo Making the haxelib and setuping folder in same time...
#haxelib run astc-compressor compress-from-json -json ./setup/astc-compression-data.json         
DEST_DIR="$(pwd)/mod_core";
mkdir "$DEST_DIR";

# cd assets/shared/
# find . -name "*" -exec cp --parents -t "$DEST_DIR" {} +
# cd - > /dev/null

cd astc-textures/assets/atsc_shared/
find . -name "*" -exec cp --parents -t "$DEST_DIR" {} +
cd - > /dev/null

# cd assets/base_game/shared
# find . -name "*" -exec cp --parents -t "$DEST_DIR" {} +
# cd - > /dev/null

cd astc-textures/assets/base_game/
find characters -name "*" -exec cp --parents -t "$DEST_DIR/images" {} +
cd - > /dev/null

# cd assets/base_game/characters_pixel
# find . -name "*" -exec cp --parents -t "$DEST_DIR/images/characters" {} +
# cd - > /dev/null

cd astc-textures/assets/base_game/week_data
find . -name "*" -exec cp --parents -t "$DEST_DIR" {} +
cd - > /dev/null

cp "assets/exclude/mod/pack-astc.json" "$DEST_DIR/pack.json";
cp "art/supportMod.png" "$DEST_DIR/pack.png";