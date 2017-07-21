package com.imageviewapp.imagepicker;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ActivityEventListener;

public class ImagePickerModule extends ReactContextBaseJavaModule implements ActivityEventListener{

    private static final int PICK_IMAGE = 1;

    private Callback pickerSuccessCallback;
    private Callback pickerCancelCallback;

    public ImagePickerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addActivityEventListener(this);
    }
    @Override
    public String getName() {
        return "ImagePicker";
    }

    @Override
    public void onActivityResult(final Activity activity, final int requestCode, final int resultCode, final Intent intent) {
        if (pickerSuccessCallback != null) {
            if (resultCode == Activity.RESULT_CANCELED) {
                pickerCancelCallback.invoke("ImagePicker was cancelled");
            } else if (resultCode == Activity.RESULT_OK) {
                Uri uri = intent.getData();

                if (uri == null) {
                    pickerCancelCallback.invoke("No image data found");
                } else {
                    try {
                        pickerSuccessCallback.invoke(uri.getPath());
                    } catch (Exception e) {
                        pickerCancelCallback.invoke(e.getMessage());
                    }
                }
            }
        }
    }

    @Override
    public void onNewIntent(Intent intent){

    }

    @ReactMethod
    public void openSelectDialog(ReadableMap config, Callback successCallback, Callback cancelCallback) {
        Activity currentActivity = getCurrentActivity();

        if (currentActivity == null) {
            cancelCallback.invoke("Activity doesn't exist");
            return;
        }

        pickerSuccessCallback = successCallback;
        pickerCancelCallback = cancelCallback;

        try {
            final Intent galleryIntent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);

            //galleryIntent.setType("image/*");
            //galleryIntent.setAction(Intent.ACTION_GET_CONTENT);

            final Intent chooserIntent = Intent.createChooser(galleryIntent, "Pick an image");

            currentActivity.startActivityForResult(chooserIntent, 2);

        } catch (Exception e) {
            cancelCallback.invoke(e);
        }
    }


}