# RSFaceuDemo
Faceu脸萌一定是有一套自己的核心算法，所以它会说“有人模仿我的脸...”

![](https://img.shields.io/badge/platform-iOS-red.svg) 
![](https://img.shields.io/badge/language-Objective--C-orange.svg) 
![](https://img.shields.io/badge/download-11.6MB-brightgreen.svg) 
![](https://img.shields.io/badge/license-MIT%20License-brightgreen.svg) 

最近在研究一些图像处理的技术，其中最常见的应用就要数 “Faceu 脸萌” 了，为了展示更清晰，我选择拆分功能的方式来实现 Demo。

| 名称 |1.列表页 |2.滤镜效果页 |3.绿屏抠像页1 |4.绿屏抠像页2 |5.静态合成页 |6.动态合成页 |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| 截图 | ![](http://og1yl0w9z.bkt.clouddn.com/17-9-4/98294256.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/17-9-4/68659680.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/17-9-4/33825098.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/17-9-4/25444114.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/17-9-4/17807305.jpg) | ![](http://og1yl0w9z.bkt.clouddn.com/17-9-4/28926041.jpg) |
| 描述 | 通过 storyboard 搭建基本框架 | 基于系统的几种滤镜效果 | 基于 GPUImage 封装实现绿屏抠像 | 更换素材实现绿屏抠像 | 基于 GPUImage 封装实现静态合成 | 基于 GPUImage 封装实现合成 |

## Advantage 框架的优势
* 1.文件少，代码简洁，功能新颖
* 2.功能整合度高，体验好，结构精
* 3.单纯依赖 <GPUImage> 实现
* 4.具备较高自定义性

## Requirements 要求
* iOS 7+
* Xcode 8+


## Usage 使用方法
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

引用头文件：

```
#import <CoreImage/CoreImage.h>
#import "UIImageView+Gif.h"
```

核心方法：

```
for (UIView *view in self.oldImageView.subviews) {
    [view removeFromSuperview];
}

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
        
        CGFloat haloCenterX=faceViewBounds.origin.x+faceViewBounds.size.width/2;
        
        CGRect rect=CGRectMake(haloCenterX-haloWidth/2, faceViewBounds.origin.y-haloHeight, haloWidth, haloHeight);
        imageView.frame=rect;
        [self.oldImageView addSubview:imageView];
        
        
        NSMutableArray *list=[NSMutableArray new];
        for (int i=0; i<41; i++) {
            if (i<10) {
                NSString *name=[NSString stringWithFormat:@"halo_00%d",i];
                UIImage  *image=  [UIImage imageNamed:name];
                [list addObject:image];
            }else{
                NSString *name=[NSString stringWithFormat:@"halo_0%d",i];
                UIImage  *image=  [UIImage imageNamed:name];
                [list addObject:image];
            }
        }
        
        [imageView playGifAnim:[list copy]];
        
        // 判断是否有左眼位置
        if(faceFeature.hasLeftEyePosition){
            
            CGFloat x=faceFeature.leftEyePosition.x;
            CGFloat y=faceFeature.leftEyePosition.y;
            CGRect leftEyeRect=CGRectMake(x-10/2,y-10/2, 10, 10);
            
            //获取人脸的frame
            CGRect leftEyeBounds = CGRectApplyAffineTransform(leftEyeRect, transform);
            leftEyeBounds=CGRectApplyAffineTransform(leftEyeBounds,scaleTransform);
            leftEyeBounds.origin.x += offsetX;
            leftEyeBounds.origin.y += offsetY;
            
            UIView *leftEyeView = [[UIView alloc] initWithFrame:leftEyeBounds];
            leftEyeView .backgroundColor = [UIColor orangeColor];
            [self.oldImageView addSubview:leftEyeView ];
            
        }
        // 判断是否有右眼位置
        if(faceFeature.hasRightEyePosition){
            CGFloat x=faceFeature.rightEyePosition.x;
            CGFloat y=faceFeature.rightEyePosition.y;
            CGRect rightEyeRect=CGRectMake(x-10/2,y-10/2, 10, 10);
            
            //获取人脸的frame
            CGRect rightEyeBounds = CGRectApplyAffineTransform(rightEyeRect, transform);
            rightEyeBounds=CGRectApplyAffineTransform(rightEyeBounds,scaleTransform);
            rightEyeBounds.origin.x += offsetX;
            rightEyeBounds.origin.y += offsetY;
            
            UIView *rightEyeView = [[UIView alloc] initWithFrame:rightEyeBounds];
            rightEyeView.backgroundColor = [UIColor orangeColor];
            [self.oldImageView addSubview:rightEyeView];
            
        }
        // 判断是否有嘴位置
        if(faceFeature.hasMouthPosition){
            
        }
        
    }
    
}
```

### 动态合成

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

if (currentCameraPosition != AVCaptureDevicePositionBack) {
    isUsingFrontFacingCamera = TRUE;
}

switch (curDeviceOrientation) {
    case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
        exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
        break;
    case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
        if (isUsingFrontFacingCamera)
            exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
        else
            exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
        break;
    case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
        if (isUsingFrontFacingCamera)
            exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
        else
            exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
        break;
    case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
    default:
        exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
        break;
}

imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
NSArray *features = [self.faceDetector featuresInImage:convertedImage options:imageOptions];

// get the clean aperture
CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);


[self GPUVCWillOutputFeatures:features forClap:clap andOrientation:curDeviceOrientation];
_faceThinking = NO;
```

使用简单、效率高效、进程安全~~~如果你有更好的建议,希望不吝赐教!


## License 许可证
RSFaceuDemo 使用 MIT 许可证，详情见 LICENSE 文件。


## Contact 联系方式:
* WeChat : WhatsXie
* Email : ReverseScale@iCloud.com
* Blog : https://reversescale.github.io
