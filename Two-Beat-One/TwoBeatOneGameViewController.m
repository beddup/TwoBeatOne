//
//  TwoBeatOneGameViewController.m
//  Two Beat One
//
//  Created by Amay on 5/14/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//
#import <GameKit/GameKit.h>
#import "TwoBeatOneGameViewController.h"
#import "ChessBoard.h"
#import "TBO_Standard_Game.h"
#import "TBO_Custom_Game.h"
#import "GameChosingView.h"
#import "OptionsViewController.h"
#import "TBOTransition.h"
#import "TBOGameSetting.h"
#import "TBOGameGCCommunicator.h"
#import "TBOGameMCCommuniator.h"
#import "PlayerPhotoImageView.h"
#import "NoticeDisplayManager.h"
#import "TBOLearderBoardViewController.h"
#import "TBONoticeView.h"
#import "UIView+CenterConstraint.h"

#pragma mark -Localization
// record
#define Record_Finished NSLocalizedStringFromTable(@"Record_Finished", @"Notice", nil)
#define Recording NSLocalizedStringFromTable(@"Recording", @"Notice", nil)

//make friend
#define Notice_Send_Make_Friend_Request NSLocalizedStringFromTable(@"Notice_Send_Make_Friend_Request", @"Notice",nil)
#define Notice_Cancel_Make_Friend_Request NSLocalizedStringFromTable(@"Notice_Cancel_Make_Friend_Request", @"Notice", nil)
#define Notice_Make_Friend_Request_Message NSLocalizedStringFromTable(@"Notice_Make_Friend_Request_Message", @"Notice", nil)

// game start notice
#define Notice_Game_Start_ME_FIRST NSLocalizedStringFromTable(@"Notice_Game_Start_ME_FIRST", @"Notice", @"game starts and I am First")
#define Notice_Game_Start_OPPOSITE_FIRST NSLocalizedStringFromTable(@"Notice_Game_Start_OPPOSITE_FIRST", @"Notice", @"game starts and opposite First")

//once more game notice
#define Notice_Send_Play_Game_Once_More_Message  NSLocalizedStringFromTable(@"Notice_Send_Play_Game_Once_More_Message", @"Notice",nil)
#define Notice_Received_Once_More_Game_Message NSLocalizedStringFromTable(@"Notice_Received_Once_More_Game_Message", @"Notice", nil)
#define Notice_Accept_Once_More_Game_Message NSLocalizedStringFromTable(@"Notice_Accept_Once_More_Game_Message", @"Notice", nil)
#define Notice_Refuse_Once_More_Game_Message NSLocalizedStringFromTable(@"Notice_Refuse_Once_More_Game_Message", @"Notice", nil)
#define Notice_Opposite_Refused_Request NSLocalizedStringFromTable(@"Notice_Opposite_Refused_Request", @"Notice", nil)

// accept invitation
#define Notice_Local_Accept_Invitaion NSLocalizedStringFromTable(@"Notice_Local_Accept_Invitaion", @"Notice",nil)

//game end notice
#define Notice_Win_Message  NSLocalizedStringFromTable(@"Notice_Win_Message", @"Notice", @"win")
#define Notice_Once_More_Game_Button  NSLocalizedStringFromTable(@"Notice_Once_More_Game_Button", @"Notice",nil)
#define Notice_Win_CheckRank_Button  NSLocalizedStringFromTable(@"Notice_Win_CheckRank_Button", @"Notice", nil)
#define Notice_Lost_Message  NSLocalizedStringFromTable(@"Notice_Lost_Message", @"Notice", nil)
#define Notice_offline_win_Message NSLocalizedStringFromTable(@"Notice_offline_win_Message",@"Notice",nil)
#define Notice_offline_lost_Message NSLocalizedStringFromTable(@"Notice_offline_lost_Message",@"Notice",nil)
#define Image_Less_Than_Steps_Prefix  NSLocalizedStringFromTable(@"Image_Less_Than_Steps", @"Image", nil)

#define Notice_Game_Will_Start_In_Any_Time  NSLocalizedStringFromTable(@"Notice_Game_Will_Start_In_Any_Time", @"Notice", nil)
#define Lost_Connection_With_Player_Message NSLocalizedStringFromTable(@"Lost_Connection_With_Player_Message", @"Notice", nil)


@interface TwoBeatOneGameViewController ()<TBO_Game_Delegate,TBOGameCommunicatorDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet ChessBoard *chessBoard;

