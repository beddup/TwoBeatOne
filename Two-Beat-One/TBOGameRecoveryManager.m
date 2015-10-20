//
//  GameRecovertManager.m
//  Two Beat One
//
//  Created by Amay on 6/4/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOGameRecoveryManager.h"
#import "TBOGameSetting.h"

@implementation TBOGameRecoveryManager
-(void)storeGame:(TBO_Game *)game communicator:(TBOGameCommunicator *)communicator{

    NSDictionary *state=@{};
    if (game.stateOfGame == GameStateProcceed) {
        NSDictionary *gameState= game ? [game storeGameState] : @{};
        NSDictionary *communicatorState=communicator ? [communicator storeCommunicationState] : @{};
         state=@{@"gameState":gameState,
                 @"communicationState":communicatorState};
    }

    if( ![[NSFileManager defaultManager] fileExistsAtPath:statePath]){
        [[NSFileManager defaultManager] createFileAtPath:statePath contents:nil attributes:nil];
    }
    NSLog(@"store state:%@",state);
    [state writeToFile:statePath atomically:NO];

}
-(void)clearState{
    [@{} writeToFile:statePath atomically:NO];
}

-(NSDictionary *)restoreGame{

    NSDictionary *state=[NSDictionary dictionaryWithContentsOfFile:statePath];
    if (!state && [state isEqualToDictionary:@{}] ) {
        return nil;
    }

    NSDate *stateDate=[[[NSFileManager defaultManager] attributesOfItemAtPath:statePath error:NULL] fileModificationDate];
    if ([[NSDate date] timeIntervalSinceDate:stateDate] < RESTORE_GAME_SECOND_AGO){
        // if the state is 2min ago
        NSLog(@"restore state:%@",state);
        return state;
    }
    //otherwise, don't restore the game,
    [@{} writeToFile:statePath atomically:NO];
    return nil;
}



@end
