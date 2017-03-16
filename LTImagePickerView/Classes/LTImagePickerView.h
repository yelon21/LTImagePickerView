//
//  LTImagePickerView.h
//  Pods
//
//  Created by yelon on 17/3/16.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LTImagePickerView : UIView

@property (nonatomic, strong,readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic,strong) void(^blockImagePickerResult)(UIImage *image,NSString *error);

- (void)lt_takePhoto;

- (void)lt_startCarame;

- (void)lt_stopCarame;

@end
