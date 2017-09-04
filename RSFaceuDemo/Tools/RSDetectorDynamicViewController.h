//
//  RSDetectorDynamicViewController.h
//  RSFaceuDemo
//
//  Created by WhatsXie on 2017/9/1.
//  Copyright © 2017年 StevenXie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

//协议
@protocol RSDetectorDynamicDelegate<NSObject>
//协议的方法
- (void)detectorDynamicLocateFace:(CGRect)faceBounds;

- (void)detectorDynamicLocateLeftEyeForFace:(CGRect)leftEyeBounds;

- (void)detectorDynamicLocateRightEyeForFace:(CGRect)rightEyeBounds;
@end


@interface RSDetectorDynamicViewController : GLKViewController
@property(nonatomic,weak) id<RSDetectorDynamicDelegate> detectorDelegate;
- (void)chanageCamera;
@end
