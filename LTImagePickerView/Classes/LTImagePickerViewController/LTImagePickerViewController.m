//
//  LTImagePickerViewController.m
//  Pods
//
//  Created by yelon on 17/3/16.
//
//

#import "LTImagePickerViewController.h"
#import "LTImagePickerView.h"
#import "LTImagePickerCover.h"

@interface LTImagePickerViewController (){

    UIImage *currentImage;
}

@property (weak, nonatomic) IBOutlet LTImagePickerView *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *perviewImageView;
@property (weak, nonatomic) IBOutlet LTImagePickerCover *cvoerView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *retakePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *buttonsBackView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LTImagePickerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (!self.titleString) {
        self.titleString = @"请拍照";
    }
    else{
    
        self.titleString = self.titleString;
    }
    
    [self showTakePhotoView];
    __weak typeof(self)weakSelf = self;
    
    [self.imagePicker setBlockImagePickerResult:^(UIImage *image, NSString *error) {
        
        if (error) {
            
            NSLog(@"error%@",error);
            return ;
        }
        
        [weakSelf showPreImageView:image];
        
    }];
}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    [LTImagePickerView LT_CheckCameraAccess:^(BOOL granted) {
        
        if (!granted) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self closeAction:nil];
            });
            
        }
    }];
}

-(void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    //210 130 320
    if (self.uneditable) {
        
        self.cvoerView.maskSize = CGSizeZero;
    }
    else{
    
        self.cvoerView.maskSize = CGSizeMake(21.0/32.0*width
                                             , 13.0/32.0*width);
    }
}

-(void)setTitleString:(NSString *)titleString{
    
    _titleString = titleString;
    self.titleLabel.text = self.titleString;
}

- (void)showPreImageView:(UIImage *)image{

    if (image) {
        
        currentImage = image;
        self.perviewImageView.image = currentImage;
        self.doneBtn.hidden = NO;
        self.retakePhotoBtn.hidden = NO;
        
        self.takePhotoBtn.hidden = YES;
        self.closeBtn.hidden = YES;
        self.buttonsBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    }
}

- (IBAction)closeAction:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePhotoAction:(id)sender {
    
    [self.imagePicker lt_takePhoto];
}

- (IBAction)retakePhotoAction:(id)sender {
    
    [self.imagePicker lt_startCarame];
    [self showTakePhotoView];
}

- (void)showTakePhotoView{

    currentImage = nil;
    self.perviewImageView.image = currentImage;
    self.doneBtn.hidden = YES;
    self.retakePhotoBtn.hidden = YES;
    
    self.takePhotoBtn.hidden = NO;
    self.closeBtn.hidden = NO;
    self.buttonsBackView.backgroundColor = [UIColor clearColor];
}

- (IBAction)doneAction:(id)sender {
    
    if (self.cvoerView.maskSize.width<1.0||self.cvoerView.maskSize.height<1.0) {
        
        [self didGetImage:currentImage editedImage:currentImage];
        return;
    }
    
    UIImage *imageSource = [LTImagePickerViewController getScreenshotFromView:self.perviewImageView];
    UIImage *editedImage = [self cutImage:imageSource frame:[self maskFrame:imageSource]];
    
    [self didGetImage:imageSource editedImage:editedImage];
}

- (UIImage *)cutImage:(UIImage *)image frame:(CGRect)frame{

    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, frame);
    
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}

- (CGRect)maskFrame:(UIImage *)image{

    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    CGFloat maskWidth = self.cvoerView.maskSize.width;
    CGFloat maskHeight = self.cvoerView.maskSize.height;
    
    if (maskWidth>width) {
        
        maskWidth = width;
    }
    
    if (maskHeight>height) {
        
        maskHeight = height;
    }
    //
    
    CGFloat scale = image.scale;
    CGFloat imageWidth = image.size.width*scale;
    CGFloat imageHeight = image.size.height*scale;
    
    CGFloat ptX = (width-maskWidth)/2.0;
    CGFloat ptY = (height-maskHeight)/2.0;
    
    CGFloat radW = imageWidth/width;
    CGFloat radH = imageHeight/height;
    
    CGRect result = CGRectMake(ptX*radW
                               , ptY*radH
                               , radW*maskWidth
                               , radH*maskHeight);
    return result;
}

- (void)didGetImage:(UIImage *)originImage editedImage:(UIImage *)editedImage{

    if ([self.delegate respondsToSelector:@selector(imagePickerViewController:originImage:editedImage:)]) {
        
        [self.delegate imagePickerViewController:self
                                     originImage:originImage
                                     editedImage:editedImage];
        
        [self closeAction:nil];
    }
}

+ (UIImage *)getScreenshotFromView:(UIView *)view{
    
    if (view) {
        
        CGSize size = view.bounds.size;
        
        if (size.width * size.height == 0.0) {
            
            NSLog(@"bounds.size 不能为0");
            return nil;
        }
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat width = size.width;
        CGFloat height = size.height;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, scale);
        if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [view drawViewHierarchyInRect:CGRectMake(0, 0, width, height)
                       afterScreenUpdates:YES];
        } else {
            [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        }
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    return nil;
}

-(BOOL)shouldAutorotate{

    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    if (self.interfaceOrientationMask == 0) {
        
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    return self.interfaceOrientationMask;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    if (self.interfaceOrientation == 0) {
        
        return UIInterfaceOrientationLandscapeRight;
    }
    return self.interfaceOrientation;
}

@end
