#!/bin/bash
echo Making the haxelib and setuping folder in same time...
haxelib run astc-compressor compress -i ./assets/base_game/characters -blocksize 8x8 -quality medium -colorprofile cs
haxelib run astc-compressor compress -i ./assets/base_game/week_data -blocksize 8x8 -quality medium -colorprofile cs  -excludes ./setup/atsc_skip.txt
haxelib run astc-compressor compress -i ./assets/atsc_shared -blocksize 8x8 -quality medium -colorprofile cs