// record UI
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *recordLabel;

//playerUI
@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet PlayerPhotoImageView *playerPhotoImageView;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;

@property (weak, nonatomic) GameChosingView *gameChosingPad;
@property (strong, nonatomic) NoticeDisplayManager *noticeDisplayManager;

@property (strong, nonatomic) TBO_Game *game;
@property (strong, nonatomic) TBOGameCommunicator *gameCommunicator;

@property (strong, nonatomic) TBOTransition * customTransition; //transition manager



@end

@implementation TwoBeatOneGameViewController

#pragma mark - view controller life cycle
- (void)viewDidLoad {

    [super viewDidLoad];
    // if ipad
    self.splitViewController.preferredDisplayMode=UISplitViewControllerDisplayModePrimaryHidden;
    self.navigationController.navigationBarHidden=YES;

    // add gesture
    UITapGestureRecognizer *tapChessBoard=[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                 action:@selector(chessBoardTapped:)];
    [self.view addGestureRecognizer:tapChessBoard];
    if (!self.splitViewController) {
        UIPanGestureRecognizer *panGestureForTransition=[[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                               action:@selector(panToTransition:)];
        [self.view addGestureRecognizer:panGestureForTransition];
    }
    // add observer
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(gameModeAndContextDetermined:)
                                                name:GameModeAndGameContextDeterminedNotification
                                              object:nil];
    [self showGameChosingPad];

    // set delegate here so that self can present authencationvc in gccommunicator
    [TBOGameGCCommunicator sharedTBOGameCommunicator].delegate=self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)showGameChosingPad{
    if (self.gameChosingPad) {
        return;
    }
    if (self.game.stateOfGame == GameStateProcceed) {
        return;
    }
    if ([self.noticeDisplayManager currentNotice]) {
        return;
    }
    if (self.gameCommunicator) {
        return;
    }
    self.gameChosingPad=[[[NSBundle mainBundle] loadNibNamed:@"GameChosingView"
                                                                   owner:nil
                                                                 options:nil] lastObject];
    [self.view addSubview:self.gameChosingPad];
    [UIView makeView:self.gameChosingPad centerInView:self.view withSize:self.gameChosingPad.bounds.size];

}

-(void)dismissGameChosingPad{
    [self.gameChosingPad removeFromSuperview];
    self.gameChosingPad=nil;
}


-(void)updateRecordButtonUI{

    // update recordButton and recordingLabel
    self.recordButton.hidden=!self.game;
    self.recordLabel.hidden= !self.game || !self.game.isRecording;

    if (!self.recordLabel.hidden) {
        self.recordLabel.text=self.game.stateOfGame == GameStateEnd ? Record_Finished :Recording;
    }

    if (!self.recordButton.hidden) {
        [self.recordButton setBackgroundImage:[UIImage imageNamed:self.game.isRecording ? @"Record_Recording" :@"Record_TapToStartButtonImage"]
                                     forState:UIControlStateNormal];
        [self.recordButton setTitle:self.game.isRecording ? [@(self.game.stepCount) stringValue] : @""
                           forState:UIControlStateNormal];
    }
}
-(void)updatePlayerUI{

    self.playerNameLabel.alpha=1.0;
    if (!self.gameCommunicator) {
        // if offline context or disconnect, then don't display playerUI;
        self.playerNameLabel.text=@"";
        self.playerPhotoImageView.photo=nil;
        self.playerPhotoImageView.hidden=YES;
        self.addFriendButton.hidden=YES;
        return;
    }

    // if connect with opposite, display its name and photo
    self.playerNameLabel.text=self.gameCommunicator.playerName;
    self.playerPhotoImageView.hidden=NO;
    self.playerPhotoImageView.photo=self.gameCommunicator.playerPhoto;
    
    if ([self.gameCommunicator isKindOfClass:[TBOGameGCCommunicator class]] &&
        ![(TBOGameGCCommunicator *)self.gameCommunicator oppositeIsFriend]) {
        self.addFriendButton.hidden=NO;
    }else{
        self.addFriendButton.hidden=YES;
    }
}
#pragma  mark - Properties
-(NoticeDisplayManager *)noticeDisplayManager{

    if (!_noticeDisplayManager) {

        _noticeDisplayManager=[[NoticeDisplayManager alloc]initWithContainerView:self.view];
        CGFloat width=  CGRectGetWidth(self.chessBoard.bounds)>300 ? 300-10 : CGRectGetWidth(self.chessBoard.bounds)-10;
        CGFloat height= width*2/3;
        [_noticeDisplayManager setNoticeWidth:width height:height];

    }
    return _noticeDisplayManager;
}
-(TBOTransition *)customTransition{
    
    if (!_customTransition) {
        _customTransition=[[TBOTransition alloc]init];
        _customTransition.isInteractive=YES;
    }
    return _customTransition;
}
#pragma mark -  IBAction
- (IBAction)recordButtonPressed:(UIButton *)button {
    if (!self.game.isRecording) {
        NSString *oppositeName=self.gameCommunicator.playerName ? self.gameCommunicator.playerName : @"Unknow";
        [self.game startRecord:oppositeName];
        [self updateRecordButtonUI];
    }
}
- (IBAction)showOptions:(UIButton *)sender {

    if (self.splitViewController) {
        self.splitViewController.preferredDisplayMode=UISplitViewControllerDisplayModePrimaryOverlay;
        return;
    }

    self.customTransition.isInteractive=NO; // user tapped the 'MENU' button, interactive transition should not work

    OptionsViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"optionsVC"];
    vc.transitioningDelegate=self.customTransition;
    vc.transiton=self.customTransition;
    [self presentViewController:vc animated:YES completion:nil];

}

