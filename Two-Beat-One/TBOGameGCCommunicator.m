//
//  TBOGameGCCommunicator.m
//  Two Beat One
//
//  Created by Amay on 5/30/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOGameGCCommunicator.h"
#import "TBOGameCommunicator+DataParser.h"
#import "TBOGameSetting.h"

@interface TBOGameGCCommunicator()<GKMatchDelegate,GKLocalPlayerListener,GKMatchmakerViewControllerDelegate,GKFriendRequestComposeViewControllerDelegate>

@property(strong,nonatomic)NSString *currentPlayerID;
@property(strong,nonatomic)GKMatch *match;
@property(strong,nonatomic)GKScore *localScore;
@property(strong,nonatomic,readwrite)GKPlayer * opposite;// your opposite
@property(strong,nonatomic,readwrite)   NSString *          playerName;
@property(strong,nonatomic,readwrite)   UIImage *          playerPhoto;

@property(strong,nonatomic)NSArray * friends;

@property(strong,nonatomic)UIViewController *authenticationViewController;

@end


@implementation TBOGameGCCommunicator
@synthesize opposite=_opposite;
@synthesize playerName=_playerName;
@synthesize delegate=_delegate;
@synthesize playerPhoto=_playerPhoto;

+(instancetype)sharedTBOGameCommunicator{
    return [[TBOGameGCCommunicator alloc]init];
}

-(instancetype)init{

    static TBOGameGCCommunicator *GCCommuniator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GCCommuniator=[super init];
    });
    return GCCommuniator;

}
#pragma mark - properties
-(NSString *)playerName{
    return  self.opposite.alias;
}

-(void)setOpposite:(GKPlayer *)opposite{

    if (opposite) {
        [opposite loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
            if (!error) {
                self.playerPhoto=photo;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate gameCommunicator:self
                                        loadedPhoto:photo];

                });
            }
        }];
    }
    _opposite=opposite;

}
#pragma mark - Autherntication
+(BOOL)isGameCenterAPIAvailable
{
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));

    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    return (gcClass && osVersionSupported);
}

-(BOOL)isAuthernticationCompleted{
    return [GKLocalPlayer localPlayer].authenticated;
}
-(void)authenticateLocalUser{
    if ([self isAuthernticationCompleted]) {
        return;
    }
    if ([TBOGameGCCommunicator isGameCenterAPIAvailable]) {
        GKLocalPlayer *localPlayer=[GKLocalPlayer localPlayer];
        localPlayer.authenticateHandler=^(UIViewController *viewController,NSError *error){

            if (viewController) {
                self.authenticationViewController=viewController;
            }
            else if (!error){
                NSString *localPlayerID=[GKLocalPlayer localPlayer].playerID;
                if (!self.currentPlayerID) {
                    // if first authentication ,then load friend
                    [[GKLocalPlayer localPlayer] loadFriendPlayersWithCompletionHandler:^(NSArray *friendPlayers, NSError *error) {
                        self.friends=friendPlayers;
                    }];
                }
                else if (![self.currentPlayerID isEqualToString:localPlayerID] ) {
                    // local player changed;
                    [self disconnect];
                    self.localScore=nil;
                    self.friends=nil;
                    [[GKLocalPlayer localPlayer] loadFriendPlayersWithCompletionHandler:^(NSArray *friendPlayers, NSError *error) {
                        self.friends=friendPlayers;
                    }];
                }
                self.currentPlayerID=localPlayerID;
            }
        };
    }
}
-(void)checkAuthenticationProgress{

    if (self.authenticationViewController && ![self isAuthernticationCompleted]) {
        [((UIViewController *)self.delegate) presentViewController:self.authenticationViewController
                                                          animated:YES
                                                        completion:^{self.authenticationViewController=nil;}];
    }

}

