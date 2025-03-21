var rewardAdCallback*: proc()

proc getAdReward {.cdecl, exportc.} =
  rewardAdCallback()

when defined(android):
  {.compile: "admobglue.c".}
  proc loadAd* {.importc.}
  proc showAd* {.importc.}
else:
  proc loadAd* =
    echo "load ad"
  proc showAd* =
    echo "AD!"
    getAdReward()