//  make friend
- (IBAction)addFriends:(id)sender {

    NSString *displayName=self.gameCommunicator.playerName;
    if (displayName.length>10) {
        displayName=[[displayName substringToIndex:8] stringByAppendingString:@"..."];
    }

    TBONoticeView *notice=[TBONoticeView noticeWithMessage:[NSString stringWithFormat:Notice_Make_Friend_Request_Message,
                                                            self.gameCommunicator.playerName]
                                           leftButtonTitle:Notice_Send_Make_Friend_Request
                                          rightButtonTitle:Notice_Cancel_Make_Friend_Request
                                            hasCloseButton:NO];

    [notice.leftButton addTarget:self
                          action:@selector(sendFriendRequest)
                forControlEvents:UIControlEventTouchUpInside];
    [notice.rightButton addTarget:self
                           action:@selector(cancelAddFriend)
                 forControlEvents:UIControlEventTouchUpInside];

    [self.noticeDisplayManager showNotice:notice fadeOut:NO];
}
-(void)sendFriendRequest{
    [[TBOGameGCCommunicator sharedTBOGameCommunicator]makeFriendWithOpposite:self];
}
-(void)cancelAddFriend{
    [self.noticeDisplayManager dismissNotice];
}

#pragma mark -  Handle Gestures
-(void)chessBoardTapped:(UITapGestureRecognizer *)gesture{

    CGPoint location=[gesture locationInView:self.chessBoard];
    Position * position=[[Position alloc]initWithX:location.x/(CGRectGetWidth(self.chessBoard.frame)/3)+1.5
                                                 Y:5-(NSInteger)(location.y/(CGRectGetHeight(self.chessBoard.frame)/3)+1.5)];
    
    [self.game positionWasHit:position];
    [self.chessBoard positionWasHit:position];
}

-(void)panToTransition:(UIPanGestureRecognizer *)gestureRecognizer{
   
    CGPoint translation=[gestureRecognizer translationInView:self.view];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.customTransition.beginInteractiveTransition=NO;
    }

    if ( translation.x < -50 && !self.customTransition.beginInteractiveTransition) {
        // set beginInteractiveTransition yes to avoid presenting vc again
        self.customTransition.beginInteractiveTransition=YES;
        OptionsViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"optionsVC"];
        vc.transitioningDelegate=self.customTransition;
        vc.transiton=self.customTransition;
        [self presentViewController:vc animated:YES completion:nil];
    }
    [self.customTransition handlePanTransitionGesture:gestureRecognizer];
    
}


