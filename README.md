## Script for automatic building of Minetest for OS X from GitHub

[Binaries made with this are available here](https://github.com/mdoege/minetest/releases)

### Usage

    bash make_mac.sh

This will create a ZIP file in releases/ with an app bundle.

### General hints for using GitHub

You cannot just go to the GitHub page and right click the script and do "save as...". This just saves the html page with the script. The entire folder provided on the GitHub page is required. Download the [zip file](https://github.com/mdoege/mtmake-osx/archive/master.zip), extract it, navigate inside it with a terminal and type ./make_mac.sh. The zip file with the application can be found in the "releases" folder.

### How it works

The script

* updates Minetest OS X executable and shared files
* does not change libraries (which is why a previous version of minetest.app with its modified dynamic libraries is included)

### Dependencies

Install with [Homebrew](http://brew.sh/) ("brew install"): cmake, freetype, gettext, hiredis, irrlicht, jpeg, leveldb, libogg, libvorbis, luajit

(snappy and libpng will get installed by brew automatically too.)

You also need Xcode 5 and the Xcode Command Line Tools. (You should get prompted for installation of the latter if you run the build script for the first time.)

(Optionally you can install XQuartz for X11 support.)

### Playing the game

* Use two finger tap for right click

* Use "e" for sneak/climb down (activate in 'Settings -> Change keys')

* If you would like to start the Minetest server from a terminal, run "/Applications/minetest.app/Contents/Resources/bin/minetest --server".

### How to update dynamic libraries (rarely needed)

The "build_libs.sh" script in releases will rebuild the libs folder.

However here are some explanations for how to do this manually.

This will create the libs directory and change library path names:

    dylibbundler -x minetest.app/Contents/Resources/bin/minetest -b -d ./minetest.app/Contents/libs/ \
    -p @executable_path/../../libs/ -cd

(Note that this only works with an unmodified minetet binary that has not had its own link s changed by e.g. the dylibbundler invocation in make_mac.sh itself.)

Check if all no libraries point to Homebrew Cellar direcory any more:

    $ for x in *.dylib ; do otool -L $x|grep Cell; done

Update a library reference that was not updated by dylibbundler with:

    $ install_name_tool -change /usr/local/Cellar/libvorbis/1.3.4/lib/libvorbis.0.dylib \
    @executable_path/../../libs/libvorbis.0.dylib libvorbisfile.3.dylib
