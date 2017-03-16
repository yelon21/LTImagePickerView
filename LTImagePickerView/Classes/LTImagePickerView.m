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
    
    [self setup];
}

-(void)layoutSubviews{

    [super layoutSubviews];
    
    self.previewLayer.frame = self.bounds;
    self.previewLayer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
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
    
    [self lt_startCarame];
    if ([self.device lockForConfiguration:nil]) {
        
        if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [self.device setFlashMode:AVCaptureFlashModeAuto];
        }
        
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [self.device unlockForConfiguration];
    }
}

- (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation {
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (interfaceOrientation) {
            
        case UIInterfaceOrientationPortrait: {
            return AVCaptureVideoOrientationPortrait;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            return AVCaptureVideoOrientationLandscapeLeft;
        }
        case UIInterfaceOrientationLandscapeRight: {
            return AVCaptureVideoOrientationLandscapeRight;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            return AVCaptureVideoOrientationPortraitUpsideDown;
        }
    }
}

#pragma mark private
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
    videoConnection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
    
    if (!videoConnection) {
        
        [self didPickerImage:nil error:@"图像获取失败"];
        return;
    }
    
    [self.output captureStillImageAsynchronouslyFromConnection:videoConnection
                                             completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                 
                                                 if (imageDataSampleBuffer == NULL) {
                                                     
                                                     [self didPickerImage:nil error:@"图像获取失败"];
                                                     return;
                                                 }
                                                 NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                 [self lt_stopCarame];
                                                 
                                                 UIImage *image = [UIImage imageWithData:imageData];
                                                 [self didPickerImage:image error:nil];
                                                 
                                             }];
}

- (void)didPickerImage:(UIImage *)image error:(NSString *)error{

    NSLog(@"image=%@,error=%@",image,error);
    
    if (self.blockImagePickerResult) {
        
        self.blockImagePickerResult(image,error);
    }
}


@end
