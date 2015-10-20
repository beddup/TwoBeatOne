//
//  NoticeView.h
//  Two Beat One
//
//  Created by Amay on 5/15/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBONoticeView : UIView

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton; // if no right button, then leftbutton is the only one button
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property(strong,nonatomic)NSDictionary *additionalInfo;

+(instancetype)noticeWithMessage:(NSString *)message
                 leftButtonTitle:(NSString *)leftTitle
                rightButtonTitle:(NSString *)rightTitle
                  hasCloseButton:(BOOL)hasCloseButton;


@end
