//
//  TBOInteractiveTransition.m
//  Two Beat One
//
//  Created by Amay on 5/16/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOPanInteractiveTransition.h"
@interface TBOPanInteractiveTransition()


@end

@implementation TBOPanInteractiveTransition

-(void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer{
    static  BOOL shouldComplete;
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    switch (gestureRecognizer.state) {
        
        case UIGestureRecognizerStateBegan:{
            shouldComplete=NO;
        }
        case UIGestureRecognizerStateChanged: {
            
            CGFloat fraction =fabs(translation.x)/ gestureRecognizer.view.frame.size.width;
            fraction = fminf(fmaxf(fraction, 0.0), 0.9);
            shouldComplete = (fraction > 0.5);
            [self updateInteractiveTransition:fraction];
            break;
            
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (!shouldComplete || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                [self cancelInteractiveTransition];
            }
            else {
                [self finishInteractiveTransition];
            }
            break;
        }
        default:
            break;
    }

}

@end
