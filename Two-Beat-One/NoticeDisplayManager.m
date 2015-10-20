//
//  NoticeManager.m
//  Two Beat One
//
//  Created by Amay on 6/2/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "NoticeDisplayManager.h"
#import "TBONoticeView.h"
#import "UIView+CenterConstraint.h"
#import <UIKit/UIKit.h>
@interface NoticeDisplayManager()

@property(weak,nonatomic)UIView *viewToDisplayNotice;

@property(weak,nonatomic,readwrite)TBONoticeView* noticeDisplayedCurrently;
@property(strong,nonatomic)TBONoticeView* noticeDisplayedBefore;
@property(nonatomic)BOOL fadeOut;
@property(nonatomic)CGRect noticeBounds;

@end

@implementation NoticeDisplayManager

-(instancetype)initWithContainerView:(UIView *)containerView{

    self=[super init];
    if (self) {
        _viewToDisplayNotice=containerView;
    }
    return self;

}
-(void)setNoticeWidth:(float)width height:(float)height{
    self.noticeBounds=CGRectMake(0, 0, width, height);
}
-(TBONoticeView *)currentNotice{

    return self.noticeDisplayedCurrently;

}

-(void)showNotice:(TBONoticeView *)notice fadeOut:(BOOL)fadeOut{

    self.fadeOut=fadeOut;


    if (notice != self.noticeDisplayedCurrently) {

        self.noticeDisplayedBefore=nil;
        
        self.noticeDisplayedBefore=self.noticeDisplayedCurrently;
        
        [self.noticeDisplayedCurrently removeFromSuperview];
        
        self.noticeDisplayedCurrently=notice;
        [self.viewToDisplayNotice addSubview:self.noticeDisplayedCurrently];
        [UIView makeView:self.noticeDisplayedCurrently centerInView:self.viewToDisplayNotice withSize:self.noticeBounds.size];


    }

    if (fadeOut) {
        [self.noticeDisplayedCurrently performSelector:@selector(removeFromSuperview)
                                            withObject:nil
                                            afterDelay:1];
    }
}

-(void)showPreviousNotice{

    if (!self.noticeDisplayedCurrently) {
        return;
    }

    [self.noticeDisplayedCurrently removeFromSuperview];
    self.noticeDisplayedCurrently=self.noticeDisplayedBefore;
    [self.viewToDisplayNotice addSubview:self.noticeDisplayedCurrently];
    [UIView makeView:self.noticeDisplayedCurrently centerInView:self.viewToDisplayNotice withSize:self.noticeBounds.size];

    self.noticeDisplayedBefore=nil;
    
    
}
-(void)dismissNotice{
    
    [self.noticeDisplayedCurrently removeFromSuperview];
    self.noticeDisplayedCurrently=nil;
    self.noticeDisplayedBefore=nil;
    
}




@end
