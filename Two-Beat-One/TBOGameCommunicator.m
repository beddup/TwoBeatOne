//
//  TBOGameCenterHelper.m
//  Two Beat One
//
//  Created by Amay on 5/20/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBOGameCommunicator.h"
#import "TBOGameCommunicator+DataParser.h"
#import "TBOGameSetting.h"

@interface TBOGameCommunicator(){

    NSInteger latestReceivedReplyDataID;
    NSInteger latestReceivedActionDataID;
    NSInteger latestSentActionDataID;
    NSInteger myRandomNumberForDecidingWhoFirst;

}
// array of data info  that has been send but reply not received
@property(strong,nonatomic)             NSMutableArray *    unconfirmedSentActionInfo;

// timer to check unconfirmedSentActionInfo and resend it
@property(strong,nonatomic)             NSTimer *           timer;

@property(strong,nonatomic)             id                  opposite;

@end

@implementation TBOGameCommunicator

static TBOGameCommunicator *GChelper=nil;

#pragma mark - instantiation
+(instancetype)sharedTBOGameCommunicator{
    return nil;
}

#pragma mark- properties
-(NSMutableArray *)unconfirmedSentActionInfo{
    if (!_unconfirmedSentActionInfo) {
        _unconfirmedSentActionInfo=[@[] mutableCopy];
    }
    return _unconfirmedSentActionInfo;
}

#pragma mark - timer to check Whether Action Data Received
-(void)continueCommunication{
    if (matchState != MatchStateStarted) {
        return;
    }

    [self pauseCommunication];
    self.timer=[NSTimer timerWithTimeInterval:2.0
                                       target:self
                                     selector:@selector(checkWhetherActionDataReceived:)
                                     userInfo:nil
                                      repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer
                              forMode:NSDefaultRunLoopMode];


}
-(void)pauseCommunication{
    [self.timer invalidate];
    self.timer=nil;
}
-(void)checkWhetherActionDataReceived:(NSTimer *)timer{
    if (matchState != MatchStateStarted || self.unconfirmedSentActionInfo.count == 0) {
        return;
    }

    for (NSInteger i=0; i< self.unconfirmedSentActionInfo.count; i++) {
        // re-send each unconfirmed sent action info
        NSDictionary *unconfirmedOldestSentActionInfo=self.unconfirmedSentActionInfo[i];
        if (unconfirmedOldestSentActionInfo) {
            NSInteger dataID=[unconfirmedOldestSentActionInfo[DATA_INFO_KEY_DATAID] integerValue];
            if (latestReceivedReplyDataID < dataID) {
                [self sendInfo:unconfirmedOldestSentActionInfo
                      dateMode:TBOSendDataModeUnreliable];
            }
        }
    }
}

#pragma mark - communication life cycle
//clear communication record when necessary like a new session
-(void)resetCommunicationRecord{

    latestReceivedReplyDataID = -1;
    latestReceivedActionDataID = -1;
    latestSentActionDataID=0;
    myRandomNumberForDecidingWhoFirst=arc4random();
    self.unconfirmedSentActionInfo=nil;

}

-(void)preparedToStartGame
{
    [self resetCommunicationRecord];
    [self sendRandomNumber:myRandomNumberForDecidingWhoFirst];
    [self continueCommunication];
}

