## Tasks

1. build stack from homebrew to a prsivate prefix

2. package into .app with plist, a start script, icon, metadata, etc.

3. sign

## Build

Just copy stuff from the homebrew install. Make sure it's up to date, then:

    rm -rf build
    ./build.sh build nip4

Test with:

    sudo mv /opt/homebrew /opt/x
    ./run.sh build nip4
    sudo mv /opt/x /opt/homebrew 

## Package

## Sign

macos code signing tips

    https://www.reddit.com/r/macosprogramming/comments/1rpe0mx/macos_app_development_outside_of_app_store/


