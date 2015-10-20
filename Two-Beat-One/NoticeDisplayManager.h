//
//  NoticeManager.h
//  Two Beat One
//
//  Created by Amay on 6/2/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TBONoticeView;
@class UIView;
@interface NoticeDisplayManager : NSObject

-(instancetype)initWithContainerView:(UIView *)containerView;

-(void)setNoticeWidth:(float)width height:(float)height;
-(void)showNotice:(TBONoticeView *)notice fadeOut:(BOOL)fadeOut ;
-(TBONoticeView *)currentNotice;
-(void)showPreviousNotice;
-(void)dismissNotice;


@end
