//
//  DynamicSyntheticViewController.m
//  RSFaceuDemo
//
//  Created by WhatsXie on 2017/9/1.
//  Copyright © 2017年 StevenXie. All rights reserved.
//

#import "DynamicSyntheticViewController.h"
#import "RSDetectorDynamicViewController.h"
#import "UIImageView+Gif.h"

@interface DynamicSyntheticViewController ()<RSDetectorDynamicDelegate>
@property (nonatomic,readwrite,strong) RSDetectorDynamicViewController *detectorVC;
@property (nonatomic,readwrite,strong) UIView      *faceView;
@property (nonatomic,readwrite,strong) UIImageView *haloImgView;
@property (nonatomic,readwrite,strong) NSArray     *haloImgList;
@property (nonatomic,readwrite,strong) UIImageView *leftEyeImgView;
@property (nonatomic,readwrite,strong) UIImageView *rightEyeImgView;
@property (nonatomic,readwrite,strong) UIButton         *rightButton;
@property (nonatomic,readwrite,strong) UIBarButtonItem  *rightBarButtonItem;
@end

@implementation DynamicSyntheticViewController

- (void)viewDidLoad {
    [super viewDidLoad ];
    
    self.navigationItem.rightBarButtonItem=self.rightBarButtonItem;
    
    [self addChildViewController:self.detectorVC];
    [self.view addSubview:self.detectorVC.view];
    self.detectorVC.view.frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);
    
    [self.view addSubview:self.faceView];
    [self.view addSubview:self.haloImgView];
    [self.haloImgView playGifAnim:self.haloImgList];
    
    [self.view addSubview:self.leftEyeImgView];
    [self.view addSubview:self.rightEyeImgView];
}

#pragma mark - action
- (void)onRightNavButtonTapped:(UIBarButtonItem *)sender event:(UIEvent *)event {
    
    [self.detectorVC chanageCamera];
    self.rightButton.selected=(!self.rightButton.selected);
    
    //    [self.detectorVC.view removeFromSuperview];
    //    [self.view addSubview:self.detectorVC.view];
    [self.rightButton sizeToFit];
}

#pragma mark - delegate
- (void)detectorDynamicLocateFace:(CGRect)faceBounds {
    if (CGRectEqualToRect(faceBounds, CGRectZero)   ) {
        self.leftEyeImgView.hidden=self.rightEyeImgView.hidden=self.faceView.hidden=self.haloImgView.hidden=YES;
        
    } else {
        
        self.faceView.hidden=self.haloImgView.hidden=NO;
        self.faceView.frame=faceBounds;
        {
            CGFloat haloWidth= faceBounds.size.width;
            CGFloat haloHeight= haloWidth * 159 / 351;
            
            CGFloat haloCenterX=faceBounds.origin.x+faceBounds.size.width/2;
            
            CGRect rect=CGRectMake(haloCenterX-haloWidth/2, faceBounds.origin.y-haloHeight, haloWidth, haloHeight);
            self.haloImgView.frame=rect;
        }
        
    }
}

- (void)detectorDynamicLocateLeftEyeForFace:(CGRect)leftEyeBounds {
    if (CGRectEqualToRect(leftEyeBounds, CGRectZero)) {
        self.leftEyeImgView.hidden=YES;
        
    } else {
        self.leftEyeImgView.hidden=NO;
        self.leftEyeImgView.frame=leftEyeBounds;
    }
}

- (void)detectorDynamicLocateRightEyeForFace:(CGRect)rightEyeBounds {
    if (CGRectEqualToRect(rightEyeBounds, CGRectZero)) {
        self.rightEyeImgView.hidden=YES;
        
    } else {
        self.rightEyeImgView.hidden=NO;
        self.rightEyeImgView.frame=rightEyeBounds;
    }
}

#pragma mark - getter
- (UIBarButtonItem *)rightBarButtonItem {
    if(!_rightBarButtonItem){
        _rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    }
    return _rightBarButtonItem;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        
        _rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton setTitleColor:[UIColor blackColor]
                           forState:UIControlStateNormal];
        [_rightButton setTitle:@"前"
                      forState:UIControlStateNormal];
        
        [_rightButton setTitle:@"后"
                      forState:UIControlStateSelected];
        
        [_rightButton sizeToFit];
        [_rightButton addTarget:self
                         action:@selector(onRightNavButtonTapped:event:)
               forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _rightButton;
}

- (RSDetectorDynamicViewController *)detectorVC {
    if (!_detectorVC) {
        _detectorVC = [RSDetectorDynamicViewController new];
        _detectorVC.detectorDelegate = self;
    }
    return _detectorVC;
}

- (UIView *)faceView {
    if (!_faceView) {
        _faceView = [UIView new];
        //        _faceView.layer.borderColor=[UIColor orangeColor].CGColor;
        //        _faceView.layer.borderWidth=2;
    }
    return _faceView;
}

- (UIImageView *)haloImgView {
    if (!_haloImgView) {
        _haloImgView=[UIImageView new];
    }
    return _haloImgView;
}

- (NSArray *)haloImgList {
    if (!_haloImgList) {
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
        
        _haloImgList= [list copy];
    }
    return _haloImgList;
}

- (UIImageView *)leftEyeImgView {
    if (!_leftEyeImgView) {
        _leftEyeImgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftHeart"]];
        
    }
    return _leftEyeImgView;
}

- (UIImageView *)rightEyeImgView {
    if (!_rightEyeImgView) {
        _rightEyeImgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightHeart"]];
    }
    return _rightEyeImgView;
}

@end
