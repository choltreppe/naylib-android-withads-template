#include <jni.h>

// Global variables
JavaVM *javaVM;
jobject globalThis;

JNIEXPORT void JNICALL {{JniPrefix}}_setExternalThis(JNIEnv *env, jobject instance) {
    // Store the JavaVM for later use
    (*env)->GetJavaVM(env, &javaVM);

    // Create a global reference to the `this` object
    globalThis = (*env)->NewGlobalRef(env, instance);
}

void loadAd() {
    JNIEnv *env;
    if ((*javaVM)->AttachCurrentThread(javaVM, &env, NULL) != 0)
      return;

    // Get the class and method ID
    jclass thisClass = (*env)->GetObjectClass(env, globalThis);
    jmethodID openAdMethod = (*env)->GetMethodID(env, thisClass, "loadAd", "()V");

    // Call the openAd method
    (*env)->CallVoidMethod(env, globalThis, openAdMethod);

    // Detach the thread from the JVM if it was not originally attached
    (*javaVM)->DetachCurrentThread(javaVM);
}

void showAd() {
    JNIEnv *env;
    if ((*javaVM)->AttachCurrentThread(javaVM, &env, NULL) != 0)
      return;

    // Get the class and method ID
    jclass thisClass = (*env)->GetObjectClass(env, globalThis);
    jmethodID openAdMethod = (*env)->GetMethodID(env, thisClass, "showAd", "()V");

    // Call the openAd method
    (*env)->CallVoidMethod(env, globalThis, openAdMethod);

    // Detach the thread from the JVM if it was not originally attached
    (*javaVM)->DetachCurrentThread(javaVM);
}

void getAdReward();

JNIEXPORT void JNICALL {{JniPrefix}}_getAdReward(JNIEnv *env, jobject instance) {
    getAdReward();
}