//
//  STViewController.m
//  CoreAnimation
//
//  Created by stone on 2020/9/7.
//  Copyright © 2020 3kMac. All rights reserved.
//

#import "STViewController.h"
#import "CATransactionViewController.h"
#import "CABasicAnimationViewController.h"
#import "CAKeyframeAnimationViewController.h"
#import "CAAnimationGroupViewController.h"
#import "CATransitionViewController.h"

@interface STViewController ()

@end

@implementation STViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)CATransaction:(id)sender {
    CATransactionViewController *vc = [[CATransactionViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)CABasicAnimation:(id)sender {
    CABasicAnimationViewController *vc = [[CABasicAnimationViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)CAKeyframeAnimation:(id)sender {
    CAKeyframeAnimationViewController *vc = [[CAKeyframeAnimationViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)CAAnimationGroup:(id)sender {
    CAAnimationGroupViewController *vc = [[CAAnimationGroupViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)CATransition:(id)sender {
    CATransitionViewController *vc = [[CATransitionViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
