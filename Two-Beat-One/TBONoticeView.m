//
//  NoticeView.m
//  Two Beat One
//
//  Created by Amay on 5/15/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//
#import "TBONoticeView.h"
@interface TBONoticeView()

@property (weak, nonatomic) IBOutlet UIImageView *BKGmageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end


@implementation TBONoticeView

+(instancetype)noticeWithMessage:(NSString *)message
                 leftButtonTitle:(NSString *)leftTitle
                rightButtonTitle:(NSString *)rightTitle
                  hasCloseButton:(BOOL)hasCloseButton{

    if (!rightTitle) {
        return [TBONoticeView noticeWithMessage:message
                                    buttonTitle:leftTitle
                                 hasCloseButton:hasCloseButton];
    }

    TBONoticeView *noticeView= [[[NSBundle mainBundle] loadNibNamed:@"NoticeView_TwoButtons"
                                                              owner:nil
                                                            options:nil]
                                lastObject];
    noticeView.messageLabel.text=message;
    [noticeView.leftButton setTitle:leftTitle forState:UIControlStateNormal];
    [noticeView.rightButton setTitle:rightTitle forState:UIControlStateNormal];
    if (hasCloseButton) {
        [noticeView.closeButton setBackgroundImage:[UIImage imageNamed:@"Close_Button_Image"]
                                          forState:UIControlStateNormal];
    }
    return noticeView;
    
}

+(instancetype)noticeWithMessage:(NSString *)message
                     buttonTitle:(NSString *)title
                  hasCloseButton:(BOOL)hasCloseButton{

    if (!title) {
        return [TBONoticeView noticeWithMessage:message];
    }

    TBONoticeView *noticeView= [[[NSBundle mainBundle] loadNibNamed:@"NoticeView_OneButton"
                                                              owner:nil
                                                            options:nil]
                                lastObject];
    noticeView.messageLabel.text=message;
    [noticeView.leftButton setTitle:title forState:UIControlStateNormal];
    if (hasCloseButton) {
        [noticeView.closeButton setBackgroundImage:[UIImage imageNamed:@"Close_Button_Image"]
                                          forState:UIControlStateNormal];
    }
    return noticeView;
    
}

+(instancetype)noticeWithMessage:(NSString *)message{

    if (!message) {
        return nil;
    }
    TBONoticeView *noticeView= [[[NSBundle mainBundle] loadNibNamed:@"NoticeView_OnlyMessage"
                                                               owner:nil
                                                             options:nil]
                                        lastObject];
    noticeView.messageLabel.text=message;
    return noticeView;

}

#pragma mark - setup
-(void)awakeFromNib{
    [self setup];
}

-(void)setup{

    self.backgroundColor=[UIColor clearColor];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO]; // necessary if add constraints pragramtically
    self.BKGmageView.image=[[UIImage imageNamed:@"noticeBKG"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)
                                                                            resizingMode:UIImageResizingModeStretch];

}
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
@end
