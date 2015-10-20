//
//  UIView+CenterConstraint.h
//  Two-Beat-One
//
//  Created by Amay on 6/23/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CenterConstraint)

+(void)makeView:(UIView *)view1 centerInView:(UIView *)view2 withSize:(CGSize)size;

@end
