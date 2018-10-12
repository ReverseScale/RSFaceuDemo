![](https://img.shields.io/badge/platform-iOS-red.svg) 
![](https://img.shields.io/badge/language-Objective--C-orange.svg) 
![](https://img.shields.io/badge/download-11.6MB-brightgreen.svg) 
![](https://img.shields.io/badge/license-MIT%20License-brightgreen.svg) 

[EN](https://github.com/ReverseScale/RSFaceuDemo) | [中文](https://github.com/ReverseScale/RSFaceuDemo/blob/master/README_zh.md)

Faceu 脸萌一定是有一套自己的核心算法，所以它会说“有人模仿我的脸...”

最近在研究一些图像处理的技术，其中最常见的应用就要数 “Faceu 脸萌” 了，为了展示更清晰，我选择拆分功能的方式来实现 Demo。

相关技术调研，参见 iOSPrinciple 系列 [AVFoundation](https://github.com/ReverseScale/iOSPrinciple_AVFoundation)

## 🎨 测试 UI 什么样子？

|1.列表页 |2.滤镜效果页 |3.绿屏抠像页 |4.静态合成页 |
| ------------- | ------------- | ------------- | ------------- |
| ![](http://og1yl0w9z.bkt.clouddn.com/18-3-14/35442700.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/18-3-14/79019240.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/18-3-14/56773520.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/18-3-14/86588720.jpg) |
| 搭建基本框架 | 几种滤镜效果 | 实现绿屏抠像 | 静态合成Gif |


## 🚀 框架的优势
* 1.文件少，代码简洁，功能新颖
* 2.功能整合度高，体验好，结构精
* 3.单纯依赖 GPUImage 来实现
* 4.具备较高自定义性

## 🤖 要求
* iOS 7+
* Xcode 8+

## 🛠 使用方法
### 滤镜效果 
核心代码展示：

```
//将UIImage转换成CIImage
CIImage *ciImage = [[CIImage alloc] initWithImage:self.originImage];
//创建滤镜
CIFilter *filter = [CIFilter filterWithName:filterName
                              keysAndValues:kCIInputImageKey,ciImage, nil];
//已有的值不改变，其他的设为默认值
[filter setDefaults];
        
//获取绘制上下文
CIContext *context = [CIContext contextWithOptions:nil];
        
//渲染并输出CIImage
CIImage *outputImage = [filter outputImage];
        
//创建CGImage句柄
CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
        
//获取图片
UIImage *image = [UIImage imageWithCGImage:cgImage];
        
//释放CGImage句柄
CGImageRelease(cgImage);
        
self.imageView.image = image;
```

### 绿屏抠像

引用头文件：

```
#import "RSChromaKeyFilter.h"
```

工具方法：

```
RSChromaKeyFilter *filter=[[RSChromaKeyFilter alloc] initWithInputImage:self.greenImageView.image
                                                        backgroundImage:self.resultBgImageView.image];
    
self.resultImageView.image=[[UIImage imageWithCIImage:filter.outputImage] copy];
```

### 静态合成

效果演示：

![](http://og1yl0w9z.bkt.clouddn.com/17-9-4/17807305.jpg) 

引用头文件：

```
#import <CoreImage/CoreImage.h>
#import "UIImageView+Gif.h"
```

核心方法：

```
// 图像识别能力：可以在CIDetectorAccuracyHigh(较强的处理能力)与CIDetectorAccuracyLow(较弱的处理能力)中选择，因为想让准确度高一些在这里选择CIDetectorAccuracyHigh
NSDictionary *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh
                                                 forKey:CIDetectorAccuracy];

CIDetector *detector=[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];

//    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
//                                              context:nil
//                                              options:nil];

CIImage *image=[[CIImage alloc] initWithImage:self.oldImageView.image];
NSArray *faceArray = [detector featuresInImage:image
                                       options:nil];

/** 将 Core Image 坐标转换成 UIView 坐标 **/
//得到图片的尺寸
CGSize ciImageSize = [image extent].size;;
//将image沿y轴对称
CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
//y轴负方向平移
transform = CGAffineTransformTranslate(transform,0,-ciImageSize.height);

for (CIFeature *f in faceArray){
    if ([f.type isEqualToString:CIFeatureTypeFace]) {
        CIFaceFeature *faceFeature=(CIFaceFeature *)f;
        // 实现坐标转换
        CGSize viewSize = self.oldImageView.bounds.size;
        CGFloat scale = MIN(viewSize.width / ciImageSize.width,
                            viewSize.height / ciImageSize.height);
        CGFloat offsetX = (viewSize.width - ciImageSize.width * scale) / 2;
        CGFloat offsetY = (viewSize.height - ciImageSize.height * scale) / 2;
        // 缩放
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
        //获取人脸的frame
        CGRect faceViewBounds = CGRectApplyAffineTransform(faceFeature.bounds, transform);
        // 修正
        faceViewBounds = CGRectApplyAffineTransform(faceViewBounds,scaleTransform);
        faceViewBounds.origin.x += offsetX;
        faceViewBounds.origin.y += offsetY;
        
        UIView *faceView=[[UIView alloc] initWithFrame:faceViewBounds];
        faceView.layer.borderWidth=3;
        faceView.layer.borderColor=[UIColor orangeColor].CGColor;
        
        [self.oldImageView addSubview:faceView];
        
        /** 加光环  **/
        UIImageView *imageView=[UIImageView new];
        CGFloat haloWidth= faceViewBounds.size.width;
        CGFloat haloHeight= haloWidth * 159 / 351;
	       
	    ...
    }
    
}
```

### 动态合成

效果演示：

![](http://og1yl0w9z.bkt.clouddn.com/17-9-4/28926041.jpg) 

引用头文件：

```
#import <GPUImage/GPUImage.h>
```

核心方法：
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


## ⚖ 协议

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

## 😬  联系

* 微信 : WhatsXie
* 邮件 : ReverseScale@iCloud.com
* 博客 : https://reversescale.github.io
