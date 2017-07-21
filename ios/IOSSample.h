//
//  IOSSample.h
//  sampleRNComponent
//
//  Created by Afsarunnisa on 29.06.17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RNImagePickerTarget) {
  RNImagePickerTargetCamera = 1,
  RNImagePickerTargetLibrarySingleImage,
};


@interface IOSSample : NSObject<RCTBridgeModule, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end
