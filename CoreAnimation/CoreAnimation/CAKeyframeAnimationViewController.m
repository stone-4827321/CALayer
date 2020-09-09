//
//  CAKeyframeAnimationViewController.m
//  CoreAnimation
//
//  Created by stone on 2020/9/7.
//  Copyright © 2020 3kMac. All rights reserved.
//

#import "CAKeyframeAnimationViewController.h"

@interface CAKeyframeAnimationViewController ()

@property (nonatomic, strong) CALayer *layer;

@end

@implementation CAKeyframeAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];

    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(100, 100, 100, 100);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:layer];
    
    self.layer = layer;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //创建CABasicAnimation对象
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //设置关键帧
    NSValue *key1      = [NSValue valueWithCGPoint:CGPointMake(150, 150)];
    NSValue *key2      = [NSValue valueWithCGPoint:CGPointMake(200, 20)];
    NSValue *key3      = [NSValue valueWithCGPoint:CGPointMake(200, 200)];
    NSValue *key4      = [NSValue valueWithCGPoint:CGPointMake(45, 200)];
    animation.values   = @[key1, key2, key3, key4];
    //设置各个帧的运行时间
    animation.keyTimes = @[@0.1, @0.2, @0.3, @0.4];
    //设置时间
    animation.duration = 10.0f;
    
    
//    CGRect boundingRect = CGRectMake(-150, -150, 300, 300);
//    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
//    animation.keyPath = @"position";
//    animation.path = CFAutorelease(CGPathCreateWithEllipseInRect(boundingRect, NULL));
//    animation.duration = 4;
//    animation.additive = YES;
//    animation.repeatCount = HUGE_VALF;
//    animation.calculationMode = kCAAnimationPaced;
//    animation.rotationMode = kCAAnimationRotateAuto;
    
    //为控件添加动画
    [self.layer addAnimation:animation forKey:@"keyframeAnimation"];
}

@end