#pragma mark - Build Game
-(void)gameModeAndContextDetermined:(NSNotification *)notification{

    [self dismissViewControllerAnimated:NO completion:nil];
    // disconnect existing communicator
    [self.gameCommunicator disconnect];
    switch ([TBOGameSetting sharedGameSetting].gameContext) {
        case GameContextOnLine:
        {
            [TBOGameGCCommunicator sharedTBOGameCommunicator].delegate=self;
            [[TBOGameGCCommunicator sharedTBOGameCommunicator] findMatch:self];

            //don't receive information from TBOGameMCCommuniator if any;
            [TBOGameMCCommuniator sharedTBOGameCommunicator].delegate=nil;

            break;
        }
        case GameContextBlueTooth:{
            [TBOGameMCCommuniator sharedTBOGameCommunicator].delegate=self;
            [[TBOGameMCCommuniator sharedTBOGameCommunicator] browseNearByPlayers:self];

            // don't receive information from TBOGameGCCommunicator if any
            [TBOGameGCCommunicator sharedTBOGameCommunicator].delegate=nil;

            break;
        }
        case GameContextOffline:{
            // don't receive information from any communicator if any
            self.gameCommunicator.delegate=nil;
            self.gameCommunicator=nil;

            // create new game and starts
            self.game= ([TBOGameSetting sharedGameSetting].gameMode==GameModeStandard) ? [[TBO_Standard_Game alloc]init] :[[TBO_Custom_Game alloc]init];
            self.game.delegate=self;
            [self gameReady:arc4random()%2==1];
            break;
        }
        default:
            break;
    }
}

-(void)gameReady:(BOOL)meFirst{

    //dismiss any other VC;
    //if ipad
    if (self.splitViewController) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModePrimaryHidden];
    }
    [self dismissViewControllerAnimated:NO completion:nil];

    // update UI
    [self.chessBoard reset:[TBOGameSetting sharedGameSetting].gameMode];
    [self dismissGameChosingPad];
    [self updatePlayerUI];
    meFirst ? [self.playerPhotoImageView stopAnimating]:[self.playerPhotoImageView startAnimating];
    [self updateRecordButtonUI];

    [self.noticeDisplayManager dismissNotice];
    NSString *message= meFirst ? Notice_Game_Start_ME_FIRST : Notice_Game_Start_OPPOSITE_FIRST;
    TBONoticeView *notice=[TBONoticeView noticeWithMessage:message
                                           leftButtonTitle:nil
                                          rightButtonTitle:nil
                                            hasCloseButton:NO];
    [self.noticeDisplayManager showNotice:notice fadeOut:YES];

    [self.game startWithFirstTurn:meFirst];

}

#pragma mark - Game Communicator DELEGATE

// tell user opposite's action
-(void)gameCommunicator:(TBOGameCommunicator *)gameCommunicator
      oppositeMovedFrom:(Position *)pFrom
                     to:(Position *)pTo {

        [self.chessBoard chessPieceAtPosition:pFrom moveToPosition:pTo];
        [self.game moveFromPosition:pFrom to:pTo];
        [self.playerPhotoImageView stopAnimating];

}
-(void)gameCommunicator:(TBOGameCommunicator *)gameCommunicator
            oppositeAdd:(Position *)p{

        [self.chessBoard addChessPieceAtPosition:p isOpposite:YES];
        [self.game addPiecePosition:p isOpposite:YES];
        [self.playerPhotoImageView stopAnimating];

}
// first contact success
-(void)gameCommunicator:(TBOGameCommunicator *)gameCommunicator
                  ready:(BOOL)meFirst{

    self.gameCommunicator=gameCommunicator;
    self.gameCommunicator.delegate=self;

    self.game= [TBOGameSetting sharedGameSetting].gameMode==GameModeStandard ?
                                            [[TBO_Standard_Game alloc]init] :
                                            [[TBO_Custom_Game alloc]init];
    self.game.delegate=self;

    // communicator and gamemodel all ready, update UI to start game
    [self gameReady:meFirst];
}

