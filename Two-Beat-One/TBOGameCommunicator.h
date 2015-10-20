//
//  TBOGameCenterHelper.h
//  Two Beat One
//
//  Created by Amay on 5/20/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "defines.h"
#import "Position.h"
#import "TBOGameCommunicatorPublicity.h"

@class UIImage;
@class UIViewController;
@class TBOGameCommunicator;
@class GKPlayer;

@protocol TBOGameCommunicatorDelegate

#pragma mark - common communication methods
//  first turn have been decided, ready to start the game
-(void)gameCommunicator:(TBOGameCommunicator *)gameCommunicator ready:(BOOL)meFirst;

// the other player or peer have moved
-(void)gameCommunicator:(TBOGameCommunicator *)gameCommunicator oppositeMovedFrom:(Position *)pFrom to:(Position *)pTo ;

//the other player or peer add a chesspiece. this method is only used under custom game mode
-(void)gameCommunicator:(TBOGameCommunicator *)gameCommunicator oppositeAdd:(Position *)p;

// player or peer disconnected
-(void)gameCommunicator:(TBOGameCommunicator *)gameCommunicator disconnected:(NSString *)playerName;


#pragma mark - play game once more request
// the other player or peer request to play game again
-(void)gameCommunicator:(TBOGameCommunicator *)gameCommunicator oppositeRequestOnceMoreGame:(NSDictionary *)option;

 // the other player or peer refused your request
-(void)gameCommunicatorRefusedOnceMoreGameRequest:(TBOGameCommunicator *)gameCommunicator  ;


#pragma  mark - Special For GameKit
// local player accept opposite's invitation
-(void)gameCommunicatorLocalPlayerAcceptInvitation:(TBOGameCommunicator *)gameCommunicator ;

// the other GKplayer's photo has been loaded
-(void)gameCommunicator:(TBOGameCommunicator *)gameCommunicator loadedPhoto:(UIImage *)photo;



@end


@interface TBOGameCommunicator : NSObject
{
    MatchState matchState;
}
@property(weak,nonatomic)               id<TBOGameCommunicatorDelegate> delegate;
@property(strong,nonatomic,readonly)    NSString *                      playerName; //alias or displayName of the Opposite
@property(strong,nonatomic,readonly) UIImage *playerPhoto;

// abstract
+(instancetype)sharedTBOGameCommunicator;

// send my action info during match
-(void)sendMoveInfoFrom:(Position *)fromP to:(Position *)toP;
-(void)sendAddInfoPosition:(Position *)p;
-(void)sendRandomNumber:(NSInteger)number;
-(void)sendContinuingGameRequest;
-(void)sendAcceptingOnceMoreGameRequest;
-(void)sendRefusingOnceMoreGameRequest;

//communication life cycle
-(void)preparedToStartGame;
-(void)gameEnd:(BOOL)win;
-(void)disconnect;

// handle infomation from opposition
-(void)handleReceivedAction:(NSDictionary *)dataInfo from:(id)player;
-(void)handleReceivedReply:(NSDictionary *)dataInfo from:(id)player;

@end
