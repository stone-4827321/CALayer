//
//  CABasicAnimationViewController.m
//  CoreAnimation
//
//  Created by stone on 2020/9/7.
//  Copyright © 2020 3kMac. All rights reserved.
//

#import "CABasicAnimationViewController.h"

@interface CABasicAnimationViewController () <CAAnimationDelegate>

@property (nonatomic, strong) CALayer *layer;

@end

@implementation CABasicAnimationViewController

- (void)dealloc {
    NSLog(@"CABasicAnimationViewController dealloc");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.layer removeAnimationForKey:@"animation"];
    //self.layer = nil;
}

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
//    [self springAnimation];
//    return;
    
    
    //创建CABasicAnimation对象
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    //设置初始值
    animation.fromValue = (id)[UIColor redColor].CGColor;
    //设置结束值
    animation.toValue = (id)[UIColor blueColor].CGColor;
    //设置时间
    animation.duration = 2.0;
    
    animation.delegate = self;


//    //以下两个保证动画结束后停留在结束值
//    animation.fillMode = kCAFillModeForwards;
//    animation.removedOnCompletion = NO;

    [self.layer addAnimation:animation forKey:@"animation"];
}


- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.layer.backgroundColor = (__bridge CGColorRef)((CABasicAnimation *)anim).toValue;
    [CATransaction commit];
}

- (void)springAnimation {
    CASpringAnimation *animation = [CASpringAnimation animationWithKeyPath:@"position.y"];
    // 质量，质量越大，弹簧拉伸和压缩的幅度就越大
    animation.mass = 10;
    // 刚度系数，刚度系数越大，形变产生的力就越大，运动越快
    animation.stiffness = 5000;
    // 阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快
    animation.damping = 100.0;
    // 初始速率，速率为正数时，速度方向与运动方向一致，速率为负数时，速度方向与运动方向相反
    animation.initialVelocity = 5.f;

    // 结算时间，根据动画参数估算弹簧开始运动到停止的时间，动画设置的时间最好根据此时间来设置
    animation.duration = animation.settlingDuration;
    
    animation.toValue = @(400);
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    [self.layer addAnimation:animation forKey:@"springAnimation"];
}

@end
