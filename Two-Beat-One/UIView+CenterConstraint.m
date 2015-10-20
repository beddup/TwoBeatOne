//
//  UIView+CenterConstraint.m
//  Two-Beat-One
//
//  Created by Amay on 6/23/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "UIView+CenterConstraint.h"

@implementation UIView (CenterConstraint)
+(void)makeView:(UIView *)view1 centerInView:(UIView *)view2 withSize:(CGSize)size{
    // add size constraints
    NSLayoutConstraint *widthConstraint=[NSLayoutConstraint constraintWithItem:view1
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:size.width];
    NSLayoutConstraint *heightConstraint=[NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.height];
    [view1 addConstraints:@[widthConstraint,heightConstraint]];

    //add center constraints
    NSLayoutConstraint *centerXConstraint=[NSLayoutConstraint constraintWithItem:view1
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:view2
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0
                                                                        constant:0.0];
    NSLayoutConstraint *centerYConstraint=[NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view2 attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [view2 addConstraints:@[centerXConstraint,centerYConstraint]];

}

@end
