//
//  PlayerPhotoImageView.m
//  Two Beat One
//
//  Created by Amay on 5/26/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "PlayerPhotoImageView.h"

@interface PlayerPhotoImageView()
@end

@implementation PlayerPhotoImageView

#pragma mark -property
-(void)setPhoto:(UIImage *)photo{

    _photo=photo;
    [self setNeedsDisplay];

}
#pragma mark - draw
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    UIBezierPath *circleBorder=[UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, 1, 1)];
    [[UIColor colorWithRed:1 green:1 blue:222.0/255 alpha:1] setStroke];
    [[UIColor colorWithRed:1 green:1 blue:235.0/255 alpha:1] setFill];
    [circleBorder stroke];
    [circleBorder fill];
    [circleBorder addClip];
    
    [self.photo drawInRect:rect];
    
}

#pragma mark - animation
-(void)startAnimating{

    [self animate];

}

-(void)stopAnimating{

    [self.layer removeAllAnimations];
    self.alpha=1.0;

}

-(void)animate{

    if (!self.isHidden) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                                    self.alpha=0.3;
                                }
                         completion:nil];
    }

}

#pragma mark - setup
-(void)awakeFromNib{

 [self setup];

}

-(void)setup{
    
    self.contentMode=UIViewContentModeScaleAspectFill;
    self.backgroundColor=[UIColor clearColor];
    self.photo=[UIImage imageNamed:@"DefaultPhoto"];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    self=[super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

@end
