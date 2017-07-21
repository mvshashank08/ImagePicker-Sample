//
//  IOSSample.m
//  sampleRNComponent
//
//  Created by Afsarunnisa on 29.06.17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "IOSSample.h"
#import "React/RCTLog.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <React/RCTConvert.h>

@interface IOSSample()
@property (nonatomic, strong) RCTResponseSenderBlock callback;
@property (nonatomic, retain) NSMutableDictionary *options, *response;
@property (nonatomic, strong) UIImagePickerController *picker;

@end


@implementation IOSSample

// This RCT (React) "macro" exposes the current module to JavaScript
RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(getInfo,
                 getInfoResolver:(RCTPromiseResolveBlock)resolve
                 getInfoRejecter:(RCTPromiseRejectBlock)reject)
{

  
  NSString *str = @"some info from objective C";
  
  if(![str  isEqual: @""]){
    resolve(str);
  }else{
    reject(@"failed",@"failed", nil);
  }

  
}

//RCT_EXPORT_METHOD(showImagePicker:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback)

RCT_EXPORT_METHOD(showImagePicker: (RCTResponseSenderBlock)callback)
{
  self.callback = callback; // Save the callback so we can use it from the delegate methods
  //self.options = options;
  
  NSString *title = [self.options valueForKey:@"title"];
  if ([title isEqual:[NSNull null]] || title.length == 0) {
    title = nil; // A more visually appealing UIAlertControl is displayed with a nil title rather than title = @""
  }

  
  [self launchImagePicker:RNImagePickerTargetLibrarySingleImage];

  
}


- (void)launchImagePicker:(RNImagePickerTarget)target
{
  self.picker = [[UIImagePickerController alloc] init];
  
  if (target == RNImagePickerTargetCamera) {
#if TARGET_IPHONE_SIMULATOR
    self.callback(@[@{@"error": @"Camera not available on simulator"}]);
    return;
#else
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([[self.options objectForKey:@"cameraType"] isEqualToString:@"front"]) {
      self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    else { // "back"
      self.picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
#endif
  }
  else { // RNImagePickerTargetLibrarySingleImage
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  }
  
  if ([[self.options objectForKey:@"mediaType"] isEqualToString:@"video"]
      || [[self.options objectForKey:@"mediaType"] isEqualToString:@"mixed"]) {
    
    if ([[self.options objectForKey:@"videoQuality"] isEqualToString:@"high"]) {
      self.picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }
    else if ([[self.options objectForKey:@"videoQuality"] isEqualToString:@"low"]) {
      self.picker.videoQuality = UIImagePickerControllerQualityTypeLow;
    }
    else {
      self.picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    }
    
    id durationLimit = [self.options objectForKey:@"durationLimit"];
    if (durationLimit) {
      self.picker.videoMaximumDuration = [durationLimit doubleValue];
      self.picker.allowsEditing = NO;
    }
  }
//  if ([[self.options objectForKey:@"mediaType"] isEqualToString:@"video"]) {
//    self.picker.mediaTypes = @[(NSString *)kUTTypeMovie];
//  } else if ([[self.options objectForKey:@"mediaType"] isEqualToString:@"mixed"]) {
 //   self.picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
//  } else {
 //   self.picker.mediaTypes = @[(NSString *)kUTTypeImage];
 // }
  
  if ([[self.options objectForKey:@"allowsEditing"] boolValue]) {
    self.picker.allowsEditing = true;
  }
  self.picker.modalPresentationStyle = UIModalPresentationCurrentContext;
  self.picker.delegate = self;
  
  // Check permissions
  void (^showPickerViewController)() = ^void() {
    dispatch_async(dispatch_get_main_queue(), ^{
      UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
      while (root.presentedViewController != nil) {
        root = root.presentedViewController;
      }
      [root presentViewController:self.picker animated:YES completion:nil];
    });
  };
  
  if (target == RNImagePickerTargetCamera) {
    [self checkCameraPermissions:^(BOOL granted) {
      if (!granted) {
        self.callback(@[@{@"error": @"Camera permissions not granted"}]);
        return;
      }
      
      showPickerViewController();
    }];
  }
  else { // RNImagePickerTargetLibrarySingleImage
    [self checkPhotosPermissions:^(BOOL granted) {
      if (!granted) {
        self.callback(@[@{@"error": @"Photo library permissions not granted"}]);
        return;
      }
      
      showPickerViewController();
    }];
  }
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

  NSURL* imageUrl = [info valueForKey:UIImagePickerControllerReferenceURL];
  NSLog(@"imageUrl: %@", imageUrl);
  NSString *stringUrl = imageUrl.absoluteString;
  NSLog(@"stringUrl: %@", stringUrl);

  
  dispatch_async(dispatch_get_main_queue(), ^{
    [picker dismissViewControllerAnimated:YES completion:^{
      self.callback(@[@{@"didSelect": stringUrl}]);
    }];
  });

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [picker dismissViewControllerAnimated:YES completion:^{
      self.callback(@[@{@"didCancel": @YES}]);
    }];
  });
}





#pragma mark - Helpers

- (void)checkCameraPermissions:(void(^)(BOOL granted))callback
{
  AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  if (status == AVAuthorizationStatusAuthorized) {
    callback(YES);
    return;
  } else if (status == AVAuthorizationStatusNotDetermined){
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
      callback(granted);
      return;
    }];
  } else {
    callback(NO);
  }
}

- (void)checkPhotosPermissions:(void(^)(BOOL granted))callback
{
  PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
  if (status == PHAuthorizationStatusAuthorized) {
    callback(YES);
    return;
  } else if (status == PHAuthorizationStatusNotDetermined) {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
      if (status == PHAuthorizationStatusAuthorized) {
        callback(YES);
        return;
      }
      else {
        callback(NO);
        return;
      }
    }];
  }
  else {
    callback(NO);
  }
}





@end
