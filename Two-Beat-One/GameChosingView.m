//
//  GameChosingView.m
//  Two Beat One
//
//  Created by Amay on 5/15/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "GameChosingView.h"
#import "Reachability.h"
#import "TBOGameSetting.h"
#import "TBOGameGCCommunicator.h"

#define Game_Chosing_View_BlueTooth_Disable NSLocalizedStringFromTable(@"Game_Chosing_View_BlueTooth_Disable", @"GameChosingInfo", @"BlueTooth_Disable")
#define Game_Chosing_View_Network_Disable NSLocalizedStringFromTable(@"Game_Chosing_View_Network_Disable", @"GameChosingInfo", @"Game_Chosing_View_Network_Disable")
#define Game_Chosing_View_Authenticating NSLocalizedStringFromTable(@"Game_Chosing_View_Authenticating", @"GameChosingInfo", @"Game_Chosing_View_Authenticating")

@interface GameChosingView()

@property (weak, nonatomic) IBOutlet UIButton *online;
@property (weak, nonatomic) IBOutlet UIButton *bluetooth;
@property (weak, nonatomic) IBOutlet UIButton *offline;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *bkgImageView;

@property(nonatomic)GameContext chosenGameContext;

@end

@implementation GameChosingView

#pragma mark - property
-(void)setDisplayedInfo:(NSString *)displayedInfo{

    _displayedInfo=displayedInfo;
    self.label.text=displayedInfo;
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
        self.label.alpha=0;
    } completion:^(BOOL finished) {
        self.label.text=@"";
        self.label.alpha=1.0;
    }];
}
#pragma mark - Internal Methods
-(void)startGame:(GameMode)gameMode{

    if ([self shouldStartGame]) {
        [TBOGameSetting sharedGameSetting].gameMode=gameMode;
        [TBOGameSetting sharedGameSetting].gameContext=self.chosenGameContext;
        [[NSNotificationCenter defaultCenter]postNotificationName:GameModeAndGameContextDeterminedNotification
                                                           object:self];
    }

}

-(BOOL)shouldStartGame{

    switch (self.chosenGameContext) {
        case GameContextOnLine:{
            if (![self isNetworkAvailable]) {
                self.displayedInfo=Game_Chosing_View_Network_Disable;
                return NO;
            }
            if (![[TBOGameGCCommunicator sharedTBOGameCommunicator] isAuthernticationCompleted]) {
                self.displayedInfo=Game_Chosing_View_Authenticating;
                [[TBOGameGCCommunicator sharedTBOGameCommunicator] checkAuthenticationProgress];
                return NO;
            }
            return YES;
        }
        default:
            return YES;
    }
}

-(BOOL)isNetworkAvailable{
    BOOL networkingAvailabel=[Reachability reachabilityForInternetConnection].currentReachabilityStatus;
    return networkingAvailabel;
}

-(void)highlight:(UIButton *)button
            grey:(UIButton *)button1
             and:(UIButton *)button2{

    // hightlight buttion
    [button setTitleColor:[UIColor colorWithRed:1 green:1 blue:222.0/255 alpha:1] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithRed:40.0/255 green:179.0/255 blue:1.0 alpha:1]];

    //clear hightlight
    [button1 setBackgroundColor:[UIColor clearColor]];
    [button1 setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
    [button2 setBackgroundColor:[UIColor clearColor]];
    [button2 setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];

}

-(void)gameContextChanged:(GameContext)gameContext{
    self.chosenGameContext=gameContext;
    switch (gameContext) {
        case GameContextOnLine:
        {
            [self highlight:self.online grey:self.offline and:self.bluetooth];
            break;
        }
        case GameContextBlueTooth:
        {
            [self highlight:self.bluetooth grey:self.offline and:self.online];
            break;
        }
        case GameContextOffline:
        {
            [self highlight:self.offline grey:self.online and:self.bluetooth];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Actions
- (IBAction)customGameButton:(UIButton *)sender {

    [self startGame:GameModeCustom];

}

- (IBAction)standardGameButton:(UIButton *)sender {

    [self startGame:GameModeStandard];

}


- (IBAction)onLine:(UIButton *)sender {

    [self gameContextChanged:GameContextOnLine];

}
- (IBAction)blueTooth:(id)sender {

    [self gameContextChanged:GameContextBlueTooth];
}

- (IBAction)offLine:(id)sender {
    
    [self gameContextChanged:GameContextOffline];

}


#pragma mark - setup
-(void)awakeFromNib{
   
    [self setup];
    
}

-(void)setup{
    
    [self gameContextChanged:[TBOGameSetting sharedGameSetting].gameContext];
    self.backgroundColor=[UIColor clearColor];
    self.label.adjustsFontSizeToFitWidth=YES;
    [self setTranslatesAutoresizingMaskIntoConstraints:NO]; // necessary if add constraints pragramtically
    self.bkgImageView.image=[[UIImage imageNamed:@"noticeBKG"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)
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
