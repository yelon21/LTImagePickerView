//
//  LTImagePickerCover.m
//  Pods
//
//  Created by yelon on 17/3/16.
//
//

#import "LTImagePickerCover.h"

@interface LTImagePickerCover ()

@property(nonatomic,strong) CALayer *baseLayer;
@property(nonatomic,strong) CAShapeLayer *maskLayer;
@property(nonatomic,strong) CAShapeLayer *rectLayer;

@end

@implementation LTImagePickerCover

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
    
    [self updatePath];
}
#pragma mark setup
- (void)setup{
    
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    self.baseLayer = [CALayer layer];
    self.baseLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.45].CGColor;
    
    [self.layer addSublayer:self.baseLayer];
    
    self.maskLayer = [CAShapeLayer layer];
    
    self.baseLayer.mask = self.maskLayer;
    
    self.rectLayer = [CAShapeLayer layer];
    
    self.rectLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.rectLayer.lineWidth = 4.0;
    self.rectLayer.fillColor = nil;
    
    [self.layer addSublayer:self.rectLayer];
    
    [self updatePath];
}

-(void)setMaskSize:(CGSize)maskSize{

    if (CGSizeEqualToSize(_maskSize, maskSize)) {
        
        return;
    }
    
    _maskSize = maskSize;
    
    [self updatePath];
}

- (void)updatePath{
    
    if (self.maskSize.width<10||self.maskSize.height<10) {
        
        return;
    }
    
    self.baseLayer.frame = self.bounds;
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat maskWidth = self.maskSize.width;
    CGFloat maskHeight = self.maskSize.height;
    
    if (maskWidth>width||maskHeight>height) {
        
        return;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat boundsLength = 0.0;
    
    [path moveToPoint:CGPointMake(boundsLength, boundsLength)];
    [path addLineToPoint:CGPointMake(width-boundsLength, boundsLength)];
    [path addLineToPoint:CGPointMake(width-boundsLength, height-boundsLength)];
    [path addLineToPoint:CGPointMake(boundsLength, height-boundsLength)];
    
    [path addLineToPoint:CGPointMake(boundsLength, boundsLength)];
    
    CGFloat deltY = 0.0;
    
    CGFloat deltW = (width-maskWidth)/2.0;
    CGFloat deltH = (height-maskHeight)/2.0;
    
    [path moveToPoint:CGPointMake(boundsLength+deltW, boundsLength+deltH+deltY)];
    [path addLineToPoint:CGPointMake(boundsLength+deltW, height-boundsLength-deltH+deltY)];
    [path addLineToPoint:CGPointMake(width-boundsLength-deltW, height-boundsLength-deltH+deltY)];
    [path addLineToPoint:CGPointMake(width-boundsLength-deltW, boundsLength+deltH+deltY)];
    [path addLineToPoint:CGPointMake(boundsLength+deltW, boundsLength+deltH+deltY)];
    
    self.maskLayer.path = path.CGPath;
    
    CGRect rectFrame = CGRectMake(boundsLength+deltW,
                                  boundsLength+deltH+deltY,
                                  maskWidth,
                                  maskHeight);
    self.rectLayer.frame = rectFrame;
    [self updateRectLayerContent];
}

- (void)updateRectLayerContent{
    
    CGFloat maskWidth = CGRectGetWidth(self.rectLayer.bounds);
    CGFloat maskHeight = CGRectGetHeight(self.rectLayer.bounds);
    
    CGFloat lineLength = 40.0;
    
    UIBezierPath *rectPath = [UIBezierPath bezierPath];
    //左上角
    [rectPath moveToPoint:CGPointMake(0.0, lineLength)];
    [rectPath addLineToPoint:CGPointMake(0.0, 0.0)];
    [rectPath addLineToPoint:CGPointMake(lineLength, 0.0)];
    
    //右上角
    [rectPath moveToPoint:CGPointMake(maskWidth-lineLength, 0.0)];
    [rectPath addLineToPoint:CGPointMake(maskWidth, 0.0)];
    [rectPath addLineToPoint:CGPointMake(maskWidth, lineLength)];
    
    //右下角
    [rectPath moveToPoint:CGPointMake(maskWidth, maskHeight-lineLength)];
    [rectPath addLineToPoint:CGPointMake(maskWidth, maskHeight)];
    [rectPath addLineToPoint:CGPointMake(maskWidth-lineLength, maskHeight)];
    
    //左下角
    [rectPath moveToPoint:CGPointMake(lineLength, maskHeight)];
    [rectPath addLineToPoint:CGPointMake(0.0, maskHeight)];
    [rectPath addLineToPoint:CGPointMake(0.0, maskHeight-lineLength)];
    
    self.rectLayer.path = rectPath.CGPath;
}


@end
