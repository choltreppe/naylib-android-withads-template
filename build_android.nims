# This script builds an Android application (APK file).
# Copyright (c) 2017-2023 Ramon Santamaria (@raysan5)
# Converted to nimscript by Antonis Geralis (@planetis-m) in 2023
# See the file "LICENSE", included in this distribution,
# for details about the copyright.

import std/[os, strutils, strformat, sugar]
from std/private/globs import nativeToUnixPath
import nimja

type
  CpuPlatform = enum
    arm, arm64, i386, amd64
  GlEsVersion = enum
    openglEs20 = "GraphicsApiOpenGlEs2"
    openglEs30 = "GraphicsApiOpenGlEs3"
  DeviceOrientation = enum
    portrait, landscape, sensor

proc toArchName(x: CpuPlatform): string =
  case x
  of arm: "armeabi-v7a"
  of arm64: "arm64-v8a"
  of i386: "x86"
  of amd64: "x86_64"

proc toValue(x: GlEsVersion): string =
  case x
  of openglEs20: "0x00020000"
  of openglEs30: "0x00030000"

# Define Android architecture (armeabi-v7a, arm64-v8a, x86, x86-64), GLES and API version
const
  AndroidApiVersion = 21..34
  AndroidCPUs = [arm, arm64]
  AndroidGlEsVersion = openglEs20

# Required path variables
const
  AndroidHome = getEnv"ANDROID_HOME"
  AndroidNdk = getEnv"ANDROID_NDK"
  AndroidBuildTools = AndroidHome / "build-tools/34.0.0"
  KeyStorePath = ""  # path to .keystore file for signing .aab

# Android project configuration variables
const
  ProjectName = "raylib_game"
  AppCompanyTld = "com"
  AppCompanyName = "raylib"
  AppProductName = "rgame"
  AppVersionCode = 1
  AppVersionName = "1.0"
  ProjectLibraryName = "main"
  ProjectResourcesPath = "src/resources"
  ProjectSourceFile = "src/main.nim"

# Android Ads
const
  AdsApplicationId = "ca-app-pub-3940256099942544~3347511713"
  RewardedAdUnitId = "ca-app-pub-3940256099942544/5224354917"


# Android app configuration variables
const
  AppLabelName = "rGame"
  AppIconLdpi = "icon/36x36.png"
  AppIconMdpi = "icon/48x48.png"
  AppIconHdpi = "icon/72x72.png"


task setupAndroid, "Prepare raylib project for Android development":
  const
    ProjectBuildPath = "android/app/src/main"
    ApplicationId = &"{AppCompanyTld}.{AppCompanyName}.{AppProductName}"

  # Create required temp directories for APK building
  for cpu in AndroidCPUs: mkDir(ProjectBuildPath / "jniLibs" / cpu.toArchName)
  mkDir(ProjectBuildPath / "res/drawable-ldpi")
  mkDir(ProjectBuildPath / "res/drawable-mdpi")
  mkDir(ProjectBuildPath / "res/drawable-hdpi")
  mkDir(ProjectBuildPath / "res/drawable-xhdpi")
  mkDir(ProjectBuildPath / "res/values")
  mkDir(ProjectBuildPath / "assets/resources")
  mkDir(ProjectBuildPath / "obj/screens")
  # Copy project required resources: strings.xml, icon.png, assets
  writeFile(ProjectBuildPath / "res/values/strings.xml",
      &"<?xml version='1.0' encoding='utf-8'?>\n<resources><string name='app_name'>{AppLabelName}</string></resources>\n")
  cpFile(AppIconLdpi, ProjectBuildPath / "res/drawable-ldpi/icon.png")
  cpFile(AppIconMdpi, ProjectBuildPath / "res/drawable-mdpi/icon.png")
  cpFile(AppIconHdpi, ProjectBuildPath / "res/drawable-hdpi/icon.png")
  cpDir(ProjectResourcesPath, ProjectBuildPath / "assets/resources")

  template fillTemplate(templ, outPath: static string) =
    writeFile(outPath, tmplf(templ, baseDir = getScriptDir()/"android_templates"))

  # Create android/gradle project files
  fillTemplate("AndroidManifest.xml", ProjectBuildPath / "AndroidManifest.xml")
  fillTemplate("settings.gradle.kts", "android/settings.gradle.kts")
  fillTemplate("app.build.gradle.kts", "android/app/build.gradle.kts")
  writeFile("android/local.properties", "sdk.dir=" & AndroidHome)
  # Create NativeLoader
  const NativeLoaderPath = ProjectBuildPath / "java" / AppCompanyTld / AppCompanyName / AppProductName
  mkDir(NativeLoaderPath)
  fillTemplate("NativeLoader.kt", NativeLoaderPath / "NativeLoader.kt")

  # Create glue c-file for admob
  const JniPrefix = &"Java_{AppCompanyTld}_{AppCompanyName}_{AppProductName}_NativeLoader"
  fillTemplate("admobglue.c", "src/admobglue.c")

task buildAndroid, "Compile and package raylib project for Android":
  for cpu in AndroidCPUs:
    exec("nim c -d:release --os:android --cpu:" & $cpu & " -d:AndroidApiVersion=" & $AndroidApiVersion.a &
        " -d:AndroidNdk=" & AndroidNdk & " -d:" & $AndroidGlEsVersion &
        " -o:" & "android/app/src/main/jniLibs" / cpu.toArchName / ("lib" & ProjectLibraryName & ".so") &
        " --nimcache:" & nimcacheDir().parentDir / (ProjectName & "_" & $cpu) & " " & ProjectSourceFile)
  exec("cd android && ./gradlew build")
  exec("cp android/app/build/outputs/apk/debug/app-debug.apk " & ProjectName & ".apk")

task bundleReleaseAndroid, "Create and sign a .aab for release":
  exec("cd android && ./gradlew bundleRelease")
  exec("cp android/app/build/outputs/bundle/release/app-release.aab " & ProjectName & ".aab")
  exec(AndroidBuildTools/"apksigner" & " sign --ks " & KeyStorePath &
      " --min-sdk-version " & $AndroidApiVersion.a &
      " --v1-signing-enabled true --v2-signing-enabled true " &
      ProjectName&".aab")

task info, "Retrieve device compatibility information":
  # Check supported ABI for the device (armeabi-v7a, arm64-v8a, x86, x86_64)
  echo "Checking supported ABI for the device..."
  exec("adb shell getprop ro.product.cpu.abi")
  # Check supported API level for the device (31, 32, 33, ...)
  echo "Checking supported API level for the device..."
  exec("adb shell getprop ro.build.version.sdk")

task logcat, "Display raylib-specific logs from the Android device":
  # Monitorize output log coming from device, only raylib tag
  exec("adb logcat -c")
  exec("adb logcat raylib:V *:S")

task deploy, "Install and monitor raylib project on Android device/emulator":
  # Install and monitorize {ProjectName}.apk to default emulator/device
  exec("adb install -r " & ProjectName & ".apk")
  logcatTask()
