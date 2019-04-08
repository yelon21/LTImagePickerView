//
//  LTImagePickerViewController.h
//  Pods
//
//  Created by yelon on 17/3/16.
//
//

#import <UIKit/UIKit.h>

@protocol LTImagePickerDelegate;

@interface LTImagePickerViewController : UIViewController

@property(nonatomic,weak)id<LTImagePickerDelegate> delegate;
@property(nonatomic,assign) BOOL uneditable;

@property(nonatomic,assign) UIInterfaceOrientationMask interfaceOrientationMask;
@property(nonatomic,assign) UIInterfaceOrientation interfaceOrientation;

@property(nonatomic, strong) NSString *titleString;
@end

@protocol LTImagePickerDelegate <NSObject>
@optional
- (void)imagePickerViewController:(LTImagePickerViewController *)imagePickerViewController
                      originImage:(UIImage *)originImage
                      editedImage:(UIImage *)editedImage;

@end
