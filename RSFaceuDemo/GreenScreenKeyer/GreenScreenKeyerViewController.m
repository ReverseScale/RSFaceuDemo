//
//  GreenScreenKeyerViewController.m
//  RSFaceuDemo
//
//  Created by WhatsXie on 2017/9/1.
//  Copyright © 2017年 StevenXie. All rights reserved.
//

#import "GreenScreenKeyerViewController.h"
#import "RSChromaKeyFilter.h"

@interface GreenScreenKeyerViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *greenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *resultBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;

@property (nonatomic,readwrite,strong) UIImagePickerController *imagePicker;
@property (nonatomic,readwrite,strong) UIView *selectedView;
@end

@implementation GreenScreenKeyerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self hz_addView:self.greenImageView touchAction:@selector(tapImgView:)];
    [self hz_addView:self.resultBgImageView touchAction:@selector(tapImgView:)];
}
- (IBAction)tapResultButton:(id)sender {
    RSChromaKeyFilter *filter=[[RSChromaKeyFilter alloc] initWithInputImage:self.greenImageView.image
                                                            backgroundImage:self.resultBgImageView.image];
    
    self.resultImageView.image=[[UIImage imageWithCIImage:filter.outputImage] copy];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //UIImage *image=info[UIImagePickerControllerEditedImage];
    UIImage *image=info[UIImagePickerControllerOriginalImage];
    if (self.selectedView==self.greenImageView) {
        self.greenImageView.image=image;
        return;
    }
    
    self.resultBgImageView.image=image;
    return;
}

#pragma mark - Action
- (void)tapImgView:(UITapGestureRecognizer *)gesture {
    if (gesture.view) {
        self.selectedView=gesture.view;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

#pragma mark - private
- (void)hz_addView:(UIView *)view touchAction:(SEL)action {
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *g =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [view addGestureRecognizer:g];
}

#pragma mark - lazy
- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker=[UIImagePickerController new];
        _imagePicker.allowsEditing = NO;
        _imagePicker.sourceType= UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker.delegate=self;
    }
    return _imagePicker;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
