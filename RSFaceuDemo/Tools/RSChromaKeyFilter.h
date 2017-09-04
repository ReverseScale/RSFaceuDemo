//
//  RSChromaKeyFilter.h
//  RSFaceuDemo
//
//  Created by WhatsXie on 2017/9/1.
//  Copyright © 2017年 StevenXie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface RSChromaKeyFilter : CIFilter
- (instancetype)initWithInputImage:(UIImage *)image backgroundImage:(UIImage *)bgImage;

@property (nonatomic,readwrite,strong) UIImage *inputFilterImage;
@property (nonatomic,readwrite,strong) UIImage *backgroundImage;
@end
