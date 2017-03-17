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
@end

@protocol LTImagePickerDelegate <NSObject>
@optional
- (void)imagePickerViewController:(LTImagePickerViewController *)imagePickerViewController
                      originImage:(UIImage *)originImage
                      editedImage:(UIImage *)editedImage;

@end
