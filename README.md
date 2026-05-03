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

Copy build/ and run.sh into exe.app.

    rm -rf nip4.app/
    ./package.sh build nip4

## Sign

macos code signing tips

    https://www.reddit.com/r/macosprogramming/comments/1rpe0mx/macos_app_development_outside_of_app_store/

Sign the app:

    codesign --deep --force --verify --verbose \
        --options runtime \
        --sign "Developer ID Application: Your Name (TEAMID)" \
        nip4.app

Verify the signature:

    codesign --verify --deep --strict --verbose=2 nip4.app

Check Gatekeeper locally:

    spctl --assess --type execute -vv nip4.app

You should see something like:

    accepted
    source=Developer ID

Submit dmg for notarization:

    xcrun notarytool submit nip4.app.dmg \
        --apple-id "APPLE_ID_EMAIL" \
        --team-id TEAMID \
        --password "APP_SPECIFIC_PASSWORD" \
        --wait

Staple the notarization ticket:

    xcrun stapler staple nip4.app

Verify stapling:

    xcrun stapler validate nip4.app

Rebuild dmg after stapling:

    hdiutil create -srcfolder $app.app -o $app.app.dmg

