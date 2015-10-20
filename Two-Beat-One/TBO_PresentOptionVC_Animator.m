//
//  TBO_Transition_Animator.m
//  Two Beat One
//
//  Created by Amay on 5/16/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBO_PresentOptionVC_Animator.h"


@interface TBO_PresentOptionVC_Animator()


@end

@implementation TBO_PresentOptionVC_Animator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.3;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *toVC=[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC=[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // set the toVC frame
    CGRect bounds=[[UIScreen mainScreen]bounds];
    CGRect finalFrame=[transitionContext finalFrameForViewController:toVC];
    toVC.view.frame=CGRectOffset(finalFrame, bounds.size.width,0);
    
    //the container view already container fromview
    UIView *containerView=[transitionContext containerView];
    [containerView addSubview:toVC.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         toVC.view.frame=finalFrame;
                         fromVC.view.frame=CGRectOffset(bounds, -bounds.size.width, 0);
                          }
                     completion:^(BOOL finished){
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}


@end
