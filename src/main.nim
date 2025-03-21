# ****************************************************************************************
#
#   raylib game template
#
#   <Game title>
#   <Game description>
#
#   This game has been created using raylib (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2021 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, ./admob

when not defined(android):
  import std/os
  setCurrentDir getAppDir()

const
  screenWidth = 800
  screenHeight = 450

var centerText = "click to start rewarded ad"

rewardAdCallback = proc() =
  centerText = "got reward"

proc main =
  echo "open window.."
  initWindow(screenWidth, screenHeight, "raylib game template")
  initAudioDevice()
  const textSize = 20
  let textWidth = measureText(centerText, textSize)
  loadAd()
  try:
    var music = loadMusicStream("resources/ambient.ogg")
    setMusicVolume(music, 1)
    playMusicStream(music)
    setTargetFPS(60)
    while not windowShouldClose():
      updateMusicStream(music)
      drawing:
        clearBackground(Black)
        drawText(centerText, (screenWidth - textWidth) div 2, 200, textSize, White)
      if isGestureDetected(Tap):
        showAd()

    reset(music)
  finally:
    closeAudioDevice()
    closeWindow()

main()
