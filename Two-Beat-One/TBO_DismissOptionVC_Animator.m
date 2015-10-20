//
//  TBO_DismissOptionVC_Animator.m
//  Two Beat One
//
//  Created by Amay on 5/16/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBO_DismissOptionVC_Animator.h"

@implementation TBO_DismissOptionVC_Animator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.3;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *fromVC=[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC=[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // set toview frame
    CGRect bounds=[[UIScreen mainScreen]bounds];
    CGRect finalFrame=[transitionContext finalFrameForViewController:toVC];
    toVC.view.frame=CGRectOffset(finalFrame, -bounds.size.width, 0);
    
    //the containervies has container the fromvc
    UIView *containerView=[transitionContext containerView];
    [containerView addSubview:toVC.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         toVC.view.frame=finalFrame;
                         fromVC.view.frame=CGRectOffset(finalFrame, bounds.size.width, 0);
                     }
                     completion:^(BOOL finished){
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end