// handle opposite's request of playing once more
-(void)gameCommunicator:(TBOGameCommunicator *)gameCommunicator
oppositeRequestOnceMoreGame:(NSDictionary *)option {

    NSString *displayName=gameCommunicator.playerName;
    if (displayName.length>10) {
        displayName=[[displayName substringToIndex:8] stringByAppendingString:@"..."];
    }

    TBONoticeView *notice=[TBONoticeView noticeWithMessage:[NSString stringWithFormat:Notice_Received_Once_More_Game_Message,displayName]
                                           leftButtonTitle:Notice_Accept_Once_More_Game_Message
                                          rightButtonTitle:[NSString stringWithFormat:Notice_Refuse_Once_More_Game_Message,@(Default_Time_Out)]
                                            hasCloseButton:YES];
    notice.additionalInfo=@{@"option":option,
                            @"gameCommunicator":gameCommunicator};
    [notice.leftButton addTarget:self
                       action:@selector(acceptRequest:)
             forControlEvents:UIControlEventTouchUpInside];
    [notice.rightButton addTarget:self
                       action:@selector(refuseRequest:)
             forControlEvents:UIControlEventTouchUpInside];
    [notice.closeButton addTarget:self action:@selector(closeReceivedRequest:) forControlEvents:UIControlEventTouchUpInside];
    [self.noticeDisplayManager showNotice:notice fadeOut:NO];

    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(timeLeftBeforeRefusingRequest:)
                                   userInfo:@{@"notice":notice}
                                    repeats:YES];
}
-(void)closeReceivedRequest:(UIButton *)closeButton{

    TBONoticeView *notice=[self.noticeDisplayManager currentNotice];
    [(TBOGameCommunicator *)notice.additionalInfo[@"gameCommunicator"] sendRefusingOnceMoreGameRequest];
    [self.noticeDisplayManager showPreviousNotice];
    // clear communicator
    self.gameCommunicator.delegate=nil;
    self.gameCommunicator=nil;
    [self updatePlayerUI];

}
-(void)acceptRequest:(UIButton *)button{

    if (!self.gameCommunicator) {
        // if disconnected, tell the user, and update  player UI
        self.playerNameLabel.text= Lost_Connection_With_Player_Message;
        [UIView animateWithDuration:0.5 delay:0.8 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                                self.playerNameLabel.alpha=0;
                                }
                         completion:^(BOOL finished) {
                                     [self updatePlayerUI];
                                }];

        return;
    }
    // if still connected, tell opposite my reply
    TBONoticeView *notice=[self.noticeDisplayManager currentNotice];
    [TBOGameSetting sharedGameSetting].gameMode=[notice.additionalInfo[@"option"][GAME_MODE] integerValue];
    [TBOGameSetting sharedGameSetting].gameContext=[notice.additionalInfo[@"option"][GAME_CONTEXT] integerValue];
    [(TBOGameCommunicator *)notice.additionalInfo[@"gameCommunicator"] sendAcceptingOnceMoreGameRequest];

    TBONoticeView *pleaswWaitNotice=[TBONoticeView noticeWithMessage:Notice_Game_Will_Start_In_Any_Time
                                                     leftButtonTitle:nil
                                                    rightButtonTitle:nil
                                                      hasCloseButton:NO];
    [self.noticeDisplayManager showNotice:pleaswWaitNotice fadeOut:NO];
}
-(void)refuseRequest:(UIButton *)button{

    TBONoticeView *notice=[self.noticeDisplayManager currentNotice];
    [(TBOGameCommunicator *)notice.additionalInfo[@"gameCommunicator"] sendRefusingOnceMoreGameRequest];
    [self.noticeDisplayManager showPreviousNotice];

    //clear communicator, and update player UI
    self.gameCommunicator.delegate=nil;
    self.gameCommunicator=nil;
    [self updatePlayerUI];
}
-(void)timeLeftBeforeRefusingRequest:(NSTimer *)timer{

    static NSInteger timeLeftToRefuseRequest=Default_Time_Out;
    timeLeftToRefuseRequest--;
    TBONoticeView *notice=(TBONoticeView *)timer.userInfo[@"notice"];
    if (!notice.superview) {
        // if user replyed, invalidate timer ( whether accept or decline ,notice will be remove from superview)
        [timer invalidate];
        timeLeftToRefuseRequest=Default_Time_Out;
        return;
    }
    if (timeLeftToRefuseRequest) {
        // if still some left,update UI
        [notice.rightButton setTitle:[NSString stringWithFormat:Notice_Refuse_Once_More_Game_Message,@(timeLeftToRefuseRequest)]
                            forState:UIControlStateNormal];
        return;

    }

    // default is declining the request
    [timer invalidate];
    [(TBOGameCommunicator *)notice.additionalInfo[@"gameCommunicator"] sendRefusingOnceMoreGameRequest];
    timeLeftToRefuseRequest=Default_Time_Out;

    [self.noticeDisplayManager showPreviousNotice];
    [self updatePlayerUI];

}