-(void)handleReceivedAction:(NSDictionary *)dataInfo from:(id)player {
    // if we didn't received this actionInfo before ,then handle it
    if ([dataInfo[DATA_INFO_KEY_DATAID] integerValue] > latestReceivedActionDataID) {
        // update the latestReceivedActionDataID
        latestReceivedActionDataID = [dataInfo[DATA_INFO_KEY_DATAID] integerValue];
        switch ([dataInfo[DATA_INFO_KEY_ACTIONTYPE] integerValue]) {
            case ACTIONTYPEMOVE:{

                // tell delegate opposition move info
                NSDictionary *moveInfo=dataInfo[DATA_INFO_KEY_ACTION];
                Position *from=[Position positionByString:moveInfo[ACTION_MOVE_KEY_FROM]];
                Position *to=  [Position positionByString:moveInfo[ACTION_MOVE_KEY_TO]];
                [self.delegate gameCommunicator:self
                              oppositeMovedFrom:[from reversedPosition]
                                             to:[to reversedPosition]];
                break;
            }

            case ACTIONTYPERANDOMNUMBER:{
                NSInteger peerRandomNumber=[dataInfo[DATA_INFO_KEY_ACTION]integerValue];
                if (latestSentActionDataID == 0 ) {
                    [self preparedToStartGame];
                }
                [self.delegate gameCommunicator:self
                                          ready:myRandomNumberForDecidingWhoFirst > peerRandomNumber];

                break;
            }
            case ACTIONTYPEADDCHESSPIECE:{

                Position *p=[Position positionByString:dataInfo[DATA_INFO_KEY_ACTION]];
                [self.delegate gameCommunicator:self
                                    oppositeAdd:[p reversedPosition]];

                break;
            }
            case ACTIONTYPEREQUESTPLAYONCEMORE:{

                switch ([dataInfo[DATA_INFO_KEY_ACTION] integerValue]) {
                    case REQUESTPLAYONCEMORESENT:{
                        // opposite request to playing game again
                        [self.delegate gameCommunicator:self oppositeRequestOnceMoreGame:@{GAME_MODE:dataInfo[GAME_MODE],
                                                                                           GAME_CONTEXT:dataInfo[GAME_CONTEXT]}];
                        break;
                    }
                    case REQUESTPLAYONCEMOREACCEPTTED:{
                        [self preparedToStartGame];
                        break;
                    }
                    case REQUESTPLAYONCEMOREREFUSED:{

                        // opposite refuse to playing game again
                        [self.delegate gameCommunicatorRefusedOnceMoreGameRequest:self];
                        [self disconnect];

                        break;
                    }
                    default:
                        break;
                }
                break;
            }
            default:
                break;
        }
    }
}

-(void)handleReceivedReply:(NSDictionary *)dataInfo from:(id)player{

    latestReceivedReplyDataID=[dataInfo[DATA_INFO_KEY_DATAID] integerValue];

    for (NSDictionary *dictionary in self.unconfirmedSentActionInfo) {
        // if the send action info is replied, then remove the info from unconfirmedSentActionInfo
        if ([dictionary[DATA_INFO_KEY_DATAID] integerValue] == latestReceivedReplyDataID) {
            [self.unconfirmedSentActionInfo removeObject:dictionary];
            return;
        }
    }
}

-(void)gameEnd:(BOOL)win  // abstract,  need overriding
{
}

-(void)disconnect{

    self.opposite=nil;
    matchState=MatchStateDefault;
    [self pauseCommunication];
    [self resetCommunicationRecord];
}
#pragma mark - send info to the other player

// abstract method, need overriding
-(BOOL)sendData:(NSData *)dataInfo
      toPlayers:(NSArray *)players
       withMode:(TBOSendDataMode)dataMode
          error:(NSError *__autoreleasing *)error
{
    return YES;
}

