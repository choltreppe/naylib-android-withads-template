# Package
version       = "1.0.0"
author        = "Author"
description   = "Raylib game template"
license       = "License"
srcDir        = "src"
binDir        = "desktop"
namedBin      = {"main": "game"}.toTable

# Dependencies
requires "nim 2.2.2"
requires "naylib"
requires "nimja"

import std/distros
if detectOs(Windows):
 foreignDep "openjdk"
 foreignDep "wget"
elif detectOs(Ubuntu):
 foreignDep "default-jdk"

# Tasks
include "build_android.nims"