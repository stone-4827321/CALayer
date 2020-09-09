//
//  CATransitionViewController.m
//  CoreAnimation
//
//  Created by stone on 2020/9/7.
//  Copyright © 2020 3kMac. All rights reserved.
//

#import "CATransitionViewController.h"

@interface CATransitionViewController ()

@property (nonatomic, strong) CALayer *layer;

@end

@implementation CATransitionViewController

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
    CATransition *transition = [CATransition animation];
    // 设置动画类型
    transition.type = kCATransitionMoveIn;
    // 设置动画方向
    transition.subtype = kCATransitionFromLeft;
    transition.duration = 2.0f;
    // 可以控制动画只执行中间部分
    //transition.startProgress = 0.1;
    //transition.endProgress = 0.9;
    [self.layer addAnimation:transition forKey:@"transitionAnimation"];
    
    // 使添加动画的视图执行转场动作，如修改颜色、背景图片等
    self.layer.backgroundColor = [UIColor blueColor].CGColor;
}
@end
