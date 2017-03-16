//
//  LYViewController.m
//  LTImagePickerView
//
//  Created by 254956982@qq.com on 03/16/2017.
//  Copyright (c) 2017 254956982@qq.com. All rights reserved.
//

#import "LYViewController.h"
#import "LTImagePickerViewController.h"

@interface LYViewController ()<LTImagePickerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation LYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)showCarema:(id)sender {
    
    LTImagePickerViewController *view = [[LTImagePickerViewController alloc]initWithNibName:@"LTImagePickerViewController" bundle:nil];
    view.delegate = self;
    [self presentViewController:view
                       animated:YES completion:nil];
}

-(void)imagePickerViewController:(LTImagePickerViewController *)imagePickerViewController
                     originImage:(UIImage *)originImage
                     editedImage:(UIImage *)editedImage{

    NSLog(@"originImage=%@",originImage);
    NSLog(@"editedImage=%@",editedImage);
    
    self.imageView.image = editedImage;
}

@end
