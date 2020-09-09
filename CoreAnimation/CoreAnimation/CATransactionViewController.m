//
//  STCATransitionViewController.m
//  CoreAnimation
//
//  Created by stone on 2020/9/7.
//  Copyright © 2020 3kMac. All rights reserved.
//

#import "CATransactionViewController.h"
 
@interface CATransactionViewController () <CALayerDelegate>

@property (nonatomic, strong) CALayer *layer;

@end

@implementation CATransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(100, 100, 100, 100);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:layer];
    self.layer = layer;
    
    layer.delegate = self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [CATransaction begin];
    // 动画持续时间
    [CATransaction setAnimationDuration:2];
    // 动画时间曲线
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [CATransaction setCompletionBlock:^{
        // 动画完成后执行
        NSLog(@"动画执行完毕");
    }];
    // 修改layer的可动画属性
    self.layer.backgroundColor = [UIColor blueColor].CGColor;
    [CATransaction commit];
}

- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    if ([event isEqualToString:@"backgroundColor"]) {
        // 增加一些转场效果
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        return transition;
    }
    return nil;
}

@end
