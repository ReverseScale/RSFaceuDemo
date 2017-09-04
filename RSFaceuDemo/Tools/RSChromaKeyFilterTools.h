//
//  RSChromaKeyFilterTools.h
//  RSFaceuDemo
//
//  Created by WhatsXie on 2017/9/1.
//  Copyright © 2017年 StevenXie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSChromaKeyFilterTools : NSObject
void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v );

@end
