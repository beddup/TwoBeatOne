//
//  TBOGameMCCommuniator.m
//  Two Beat One
//
//  Created by Amay on 5/30/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOGameMCCommuniator.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <GameKit/GameKit.h>
#import "TBOGameSetting.h"
#import "TBOGameCommunicator+DataParser.h"

@interface TBOGameMCCommuniator()<MCSessionDelegate,MCAdvertiserAssistantDelegate,MCBrowserViewControllerDelegate>

@property(strong,nonatomic)MCSession *session;
@property(strong,nonatomic)MCAdvertiserAssistant *advertiserAssistant;
@property(strong,nonatomic)MCBrowserViewController *browserVC;

@property(strong,nonatomic,readwrite)MCPeerID * opposite;
@property(strong,nonatomic,readwrite)NSString *playerName;
@property(copy,nonatomic)NSString *MCServiceType;

@end


@implementation TBOGameMCCommuniator
@synthesize session=_session;
@synthesize opposite=_opposite;
@synthesize playerName=_playerName;

+(instancetype)sharedTBOGameCommunicator{
    return [[TBOGameMCCommuniator alloc]init];
}

-(instancetype)init{

    static TBOGameMCCommuniator *MCCommuniator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MCCommuniator=[super init];
    });
    return MCCommuniator;
    
}

+(MCPeerID *)localPeer{
    static  MCPeerID * localPeer;
    if (!localPeer) {
        localPeer=[[MCPeerID alloc]initWithDisplayName:[UIDevice currentDevice].name];
    }
    return localPeer;
}

#pragma mark - properties
-(NSString *)playerName{
    return self.opposite.displayName;
}
-(NSString *)MCServiceType{
    return [NSString stringWithFormat:@"tbo-game%@",@([TBOGameSetting sharedGameSetting].gameMode)];
}

- (void)advertiserAssistantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant{}
- (void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant{}


-(MCSession *)session{
    if (!_session) {
        _session=[[MCSession alloc]initWithPeer:[TBOGameMCCommuniator localPeer]];
        _session.delegate=self;
    }
    return _session;
}

-(void)setSession:(MCSession *)session{
    if (_session !=session) {
        [_session disconnect];
        _session=session;
        _session.delegate=self;
    }
}
-(UIImage *)playerPhoto{
    return [UIImage imageNamed:@"DefaultPhoto"];
}
#pragma mark - Browse Near Players

-(void)browseNearByPlayers:(UIViewController *)presentingVC{

    self.session=nil;
    MCBrowserViewController *browserVC=[[MCBrowserViewController alloc]initWithServiceType:self.MCServiceType
                                                                                   session:self.session];
    browserVC.delegate=self;
    self.browserVC=browserVC;
    [presentingVC presentViewController:browserVC animated:YES completion:nil];
    [self startAdvertising];


}
//MCBrowserViewControllerDelegate
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [self stopAdvertising];
    [browserViewController.presentingViewController dismissViewControllerAnimated:YES
                                                                       completion:nil];

}
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [self stopAdvertising];
    [self disconnect];
    [browserViewController.presentingViewController dismissViewControllerAnimated:YES
                                                                       completion:nil];

}
-(BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{

    return YES;

}

#pragma mark - communiction life cycle
-(void)startAdvertising{

    [self.advertiserAssistant stop];
    if (!self.advertiserAssistant || ![self.advertiserAssistant.serviceType isEqualToString:self.MCServiceType]){
        self.advertiserAssistant=[[MCAdvertiserAssistant alloc] initWithServiceType:self.MCServiceType
                                                                      discoveryInfo:nil
                                                                            session:self.session];
        self.advertiserAssistant.delegate=self;
    }
    [self.advertiserAssistant start];

}
-(void)stopAdvertising{
    [self.advertiserAssistant stop];
}

-(void)preparedToStartGame{

    [self stopAdvertising]; // when start playing, stop advertising ,which avoid receiving any invite and distracting player
    [super preparedToStartGame];
    
}

-(BOOL)sendData:(NSData *)dataInfo
      toPlayers:(NSArray *)players
       withMode:(TBOSendDataMode)dataMode
          error:(NSError *__autoreleasing *)error
{
    BOOL success= [self.session sendData:dataInfo
                          toPeers:players
                         withMode:dataMode==TBOSendDataModeReliable ? MCSessionSendDataReliable :MCSessionSendDataUnreliable
                            error:error];
    return success;
}

-(void)disconnect{

    [super disconnect];
    self.session=nil;

}
-(void)gameEnd:(BOOL)win{
    [super gameEnd:win];
}
#pragma mark - MCSessionDelegate
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{

    switch (state) {
        case MCSessionStateConnected:{

            self.session=session;
            self.playerName=peerID.displayName;
            self.opposite=peerID;
            if (matchState != MatchStateStarted) {
                matchState=MatchStateStarted;
                [self preparedToStartGame];
            }
            [self stopAdvertising];
            break;
        }
        case MCSessionStateNotConnected:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate gameCommunicator:self
                                   disconnected:peerID.displayName];
            });
            [self disconnect];
            break;
        }
        default:{
            break;
        }
    }
}
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{

    NSDictionary *dataInfo=[self dictionaryByData:data];
    if (dataInfo) {
        switch ([dataInfo[DATA_INFO_KEY_DATATYPE] integerValue]) {
            case DATATYPE_ACTION:{
                // tell opposite that this info was received, and opposite will stop send this info again
                NSDictionary *info=@{DATA_INFO_KEY_DATATYPE:@(DATATYPE_RETURNRECEIPT),
                                     DATA_INFO_KEY_DATAID:dataInfo[DATA_INFO_KEY_DATAID]};
                NSError *error;

                if(![self sendData:[self dataByDictionary:info]
                         toPlayers:@[peerID]
                          withMode:TBOSendDataModeUnreliable
                            error:&error]){

                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handleReceivedAction:dataInfo from:peerID];
                });
                break;
            }
            case DATATYPE_RETURNRECEIPT:{
                [self handleReceivedReply:dataInfo from:peerID];
                break;
            }
            default:{
                break;
            }
        }
    }
}
- (void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
       withName:(NSString *)streamName
       fromPeer:(MCPeerID *)peerID{}

- (void)session:(MCSession *)session
didStartReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
   withProgress:(NSProgress *)progress{}

- (void)session:(MCSession *)session
didFinishReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
          atURL:(NSURL *)localURL
      withError:(NSError *)error{}

-(void)dealloc{
    [self stopAdvertising];
    self.advertiserAssistant=nil;
}

@end
