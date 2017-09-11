#!/bin/bash
cd "$(dirname "$(which emulator)")" && ./emulator -no-window -no-boot-anim -no-snapshot -no-audio "$@" &