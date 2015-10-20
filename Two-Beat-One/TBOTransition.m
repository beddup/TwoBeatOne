//
//  TBOTransition.m
//  Two Beat One
//
//  Created by Amay on 5/16/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOTransition.h"
#import "TBO_PresentOptionVC_Animator.h"
#import "TBO_DismissOptionVC_Animator.h"
#import "TBOPanInteractiveTransition.h"

#import "OptionsViewController.h"

@interface TBOTransition()

@property(strong,nonatomic)TBO_PresentOptionVC_Animator *presentOptionAnimator;

@property(strong,nonatomic)TBO_DismissOptionVC_Animator *dismissOptionAnimator;

@property(strong,nonatomic) TBOPanInteractiveTransition *panInteractivePA;

@end


@implementation TBOTransition

-(void)handlePanTransitionGesture:(UIPanGestureRecognizer *)gesture{

    if (self.isInteractive) {
        [self.panInteractivePA handlePanGesture:gesture];
    }

}

-(TBO_PresentOptionVC_Animator *)presentOptionAnimator{
    if (!_presentOptionAnimator) {
        _presentOptionAnimator=[[TBO_PresentOptionVC_Animator alloc]init];
    }
    return _presentOptionAnimator;
}
-(TBO_DismissOptionVC_Animator *)dismissOptionAnimator{
    if (!_dismissOptionAnimator) {
        _dismissOptionAnimator=[[TBO_DismissOptionVC_Animator alloc]init];
    }
    return _dismissOptionAnimator;
}
-(TBOPanInteractiveTransition *)panInteractivePA{
    if (!_panInteractivePA) {
        _panInteractivePA=[[TBOPanInteractiveTransition alloc]init];
    }
    return _panInteractivePA;
}


// UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    
    if ([presented isKindOfClass:[OptionsViewController class]]) {
        return self.presentOptionAnimator;
    }
    return nil;
    
}
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    if ([dismissed isKindOfClass:[OptionsViewController class]]) {
        return self.dismissOptionAnimator;
    }
    
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
    return  self.isInteractive ?  self.panInteractivePA :nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    return self.isInteractive ? self.panInteractivePA : nil;
}



@end
