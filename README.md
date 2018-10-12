# RSFaceuDemo

![](https://img.shields.io/badge/platform-iOS-red.svg) 
![](https://img.shields.io/badge/language-Objective--C-orange.svg) 
![](https://img.shields.io/badge/download-11.6MB-brightgreen.svg) 
![](https://img.shields.io/badge/license-MIT%20License-brightgreen.svg) 

[EN](https://github.com/ReverseScale/RSFaceuDemo) | [中文](https://github.com/ReverseScale/RSFaceuDemo/blob/master/README_zh.md)

Faceu Face Moe must have had a set of its own core algorithms, so it would say "Someone mimics my face ..."

Recently in the study of some image processing technology, the most common applications are the number of "Faceu Meng", in order to show clearer, I choose to split the way to achieve Demo.

Related technology research, see iOSPrinciple series [AVFoundation](https://github.com/ReverseScale/iOSPrinciple_AVFoundation)

## 🎨 Why test the UI?

|1.List page | 2.Filter effect page | 3.Green screen image page | 4.Static composition page |
| ------------- | ------------- | ------------- | ------------- |
| ![](http://og1yl0w9z.bkt.clouddn.com/18-3-14/35442700.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/18-3-14/79019240.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/18-3-14/56773520.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/18-3-14/86588720.jpg) |
| Build a basic framework | Several filter effects | Realize green screen artifacts | Static synthesis Gif |

## 🚀 Advantage 
* 1. Less documents, code concise, innovative features
* 2. High functionality integration, good experience, fine structure
* 3. Relies solely on GPUImage to achieve
* 4. Has a high custom

## 🤖 Requirements 
* iOS 7+
* Xcode 8+


## 🛠 Usage
### filter effect
Core code display:

```
//Convert UIImage to CIImage
CIImage *ciImage = [[CIImage alloc] initWithImage:self.originImage];
//Create a filter
CIFilter *filter = [CIFilter filterWithName:filterName
                              keysAndValues:kCIInputImageKey,ciImage, nil];
//The existing value does not change, the other is set as the default value
[filter setDefaults];
        
//Get the drawing context
CIContext *context = [CIContext contextWithOptions:nil];
        
//Render and output CIImage
CIImage *outputImage = [filter outputImage];
        
//Create a CGImage handle
CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
        
//Get the picture
UIImage *image = [UIImage imageWithCGImage:cgImage];
        
//Release the CGImage handle
CGImageRelease(cgImage);
        
self.imageView.image = image;
```

### green screen keying

Quote header file:
```
#import "RSChromaKeyFilter.h"
```

Tool method:

```
RSChromaKeyFilter *filter=[[RSChromaKeyFilter alloc] initWithInputImage:self.greenImageView.image
                                                        backgroundImage:self.resultBgImageView.image];
    
self.resultImageView.image=[[UIImage imageWithCIImage:filter.outputImage] copy];
```

### Static Synthesis

Effect demonstration:

![](http://og1yl0w9z.bkt.clouddn.com/17-9-4/17807305.jpg) 

Quote header file:

```
#import <CoreImage/CoreImage.h>
#import "UIImageView+Gif.h"
```

The core method:

```
// Image Recognition: You can choose between CIDetectorAccuracyHigh and CIDetectorAccuracyLow, because you want to be more accurate
CIDetectorAccuracyHigh
NSDictionary *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh
                                                 forKey:CIDetectorAccuracy];

CIDetector *detector=[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
CIImage *image=[[CIImage alloc] initWithImage:self.oldImageView.image];
NSArray *faceArray = [detector featuresInImage:image
                                       options:nil];

/ ** Convert Core Image Coordinates to UIView Coordinates ** /
// get the size of the image
CGSize ciImageSize = [image extent] .size ;;
// Symmetry the image along the y axis
CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
// Negative y-axis translation
transform = CGAffineTransformTranslate(transform,0,-ciImageSize.height);

for (CIFeature *f in faceArray){
    
    if ([f.type isEqualToString:CIFeatureTypeFace]) {
        
        CIFaceFeature *faceFeature=(CIFaceFeature *)f;
        // Achieve coordinate conversion
        CGSize viewSize = self.oldImageView.bounds.size;
        CGFloat scale = MIN(viewSize.width / ciImageSize.width,
                            viewSize.height / ciImageSize.height);
        CGFloat offsetX = (viewSize.width - ciImageSize.width * scale) / 2;
        CGFloat offsetY = (viewSize.height - ciImageSize.height * scale) / 2;
        // Zoom
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
        // Get face frame
        CGRect faceViewBounds = CGRectApplyAffineTransform(faceFeature.bounds, transform);
        // Fix
        faceViewBounds = CGRectApplyAffineTransform(faceViewBounds,scaleTransform);
        faceViewBounds.origin.x += offsetX;
        faceViewBounds.origin.y += offsetY;
        
        UIView *faceView=[[UIView alloc] initWithFrame:faceViewBounds];
        faceView.layer.borderWidth=3;
        faceView.layer.borderColor=[UIColor orangeColor].CGColor;
        
        [self.oldImageView addSubview:faceView];
        
        / ** plus light ring ** /
        UIImageView *imageView=[UIImageView new];
        CGFloat haloWidth= faceViewBounds.size.width;
        CGFloat haloHeight= haloWidth * 159 / 351;
        
        ...
    }
}
```

### Dynamic synthesis

Effect demonstration:

![](http://og1yl0w9z.bkt.clouddn.com/17-9-4/28926041.jpg) 

Quote header file:
```
#import <GPUImage/GPUImage.h>
```

The core method:
```
_faceThinking = YES;
CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];

if (attachments)
    CFRelease(attachments);
NSDictionary *imageOptions = nil;
UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
int exifOrientation;

enum {
    PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
    PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
    PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
    PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
    PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
    PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
    PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
    PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
};
BOOL isUsingFrontFacingCamera = FALSE;
AVCaptureDevicePosition currentCameraPosition = [self.videoCamera cameraPosition];

...
```


## ⚖ License

```
MIT License

Copyright (c) 2017 ReverseScale

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 😬 Contributions

* WeChat : WhatsXie
* Email : ReverseScale@iCloud.com
* Blog : https://reversescale.github.io