//handle opposite's reply to my onece more request
-(void)gameCommunicatorRefusedOnceMoreGameRequest:(TBOGameCommunicator *)gameCommunicator{

    // clear communictor and game
    [self.gameCommunicator disconnect];
    self.gameCommunicator.delegate=nil;
    self.gameCommunicator=nil;

    [self.game reset];
    self.game=nil;

    TBONoticeView *notice=[TBONoticeView noticeWithMessage:Notice_Opposite_Refused_Request
                                           leftButtonTitle:nil
                                          rightButtonTitle:nil
                                            hasCloseButton:NO];
    [self.noticeDisplayManager showNotice:notice fadeOut:YES ];

    [self updatePlayerUI];
    [self performSelector:@selector(showGameChosingPad)
               withObject:nil
               afterDelay:1.0];

}
// has disconnected with opposite
-(void) gameCommunicator:(TBOGameCommunicator *)gameCommunicator disconnected:(NSString *)playerName{

        // clear communicator and game
        [self.gameCommunicator disconnect];
        self.gameCommunicator.delegate=nil;
        self.gameCommunicator=nil;

        [self.game reset];
        self.game=nil;

        //upate UI
        self.playerNameLabel.text=Lost_Connection_With_Player_Message;
        [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.playerNameLabel.alpha=0;
                         }
                         completion:^(BOOL finished) {
                             if (!([self.noticeDisplayManager currentNotice].leftButton)) {
                                 // if currentnotice not nil and has no button,
                                 // then dismiss the notice and show gamechosingPad
                                 [self.noticeDisplayManager dismissNotice];
                                 [self showGameChosingPad];
                             }
                             [self updatePlayerUI];
                             [self updateRecordButtonUI];
                         }];


}

-(void)gameCommunicator:(TBOGameCommunicator *)gameCommunicator loadedPhoto:(UIImage *)photo{

    if(!photo){
        return;
    }

    self.playerPhotoImageView.photo=photo;
    [self updatePlayerUI];
}


// local player accept opposite's invitation
-(void)gameCommunicatorLocalPlayerAcceptInvitation:(TBOGameCommunicator *)gameCommunicator{


    TBONoticeView *notice=[TBONoticeView noticeWithMessage:Notice_Local_Accept_Invitaion
                                           leftButtonTitle:nil
                                          rightButtonTitle:nil
                                            hasCloseButton:NO];

    [self.noticeDisplayManager showNotice:notice fadeOut:NO];
}

#pragma mark - notice button action
-(void)closeNoticeView:(UIButton *)closeButton{
    // dismiss game and communicator
    [self.gameCommunicator disconnect];
    self.gameCommunicator=nil;
    [self.game reset];
    self.game=nil;

    // update UI
    [self.noticeDisplayManager dismissNotice];
    [self showGameChosingPad];
    [self updatePlayerUI];
    [self updateRecordButtonUI];

}

-(void)playGameOnceMore:(UIButton *)button{

    // if GameContextOffline, start game directly
    if ([TBOGameSetting sharedGameSetting].gameContext == GameContextOffline) {
        [self.game reset];
        [self gameReady:arc4random()%2==1];
        return;
    }

    // if disconnected with opposite, tell the player
    if (!self.gameCommunicator) {

        self.playerNameLabel.text=Lost_Connection_With_Player_Message;
        [UIView animateWithDuration:0.5 delay:0.8 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                                    self.playerNameLabel.alpha=0;
                                    }
                         completion:^(BOOL finished) {
                             [self updatePlayerUI];
                         }];
        return;
    }

    // if still connected, then reset game and send request
    [self.game reset];
    [self.gameCommunicator sendContinuingGameRequest];
    TBONoticeView *notice=[TBONoticeView noticeWithMessage:Notice_Send_Play_Game_Once_More_Message
                                           leftButtonTitle:nil
                                          rightButtonTitle:nil
                                            hasCloseButton:NO];
    [self.noticeDisplayManager showNotice:notice fadeOut:NO];
    
}

-(void)checkRank:(UIButton *)button{
    //if ipad
    if (self.splitViewController) {
        self.splitViewController.preferredDisplayMode=UISplitViewControllerDisplayModePrimaryOverlay;
        UINavigationController *navigationController=(UINavigationController *)self.splitViewController.viewControllers[0];
        if (![navigationController.topViewController isKindOfClass:[TBOLearderBoardViewController class]]) {
            [navigationController.viewControllers[0] performSegueWithIdentifier:@"showLeaderBoard" sender:nil];
        }
        return;
    }
    //if not ipad
    UIViewController *rankVC=[self.storyboard instantiateViewControllerWithIdentifier:@"RankVC"];
    [self presentViewController:rankVC animated:YES completion:nil];
    [self.noticeDisplayManager dismissNotice];
}

