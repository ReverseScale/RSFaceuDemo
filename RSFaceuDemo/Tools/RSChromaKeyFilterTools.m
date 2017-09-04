//
//  RSChromaKeyFilterTools.m
//  RSFaceuDemo
//
//  Created by WhatsXie on 2017/9/1.
//  Copyright © 2017年 StevenXie. All rights reserved.
//

#import "RSChromaKeyFilterTools.h"

@implementation RSChromaKeyFilterTools

void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v ){
    float min, max, delta;
    min = MIN( r, MIN(g, b) );
    max = MAX( r, MAX(g, b) );
    *v = max;                // v
    delta = max - min;
    if( max != 0 )
        *s = delta / max;      // s
    else {
        // r = g = b = 0       // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;        // between yellow & magenta
    else if( g == max )
        *h = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        *h = 4 + ( r - g ) / delta; // between magenta & cyan
    *h *= 60;               // degrees
    if( *h < 0 )
        *h += 360;
}

@end
