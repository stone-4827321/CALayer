//
//  CAAnimationGroupViewController.m
//  CoreAnimation
//
//  Created by stone on 2020/9/7.
//  Copyright © 2020 3kMac. All rights reserved.
//

#import "CAAnimationGroupViewController.h"

@interface CAAnimationGroupViewController () <CAAnimationDelegate>

@property (nonatomic, strong) CALayer *layer;

@end

@implementation CAAnimationGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];

    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 100, 100, 100);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:layer];
    self.layer = layer;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CAKeyframeAnimation *rotation = [CAKeyframeAnimation animation];
    rotation.keyPath = @"transform.rotation";
    rotation.values = @[@0, @0.5, @0];
    rotation.duration = 3;

    CAKeyframeAnimation *position = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //设置关键帧
    NSValue *key1      = [NSValue valueWithCGPoint:CGPointMake(50, 150)];
    NSValue *key2      = [NSValue valueWithCGPoint:CGPointMake(300, 150)];
    NSValue *key3      = [NSValue valueWithCGPoint:CGPointMake(300, 450)];
    NSValue *key4      = [NSValue valueWithCGPoint:CGPointMake(50, 450)];
    position.values   = @[key1, key2, key3, key4];
    //设置各个帧的运行时间
    position.keyTimes = @[@0.1, @0.2, @0.3, @0.4];
    //设置时间
    position.duration = 3.0f;

    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.animations = @[rotation, position];
    group.duration = 3;

    [self.layer addAnimation:group forKey:@"group"];
}


@end
