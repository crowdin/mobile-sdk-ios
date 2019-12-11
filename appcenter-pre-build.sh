#!/usr/bin/env bash

- cd $APPCENTER_SOURCE_DIRECTORY
- npm install -g danger
- swift build
- swift run danger-swift ci