-(BOOL)sendInfo:(NSDictionary *)info dateMode:(TBOSendDataMode)dataMode
{
    //if it is in the background, then don't send
    
    NSData *dataInfo=[self dataByDictionary:info];

    NSError *error;
    BOOL sendSuccess=NO;
    if (self.opposite) {
        sendSuccess=[self sendData:dataInfo
                           toPlayers:@[self.opposite]
                          withMode:dataMode
                             error:&error];

        if (![self.unconfirmedSentActionInfo containsObject:info]) {
            latestSentActionDataID++;
            [self.unconfirmedSentActionInfo addObject:info];
        }
    }
    return sendSuccess && !error;

}
-(void)sendMoveInfoFrom:(Position *)fromP to:(Position *)toP{
    NSDictionary *actionInfo=@{DATA_INFO_KEY_DATAID:@(latestSentActionDataID),
                               DATA_INFO_KEY_DATATYPE:@(DATATYPE_ACTION),
                               DATA_INFO_KEY_ACTIONTYPE:@(ACTIONTYPEMOVE),
                               DATA_INFO_KEY_ACTION:@{ACTION_MOVE_KEY_FROM : fromP.string,
                                                 ACTION_MOVE_KEY_TO:toP.string}
                               };
    [self sendInfo:actionInfo  dateMode:TBOSendDataModeUnreliable];
}
-(void)sendAddInfoPosition:(Position *)p{

    NSDictionary *actionInfo=@{DATA_INFO_KEY_DATAID:@(latestSentActionDataID),
                               DATA_INFO_KEY_DATATYPE:@(DATATYPE_ACTION),
                               DATA_INFO_KEY_ACTIONTYPE:@(ACTIONTYPEADDCHESSPIECE),
                               DATA_INFO_KEY_ACTION:p.string};
    
    [self sendInfo:actionInfo  dateMode:TBOSendDataModeUnreliable];

}
-(void)sendRandomNumber:(NSInteger)number{

    NSDictionary *actionInfo=@{DATA_INFO_KEY_DATAID:@(latestSentActionDataID),
                               DATA_INFO_KEY_DATATYPE:@(DATATYPE_ACTION),
                               DATA_INFO_KEY_ACTIONTYPE:@(ACTIONTYPERANDOMNUMBER),
                               DATA_INFO_KEY_ACTION:@(number)
                               };
    [self sendInfo:actionInfo  dateMode:TBOSendDataModeUnreliable];
    
}

-(void)sendContinuingGameRequest{  //send playing game once more request
    NSDictionary *actionInfo=@{DATA_INFO_KEY_DATAID:@(latestSentActionDataID),
                               DATA_INFO_KEY_DATATYPE:@(DATATYPE_ACTION),
                               DATA_INFO_KEY_ACTIONTYPE:@(ACTIONTYPEREQUESTPLAYONCEMORE),
                               DATA_INFO_KEY_ACTION:@(REQUESTPLAYONCEMORESENT),
                               GAME_MODE:@([TBOGameSetting sharedGameSetting].gameMode),
                               GAME_CONTEXT:@([TBOGameSetting sharedGameSetting].gameContext)};

    [self sendInfo:actionInfo  dateMode:TBOSendDataModeUnreliable];
    [self resetCommunicationRecord];


}
-(void)sendAcceptingOnceMoreGameRequest{

    NSDictionary *actionInfo=@{DATA_INFO_KEY_DATAID:@(latestSentActionDataID),
                               DATA_INFO_KEY_DATATYPE:@(DATATYPE_ACTION),
                               DATA_INFO_KEY_ACTIONTYPE:@(ACTIONTYPEREQUESTPLAYONCEMORE),
                               DATA_INFO_KEY_ACTION:@(REQUESTPLAYONCEMOREACCEPTTED),
                               };
    [self sendInfo:actionInfo  dateMode:TBOSendDataModeUnreliable];
    [self resetCommunicationRecord];

}
-(void)sendRefusingOnceMoreGameRequest{

    NSDictionary *actionInfo=@{DATA_INFO_KEY_DATAID:@(latestSentActionDataID),
                               DATA_INFO_KEY_DATATYPE:@(DATATYPE_ACTION),
                               DATA_INFO_KEY_ACTIONTYPE:@(ACTIONTYPEREQUESTPLAYONCEMORE),
                               DATA_INFO_KEY_ACTION:@(REQUESTPLAYONCEMOREREFUSED),
                               };
    [self sendInfo:actionInfo  dateMode:TBOSendDataModeUnreliable];
    [self disconnect];
    
}

@end
