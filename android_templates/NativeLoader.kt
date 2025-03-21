package {{ApplicationId}}

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.app.NativeActivity
import com.google.android.gms.ads.*
import com.google.android.gms.ads.rewarded.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class NativeLoader: NativeActivity() {
  companion object {
    private const val AD_UNIT_ID = "{{RewardedAdUnitId}}"
    init {
      System.loadLibrary("main")
    }
  }

  private var rewardedAd: RewardedAd? = null
  private final var TAG = "{{AppLabelName}}"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setExternalThis()
    val backgroundScope = CoroutineScope(Dispatchers.IO)
    backgroundScope.launch {
      // Initialize the Google Mobile Ads SDK on a background thread.
      MobileAds.initialize(this@NativeLoader) {}
      runOnUiThread {
        // Load an ad on the main thread.
        actuallyLoadAd()
      }
    }
  }

  external fun setExternalThis()
 
  private fun loadAd() {
    if (Looper.myLooper() != Looper.getMainLooper()) {
      Handler(Looper.getMainLooper()).post {
        actuallyLoadAd()
      }
    } else {
      actuallyLoadAd()
    }
  }

  private fun actuallyLoadAd() {
    if (rewardedAd == null) {
      var adRequest = AdRequest.Builder().build()

      RewardedAd.load(
        this,
        AD_UNIT_ID,
        adRequest,
        object : RewardedAdLoadCallback() {
          override fun onAdFailedToLoad(adError: LoadAdError) {
            Log.d(TAG, adError.message)
            rewardedAd = null
          }

          override fun onAdLoaded(ad: RewardedAd) {
            Log.d(TAG, "Ad was loaded.")
            rewardedAd = ad
          }
        },
      )
    }
  }

  private fun showAd() {
    if (Looper.myLooper() != Looper.getMainLooper()) {
      Handler(Looper.getMainLooper()).post {
        actuallyShowAd()
      }
    } else {
      actuallyShowAd()
    }
  }

  private fun actuallyShowAd() {
    if (rewardedAd != null) {
      rewardedAd?.fullScreenContentCallback =
        object : FullScreenContentCallback() {
          override fun onAdDismissedFullScreenContent() {
            Log.d(TAG, "Ad was dismissed.")
          }

          override fun onAdFailedToShowFullScreenContent(adError: AdError) {
            Log.d(TAG, "Ad failed to show.")
            // Don't forget to set the ad reference to null so you
            // don't show the ad a second time.
            rewardedAd = null
          }

          override fun onAdShowedFullScreenContent() {
            Log.d(TAG, "Ad showed fullscreen content.")
            // Called when ad is dismissed.
          }
        }
      rewardedAd?.show(
        this,
        OnUserEarnedRewardListener { rewardItem ->
          //val rewardAmount = rewardItem.amount
          rewardedAd = null
          getAdReward()
          Log.d("TAG", "User earned the reward.")
          runOnUiThread {actuallyLoadAd()}
        },
      )
    }
  }

  external fun getAdReward()
}