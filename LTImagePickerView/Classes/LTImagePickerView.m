//
//  LTImagePickerView.m
//  Pods
//
//  Created by yelon on 17/3/16.
//
//

#import "LTImagePickerView.h"

@interface LTImagePickerView ()<AVCaptureMetadataOutputObjectsDelegate>

/** 设备 */
@property (nonatomic, strong) AVCaptureDevice *device;
/** 会话对象 */
@property (nonatomic, strong) AVCaptureSession *session;
/** 图层类 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *output;

@end

@implementation LTImagePickerView

-(void)dealloc{
    
    [self.previewLayer removeFromSuperlayer];
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

-(void)awakeFromNib{
    
    [super awakeFromNib];
    [self setup];
}

-(void)layoutSubviews{

    [super layoutSubviews];
    
    self.previewLayer.frame = self.bounds;
    AVCaptureConnection *videoConnection = self.previewLayer.connection;
    
    if ([videoConnection isVideoOrientationSupported]) {
        
        videoConnection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
    }
}

- (void)setup{
    
    self.session = [[AVCaptureSession alloc] init];
    // 实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    
    // 1、获取摄像设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2、创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // 3、创建输出流
    self.output = [[AVCaptureStillImageOutput alloc] init];
    self.output.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG, AVVideoScalingModeKey:AVVideoScalingModeResize};
    
    // 5、初始化链接对象（会话对象）
    // 高质量采集率
    //session.sessionPreset = AVCaptureSessionPreset1920x1080; // 如果二维码图片过小、或者模糊请使用这句代码，注释下面那句代码
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 5.1 添加会话输入
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    
    // 5.2 添加会话输出
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    
    // 7、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.bounds;
    [self.layer addSublayer:self.previewLayer];
    
    if ([self.device lockForConfiguration:nil]) {
        
        if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [self.device setFlashMode:AVCaptureFlashModeAuto];
        }
        if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    [LTImagePickerView LT_CheckCameraAccess:^(BOOL granted) {
        
        if (granted) {
            
            [self lt_startCarame];
        }
        else{
        
            NSLog(@"未授权访问摄像头");
        }
    }];
}

- (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation {
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    switch (interfaceOrientation) {
            
        case UIInterfaceOrientationLandscapeLeft: {
            
            return AVCaptureVideoOrientationLandscapeLeft;
        }
        case UIInterfaceOrientationLandscapeRight: {
            
            return AVCaptureVideoOrientationLandscapeRight;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            
            return AVCaptureVideoOrientationPortraitUpsideDown;
        }
        default: {
            
            return AVCaptureVideoOrientationPortrait;
        }
    }
}

#pragma mark private
- (void)tapGestureAction:(UITapGestureRecognizer*)gesture{
    
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point{
    
    //CGSize size = self.bounds.size;
    
   // CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    
    CGPoint focusPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        self.device.subjectAreaChangeMonitoringEnabled = YES;
        self.device.focusPointOfInterest = focusPoint;
        
        [self.device unlockForConfiguration];
        
    }
    
}

- (void)lt_takePhoto{

    if (self.session.isRunning) {
        
        [self takePhotoAction];
    }
    else{
    
        [self lt_startCarame];
    }
}

- (void)lt_startCarame{
    
    if (!self.session.isRunning) {
        
        [self.session startRunning];
    }
}

- (void)lt_stopCarame{
    
    if (self.session.isRunning) {
        
        [self.session stopRunning];
    }
}

- (void)takePhotoAction{
    
    AVCaptureConnection *videoConnection = [self.output connectionWithMediaType:AVMediaTypeVideo];
    if ([videoConnection isVideoOrientationSupported]) {
        
        videoConnection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
    }
    
    
    if (!videoConnection) {
        
        [self didPickerImage:nil error:@"图像获取失败"];
        return;
    }
    
    videoConnection.videoScaleAndCropFactor = 1;
    
    [self.output captureStillImageAsynchronouslyFromConnection:videoConnection
                                             completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                 
                                                 if (imageDataSampleBuffer == NULL) {
                                                     
                                                     [self didPickerImage:nil error:@"图像获取失败"];
                                                     return;
                                                 }
                                                 NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                 [self lt_stopCarame];
                                                 
                                                 UIImage *image = [UIImage imageWithData:imageData];
                                                 image = [self fixOrientation:image];
                                                 [self didPickerImage:image error:nil];
                                                 
                                             }];
}

- (void)didPickerImage:(UIImage *)image error:(NSString *)error{

    NSLog(@"image=%@,error=%@",image,error);
    
    if (self.blockImagePickerResult) {
        
        self.blockImagePickerResult(image,error);
    }
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
#pragma mark check
+ (void)LT_CheckCameraAccess:(void (^)(BOOL granted))handler{

    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:handler];
}

@end
