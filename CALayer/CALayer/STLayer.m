//
//  STLayer.m
//  CALayer
//
//  Created by stone on 2020/9/2.
//  Copyright © 2020 3kMac. All rights reserved.
//

#import "STLayer.h"
#import <UIKit/UIKit.h>

@implementation STLayer

//- (void)display {
//    NSLog(@"display");
//    UIImage *image = [UIImage imageNamed:@"1.png"];
//    self.contents = (__bridge id)image.CGImage;
//}
//
- (void)drawInContext:(CGContextRef)ctx {
    // 绘制一个圆
    CGContextSetLineWidth(ctx, 10.0f);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextStrokeEllipseInRect(ctx, self.bounds);
}

- (void)setNeedsLayout {
    NSLog(@"setNeedsLayout");
    [super setNeedsLayout];
}

- (void)displayIfNeeded {
    NSLog(@"displayIfNeeded");
}

@end
