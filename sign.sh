#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "sign and make signed installer"
    echo "usage: $0 app-name"
    exit 1
fi

app="$1"

devid_app="Developer ID Application: John Cupitt (64AS5FZ57X)"
devid_install="Developer ID Installer: John Cupitt (64AS5FZ57X)"

codesign --deep --force --verify --verbose \
    --options runtime \
    --sign "$devid_app" \
    $app.app

if [ ! codesign --verify --deep --strict --verbose=2 $app.app ]; then
  echo codesign verify failed
  exit 1
fi

# check gatekeeper locally
if [ ! spctl --assess --type execute -vv nip4.app ]; then
  echo gatekeeper failed
  exit 1
fi