#pragma mark - game delegate

// tell opposite my action and update chessBoard
-(void) pieceAtPosition:(Position*)position moveTo:(Position*)newPosition{
    [self.gameCommunicator sendMoveInfoFrom:position to:newPosition];
    [self.chessBoard chessPieceAtPosition:position moveToPosition:newPosition];

    [self updateRecordButtonUI];

    if (self.game.stateOfGame==GameStateEnd) {
        [self.playerPhotoImageView stopAnimating];
        return;
    }
    [self.playerPhotoImageView startAnimating];

}
-(void)addPieceAtPosition:(Position*)positon isOpposite:(BOOL)isOpposite{
    [self.gameCommunicator sendAddInfoPosition:positon];
    [self.chessBoard addChessPieceAtPosition:positon isOpposite:isOpposite];

    [self.playerPhotoImageView startAnimating];
}
-(void)pieceAtPositionKilled:(Position*)position{
    ChessPieceView *killedPiece=[self.chessBoard chessPieceAtPosition:position];
    [self.chessBoard removeChessPiece:killedPiece];
}

-(void)gameEnd:(BOOL)win{

    [self.playerPhotoImageView stopAnimating];
    [self.gameCommunicator gameEnd:win];
    TBONoticeView * notice=nil;
    if (win) {

        notice=[TBONoticeView noticeWithMessage:[TBOGameSetting sharedGameSetting].gameContext == GameContextOffline ?    Notice_offline_win_Message : Notice_Win_Message
                                leftButtonTitle:Notice_Once_More_Game_Button
                               rightButtonTitle:[TBOGameSetting sharedGameSetting].gameContext == GameContextOnLine ?Notice_Win_CheckRank_Button : nil
                                 hasCloseButton:YES];

        if ([TBOGameSetting sharedGameSetting].gameContext !=GameContextOffline) {
            UIImageView *imageView=[self winInhowManyStep];
            imageView.frame=notice.bounds;
            imageView.center=CGPointMake(CGRectGetWidth(notice.bounds)/4, CGRectGetHeight(notice.bounds)/4);
            imageView.alpha=0;
            [notice addSubview:imageView];
            [UIView animateWithDuration:0.8
                             animations:^{
                                        imageView.frame=CGRectMake(0, 0, notice.bounds.size.width*3/5, notice.bounds.size.height*3/5);
                                        imageView.alpha=1.0;
                                    }
                             completion:nil];
        }
    }
    else{
        notice=[TBONoticeView noticeWithMessage:[TBOGameSetting sharedGameSetting].gameContext == GameContextOffline ?     Notice_offline_lost_Message : Notice_Lost_Message
                                leftButtonTitle:Notice_Once_More_Game_Button
                               rightButtonTitle:nil
                                 hasCloseButton:YES];
    }
    [notice.leftButton addTarget:self action:@selector(playGameOnceMore:) forControlEvents:UIControlEventTouchUpInside];
    [notice.rightButton addTarget:self action:@selector(checkRank:) forControlEvents:UIControlEventTouchUpInside];
    [notice.closeButton addTarget:self action:@selector(closeNoticeView:) forControlEvents:UIControlEventTouchUpInside];

    // updateUI
    [self updateRecordButtonUI];
    [self.noticeDisplayManager showNotice:notice fadeOut:NO];

}


-(UIImageView *)winInhowManyStep{

    NSInteger steps=self.game.stepCount;
    NSInteger i;
    if (steps<=10) {
        i=10;
    }
    else if (steps<=20){
        i=20;
    }
    else if (steps<=30){
        i=30;
    }
    else{
        return nil;
    }

    UIImage *image=[UIImage imageNamed:[NSString stringWithFormat:@"Less_Than_%ld_%@",(long)i,Image_Less_Than_Steps_Prefix]];
    return [[UIImageView alloc]initWithImage:image];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.noticeDisplayManager dismissNotice];
    self.noticeDisplayManager=nil;
    [self.game didReceiveMemoryWarning];
}

#pragma mark - navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Show History"]){
        [self.navigationController popToViewController:self animated:YES];
    }
}

@end