#pragma mark - Match
-(void)findMatch:(UIViewController *)presentingVC{

    [[GKLocalPlayer localPlayer] registerListener:self];

    GKMatchRequest *matchRequest=[[GKMatchRequest alloc]init];
    matchRequest.defaultNumberOfPlayers=2;
    matchRequest.playerGroup=[TBOGameSetting sharedGameSetting].gameMode;

    GKMatchmakerViewController *mmvc=[[GKMatchmakerViewController alloc]initWithMatchRequest:matchRequest];
    mmvc.matchmakerDelegate=self;
    [presentingVC presentViewController:mmvc animated:YES completion:nil];

}
//GKMatchmakerViewControllerDelegate
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController{
    [self disconnect];
    [viewController.presentingViewController dismissViewControllerAnimated:YES
                                                                completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController
                didFailWithError:(NSError *)error{
    [self disconnect];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController
                    didFindMatch:(GKMatch *)match {

    self.match=match;
    match.delegate=self;
    if (matchState != MatchStateStarted  && match.expectedPlayerCount == 0) {
        // all players connected, time for first contact
        matchState=MatchStateStarted;
        self.opposite=[match.players firstObject];
        [self preparedToStartGame];
    }

    [viewController.presentingViewController dismissViewControllerAnimated:YES
                                                                completion:nil];
}
#pragma mark - MakeFriend
#define Communication_Make_Friend_Message NSLocalizedStringFromTable(@"Communication_Make_Friend_Message", @"Communication", @"messge the one that you want to make friends  with will see")
-(void)makeFriendWithOpposite:(UIViewController *)presentingVC{

    GKFriendRequestComposeViewController *vc=[[GKFriendRequestComposeViewController alloc]init];
    [vc setMessage:Communication_Make_Friend_Message];
    [vc addRecipientPlayers:self.match.players];
    vc.composeViewDelegate=self;
    [presentingVC presentViewController:vc animated:YES completion:nil];

}
//GKFriendRequestComposeViewControllerDelegate
-(void)friendRequestComposeViewControllerDidFinish:(GKFriendRequestComposeViewController *)viewController{
    [viewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)oppositeIsFriend{
    return [self.friends containsObject:self.opposite];
}

#pragma mark - game cycle
-(void)preparedToStartGame{

    [[GKLocalPlayer localPlayer] unregisterListener:self];
    [self loadScore];
    [super preparedToStartGame];

}
-(BOOL)sendData:(NSData *)dataInfo
      toPlayers:(NSArray *)players
       withMode:(TBOSendDataMode)dataMode
          error:(NSError *__autoreleasing *)error
{
    if (!players || players.count==0) {
        return NO;
    }
    BOOL success=NO;
    success=[self.match sendData:dataInfo
                       toPlayers:players
                        dataMode:dataMode==TBOSendDataModeReliable ? GKMatchSendDataReliable :GKMatchSendDataUnreliable
                           error:error];
    return success;
}

-(void)disconnect{

    [[GKLocalPlayer localPlayer] unregisterListener:self];
    [super disconnect];
    [self.match disconnect];
    self.playerPhoto=nil;
    self.match=nil;

}
-(void)gameEnd:(BOOL)win
{
    [super gameEnd:win];
    [self reportScore:win];
}

#define Fail_To_Upload_Score NSLocalizedStringFromTable(@"Fail_To_Upload_Score", @"Banner", nil)
-(void)loadScore{
    [[GKLocalPlayer localPlayer]loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
        GKLeaderboard *leaderBoard=[[GKLeaderboard alloc]init];
        leaderBoard.identifier=leaderboardIdentifier;
        [leaderBoard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
            self.localScore=leaderBoard.localPlayerScore;
        }];


    }];
}
-(void)reportScore:(BOOL)win{

    // if 'value' doesn't change, report will fail.
    // so each game ,'value' will be added by 1 or 2.
    // the context will be always added by 2.
    // the times that localPlayer played will be context/2, actual times that localPlayer won will be value - context/2,

    if (self.localScore) {
         NSInteger score=win ? 2:1;
        self.localScore.value=self.localScore.value+score; //times that localPlayer won
        self.localScore.context=self.localScore.context+2; // times that localPlayer played

        [GKScore reportScores:@[self.localScore] withCompletionHandler:^(NSError *error) {
            if (error) {
                [GKNotificationBanner showBannerWithTitle:@"" message:Fail_To_Upload_Score duration:1.0 completionHandler:nil];
            }
            self.localScore=nil;
        }];
    }
}

#pragma mark - GKMatchDelegate
- (void)match:(GKMatch *)match
didReceiveData:(NSData *)data
fromRemotePlayer:(GKPlayer *)player {
    
    NSDictionary *dataInfo=[self dictionaryByData:data];

    if (dataInfo) {
        switch ([dataInfo[DATA_INFO_KEY_DATATYPE] integerValue]) {
            case DATATYPE_ACTION:{
                // confirm  that this info received
                NSDictionary *info=@{DATA_INFO_KEY_DATATYPE:@(DATATYPE_RETURNRECEIPT),
                                     DATA_INFO_KEY_DATAID:dataInfo[DATA_INFO_KEY_DATAID]};

                [self sendData:[self dataByDictionary:info]
                     toPlayers:@[player]
                      withMode:TBOSendDataModeUnreliable
                         error:nil];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handleReceivedAction:dataInfo from:player];
                });
                break;
            }
            case DATATYPE_RETURNRECEIPT:{
                [self handleReceivedReply:dataInfo from:player];
                break;
            }
            default :{
                break;
            }
        }
    }
}

- (void)match:(GKMatch *)match player:(GKPlayer *)player didChangeConnectionState:(GKPlayerConnectionState)state{
    
    switch (state) {
        case GKPlayerStateConnected:{
            if (matchState!=MatchStateStarted && match.expectedPlayerCount == 0) {
                matchState=MatchStateStarted;
                self.opposite=player;
                [self preparedToStartGame];
            }
            break;
        }
        case GKPlayerStateDisconnected:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate gameCommunicator:self
                                       disconnected:self.opposite.alias];
            });
            [self disconnect];
            break;
        }
        default:
            break;
    }
}
#define Banner_Fail_To_Connect_Anyone NSLocalizedStringFromTable(@"Banner_Fail_To_Connect_Anyone", @"Banner", nil)

- (void)match:(GKMatch *)match didFailWithError:(NSError *)error{
    [GKNotificationBanner showBannerWithTitle:@"" message:Banner_Fail_To_Connect_Anyone duration:1.0 completionHandler:nil];
    [self disconnect];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate gameCommunicator:self disconnected:nil];
    });
}

#pragma mark - GKLocalPlayerListener
-(void)player:(GKPlayer *)player didAcceptInvite:(GKInvite *)invite{

    if (invite) {

        [self.delegate  gameCommunicatorLocalPlayerAcceptInvitation:self];

        [[GKMatchmaker sharedMatchmaker] matchForInvite:invite completionHandler:^(GKMatch *match, NSError *error) {
            if (match){
                [self disconnect];
                self.match=match;
                match.delegate=self;
                if (matchState != MatchStateStarted && match.expectedPlayerCount == 0) {
                    matchState=MatchStateStarted;
                    self.opposite=[match.players firstObject];
                    [self preparedToStartGame];
                }
            }
        }];
    }
}
@end
