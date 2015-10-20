//
//  GameRecovertManager.h
//  Two Beat One
//
//  Created by Amay on 6/4/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBO_Game.h"
#import "TBOGameCommunicator.h"

@interface TBOGameRecoveryManager : NSObject

-(void)storeGame:(TBO_Game *)game communicator:(TBOGameCommunicator *)communicator;
-(void)clearState;
-(NSDictionary *)restoreGame;

@end
