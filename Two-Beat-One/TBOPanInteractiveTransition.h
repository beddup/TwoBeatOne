//
//  TBOInteractiveTransition.h
//  Two Beat One
//
//  Created by Amay on 5/16/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <UIKit/UIKit.h>

//only for TBO pan transition
@interface TBOPanInteractiveTransition : UIPercentDrivenInteractiveTransition

-(void)handlePanGesture:(UIPanGestureRecognizer *)gesture;

@end
