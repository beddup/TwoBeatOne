//
//  TBOTransition.h
//  Two Beat One
//
//  Created by Amay on 5/16/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface TBOTransition : NSObject<UIViewControllerTransitioningDelegate>

@property(nonatomic)BOOL isInteractive;
@property(nonatomic)BOOL beginInteractiveTransition;

-(void)handlePanTransitionGesture:(UIPanGestureRecognizer *)gesture;
@end
